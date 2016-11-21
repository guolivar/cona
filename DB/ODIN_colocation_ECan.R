##### Load relevant packages #####
library(RPostgreSQL)
##### Set the working directory DB ####
setwd("~/repositories/cona/DB")
##### Set the path where location info is #####
filepath <- '/home/gustavo/data_gustavo/cona'
##### Read the credentials file (hidden file not on the GIT repository) ####
access <- read.delim("./.cona_login")
##### Open DATA connection to the DB ####
p <- dbDriver("PostgreSQL")
con<-dbConnect(p,
               user=as.character(access$user[1]),
               password=as.character(access$pwd[1]),
               host='penap-data.dyndns.org',
               dbname='cona',
               port=5432)
# Load only data from ODINs at ECan's site
siteid = 18 # ECan site
data <- dbGetQuery(con," SELECT d.recordtime at time zone 'NZST' as date, d.value as pm25, i.serialn as instrument
                   FROM data.fixed_data as d, admin.sensor as s, admin.instrument as i
                   WHERE s.id = d.sensorid AND
                   s.instrumentid = i.id AND
                   i.name = 'ODIN-SD-3' AND
                   d.siteid = 18 AND
                   s.name = 'PM2.5';")
data$pm2.5 <- as.numeric(gsub("'","",data$pm25))
data$pm25 <- NULL
ggplot(data)+
  geom_line(aes(x=date,y=pm2.5,colour = instrument))+
  ggtitle('ODIN colocation')+
  xlab('Local Date')+
  ylab(expression(paste('PM2.5 [',mu,'g/',m^3)))

wide_data <- dcast(data,date~instrument,value.var = 'pm2.5',fun.aggregate = mean)
wide_data.1hr <- timeAverage(wide_data,avg.time = '1 hour')
timePlot(wide_data.1hr,pollutant = names(wide_data)[2:14],group = TRUE, avg.time = '1 day')
timeVariation(wide_data.1hr,pollutant = names(wide_data)[2:14])
