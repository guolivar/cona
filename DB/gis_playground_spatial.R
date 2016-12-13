##### Load relevant packages #####
library(RPostgreSQL)
library(openair)
library(ggplot2)
library(reshape2)
library(automap)
library(raster)
library(gstat)
library(sp)
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
data <- dbGetQuery(con,"SELECT fs.id, avg(d.value::numeric) as pm25, ST_X(ST_TRANSFORM(fs.geom::geometry,2193)) as x, ST_Y(ST_TRANSFORM(fs.geom::geometry,2193)) as y, ST_AsText(fs.geom) as geom, date_part('hour', d.recordtime at time zone 'NZST') as d_hour
  FROM data.fixed_data as d, admin.sensor as s, admin.instrument as i, admin.fixedsites as fs
  WHERE s.id = d.sensorid AND
	  s.instrumentid = i.id AND
	  fs.id = d.siteid AND
  	i.name = 'ODIN-SD-3' AND
  	s.name = 'PM2.5' AND
    ST_WITHIN(fs.geom::geometry, ST_BUFFER((select x.geom::geometry from admin.fixedsites as x where x.id=27),0.032))
  	group by fs.id, date_part('hour', d.recordtime at time zone 'NZST')")
data$pm2.5 <- data$pm25
data$pm25 <- NULL

for (hr in (0:23)){
  c_data <- subset(data,subset = (d_hour==hr))
  coordinates(c_data) <- ~ x + y
  eval(parse(text=paste0("surf.",hr," <- ",
                         "autoKrige(pm2.5 ~ 1,data=c_data,input_data=c_data)")))
  
}


plot(surf.23$krige_output)



