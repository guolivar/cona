##### Load relevant packages #####
library("RPostgreSQL")
library("openair")
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
data <- dbGetQuery(con,"SELECT d.recordtime at time zone 'NZST' as date, d.value as pm25, i.serialn as instrument
                   FROM data.fixed_data as d, admin.sensor as s, admin.instrument as i
                   WHERE s.id = d.sensorid AND
                   s.instrumentid = i.id AND
                   i.name = 'ODIN-SD-3' AND
                   s.name = 'PM2.5'")
data$pm2.5 <- as.numeric(gsub("'","",data$pm25))



last_date <- dbGetQuery(con,"SELECT i.serialn, max(fd.recordtime) at time zone 'NZST' as date
                              FROM data.fixed_data fd, admin.instrument i, admin.sensor s
                              WHERE
                        i.id = s.instrumentid AND
                        fd.sensorid = s.id
                        group by i.serialn;")


