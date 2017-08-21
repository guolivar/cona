##### Load relevant packages #####
library(RPostgreSQL)
library(readr)
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
    (d.recordtime at time zone 'NZST') >= timestamp '2017-06-20 11:55:00' AND
    (d.recordtime at time zone 'NZST') <= timestamp '2017-08-31 16:00:00' AND
    ST_WITHIN(fs.geom::geometry, ST_BUFFER((select x.geom::geometry from admin.fixedsites as x where x.id=18),0.05))
  GROUP BY
    date_trunc('minute',d.recordtime at time zone 'NZST'),
    i.serialn,
    fs.id;")
dbDisconnect(con)


# Turn into a 10min running average
serialn <- unique(data$serialn)
for (sn in serialn){
  # Subset the data to have only 1 sensor
  indices <- which(data$serialn==sn)
  sensordata <- data[indices,]
  # Moving average
  sensordata$pm25 <- ma(sensordata$pm25,10)
  data$pm25[indices] <- sensordata$pm25
}
save(data,file = '/data/data_gustavo/cona/odin_June2017.RData')
write_tsv(x = data,path =  '/data/data_gustavo/cona/odin_June2017.txt')