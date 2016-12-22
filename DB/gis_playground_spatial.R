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
##### Set the working directory DB ####
setwd("~/repositories/cona/DB")
##### Read the credentials file (hidden) ####
access <- read.delim("./.cona_login")
##### Open the connection to the DB ####
p <- dbDriver("PostgreSQL")
con<-dbConnect(p,
               user='cona_data',
               password='c0nad@ta',
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
    (d.recordtime at time zone 'NZST') >= timestamp '2016-08-09 16:00:00' AND
    (d.recordtime at time zone 'NZST') <= timestamp '2016-08-10 16:00:00' AND
    ST_WITHIN(fs.geom::geometry, ST_BUFFER((select x.geom::geometry from admin.fixedsites as x where x.id=27),0.032)) AND
count(fs.geom) > 4
  GROUP BY fs.id,
    date_trunc('hour',d.recordtime at time zone 'NZST');")
data$pm2.5 <- data$pm25
data$pm25 <- NULL
data$date <- as.POSIXct(paste0(data$tstmp_dy," ",data$tstmp), tz='NZST')
i=0
for (d_slice in sort(unique(data$date))){
  c_data <- subset(data,subset = (date==d_slice))
  coordinates(c_data) <- ~ x + y
  eval(parse(text=paste0("surf.",i," <- ",
                         "autoKrige(pm2.5 ~ 1,data=c_data,input_data=c_data)")))
  eval(parse(text=paste0("surf.",i,"$krige_output$timestamp <-d_slice")))
  if (hr==0){
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


writeOGR(all_data, ".", "ep9Aug_pm25_1_min_krigged", driver = "ESRI Shapefile", overwrite_layer = TRUE)
