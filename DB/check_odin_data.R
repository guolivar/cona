##### Load relevant packages #####
library(RPostgreSQL)
library(openair)
library(ggplot2)
library(reshape2)
##### Set the working directory DB ####
setwd("~/repositories/cona/DB")
##### Read the credentials file (hidden) ####
access <- read.delim("./.cona_login")
##### Open the connection to the DB ####
p <- dbDriver("PostgreSQL")
con<-dbConnect(p,
               user='cona_data',
               password='c0nad@ta',
               host='localhost',
               dbname='cona',
               port=5432)


##### Get data ####
data <- dbGetQuery(con," SELECT d.recordtime AT TIME ZONE 'UTC' AS date,
                                 i.serialn AS instrument,
                                 s.name AS sensor,
                                 d.value AS value,
                                 d.siteid as siteid
FROM data.fixed_data AS d,
     admin.sensor AS s,
     admin.instrument AS i
WHERE s.id = d.sensorid
    AND s.instrumentid = i.id
    AND (s.name = 'PM2.5')
ORDER BY date, siteid;")

data$pm2.5 <- data$pm25
data$pm25 <- NULL

ggplot(data)+
  geom_point(aes(x=temp,y=pm2.5, colour = instrument))

ggplot(data)+
  geom_point(aes(x=rh,y=pm2.5, colour = instrument))


wide_data <- dcast(data,date~instrument,value.var = 'pm2.5',fun.aggregate = mean)
one_hour <- timeAverage(wide_data,avg.time = '1 hour')
one_day <- timeAverage(wide_data,avg.time = '1 day')
long_one_hour <- melt(one_hour,id.vars = c('date'))
names(long_one_hour) <- c('date','instrument','pm2.5')
long_one_day <- melt(one_day,id.vars = c('date'))
names(long_one_day) <- c('date','instrument','pm2.5')

last_date <- dbGetQuery(con,"SELECT i.serialn, max(fd.recordtime) at time zone 'NZST' as date
                              FROM data.fixed_data fd, admin.instrument i, admin.sensor s
                              WHERE
                        i.id = s.instrumentid AND
                        fd.sensorid = s.id
                        group by i.serialn
                        order by i.serialn;")

ggplot(long_one_day)+
  geom_line(aes(x=date,y=pm2.5,colour = instrument))+
  ggtitle('Daily averages')+
  xlab('Local Date')+
  ylab(expression(paste('PM2.5 [',mu,'g/',m^3)))

ggplot(long_one_hour)+
  geom_line(aes(x=date,y=pm2.5,colour = instrument))+
  ggtitle('Hourly averages')+
  xlab('Local Time')+
  ylab(expression(paste('PM2.5 [',mu,'g/',m^3)))

timeVariation(wide_data,pollutant = c('ODIN-100'))
avtime = '6 hour'
timePlot(wide_data,pollutant = c('ODIN-100'),avg.time = avtime,group = TRUE)
