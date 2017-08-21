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
               host='penap-data.dyndns.org',
               dbname='cona',
               port=5432)
##### Moving Average function ####
ma <- function(x,n=5){filter(x,rep(1/n,n), sides=1)}

##### Load data from file ####
load(file = '~/data/CONA/2017/WORKING/odin/odin_June2017_2.RData')
data.10m <- subset(data.10m,date>as.POSIXct('2017-06-21 04:00:00'))
coordinates(data.10m) <- ~ x + y
coordinates(data) <- ~ x + y
proj4string(data.10m) <- CRS('+init=epsg:2193')
proj4string(data) <- CRS('+init=epsg:2193')

i=0
for (d_slice in sort(unique(data.10m$date))){
  c_data <- subset(data.10m,subset = (date==d_slice))
  plot(c_data)
  print(i)
  
  if (length(unique(c_data$siteid))<4){
    i <- i+1
    next
  }
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
  i <- i+1
}
x_bbox[1,] <-c(min(x_coords[,1]),min(x_coords[,2]))
x_bbox[2,] <-c(max(x_coords[,1]),max(x_coords[,2]))
all_data <- SpatialPointsDataFrame(coords = x_coords, data = x_data, coords.nrs = x_coords.nrs, bbox = x_bbox)
proj4string(all_data) <- CRS('+init=epsg:2193')
all_data <- spTransform(all_data,CRS("+proj=longlat +datum=WGS84"))


writeOGR(all_data, ".", "JuneJuly2017_pm25_1_min_krigged", driver = "ESRI Shapefile", overwrite_layer = TRUE)


save(krigged_odin_data,file='/data/data_gustavo/cona/krigged_data_JuneJuly2017.RData')

save(raster_cat,file = '/data/data_gustavo/cona/raster_odin_JuneJuly2017.RData')
