##### Load relevant packages #####
library(RPostgreSQL)
library(openair)
library(ggplot2)
library(reshape2)
library(BreakoutDetection)
library(AnomalyDetection)
##### Set the working directory DB ####
setwd("./DB")
##### Read the credentials file (hidden) ####
access <- read.delim("./.cona_login", stringsAsFactors = FALSE)
##### Open the connection to the DB ####
p <- dbDriver("PostgreSQL")
con<-dbConnect(p,
               user=access$user[2],
               password=access$pwd[2],
               host='localhost',
               dbname='cona',
               port=5432)


##### Get data ####
data <- dbGetQuery(con,"select id.recordtime at time zone 'NZST' as date, id.value::numeric as pm
from data.indoor_data as id
where
id.houseid = 6 AND
id.sensorid = 63
order by date;")

data.1min <- timeAverage(data,avg.time = '1 min')
data.10min <- timeAverage(data,avg.time = '10 min')
data.1hr <- timeAverage(data,avg.time = '1 hour')
timePlot(data,pollutant = 'pm',avg.time = '1 min')

save.image("house_6.RData")

sample_data <- data.10min
res = AnomalyDetectionVec(sample_data$pm,
                          max_anoms=0.2,
                          direction='pos',
                          period = 20,
                          plot=TRUE,
                          alpha = 0.5,
                          e_value = T,
                          longterm_period = 144)
sample_data$expected <- sample_data$pm
sample_data$expected[res$anoms$index] <- res$anoms$expected_value
sample_data$anomaly <- sample_data$pm - sample_data$expected
timePlot(sample_data,pollutant = c('expected','pm'), group = TRUE)
timePlot(sample_data,pollutant = c('anomaly'), group = TRUE)

res2 <- breakout(data.1min$pm,method = 'amoc', plot = TRUE, min.size =  60)
res2$plot
