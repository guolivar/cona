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
               user=access$user[2],
               password=access$pwd[2],
               host='penap-data.dyndns.org',
               dbname='cona',
               port=5432)


##### Get data ####
for (hour in (0:23)){
  c_data <- dbGetQuery(con,paste0("SELECT fs.id,
  percentile_disc(0.05) WITHIN GROUP (ORDER BY d.value::numeric) as pm25,
  ST_X(ST_TRANSFORM(fs.geom::geometry,2193)) as x,
  ST_Y(ST_TRANSFORM(fs.geom::geometry,2193)) as y,
  ST_AsText(fs.geom) as geom
  FROM data.fixed_data as d, admin.sensor as s, admin.instrument as i, admin.fixedsites as fs
  WHERE s.id = d.sensorid AND
	  s.instrumentid = i.id AND
	  fs.id = d.siteid AND
  	i.name = 'ODIN-SD-3' AND
  	s.name = 'PM2.5' AND
    ST_WITHIN(fs.geom::geometry, ST_BUFFER((select x.geom::geometry from admin.fixedsites as x where x.id=27),0.032)) AND
    extract(hour from d.recordtime at time zone 'NZST') = ",hour,"
  GROUP BY fs.id
  HAVING
    count(fs.geom) > 4;"))
  c_data$pm2.5 <- c_data$pm25
  c_data$pm25 <- NULL
  coordinates(c_data) <- ~ x + y
  eval(parse(text=paste0("surf.",hour," <- ",
                         "autoKrige(pm2.5 ~ 1,data=c_data,input_data=c_data)")))
  eval(parse(text=paste0("surf.",hour,"$krige_output$timestamp <-hour")))
  eval(parse(text=paste0("proj4string(surf.",hour,"$krige_output) <- CRS('+init=epsg:2193')")))
  if (hour==0){
    eval(parse(text=paste0("x_data <- surf.",hour,"$krige_output@data")))
    eval(parse(text=paste0("x_bbox <- surf.",hour,"$krige_output@bbox")))
    eval(parse(text=paste0("x_coords <- surf.",hour,"$krige_output@coords")))
    x_coords.nrs <- c(1,2)
  }
  else {
    eval(parse(text=paste0("x_data <- rbind(x_data,surf.",hour,"$krige_output@data)")))
    eval(parse(text=paste0("x_coords <- rbind(x_coords,surf.",hour,"$krige_output@coords)")))
  }
}
  

x_bbox[1,] <-c(min(x_coords[,1]),min(x_coords[,2]))
x_bbox[2,] <-c(max(x_coords[,1]),max(x_coords[,2]))
all_data <- SpatialPointsDataFrame(coords = x_coords, data = x_data, coords.nrs = x_coords.nrs, bbox = x_bbox)
proj4string(all_data) <- CRS('+init=epsg:2193')
all_data <- spTransform(all_data,CRS("+proj=longlat +datum=WGS84"))


writeOGR(all_data, ".", "all_data_1hr_krigged", driver = "ESRI Shapefile", overwrite_layer = TRUE)

min_pm <- min(all_data$var1.pred)
max_pm <- max(all_data$var1.pred)
min_var <- min(all_data$var1.var)
max_var <- max(all_data$var1.var)

for (hour in (0:23)){
  map <- get_map(location = rowMeans(bbox(all_data)),zoom = 14)
  ggmap(map) +
    geom_point(data=as.data.frame(subset(all_data,subset = (timestamp == hour))),
               aes(x1,x2,fill=var1.pred,color=var1.pred),
               size=2.2,
               shape=22,
               alpha=0.8) +
    scale_fill_gradientn(name = 'PM2.5', limits = c(min_pm,max_pm), colours = rev(heat.colors(5))) +
    scale_color_gradientn(name = 'PM2.5', limits = c(min_pm,max_pm), colours = rev(heat.colors(5))) +
    ggtitle(paste0(hour,':00'))
  ggsave(paste0('./',sprintf('%02d',hour),'_pm25.png'))
  
  map <- get_map(location = rowMeans(bbox(all_data)),zoom = 14)
  ggmap(map) +
    geom_point(data=as.data.frame(subset(all_data,subset = (timestamp == hour))),
               aes(x1,x2,fill=var1.var,color=var1.var),
               size=2.2,
               shape=22,
               alpha=0.8) +
    scale_fill_gradientn(name = 'Variance', limits = c(min_var,max_var), colours = rev(heat.colors(5))) +
    scale_color_gradientn(name = 'Variance', limits = c(min_var,max_var), colours = rev(heat.colors(5))) +
    ggtitle(paste0(hour,':00'))
  ggsave(paste0('./',sprintf('%02d',hour),'_pm25_var.png'))
}
system('ffmpeg -y -framerate 2 -i %02d_pm25.png pm25.mp4')
system('ffmpeg -y -framerate 2 -i %02d_pm25_var.png pm25_var.mp4')

dbDisconnect(con)

