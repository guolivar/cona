#' ---
#' title: "ODIN CONA"
#' author: "Gustavo Olivares"
#' output: html_document
#' ---
# Load libraries
require('openair')
require('reshape2')
require('ggplot2')
# load_odin data

## ODIN_02.
odin_02 <- read.table("/home/gustavo/data/CONA/ODIN/deployment/odin_02.data",
                      header=T, quote="")

odin_02$date=as.POSIXct(paste(odin_02$Date,odin_02$Time),tz='NZST')
odin_02$Time<-NULL
odin_02$Date<-NULL
odin_02$Batt<-5*odin_02$Batt/1024
timePlot(odin_02,pollutant = c('Dust','Temperature'))


## ODIN_03
odin_03 <- read.table("/home/gustavo/data/CONA/ODIN/deployment/odin_03.data",
                      header=T, quote="")

odin_03$date=as.POSIXct(paste(odin_03$Date,odin_03$Time),tz='NZST')
odin_03$Time<-NULL
odin_03$Date<-NULL
odin_03$Batt<-5*odin_03$Batt/1024
timePlot(odin_03,pollutant = c('Dust','Temperature'))

## ODIN_04
odin_04 <- read.table("/home/gustavo/data/CONA/ODIN/deployment/odin_04.data",
                      header=T, quote="")

odin_04$date=as.POSIXct(paste(odin_04$Date,odin_04$Time),tz='NZST')
odin_04$Time<-NULL
odin_04$Date<-NULL
odin_04$Batt<-5*odin_04$Batt/1024
timePlot(odin_04,pollutant = c('Dust','Temperature'))

## ODIN_05
odin_05 <- read.table("/home/gustavo/data/CONA/ODIN/deployment/odin_05.data",
                      header=T, quote="")

odin_05$date=as.POSIXct(paste(odin_05$Date,odin_05$Time),tz='NZST')
odin_05$Time<-NULL
odin_05$Date<-NULL
odin_05$Batt<-5*odin_05$Batt/1024
timePlot(odin_05,pollutant = c('Dust','Temperature'))

## ODIN_06
odin_06 <- read.table("/home/gustavo/data/CONA/ODIN/deployment/odin_06.data",
                      header=T, quote="")
#force GMT as the time zone to avoid openair issues with daylight saving switches
#The actual time zone is 'NZST'
odin_06$date=as.POSIXct(paste(odin_06$Date,odin_06$Time),tz='NZST')
odin_06$Time<-NULL
odin_06$Date<-NULL
odin_06$Batt<-5*odin_06$Batt/1024
timePlot(odin_06,pollutant = c('Dust','Temperature'))

## ODIN_07.
odin_07 <- read.table("/home/gustavo/data/CONA/ODIN/deployment/odin_07.data",
                      header=T, quote="")

odin_07$date=as.POSIXct(paste(odin_07$Date,odin_07$Time),tz='NZST')
odin_07$Time<-NULL
odin_07$Date<-NULL
odin_07$Batt<-5*odin_07$Batt/1024
timePlot(odin_07,pollutant = c('Dust','Temperature'))

# Load ECan data

download.file(url = "http://data.ecan.govt.nz/data/29/Air/Air%20quality%20data%20for%20a%20monitored%20site%20(Hourly)/CSV?SiteId=5&StartDate=14%2F08%2F2015&EndDate=29%2F09%2F2015",destfile = "ecan_data.csv",method = "curl")
system("sed -i 's/a.m./AM/g' ecan_data.csv")
system("sed -i 's/p.m./PM/g' ecan_data.csv")
ecan_data_raw <- read.csv("ecan_data.csv",stringsAsFactors=FALSE)
ecan_data_raw$date<-as.POSIXct(ecan_data_raw$DateTime,format = "%d/%m/%Y %I:%M:%S %p",tz='NZST')
ecan_data<-as.data.frame(ecan_data_raw[,c('date','PM10.FDMS','Temperature..2m')])
names(ecan_data)<-c('date','PM10.FDMS','Temperature..1m')

## Merging the data
# ECan's data was provided as 10 minute values while ODIN reports every 1 minute so before merging the data, the timebase must be homogenized

names(odin_02)<-c('Dust.02','RH.02','Temperature.02','Batt.02','date')
names(odin_03)<-c('Dust.03','RH.03','Temperature.03','Batt.03','date')
names(odin_04)<-c('Dust.04','RH.04','Temperature.04','Batt.04','date')
names(odin_05)<-c('Dust.05','RH.05','Temperature.05','Batt.05','date')
names(odin_06)<-c('Dust.06','RH.06','Temperature.06','Batt.06','date')
names(odin_07)<-c('Dust.07','RH.07','Temperature.07','Batt.07','date')

odin <- merge(odin_02,odin_03,by = 'date', all = TRUE)
odin <- merge(odin,odin_04,by='date',all=TRUE)
odin <- merge(odin,odin_05,by='date',all=TRUE)
odin <- merge(odin,odin_06,by='date',all=TRUE)
odin <- merge(odin,odin_07,by='date',all=TRUE)
odin <- selectByDate(odin,start = '2015-08-15',end = '2015-09-10')
odin.10min<-timeAverage(odin,avg.time='10 min')
all_merged.1min<-merge(odin,ecan_data,by='date',all=TRUE)
all_merged.10min<-timeAverage(all_merged.1min,avg.time = '10 min')
timePlot(all_merged.10min,pollutant = c('Temperature..1m',
                                        'Temperature.02',
                                        'Temperature.03',
                                        'Temperature.04',
                                        'Temperature.05',
                                        'Temperature.06',
                                        'Temperature.07'))
## Time sync

lag_test=ccf(all_merged.10min$Temperature.05,
             all_merged.10min$Temperature..1m,
             na.action=na.pass,
             lag.max=100,
             type='covariance',
             ylab='Correlation',
             main='Temperature correlation as function of clock lag')
odin_lag=lag_test$lag[which.max(lag_test$acf)]

# correct timing
odin$date=odin$date-odin_lag*10*60
odin.10min<-timeAverage(odin,avg.time='10 min')
all_merged.10min<-merge(odin.10min,ecan_data,by='date',all=TRUE)
lag_test=ccf(all_merged.10min$Temperature.05,
             all_merged.10min$Temperature..1m,
             na.action=na.pass,
             lag.max=100,
             type='covariance',
             ylab='Correlation',
             main='Temperature correlation as function of clock lag')

## Remove drift from ODIN raw data

# Estimate the baseline from a simple linear regression

all_merged.10min$ODIN_drift.02<-predict(lm(all_merged.10min$Dust.02~seq(all_merged.10min$Dust.02)),newdata = all_merged.10min)
all_merged.10min$ODIN_drift.03<-predict(lm(all_merged.10min$Dust.03~seq(all_merged.10min$Dust.03)),newdata = all_merged.10min)
all_merged.10min$ODIN_drift.04<-predict(lm(all_merged.10min$Dust.04~seq(all_merged.10min$Dust.04)),newdata = all_merged.10min)
all_merged.10min$ODIN_drift.05<-predict(lm(all_merged.10min$Dust.05~seq(all_merged.10min$Dust.05)),newdata = all_merged.10min)
all_merged.10min$ODIN_drift.06<-predict(lm(all_merged.10min$Dust.06~seq(all_merged.10min$Dust.06)),newdata = all_merged.10min)
all_merged.10min$ODIN_drift.07<-predict(lm(all_merged.10min$Dust.07~seq(all_merged.10min$Dust.07)),newdata = all_merged.10min)

# Remove the baseline drift from the raw ODIN data
all_merged.10min$Dust.02.raw <- all_merged.10min$Dust.02
all_merged.10min$Dust.02.detrend<-all_merged.10min$Dust.02.raw - all_merged.10min$ODIN_drift.02

all_merged.10min$Dust.03.raw <- all_merged.10min$Dust.03
all_merged.10min$Dust.03.detrend<-all_merged.10min$Dust.03.raw - all_merged.10min$ODIN_drift.03

all_merged.10min$Dust.04.raw <- all_merged.10min$Dust.04
all_merged.10min$Dust.04.detrend<-all_merged.10min$Dust.04.raw - all_merged.10min$ODIN_drift.04

all_merged.10min$Dust.05.raw <- all_merged.10min$Dust.05
all_merged.10min$Dust.05.detrend<-all_merged.10min$Dust.05.raw - all_merged.10min$ODIN_drift.05

all_merged.10min$Dust.06.raw <- all_merged.10min$Dust.06
all_merged.10min$Dust.06.detrend<-all_merged.10min$Dust.06.raw - all_merged.10min$ODIN_drift.06

all_merged.10min$Dust.07.raw <- all_merged.10min$Dust.07
all_merged.10min$Dust.07.detrend<-all_merged.10min$Dust.07.raw - all_merged.10min$ODIN_drift.07

## Testing not correcting drift
all_merged.10min$Dust.02.detrend<-all_merged.10min$Dust.02.raw
all_merged.10min$Dust.03.detrend<-all_merged.10min$Dust.03.raw
all_merged.10min$Dust.04.detrend<-all_merged.10min$Dust.04.raw
all_merged.10min$Dust.05.detrend<-all_merged.10min$Dust.05.raw
all_merged.10min$Dust.06.detrend<-all_merged.10min$Dust.06.raw
# all_merged.10min$Dust.07.detrend<-all_merged.10min$Dust.07.raw

## Estimate temperature for ODIN 02 as the average of all the other temperatures (which are very well correlated)
no_TRH_sensor.02<-(all_merged.10min$RH.02==0)|(is.na(all_merged.10min$RH.02))
all_merged.10min$Temperature.02[no_TRH_sensor.02] <- NA
  # with(all_merged.10min,(Temperature.04[no_TRH_sensor.02]+Temperature.05[no_TRH_sensor.02]+Temperature.06[no_TRH_sensor.02])/3)

## Calculate the temperature interference
all_merged.10min$Temperature.02.bin<-cut(all_merged.10min$Temperature.02,breaks = c(0,5,10,15,20,25),labels = c('2.5','7.5','12.5','17.5','22.5'))
all_merged.10min$Temperature.03.bin<-cut(all_merged.10min$Temperature.03,breaks = c(0,5,10,15,20,25),labels = c('2.5','7.5','12.5','17.5','22.5'))
all_merged.10min$Temperature.04.bin<-cut(all_merged.10min$Temperature.04,breaks = c(0,5,10,15,20,25),labels = c('2.5','7.5','12.5','17.5','22.5'))
all_merged.10min$Temperature.05.bin<-cut(all_merged.10min$Temperature.05,breaks = c(0,5,10,15,20,25),labels = c('2.5','7.5','12.5','17.5','22.5'))
all_merged.10min$Temperature.06.bin<-cut(all_merged.10min$Temperature.06,breaks = c(0,5,10,15,20,25),labels = c('2.5','7.5','12.5','17.5','22.5'))
all_merged.10min$Temperature.07.bin<-cut(all_merged.10min$Temperature.07,breaks = c(0,5,10,15,20,25),labels = c('2.5','7.5','12.5','17.5','22.5'))
Temp <- c(2.5,7.5,12.5,17.5,22.5)

Dust.02<-tapply(all_merged.10min$Dust.02.detrend,all_merged.10min$Temperature.02.bin,quantile,0.25)
Dust.03<-tapply(all_merged.10min$Dust.03.detrend,all_merged.10min$Temperature.03.bin,quantile,0.25)
Dust.04<-tapply(all_merged.10min$Dust.04.detrend,all_merged.10min$Temperature.04.bin,quantile,0.25)
Dust.05<-tapply(all_merged.10min$Dust.05.detrend,all_merged.10min$Temperature.05.bin,quantile,0.25)
Dust.06<-tapply(all_merged.10min$Dust.06.detrend,all_merged.10min$Temperature.06.bin,quantile,0.25)
Dust.07<-tapply(all_merged.10min$Dust.07.detrend,all_merged.10min$Temperature.07.bin,quantile,0.25)

TC_Dust.02 <- data.frame(Dust.02.detrend = Dust.02,Temperature.02 = Temp)
TC_Dust.03 <- data.frame(Dust.03.detrend = Dust.03,Temperature.03 = Temp)
TC_Dust.04 <- data.frame(Dust.04.detrend = Dust.04,Temperature.04 = Temp)
TC_Dust.05 <- data.frame(Dust.05.detrend = Dust.05,Temperature.05 = Temp)
TC_Dust.06 <- data.frame(Dust.06.detrend = Dust.06,Temperature.06 = Temp)
TC_Dust.07 <- data.frame(Dust.07.detrend = Dust.07,Temperature.07 = Temp)

# Now we calculate the linear regression for the minimum dust response in each temperature bin and subtract it from the detrended data

summary(odin.02_T<-lm(data = TC_Dust.02,Dust.02.detrend~Temperature.02))
summary(odin.03_T<-lm(data = TC_Dust.03,Dust.03.detrend~Temperature.03))
summary(odin.04_T<-lm(data = TC_Dust.04,Dust.04.detrend~Temperature.04))
summary(odin.05_T<-lm(data = TC_Dust.05,Dust.05.detrend~Temperature.05))
summary(odin.06_T<-lm(data = TC_Dust.06,Dust.06.detrend~Temperature.06))
summary(odin.07_T<-lm(data = TC_Dust.07,Dust.07.detrend~Temperature.07))

all_merged.10min$Dust.02.corr <- all_merged.10min$Dust.02.detrend - predict(odin.02_T,newdata = all_merged.10min)
all_merged.10min$Dust.03.corr <- all_merged.10min$Dust.03.detrend - predict(odin.03_T,newdata = all_merged.10min)
all_merged.10min$Dust.04.corr <- all_merged.10min$Dust.04.detrend - predict(odin.04_T,newdata = all_merged.10min)
all_merged.10min$Dust.05.corr <- all_merged.10min$Dust.05.detrend - predict(odin.05_T,newdata = all_merged.10min)
all_merged.10min$Dust.06.corr <- all_merged.10min$Dust.06.detrend - predict(odin.06_T,newdata = all_merged.10min)
all_merged.10min$Dust.07.corr <- all_merged.10min$Dust.07.detrend - predict(odin.07_T,newdata = all_merged.10min)


timePlot(all_merged.10min,pollutant = c('PM10.FDMS',
                                      'Dust.02.corr',
                                      'Dust.03.corr',
                                      'Dust.04.corr',
                                      'Dust.05.corr',
                                      'Dust.06.corr',
                                      'Dust.07.corr'
                                      )
         ,group = FALSE
         ,main = '10 min')

timebase = '1 hour'
timePlot(all_merged.10min,pollutant = c('PM10.FDMS',
                                      'Dust.02.corr',
                                      # 'Dust.03.corr',
                                      'Dust.04.corr',
                                      'Dust.05.corr',
                                      'Dust.06.corr',
                                      'Dust.07.corr'
                                      )
         ,group = TRUE
         ,normalise = 'mean'
         ,avg.time = timebase
         ,main = timebase)

TV_norm <- timeVariation(all_merged.10min,pollutant = c('PM10.FDMS'
                                                      ,'Dust.02.corr'
                                                      ,'Dust.03.corr'
                                                      ,'Dust.04.corr'
                                                      ,'Dust.05.corr'
                                                      ,'Dust.06.corr'
                                                      ,'Dust.07.corr'
                                                      )
                         ,normalise = TRUE)

ggplot(TV_norm$data$hour)+
  geom_ribbon(aes(x=hour,ymin=Lower,ymax=Upper),fill='red', alpha = 0.3)+
  geom_line(aes(x=hour,y=Mean))+
  facet_grid(variable~.)+
  ggtitle('Movement')+
  xlab('NZST hour')+
  ylab('Corrected Dust [mV]')

timebase = '1 hour'
start_date = as.POSIXct('2015-08-15')
for (xday in (0:25)){
  current_day = format(start_date + xday*24*3600,'%Y-%m-%d')
  plot_data <- selectByDate(all_merged.10min,start = current_day, end = current_day)
  png(paste0('./tseries_',current_day,'.png'),width = 1024, height = 1024)
  timePlot(plot_data,pollutant = c('PM10.FDMS'
                                   ,'Dust.02.corr'
                                   ,'Dust.03.corr'
                                   ,'Dust.04.corr'
                                   ,'Dust.05.corr'
                                   ,'Dust.06.corr'
                                   ,'Dust.07.corr'
                                   )
           ,group = FALSE
           #,normalise = 'mean'
           ,avg.time = timebase
           ,main = paste(current_day,timebase)
           )
  dev.off()
}


timePlot(all_merged.10min,pollutant = c('Temperature.07','Dust.07.raw','Dust.07.detrend','Dust.07.corr'))




timePlot(all_merged.10min,pollutant = c('Temperature..1m'
                                      ,'Temperature.02'
                                      ,'Temperature.03'
                                      ,'Temperature.04'
                                      ,'Temperature.05'
                                      ,'Temperature.06'
                                      ,'Temperature.07')
,group = TRUE
,avg.time = '1 hour'
,main = '1 hour'
)


timePlot(all_merged.10min,pollutant = c('PM10.FDMS'
                                        ,'Dust.02.corr'
                                        ,'Dust.03.corr'
                                        ,'Dust.04.corr'
                                        ,'Dust.05.corr'
                                        ,'Dust.06.corr'
                                        ,'Dust.07.corr')
         ,group = TRUE
         ,normalise = 'mean'
         ,avg.time = '1 day'
         ,main = '1 day'
)


ggplot(data = all_merged.10min,aes(x = date)) +
  geom_line(aes(y = Dust.07.raw,colour = 'Raw')) +
  geom_line(aes(y = Dust.07, colour = 'Raw2')) +
  geom_line(aes(y = Dust.07.detrend, colour = 'Detrend')) +
  ylab('Dust [mV]')
  

