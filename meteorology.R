#CONA MET
library('openair')
rangiora.0.1 <- read.csv("~/data/CONA/from_work/MET/rangiora_0.csv")
rangiora.1_1 <- read.csv("~/data/CONA/from_work/MET/rangiora_1.csv")
rangiora.2_1 <- read.csv("~/data/CONA/from_work/MET/rangiora_2.csv")
rangiora.3_1 <- read.csv("~/data/CONA/from_work/MET/rangiora_3.csv")
rangiora.0_1$date <- as.POSIXct(paste(rangiora.1_1$Date,rangiora.1_1$Time),format = '%d/%m/%Y %H:%M:%S')
rangiora.0_1$Date<-NULL
rangiora.0_1$Time<-NULL
names(rangiora.0_1)<-c('wd.0.1','Tmin.0.1','Tmax.0.1','Tavg.0.1','rh.0.1','pres.0.1','sd.wd.0.1','gust.wd.0.1','ws.0.1','sd.ws.0.1','gust.ws.0.1','batt.0.1','date')
rangiora.1_1$date <- as.POSIXct(paste(rangiora.1_1$Date,rangiora.1_1$Time),format = '%d/%m/%Y %H:%M:%S')
rangiora.1_1$Date<-NULL
rangiora.1_1$Time<-NULL
names(rangiora.1_1)<-c('wd.1.1','Tmin.1.1','Tmax.1.1','Tavg.1.1','rh.1.1','pres.1.1','sd.wd.1.1','gust.wd.1.1','ws.1.1','sd.ws.1.1','gust.ws.1.1','batt.1.1','date')
rangiora.2_1$date <- as.POSIXct(paste(rangiora.2_1$Date,rangiora.2_1$Time),format = '%d/%m/%Y %H:%M:%S')
rangiora.2_1$Date<-NULL
rangiora.2_1$Time<-NULL
names(rangiora.2_1)<-c('wd.2.1','Tmin.2.1','Tmax.2.1','Tavg.2.1','rh.2.1','pres.2.1','sd.wd.2.1','gust.wd.2.1','ws.2.1','sd.ws.2.1','gust.ws.2.1','batt.2.1','date')
rangiora.3_1$date <- as.POSIXct(paste(rangiora.3_1$Date,rangiora.3_1$Time),format = '%d/%m/%Y %H:%M:%S')
rangiora.3_1$Date<-NULL
rangiora.3_1$Time<-NULL
timePlot(met_data,pollutant = c('ws.1.1','ws.2.1','ws.3.1'),group = TRUE)
names(rangiora.3_1)<-c('wd.3.1','Tmin.3.1','Tmax.3.1','Tavg.3.1','rh.3.1','pres.3.1','sd.wd.3.1','gust.wd.3.1','ws.3.1','sd.ws.3.1','gust.ws.3.1','batt.3.1','date')
met_data <- merge(rangiora.1_1,rangiora.2_1,by='date',all = TRUE)
met_data <- merge(met_data,rangiora.3_1,by='date',all = TRUE)
names(met_data)

#Plots
timePlot(met_data,pollutant = c('Tavg.1.1','Tavg.2.1','Tavg.3.1'),group = TRUE)
timePlot(met_data,pollutant = c('wd.1.1','wd.2.1','wd.3.1'),group = TRUE)
timePlot(met_data,pollutant = c('rh.1.1','rh.2.1','rh.3.1'),group = TRUE)
timePlot(met_data,pollutant = c('wd.1.1','wd.2.1','wd.3.1'),group = TRUE,avg.time = '10 min')
timePlot(met_data,pollutant = c('ws.1.1','ws.2.1','ws.3.1'),group = TRUE,avg.time = '10 min')
timePlot(met_data,pollutant = c('pres.1.1','pres.2.1','pres.3.1'),group = TRUE,avg.time = '10 min')
timePlot(met_data,pollutant = c('batt.1.1','batt.2.1','batt.3.1'),group = TRUE,avg.time = '10 min')
timePlot(met_data,pollutant = c('Tavg.1.1','Tavg.2.1','Tavg.3.1'),group = TRUE,avg.time = '10 min')

scatterPlot(met_data,x='wd.1.1',y='wd.2.1')
scatterPlot(met_data,x='wd.1.1',y='wd.2.1',avg.time = '10 min')
scatterPlot(met_data,x='wd.1.1',y='wd.3.1',avg.time = '10 min')
scatterPlot(met_data,x='wd.2.1',y='wd.3.1',avg.time = '10 min')
scatterPlot(met_data,x='wd.2.1',y='wd.3.1',avg.time = '5 min')
scatterPlot(met_data,x='wd.2.1',y='wd.3.1',avg.time = '10 min')
scatterPlot(met_data,x='ws.2.1',y='ws.3.1',avg.time = '10 min')
scatterPlot(met_data,x='Tave.2.1',y='Tave.3.1',avg.time = '10 min')
scatterPlot(met_data,x='Tavg.2.1',y='Tavg.3.1',avg.time = '10 min')
scatterPlot(met_data,x='Tavg.2.1',y='Tavg.1.1',avg.time = '10 min')
