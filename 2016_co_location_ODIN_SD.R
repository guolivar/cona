# PM2.5 spectrometer tests
library('ggplot2')
library('openair')
library('lubridate')
library('corrplot')

# ECan data ####
base_dir <- '/home/gustavo/data/CONA/2016/PACMAN_co-location/ECanData/'
ecan_data_raw <- read.csv(paste0(base_dir,"data.csv"),stringsAsFactors=FALSE)
ecan_data_raw$date<-as.POSIXct(ecan_data_raw$DateTime,format = "%d/%m/%Y %I:%M:%S %p",tz='GMT')
ecan_data<-as.data.frame(ecan_data_raw[,c('date','PM2.5..ug.m3.','PM10..ug.m3.','Temperature.2m..DegC.','Temperature.6m..DegC.','Wind.speed..m.s.','Wind.direction..Deg.')])
names(ecan_data)<- c('date','PM2.5.FDMS','PM10.FDMS','Temperature.2m','Temperature.6m','ws','wd')


# ODIN data ####
base_dir <- '/home/gustavo/data/CONA/2016/PACMAN_co-location/ODIN/'
# ODIN-SD-100 data ####
odin.sd.100.data <- read.delim(paste0(base_dir,"odin_sd_100.txt"))
odin.sd.100.data$date <- as.POSIXct(paste(odin.sd.100.data$Day,odin.sd.100.data$Time),tz='Pacific/Auckland')
odin.sd.100.data$Day<-NULL
odin.sd.100.data$Time<-NULL

# Date correction
Real_time <- "2016-07-08 15:00:00"

tdiff = (as.POSIXct(Real_time,format = "%Y-%m-%d %H:%M:%S") - odin.sd.100.data$date[1])
odin.sd.100.data$date <- odin.sd.100.data$date + tdiff

# Rename data fields to prepare for merging

names(odin.sd.100.data) <- c('FrameLength.100',
                            'PM1.100',
                            'PM2.5.100',
                            'PM10.100',
                            'Data4.100',
                            'Data5.100',
                            'Data6.100',
                            'Data7.100',
                            'Data8.100',
                            'Data9.100',
                            'Temperature.100',
                            'RH.100',
                            'date')

# ODIN-SD-101 data ####
odin.sd.101.data <- read.delim(paste0(base_dir,"odin_sd_101.txt"))
odin.sd.101.data$date <- as.POSIXct(paste(odin.sd.101.data$Day,odin.sd.101.data$Time),tz='Pacific/Auckland')
odin.sd.101.data$Day<-NULL
odin.sd.101.data$Time<-NULL

# Date correction
Real_time <- "2016-07-08 15:00:00"

tdiff = (as.POSIXct(Real_time,format = "%Y-%m-%d %H:%M:%S") - odin.sd.101.data$date[1])
odin.sd.101.data$date <- odin.sd.101.data$date + tdiff

# Rename data fields to prepare for merging

names(odin.sd.101.data) <- c('FrameLength.101',
                             'PM1.101',
                             'PM2.5.101',
                             'PM10.101',
                             'Data4.101',
                             'Data5.101',
                             'Data6.101',
                             'Data7.101',
                             'Data8.101',
                             'Data9.101',
                             'Temperature.101',
                             'RH.101',
                             'date')




# Merging the data ####
merged.data <- merge(odin.sd.100.data,odin.sd.101.data,by = 'date',all = TRUE)
merged.data <- merge(merged.data,ecan_data,by = 'date',all = TRUE)

# Check time differences
avgtime = '10 min'
timePlot(merged.data,pollutant = c('Temperature.100',
                                   'Temperature.101',
                                   'Temperature.2m'),
         avg.time = avgtime,
         group = TRUE)

## Time sync
all_merged.10min <- timeAverage(merged.data,avg.time = avgtime)
lag_test=ccf(all_merged.10min$Temperature.100,
             all_merged.10min$Temperature.2m,
             na.action=na.pass,
             lag.max=100,
             type='covariance',
             ylab='Correlation',
             main='Temperature correlation as function of clock lag')
odin_lag=lag_test$lag[which.max(lag_test$acf)]
odin.sd.100.data$date=odin.sd.100.data$date-odin_lag*10*60
lag_test=ccf(all_merged.10min$Temperature.100,
             all_merged.10min$Temperature.2m,
             na.action=na.pass,
             lag.max=100,
             type='covariance',
             ylab='Correlation',
             main='Temperature correlation as function of clock lag')
odin_lag=lag_test$lag[which.max(lag_test$acf)]
odin.sd.101.data$date=odin.sd.101.data$date-odin_lag*10*60+30*60

merged.data <- merge(odin.sd.100.data,odin.sd.101.data,by = 'date',all = TRUE)
merged.data <- merge(merged.data,ecan_data,by = 'date',all = TRUE)
all_merged.10min <- timeAverage(merged.data,avg.time = avgtime)


# Plotting ####
avgtime = '1 hour'
timePlot(merged.data,pollutant = c('Temperature.100',
                                   'Temperature.101',
                                   'Temperature.2m'),
         avg.time = avgtime,
         group = TRUE,
         xlab = 'GMT')

timePlot(merged.data,pollutant = c('RH.100',
                                   'RH.101'),
         avg.time = avgtime,
         group = TRUE,
         xlab = 'GMT')

timePlot(merged.data,pollutant = c('PM1.100',
                                   'PM1.101'),
         avg.time = avgtime,
         group = TRUE,
         xlab = 'GMT')

timePlot(merged.data,pollutant = c('PM2.5.100',
                                   'PM2.5.101',
                                   'PM2.5.FDMS'),
         avg.time = avgtime,
         group = TRUE,
         xlab = 'GMT')

timePlot(merged.data,pollutant = c('PM10.100',
                                   'PM10.101',
                                   'PM10.FDMS'),
         avg.time = avgtime,
         group = TRUE,
         xlab = 'GMT')

