#CONA MET
library('openair')
rangiora.0_1 <- read.csv("~/data/CONA/MET/rangiora_0.csv")
rangiora.1_1 <- read.csv("~/data/CONA/MET/rangiora_1.csv")
rangiora.2_1 <- read.csv("~/data/CONA/MET/rangiora_2.csv")
rangiora.3_1 <- read.csv("~/data/CONA/MET/rangiora_3.csv")
rangiora.0_1$date <- as.POSIXct(paste(rangiora.0_1$Date,rangiora.0_1$Time)
                                ,format = '%d/%m/%Y %H:%M:%S'
                                ,tz = 'NZST')
rangiora.0_1$Date<-NULL
rangiora.0_1$Time<-NULL
names(rangiora.0_1)<-c('ws.0.1','wd.0.1','sd.wd.0.1', 'sd.ws.0.1','Tavg.0.1','rh.0.1','rain.0.1','pres.0.1','srad.0.1','soilM.0.1','batt.0.1','date')

rangiora.1_1$date <- as.POSIXct(paste(rangiora.1_1$Date,rangiora.1_1$Time)
                                ,format = '%d/%m/%Y %H:%M:%S'
                                ,tz = 'NZST')
rangiora.1_1$Date<-NULL
rangiora.1_1$Time<-NULL
names(rangiora.1_1)<-c('Tavg.1.1',
                       'Tmin.1.1',
                       'Tmax.1.1',
                       'rh.1.1',
                       'pres.1.1',
                       'wd.1.1',
                       'sd.wd.1.1',
                       'gust.wd.1.1',
                       'ws.1.1',
                       'sd.ws.1.1',
                       'gust.ws.1.1',
                       'batt.1.1',
                       'date')

rangiora.2_1$date <- as.POSIXct(paste(rangiora.2_1$Date,rangiora.2_1$Time)
                                ,format = '%d/%m/%Y %H:%M:%S'
                                ,tz = 'NZST')
rangiora.2_1$Date<-NULL
rangiora.2_1$Time<-NULL
names(rangiora.2_1)<-c('Tavg.2.1',
                       'Tmin.2.1',
                       'Tmax.2.1',
                       'rh.2.1',
                       'pres.2.1',
                       'wd.2.1',
                       'sd.wd.2.1',
                       'gust.wd.2.1',
                       'ws.2.1',
                       'sd.ws.2.1',
                       'gust.ws.2.1',
                       'batt.2.1',
                       'date')

rangiora.3_1$date <- as.POSIXct(paste(rangiora.3_1$Date,rangiora.3_1$Time)
                                ,format = '%d/%m/%Y %H:%M:%S'
                                ,tz = 'NZST')
rangiora.3_1$Date<-NULL
rangiora.3_1$Time<-NULL
names(rangiora.3_1)<-c('Tavg.3.1',
                       'Tmin.3.1',
                       'Tmax.3.1',
                       'rh.3.1',
                       'pres.3.1',
                       'wd.3.1',
                       'sd.wd.3.1',
                       'gust.wd.3.1',
                       'ws.3.1',
                       'sd.ws.3.1',
                       'gust.ws.3.1',
                       'batt.3.1',
                       'date')

met_data.raw <- merge(rangiora.0_1,rangiora.1_1,by='date',all = TRUE)
met_data.raw <- merge(met_data.raw,rangiora.2_1,by='date',all = TRUE)
met_data.raw <- merge(met_data.raw,rangiora.3_1,by='date',all = TRUE)
met_data <- timeAverage(met_data.raw,avg.time = '10 min')
attr(met_data$date,'tzone') <- 'NZST'
start_date = as.POSIXct('2015-08-20 16:00',tz = 'NZST')
end_date = as.POSIXct('2015-09-15 11:00',tz = 'NZST')
met_data <- subset(met_data,subset = (date < end_date) & (date > start_date))

#Plots
timePlot(met_data,pollutant = c('Tavg.0.1','Tavg.1.1','Tavg.2.1','Tavg.3.1'),group = TRUE)
timePlot(met_data,pollutant = c('wd.0.1','wd.1.1','wd.2.1','wd.3.1'),group = TRUE)
timePlot(met_data,pollutant = c('rh.0.1','rh.1.1','rh.2.1','rh.3.1'),group = TRUE)
timePlot(met_data,pollutant = c('ws.0.1','ws.1.1','ws.2.1','ws.3.1'),group = TRUE)
timePlot(met_data,pollutant = c('pres.0.1','pres.1.1','pres.2.1','pres.3.1'),group = TRUE)
timePlot(met_data,pollutant = c('batt.0.1','batt.1.1','batt.2.1','batt.3.1'),group = TRUE)

scatterPlot(met_data,x='ws.2.1',y='ws.3.1')
scatterPlot(met_data,x='Tavg.0.1',y='Tavg.1.1')
scatterPlot(met_data,x='Tavg.0.1',y='Tavg.2.1')
scatterPlot(met_data,x='Tavg.0.1',y='Tavg.3.1')
