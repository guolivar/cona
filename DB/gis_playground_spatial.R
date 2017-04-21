##### Load relevant packages #####
library(RPostgreSQL)
library(openair)
library(ggplot2)
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
               host='penap-data.dyndns.org',
               dbname='cona',
               port=5432)


##### Get data ####
# Select average for an hour/day at all locations and then krig the result
data <- dbGetQuery(con,"SELECT fs.id, avg(d.value::numeric) as pm25,
  ST_X(ST_TRANSFORM(fs.geom::geometry,2193)) as x,
  ST_Y(ST_TRANSFORM(fs.geom::geometry,2193)) as y,
  ST_AsText(fs.geom) as geom,
  date_trunc('hour',d.recordtime at time zone 'NZST') as tstmp
  FROM data.fixed_data as d, admin.sensor as s, admin.instrument as i, admin.fixedsites as fs
  WHERE s.id = d.sensorid AND
	  s.instrumentid = i.id AND
	  fs.id = d.siteid AND
  	i.name = 'ODIN-SD-3' AND
  	s.name = 'PM2.5' AND
    (d.recordtime at time zone 'NZST') >= timestamp '2016-08-01 16:00:00' AND
    (d.recordtime at time zone 'NZST') <= timestamp '2016-08-31 16:00:00' AND
    ST_WITHIN(fs.geom::geometry, ST_BUFFER((select x.geom::geometry from admin.fixedsites as x where x.id=27),0.032))
  GROUP BY fs.id,
    date_trunc('hour',d.recordtime at time zone 'NZST')
  HAVING
    count(fs.geom) > 4;")
data$pm2.5 <- data$pm25
data$pm25 <- NULL
#data$date <- as.POSIXct(paste0(data$tstmp_dy," ",data$tstmp), tz='NZST')
i=0
for (d_slice in sort(unique(data$tstmp))){
  c_data <- subset(data,subset = (tstmp==d_slice))
  coordinates(c_data) <- ~ x + y
  eval(parse(text=paste0("surf.",i," <- ",
                         "autoKrige(pm2.5 ~ 1,data=c_data,input_data=c_data)")))
  eval(parse(text=paste0("surf.",i,"$krige_output$timestamp <-d_slice")))
  eval(parse(text=paste0("proj4string(surf.",i,"$krige_output) <- CRS('+init=epsg:2193')")))
  if (i==0){
    eval(parse(text=paste0("x_data <- surf.",i,"$krige_output@data")))
    eval(parse(text=paste0("x_bbox <- surf.",i,"$krige_output@bbox")))
    eval(parse(text=paste0("x_coords <- surf.",i,"$krige_output@coords")))
    x_coords.nrs <- c(1,2)
  }
  else {
    eval(parse(text=paste0("x_data <- rbind(x_data,surf.",i,"$krige_output@data)")))
    eval(parse(text=paste0("x_coords <- rbind(x_coords,surf.",i,"$krige_output@coords)")))
  }
  i=i+1
}
x_bbox[1,] <-c(min(x_coords[,1]),min(x_coords[,2]))
x_bbox[2,] <-c(max(x_coords[,1]),max(x_coords[,2]))
all_data <- SpatialPointsDataFrame(coords = x_coords, data = x_data, coords.nrs = x_coords.nrs, bbox = x_bbox)
proj4string(all_data) <- CRS('+init=epsg:2193')
all_data <- spTransform(all_data,CRS("+proj=longlat +datum=WGS84"))


writeOGR(all_data, ".", "ep9Aug_pm25_1_min_krigged", driver = "ESRI Shapefile", overwrite_layer = TRUE)


map <- get_map(location = rowMeans(bbox(all_data)),zoom = 14)
ggmap(map) +
  geom_point(data=as.data.frame(subset(all_data,subset = (timestamp == min(data$tstmp)))),
             aes(x1,x2,fill=var1.pred,color=var1.pred),
             size=2.5,
             shape=22,
             alpha=0.4) +
  scale_fill_gradientn(colours = rev(heat.colors(5))) +
  scale_color_gradientn(colours = rev(heat.colors(5)))

  


