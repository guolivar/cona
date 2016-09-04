#' # ODIN-SD test at Rangiora - July 2016
library('ggplot2')
library('openair')
# Mute some warnings
oldw <- getOption("warn")
options(warn = -1)
#' # Load Data
# ECan data ####
base_dir <- '//home/gustavo/data/CONA/2016/ODIN/ecan_site/'
ecan_data_raw <- read.csv(paste0(base_dir,"ecan_data.csv"),stringsAsFactors=FALSE)
ecan_data_raw$date<-as.POSIXct(ecan_data_raw$DateTime,format = "%d/%m/%Y %I:%M:%S %p",tz='Etc/GMT-12')
ecan_data<-as.data.frame(ecan_data_raw[,c('date','PM2.5..ug.m3.','PM10..ug.m3.','Temperature.2m..DegC.','Temperature.6m..DegC.','Wind.speed..m.s.','Wind.direction..Deg.')])
names(ecan_data)<- c('date','PM2.5.FDMS','PM10.FDMS','Temperature.2m','Temperature.6m','ws','wd')


# ODIN data ####
base_dir <- '/home/gustavo/data/CONA/2016/ODIN/ecan_site/'
# ODIN-SD-102 data ####
odin_id <- '102'
odin.sd.102.data <- read.delim(paste0(base_dir,"odin_sd_102.txt"))
odin.sd.102.data$date <- as.POSIXct(paste(odin.sd.102.data$Day,odin.sd.102.data$Time),tz='Etc/GMT+12')
odin.sd.102.data$Day<-NULL
odin.sd.102.data$Time<-NULL

# Date correction
Real_time <- "2016-07-12 09:32:00"

tdiff = (as.POSIXct(Real_time,format = "%Y-%m-%d %H:%M:%S") - odin.sd.102.data$date[1])
odin.sd.102.data$date <- odin.sd.102.data$date + tdiff

# Rename data fields to prepare for merging

names(odin.sd.102.data) <- c(paste0('FrameLength.',odin_id),
                             paste0('PM1.',odin_id),
                             paste0('PM2.5.',odin_id),
                             paste0('PM10.',odin_id),
                             paste0('Data4.',odin_id),
                             paste0('Data5.',odin_id),
                             paste0('Data6.',odin_id),
                             paste0('Data7.',odin_id),
                             paste0('Data8.',odin_id),
                             paste0('Data9.',odin_id),
                             paste0('Temperature.',odin_id),
                             paste0('RH.',odin_id),
                             'date')

# ODIN-SD-103 data ####
odin_id <- '103'
odin.sd.103.data <- read.delim(paste0(base_dir,"odin_sd_103.txt"))
odin.sd.103.data$date <- as.POSIXct(paste(odin.sd.103.data$Day,odin.sd.103.data$Time),tz='Etc/GMT+12')
odin.sd.103.data$Day<-NULL
odin.sd.103.data$Time<-NULL

# Date correction
Real_time <- "2016-07-12 09:40:00"

tdiff = (as.POSIXct(Real_time,format = "%Y-%m-%d %H:%M:%S") - odin.sd.103.data$date[1])
odin.sd.103.data$date <- odin.sd.103.data$date + tdiff

# Rename data fields to prepare for merging

names(odin.sd.103.data) <- c(paste0('FrameLength.',odin_id),
                             paste0('PM1.',odin_id),
                             paste0('PM2.5.',odin_id),
                             paste0('PM10.',odin_id),
                             paste0('Data4.',odin_id),
                             paste0('Data5.',odin_id),
                             paste0('Data6.',odin_id),
                             paste0('Data7.',odin_id),
                             paste0('Data8.',odin_id),
                             paste0('Data9.',odin_id),
                             paste0('Temperature.',odin_id),
                             paste0('RH.',odin_id),
                             'date')

# ODIN-SD-105 data ####
odin_id <- '105'
odin.sd.105.data <- read.delim(paste0(base_dir,"odin_sd_105.txt"))
odin.sd.105.data$date <- as.POSIXct(paste(odin.sd.105.data$Day,odin.sd.105.data$Time),tz='Etc/GMT+12')
odin.sd.105.data$Day<-NULL
odin.sd.105.data$Time<-NULL

# Date correction
Real_time <- "2016-07-12 10:10:00"

tdiff = (as.POSIXct(Real_time,format = "%Y-%m-%d %H:%M:%S") - odin.sd.105.data$date[1])
odin.sd.105.data$date <- odin.sd.105.data$date + tdiff

# Rename data fields to prepare for merging

names(odin.sd.105.data) <- c(paste0('FrameLength.',odin_id),
                             paste0('PM1.',odin_id),
                             paste0('PM2.5.',odin_id),
                             paste0('PM10.',odin_id),
                             paste0('Data4.',odin_id),
                             paste0('Data5.',odin_id),
                             paste0('Data6.',odin_id),
                             paste0('Data7.',odin_id),
                             paste0('Data8.',odin_id),
                             paste0('Data9.',odin_id),
                             paste0('Temperature.',odin_id),
                             paste0('RH.',odin_id),
                             'date')


# ODIN-SD-106 data ####
odin_id <- '106'
odin.sd.106.data <- read.delim(paste0(base_dir,"odin_sd_106.txt"))
odin.sd.106.data$date <- as.POSIXct(paste(odin.sd.106.data$Day,odin.sd.106.data$Time),tz='Etc/GMT+12')
odin.sd.106.data$Day<-NULL
odin.sd.106.data$Time<-NULL

# Date correction
Real_time <- "2016-07-12 10:15:00"

tdiff = (as.POSIXct(Real_time,format = "%Y-%m-%d %H:%M:%S") - odin.sd.106.data$date[1])
odin.sd.106.data$date <- odin.sd.106.data$date + tdiff

# Rename data fields to prepare for merging

names(odin.sd.106.data) <- c(paste0('FrameLength.',odin_id),
                             paste0('PM1.',odin_id),
                             paste0('PM2.5.',odin_id),
                             paste0('PM10.',odin_id),
                             paste0('Data4.',odin_id),
                             paste0('Data5.',odin_id),
                             paste0('Data6.',odin_id),
                             paste0('Data7.',odin_id),
                             paste0('Data8.',odin_id),
                             paste0('Data9.',odin_id),
                             paste0('Temperature.',odin_id),
                             paste0('RH.',odin_id),
                             'date')

# ODIN-SD-107 data ####
odin_id <- '107'
odin.sd.107.data <- read.delim(paste0(base_dir,"odin_sd_107.txt"))
odin.sd.107.data$date <- as.POSIXct(paste(odin.sd.107.data$Day,odin.sd.107.data$Time),tz='Etc/GMT+12')
odin.sd.107.data$Day<-NULL
odin.sd.107.data$Time<-NULL

# Date correction
Real_time <- "2016-07-12 10:23:00"

tdiff = (as.POSIXct(Real_time,format = "%Y-%m-%d %H:%M:%S") - odin.sd.107.data$date[1])
odin.sd.107.data$date <- odin.sd.107.data$date + tdiff

# Rename data fields to prepare for merging

names(odin.sd.107.data) <- c(paste0('FrameLength.',odin_id),
                             paste0('PM1.',odin_id),
                             paste0('PM2.5.',odin_id),
                             paste0('PM10.',odin_id),
                             paste0('Data4.',odin_id),
                             paste0('Data5.',odin_id),
                             paste0('Data6.',odin_id),
                             paste0('Data7.',odin_id),
                             paste0('Data8.',odin_id),
                             paste0('Data9.',odin_id),
                             paste0('Temperature.',odin_id),
                             paste0('RH.',odin_id),
                             'date')

# ODIN-SD-108 data ####
odin_id <- '108'
odin.sd.108.data <- read.delim(paste0(base_dir,"odin_sd_108.txt"))
odin.sd.108.data$date <- as.POSIXct(paste(odin.sd.108.data$Day,odin.sd.108.data$Time),tz='Etc/GMT+12')
odin.sd.108.data$Day<-NULL
odin.sd.108.data$Time<-NULL

# Date correction
Real_time <- "2016-07-12 10:29:00"

tdiff = (as.POSIXct(Real_time,format = "%Y-%m-%d %H:%M:%S") - odin.sd.108.data$date[1])
odin.sd.108.data$date <- odin.sd.108.data$date + tdiff

# Rename data fields to prepare for merging

names(odin.sd.108.data) <- c(paste0('FrameLength.',odin_id),
                             paste0('PM1.',odin_id),
                             paste0('PM2.5.',odin_id),
                             paste0('PM10.',odin_id),
                             paste0('Data4.',odin_id),
                             paste0('Data5.',odin_id),
                             paste0('Data6.',odin_id),
                             paste0('Data7.',odin_id),
                             paste0('Data8.',odin_id),
                             paste0('Data9.',odin_id),
                             paste0('Temperature.',odin_id),
                             paste0('RH.',odin_id),
                             'date')

# ODIN-SD-109 data ####
odin_id <- '109'
odin.sd.109.data <- read.delim(paste0(base_dir,"odin_sd_109.txt"))
odin.sd.109.data$date <- as.POSIXct(paste(odin.sd.109.data$Day,odin.sd.109.data$Time),tz='Etc/GMT+12')
odin.sd.109.data$Day<-NULL
odin.sd.109.data$Time<-NULL

# Date correction
Real_time <- "2016-07-12 10:35:00"

tdiff = (as.POSIXct(Real_time,format = "%Y-%m-%d %H:%M:%S") - odin.sd.109.data$date[1])
odin.sd.109.data$date <- odin.sd.109.data$date + tdiff

# Rename data fields to prepare for merging

names(odin.sd.109.data) <- c(paste0('FrameLength.',odin_id),
                             paste0('PM1.',odin_id),
                             paste0('PM2.5.',odin_id),
                             paste0('PM10.',odin_id),
                             paste0('Data4.',odin_id),
                             paste0('Data5.',odin_id),
                             paste0('Data6.',odin_id),
                             paste0('Data7.',odin_id),
                             paste0('Data8.',odin_id),
                             paste0('Data9.',odin_id),
                             paste0('Temperature.',odin_id),
                             paste0('RH.',odin_id),
                             'date')

# ODIN-SD-111 data ####
odin_id <- '111'
odin.sd.111.data <- read.delim(paste0(base_dir,"odin_sd_111.txt"))
odin.sd.111.data$date <- as.POSIXct(paste(odin.sd.111.data$Day,odin.sd.111.data$Time),tz='Etc/GMT+12')
odin.sd.111.data$Day<-NULL
odin.sd.111.data$Time<-NULL

# Date correction
Real_time <- "2016-07-12 10:56:00"

tdiff = (as.POSIXct(Real_time,format = "%Y-%m-%d %H:%M:%S") - odin.sd.111.data$date[1])
odin.sd.111.data$date <- odin.sd.111.data$date + tdiff

# Rename data fields to prepare for merging

names(odin.sd.111.data) <- c(paste0('FrameLength.',odin_id),
                             paste0('PM1.',odin_id),
                             paste0('PM2.5.',odin_id),
                             paste0('PM10.',odin_id),
                             paste0('Data4.',odin_id),
                             paste0('Data5.',odin_id),
                             paste0('Data6.',odin_id),
                             paste0('Data7.',odin_id),
                             paste0('Data8.',odin_id),
                             paste0('Data9.',odin_id),
                             paste0('Temperature.',odin_id),
                             paste0('RH.',odin_id),
                             'date')

# ODIN-SD-113 data ####
odin_id <- '113'
odin.sd.113.data <- read.delim(paste0(base_dir,"odin_sd_113.txt"))
odin.sd.113.data$date <- as.POSIXct(paste(odin.sd.113.data$Day,odin.sd.113.data$Time),tz='Etc/GMT+12')
odin.sd.113.data$Day<-NULL
odin.sd.113.data$Time<-NULL

# Date correction
Real_time <- "2016-07-12 11:13:00"

tdiff = (as.POSIXct(Real_time,format = "%Y-%m-%d %H:%M:%S") - odin.sd.113.data$date[1])
odin.sd.113.data$date <- odin.sd.113.data$date + tdiff

# Rename data fields to prepare for merging

names(odin.sd.113.data) <- c(paste0('FrameLength.',odin_id),
                             paste0('PM1.',odin_id),
                             paste0('PM2.5.',odin_id),
                             paste0('PM10.',odin_id),
                             paste0('Data4.',odin_id),
                             paste0('Data5.',odin_id),
                             paste0('Data6.',odin_id),
                             paste0('Data7.',odin_id),
                             paste0('Data8.',odin_id),
                             paste0('Data9.',odin_id),
                             paste0('Temperature.',odin_id),
                             paste0('RH.',odin_id),
                             'date')

# ODIN-SD-114 data ####
odin_id <- '114'
odin.sd.114.data <- read.delim(paste0(base_dir,"odin_sd_114.txt"))
odin.sd.114.data$date <- as.POSIXct(paste(odin.sd.114.data$Day,odin.sd.114.data$Time),tz='Etc/GMT+12')
odin.sd.114.data$Day<-NULL
odin.sd.114.data$Time<-NULL

# Date correction
Real_time <- "2016-07-12 11:21:00"

tdiff = (as.POSIXct(Real_time,format = "%Y-%m-%d %H:%M:%S") - odin.sd.114.data$date[1])
odin.sd.114.data$date <- odin.sd.114.data$date + tdiff

# Rename data fields to prepare for merging

names(odin.sd.114.data) <- c(paste0('FrameLength.',odin_id),
                             paste0('PM1.',odin_id),
                             paste0('PM2.5.',odin_id),
                             paste0('PM10.',odin_id),
                             paste0('Data4.',odin_id),
                             paste0('Data5.',odin_id),
                             paste0('Data6.',odin_id),
                             paste0('Data7.',odin_id),
                             paste0('Data8.',odin_id),
                             paste0('Data9.',odin_id),
                             paste0('Temperature.',odin_id),
                             paste0('RH.',odin_id),
                             'date')

# ODIN-SD-115 data ####
odin_id <- '115'
odin.sd.115.data <- read.delim(paste0(base_dir,"odin_sd_115.txt"))
odin.sd.115.data$date <- as.POSIXct(paste(odin.sd.115.data$Day,odin.sd.115.data$Time),tz='Etc/GMT+12')
odin.sd.115.data$Day<-NULL
odin.sd.115.data$Time<-NULL

# Date correction
Real_time <- "2016-07-12 11:32:00"

tdiff = (as.POSIXct(Real_time,format = "%Y-%m-%d %H:%M:%S") - odin.sd.115.data$date[1])
odin.sd.115.data$date <- odin.sd.115.data$date + tdiff

# Rename data fields to prepare for merging

names(odin.sd.115.data) <- c(paste0('FrameLength.',odin_id),
                             paste0('PM1.',odin_id),
                             paste0('PM2.5.',odin_id),
                             paste0('PM10.',odin_id),
                             paste0('Data4.',odin_id),
                             paste0('Data5.',odin_id),
                             paste0('Data6.',odin_id),
                             paste0('Data7.',odin_id),
                             paste0('Data8.',odin_id),
                             paste0('Data9.',odin_id),
                             paste0('Temperature.',odin_id),
                             paste0('RH.',odin_id),
                             'date')

# Merging the data ####
merged.data <- merge(odin.sd.102.data,odin.sd.103.data,by = 'date',all = TRUE)
merged.data <- merge(merged.data,odin.sd.105.data,by = 'date',all = TRUE)
merged.data <- merge(merged.data,odin.sd.106.data,by = 'date',all = TRUE)
merged.data <- merge(merged.data,odin.sd.107.data,by = 'date',all = TRUE)
merged.data <- merge(merged.data,odin.sd.108.data,by = 'date',all = TRUE)
merged.data <- merge(merged.data,odin.sd.109.data,by = 'date',all = TRUE)
merged.data <- merge(merged.data,odin.sd.111.data,by = 'date',all = TRUE)
merged.data <- merge(merged.data,odin.sd.113.data,by = 'date',all = TRUE)
merged.data <- merge(merged.data,odin.sd.114.data,by = 'date',all = TRUE)
merged.data <- merge(merged.data,odin.sd.115.data,by = 'date',all = TRUE)
merged.data <- merge(merged.data,ecan_data,by = 'date',all = TRUE)
# Bring everything to 1 hour
merged.data.1hr <- timeAverage(merged.data,avg.time = '1 hour')
# Creating aux series for range of ODIN readings
merged.data.1hr$Temperature.min <- apply(merged.data.1hr[,c('Temperature.103',
                                                    'Temperature.105',
                                                    'Temperature.106',
                                                    'Temperature.107',
                                                    'Temperature.108',
                                                    'Temperature.109',
                                                    'Temperature.111',
                                                    'Temperature.113',
                                                    'Temperature.114',
                                                    'Temperature.115')],1,min, na.rm=TRUE)
merged.data.1hr$Temperature.max <- apply(merged.data.1hr[,c('Temperature.103',
                                                    'Temperature.105',
                                                    'Temperature.106',
                                                    'Temperature.107',
                                                    'Temperature.108',
                                                    'Temperature.109',
                                                    'Temperature.111',
                                                    'Temperature.113',
                                                    'Temperature.114',
                                                    'Temperature.115')],1,max, na.rm=TRUE)

merged.data.1hr$RH.min <- apply(merged.data.1hr[,c('RH.103',
                                                    'RH.105',
                                                    'RH.106',
                                                    'RH.107',
                                                    'RH.108',
                                                    'RH.109',
                                                    'RH.111',
                                                    'RH.113',
                                                    'RH.114',
                                                    'RH.115')],1,min, na.rm=TRUE)
merged.data.1hr$RH.max <- apply(merged.data.1hr[,c('RH.103',
                                                    'RH.105',
                                                    'RH.106',
                                                    'RH.107',
                                                    'RH.108',
                                                    'RH.109',
                                                    'RH.111',
                                                    'RH.113',
                                                    'RH.114',
                                                    'RH.115')],1,max, na.rm=TRUE)

merged.data.1hr$PM1.min <- apply(merged.data.1hr[,c('PM1.103',
                                            'PM1.105',
                                            'PM1.106',
                                            'PM1.107',
                                            'PM1.108',
                                            'PM1.109',
                                            'PM1.111',
                                            'PM1.113',
                                            'PM1.114',
                                            'PM1.115')],1,min,na.rm=TRUE)
merged.data.1hr$PM1.max <- apply(merged.data.1hr[,c('PM1.103',
                                            'PM1.105',
                                            'PM1.106',
                                            'PM1.107',
                                            'PM1.108',
                                            'PM1.109',
                                            'PM1.111',
                                            'PM1.113',
                                            'PM1.114',
                                            'PM1.115')],1,max,na.rm=TRUE)

merged.data.1hr$PM2.5.min <- apply(merged.data.1hr[,c('PM2.5.103',
                                              'PM2.5.105',
                                              'PM2.5.106',
                                              'PM2.5.107',
                                              'PM2.5.108',
                                              'PM2.5.109',
                                              'PM2.5.111',
                                              'PM2.5.113',
                                              'PM2.5.114',
                                              'PM2.5.115')],1,min,na.rm=TRUE)
merged.data.1hr$PM2.5.max <- apply(merged.data.1hr[,c('PM2.5.103',
                                              'PM2.5.105',
                                              'PM2.5.106',
                                              'PM2.5.107',
                                              'PM2.5.108',
                                              'PM2.5.109',
                                              'PM2.5.111',
                                              'PM2.5.113',
                                              'PM2.5.114',
                                              'PM2.5.115')],1,max,na.rm=TRUE)

merged.data.1hr$PM10.min <- apply(merged.data.1hr[,c('PM10.103',
                                             'PM10.105',
                                             'PM10.106',
                                             'PM10.107',
                                             'PM10.108',
                                             'PM10.109',
                                             'PM10.111',
                                             'PM10.113',
                                             'PM10.114',
                                             'PM10.115')],1,min,na.rm=TRUE)
merged.data.1hr$PM10.max <- apply(merged.data.1hr[,c('PM10.103',
                                             'PM10.105',
                                             'PM10.106',
                                             'PM10.107',
                                             'PM10.108',
                                             'PM10.109',
                                             'PM10.111',
                                             'PM10.113',
                                             'PM10.114',
                                             'PM10.115')],1,max,na.rm=TRUE)

#' # Time Series Plots

# Plotting ####
#+ fig.width=16, fig.height=10
avgtime = '1 hour'
timePlot(merged.data,pollutant = c('Temperature.103',
                                   'Temperature.105',
                                   'Temperature.106',
                                   'Temperature.107',
                                   'Temperature.108',
                                   'Temperature.109',
                                   'Temperature.111',
                                   'Temperature.113',
                                   'Temperature.114',
                                   'Temperature.115',
                                   'Temperature.2m'),
         avg.time = avgtime,
         group = TRUE,
         xlab = 'Local Time')
timePlot(merged.data.1hr,pollutant = c('Temperature.2m','Temperature.max','Temperature.min'),
         avg.time = avgtime,
         group = TRUE,
         xlab = 'Local Time')

timePlot(merged.data,pollutant = c('RH.103',
                                   'RH.105',
                                   'RH.106',
                                   'RH.107',
                                   'RH.108',
                                   'RH.109',
                                   'RH.111',
                                   'RH.113',
                                   'RH.114',
                                   'RH.115'),
         avg.time = avgtime,
         group = TRUE,
         xlab = 'Local Time')
timePlot(merged.data.1hr,pollutant = c('RH.max',
                                   'RH.min'),
         avg.time = avgtime,
         group = TRUE,
         xlab = 'Local Time')


timePlot(merged.data,pollutant = c('PM1.103',
                                   'PM1.105',
                                   'PM1.106',
                                   'PM1.107',
                                   'PM1.108',
                                   'PM1.109',
                                   'PM1.111',
                                   'PM1.113',
                                   'PM1.114',
                                   'PM1.115'),
         avg.time = avgtime,
         group = TRUE,
         xlab = 'Local Time')
timePlot(merged.data.1hr,pollutant = c('PM1.max',
                                   'PM1.min'),
         avg.time = avgtime,
         group = TRUE,
         xlab = 'Local Time')

timePlot(merged.data,pollutant = c('PM2.5.103',
                                   'PM2.5.105',
                                   'PM2.5.106',
                                   'PM2.5.107',
                                   'PM2.5.108',
                                   'PM2.5.109',
                                   'PM2.5.111',
                                   'PM2.5.113',
                                   'PM2.5.114',
                                   'PM2.5.115',
                                   'PM2.5.FDMS'),
         avg.time = avgtime,
         group = TRUE,
         xlab = 'Local Time')
timePlot(merged.data.1hr,pollutant = c('PM2.5.FDMS','PM2.5.max','PM2.5.min'),
         avg.time = avgtime,
         group = TRUE,
         xlab = 'Local Time')

timePlot(merged.data,pollutant = c('PM10.103',
                                   'PM10.105',
                                   'PM10.106',
                                   'PM10.107',
                                   'PM10.108',
                                   'PM10.109',
                                   'PM10.111',
                                   'PM10.113',
                                   'PM10.114',
                                   'PM10.115',
                                   'PM10.FDMS'),
         avg.time = avgtime,
         group = TRUE,
         xlab = 'Local Time')
timePlot(merged.data.1hr,pollutant = c('PM10.FDMS','PM10.max','PM10.min'),
         avg.time = avgtime,
         group = TRUE,
         xlab = 'Local Time')


#' # Scatter plots against PM2.5 FDMS 1 hour averages
#+ fig.width=16, fig.height=16
scatterPlot(merged.data.1hr,x='PM2.5.103',y='PM2.5.FDMS',linear = TRUE)
scatterPlot(merged.data.1hr,x='PM2.5.105',y='PM2.5.FDMS',linear = TRUE)
scatterPlot(merged.data.1hr,x='PM2.5.107',y='PM2.5.FDMS',linear = TRUE)
scatterPlot(merged.data.1hr,x='PM2.5.108',y='PM2.5.FDMS',linear = TRUE)
scatterPlot(merged.data.1hr,x='PM2.5.109',y='PM2.5.FDMS',linear = TRUE)
scatterPlot(merged.data.1hr,x='PM2.5.111',y='PM2.5.FDMS',linear = TRUE)
scatterPlot(merged.data.1hr,x='PM2.5.113',y='PM2.5.FDMS',linear = TRUE)
scatterPlot(merged.data.1hr,x='PM2.5.114',y='PM2.5.FDMS',linear = TRUE)
scatterPlot(merged.data.1hr,x='PM2.5.115',y='PM2.5.FDMS',linear = TRUE)

options(warn = oldw)
