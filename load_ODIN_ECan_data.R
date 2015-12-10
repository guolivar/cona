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
timePlot(odin_02,pollutant = c('Dust','Temperature'), main = 'ODIN 02')


## ODIN_03
odin_03 <- read.table("/home/gustavo/data/CONA/ODIN/deployment/odin_03.data",
                      header=T, quote="")

odin_03$date=as.POSIXct(paste(odin_03$Date,odin_03$Time),tz='NZST')
odin_03$Time<-NULL
odin_03$Date<-NULL
odin_03$Batt<-5*odin_03$Batt/1024
timePlot(odin_03,pollutant = c('Dust','Temperature'), main = 'ODIN 03')

## ODIN_04
odin_04 <- read.table("/home/gustavo/data/CONA/ODIN/deployment/odin_04.data",
                      header=T, quote="")

odin_04$date=as.POSIXct(paste(odin_04$Date,odin_04$Time),tz='NZST')
odin_04$Time<-NULL
odin_04$Date<-NULL
odin_04$Batt<-5*odin_04$Batt/1024
timePlot(odin_04,pollutant = c('Dust','Temperature'), main = 'ODIN 04')

## ODIN_05
odin_05 <- read.table("/home/gustavo/data/CONA/ODIN/deployment/odin_05.data",
                      header=T, quote="")

odin_05$date=as.POSIXct(paste(odin_05$Date,odin_05$Time),tz='NZST')
odin_05$Time<-NULL
odin_05$Date<-NULL
odin_05$Batt<-5*odin_05$Batt/1024
timePlot(odin_05,pollutant = c('Dust','Temperature'), main = 'ODIN 05')

## ODIN_06
odin_06 <- read.table("/home/gustavo/data/CONA/ODIN/deployment/odin_06.data",
                      header=T, quote="")
#force GMT as the time zone to avoid openair issues with daylight saving switches
#The actual time zone is 'NZST'
odin_06$date=as.POSIXct(paste(odin_06$Date,odin_06$Time),tz='NZST')
odin_06$Time<-NULL
odin_06$Date<-NULL
odin_06$Batt<-5*odin_06$Batt/1024
timePlot(odin_06,pollutant = c('Dust','Temperature'), main = 'ODIN 06')

## ODIN_07.
odin_07 <- read.table("/home/gustavo/data/CONA/ODIN/deployment/odin_07.data",
                      header=T, quote="")

odin_07$date=as.POSIXct(paste(odin_07$Date,odin_07$Time),tz='NZST')
odin_07$Time<-NULL
odin_07$Date<-NULL
odin_07$Batt<-5*odin_07$Batt/1024
timePlot(odin_07,pollutant = c('Dust','Temperature'), main = 'ODIN 07')

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
odin_raw <- odin
#######################
