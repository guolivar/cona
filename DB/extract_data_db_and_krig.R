##### Load relevant packages #####
library(RPostgreSQL)
library(readr)
library(reshape2)
library(automap)
library(raster)
library(gstat)
library(sp)
library(rgdal)
library(ggmap)
##### Set the working directory DB ####
setwd("~/repositories/cona/DB")
##### Read the credentials file (hidden) ####
access <- read.delim("./.cona_login", stringsAsFactors = FALSE)
##### Open the connection to the DB ####
p <- dbDriver("PostgreSQL")
con<-dbConnect(p,
               user=access$usr[2],
               password=access$pwd[2],
               host='localhost',
               dbname='cona',
               port=5432)
##### Moving Average function ####
ma <- function(x,n=5){filter(x,rep(1/n,n), sides=1)}
##### Get data ####
# Select average for an hour/day at all locations and then krig the result
data <- dbGetQuery(con,"SELECT
    (fs.id) as siteid,
    i.serialn,
    avg(d.value::numeric) as pm25,
    max(ST_X(ST_TRANSFORM(fs.geom::geometry,2193))) as x,
    max(ST_Y(ST_TRANSFORM(fs.geom::geometry,2193))) as y,
    date_trunc('minute',d.recordtime at time zone 'NZST') as date
  FROM
    data.fixed_data as d,
    admin.sensor as s,
    admin.instrument as i,
    admin.fixedsites as fs
  WHERE
    s.id = d.sensorid AND
	  s.instrumentid = i.id AND
	  fs.id = d.siteid AND
  	i.name = 'ODIN-SD-3' AND
  	s.name = 'PM2.5' AND
    (d.recordtime at time zone 'NZST') >= timestamp '2017-06-20 12:00:00' AND
    (d.recordtime at time zone 'NZST') <= timestamp '2017-08-31 16:00:00' AND
    ST_WITHIN(fs.geom::geometry, ST_BUFFER((select x.geom::geometry from admin.fixedsites as x where x.id=18),0.05))
  GROUP BY
    date_trunc('minute',d.recordtime at time zone 'NZST'),
    i.serialn,
    fs.id;")
dbDisconnect(con)



# Turn into a 60min running average
serialn <- unique(data$serialn)
data$pm2.5 <- data$pm25
for (sn in serialn){
  # Subset the data to have only 1 sensor
  indices <- which(data$serialn==sn)
  sensordata <- data[indices,]
  # Moving average
  sensordata$pm2.5 <- ma(sensordata$pm25,60)
  data$pm2.5[indices] <- sensordata$pm2.5
}

# Re-sample every 10 minutes
data.10m <- subset(data,as.numeric(format(data$date,'%M')) %in% c(0,10,20,30,40,50))
# Use only data from deployed period ... started at
data.10m <- subset(data.10m,date>as.POSIXct('2017-06-21 04:00:00'))


save(list = c('data', 'data.10m'),file = '/data/data_gustavo/cona/odin_June2017_2.RData')
write_tsv(x = data,path =  '/data/data_gustavo/cona/odin_June2017.txt')
write_tsv(x = data.10m,path =  '/data/data_gustavo/cona/odin_June2017_10min.txt')
coordinates(data.10m) <- ~ x + y
coordinates(data) <- ~ x + y
proj4string(data.10m) <- CRS('+init=epsg:2193')
proj4string(data) <- CRS('+init=epsg:2193')

print("Starting the kriging")

#Setting the  prediction grid properties
cellsize <- 100 #pixel size in projection units (NZTM, i.e. metres)
min_x <- data.10m@bbox[1,1] - cellsize#minimun x coordinate
min_y <- data.10m@bbox[2,1] - cellsize #minimun y coordinate
max_x <- data.10m@bbox[1,2] + cellsize #mximum x coordinate
max_y <- data.10m@bbox[2,2] + cellsize #maximum y coordinate

x_length <- max_x - min_x #easting amplitude
y_length <- max_y - min_y #northing amplitude

ncol <- round(x_length/cellsize,0) #number of columns in grid
nrow <- round(y_length/cellsize,0) #number of rows in grid

grid <- GridTopology(cellcentre.offset=c(min_x,min_y),cellsize=c(cellsize,cellsize),cells.dim=c(ncol,nrow))

#Convert GridTopolgy object to SpatialPixelsDataFrame object.
grid <- SpatialPixelsDataFrame(grid,
                              data=data.frame(id=1:prod(ncol,nrow)),
                              proj4string=CRS('+init=epsg:2193'))





i=0
for (d_slice in sort(unique(data.10m$date))){
  c_data <- subset(data.10m,subset = (date==d_slice))
  print(i)
  
  if (length(unique(c_data$siteid))<4){
    i <- i+1
    next
  }
  eval(parse(text=paste0("surf.",i," <- ",
                         "autoKrige(pm2.5 ~ 1,data=c_data,new_data = grid, input_data=c_data)")))
  eval(parse(text=paste0("surf.",i,"$krige_output$timestamp <-d_slice")))
  eval(parse(text=paste0("proj4string(surf.",i,"$krige_output) <- CRS('+init=epsg:2193')")))
  if (i==0){
    eval(parse(text=paste0("x_data <- surf.",i,"$krige_output@data")))
    eval(parse(text=paste0("x_bbox <- surf.",i,"$krige_output@bbox")))
    eval(parse(text=paste0("x_coords <- surf.",i,"$krige_output@coords")))
    x_coords.nrs <- c(1,2)
    eval(parse(text=paste0("to_rast <- surf.",i,"$krige_output")))
    r0 <- rasterFromXYZ(cbind(to_rast@coords,to_rast@data$var1.pred))
    crs(r0) <- '+init=epsg:2193'
    raster_cat <- r0
  }
  else {
    eval(parse(text=paste0("x_data <- rbind(x_data,surf.",i,"$krige_output@data)")))
    eval(parse(text=paste0("x_coords <- rbind(x_coords,surf.",i,"$krige_output@coords)")))
    eval(parse(text=paste0("to_rast <- surf.",i,"$krige_output")))
    r0 <- rasterFromXYZ(cbind(to_rast@coords,to_rast@data$var1.pred))
    crs(r0) <- '+init=epsg:2193'
    raster_cat <- addLayer(raster_cat,r0)
  }
  i <- i+1
}
x_bbox[1,] <-c(min(x_coords[,1]),min(x_coords[,2]))
x_bbox[2,] <-c(max(x_coords[,1]),max(x_coords[,2]))
krigged_odin_data <- SpatialPointsDataFrame(coords = x_coords, data = x_data, coords.nrs = x_coords.nrs, bbox = x_bbox)
proj4string(krigged_odin_data) <- CRS('+init=epsg:2193')
krigged_odin_data <- spTransform(krigged_odin_data,CRS("+proj=longlat +datum=WGS84"))


writeOGR(krigged_odin_data, ".", "JuneJuly2017_pm25_10_min_krigged", driver = "ESRI Shapefile", overwrite_layer = TRUE)


save(krigged_odin_data,file='/data/data_gustavo/cona/krigged_data_JuneJuly2017.RData')

save(raster_cat,file = '/data/data_gustavo/cona/raster_odin_JuneJuly2017.RData')
raster_cat_LL <- projectRaster(raster_cat,crs = "+proj=longlat +datum=WGS84")
writeRaster(raster_cat_LL, filename="./odin_June-July2017.nc", overwrite=TRUE)

