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
library(gstat)
library(ncdf4)
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



all_dates <- sort(unique(data.10m$date))
ndates <- length(all_dates)
breaks <- as.numeric(quantile((1:ndates),c(0,0.2,0.4,0.6,0.8,1), type = 1))
nbreaks <- length(breaks)
fidx <- 1
for (j in (1:(nbreaks-1))){
  i <- 0
  if (j == 1){
    j1 <- 1
    j2 <- breaks[j+1]
  } else {
    j1 <- breaks[j]
    j2 <- breaks[j+1]
  }
  for (d_slice in (j1:j2)){
    c_data <- subset(data.10m,subset = (date==all_dates[d_slice]))
    
    if (length(unique(c_data$siteid))<4){
      next
    }
    #  surf.krig <- autoKrige(pm2.5 ~ 1,data=c_data,new_data = grid, input_data=c_data)
    #  surf.krig$krige_output$timestamp <-d_slice
    #  proj4string(surf.krig$krige_output) <- CRS('+init=epsg:2193')
    
    surf.idw <- idw(pm2.5 ~ 1,newdata = grid, locations = c_data, idp = 1)
    surf.idw$timestamp <-d_slice
    proj4string(surf.idw) <- CRS('+init=epsg:2193')
    
    surf.idw2 <- idw(pm2.5 ~ 1,newdata = grid, locations = c_data, idp = 2)
    surf.idw2$timestamp <-d_slice
    proj4string(surf.idw2) <- CRS('+init=epsg:2193')
    
    if (i==0){
      #    x_data <- surf.krig$krige_output@data
      #    x_bbox <- surf.krig$krige_output@bbox
      #    x_coords <- surf.krig$krige_output@coords
      #    x_coords.nrs <- c(1,2)
      #    to_rast.krig <- surf.krig$krige_output
      #    r0.krig <- rasterFromXYZ(cbind(to_rast.krig@coords,to_rast.krig@data$var1.pred))
      #    crs(r0.krig) <- '+init=epsg:2193'
      #    raster_cat.krig <- r0.krig
      
      to_rast.idw <- surf.idw
      r0.idw <- rasterFromXYZ(cbind(surf.idw@coords,surf.idw$var1.pred))
      crs(r0.idw) <- '+init=epsg:2193'
      raster_cat.idw<- r0.idw
      
      to_rast.idw2 <- surf.idw2
      r0.idw2 <- rasterFromXYZ(cbind(surf.idw2@coords,surf.idw2$var1.pred))
      crs(r0.idw2) <- '+init=epsg:2193'
      raster_cat.idw2<- r0.idw2
      i <- 1
    }
    else {
      #    x_data <- rbind(x_data,surf.krig$krige_output@data)
      #    x_coords <- rbind(x_coords,surf.krig$krige_output@coords)
      #    to_rast.krig <- surf.krig$krige_output
      #    r0.krig <- rasterFromXYZ(cbind(to_rast.krig@coords,to_rast.krig@data$var1.pred))
      #    crs(r0.krig) <- '+init=epsg:2193'
      #    raster_cat.krig <- addLayer(raster_cat.krig,r0.krig)
      
      to_rast.idw <- surf.idw
      r0.idw <- rasterFromXYZ(cbind(surf.idw@coords,surf.idw$var1.pred))
      crs(r0.idw) <- '+init=epsg:2193'
      raster_cat.idw<- addLayer(raster_cat.idw,r0.idw)
      
      to_rast.idw2 <- surf.idw2
      r0.idw2 <- rasterFromXYZ(cbind(surf.idw2@coords,surf.idw2$var1.pred))
      crs(r0.idw2) <- '+init=epsg:2193'
      raster_cat.idw2<- addLayer(raster_cat.idw2,r0.idw2)
    }
    #  if (min(to_rast.krig@data$var1.pred)<0){
    print(all_dates[d_slice])
    #  }
  }
  save('raster_cat.idw',file = paste0('/data/data_gustavo/cona/raster_cat.idw.',fidx,'.RData'))
  save('raster_cat.idw2',file = paste0('/data/data_gustavo/cona/raster_cat.idw2.',fidx,'.Rdata'))
  rm('raster_cat.idw')
  rm('raster_cat.idw2')
  fidx <- fidx + 1
}
fidx <- 6
for (i in (1:(fidx-1))){
  load(paste0('/data/data_gustavo/cona/raster_cat.idw.',i,'.RData'))
  load(paste0('/data/data_gustavo/cona/raster_cat.idw2.',i,'.Rdata'))
  if (i == 1){
    raster_stack.idw <- raster_cat.idw
    raster_stack.idw2 <- raster_cat.idw2
  } else {
    raster_stack.idw <- addLayer(raster_stack.idw,raster_cat.idw)
    raster_stack.idw2 <- addLayer(raster_stack.idw2,raster_cat.idw2)
  }
}

#x_bbox[1,] <-c(min(x_coords[,1]),min(x_coords[,2]))
#x_bbox[2,] <-c(max(x_coords[,1]),max(x_coords[,2]))
#krigged_odin_data <- SpatialPointsDataFrame(coords = x_coords, data = x_data, coords.nrs = x_coords.nrs, bbox = x_bbox)
#proj4string(krigged_odin_data) <- CRS('+init=epsg:2193')
#krigged_odin_data <- spTransform(krigged_odin_data,CRS("+proj=longlat +datum=WGS84"))


#writeOGR(krigged_odin_data, ".", "JuneJuly2017_pm25_10_min_krigged", driver = "ESRI Shapefile", overwrite_layer = TRUE)


#save(krigged_odin_data,file='/data/data_gustavo/cona/krigged_data_JuneJuly2017.RData')

#raster_cat_LL <- projectRaster(raster_cat,crs = "+proj=longlat +datum=WGS84")
raster_cat_idw_LL <- projectRaster(raster_stack.idw,crs = "+proj=longlat +datum=WGS84")
raster_cat_idw2_LL <- projectRaster(raster_stack.idw2,crs = "+proj=longlat +datum=WGS84")
save(list = c('raster_cat_idw_LL','raster_cat_idw2_LL'),file = '/data/data_gustavo/cona/raster_odin_IDW_JuneJuly2017.RData')

#writeRaster(raster_cat_LL, filename="./odin_June-July2017_autokrig.nc", overwrite=TRUE)
writeRaster(raster_cat_idw_LL, filename="./odin_June-July2017_idw.nc", overwrite=TRUE)
writeRaster(raster_cat_idw2_LL, filename="./odin_June-July2017_idw2.nc", overwrite=TRUE)
