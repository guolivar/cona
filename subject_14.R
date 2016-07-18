# Subject summaries
library('openair')
library('ggplot2')

# ECan
download.file(url = "http://data.ecan.govt.nz/data/29/Air/Air%20quality%20data%20for%20a%20monitored%20site%20(Hourly)/CSV?SiteId=5&StartDate=01%2F09%2F2015&EndDate=30%2F09%2F2015",destfile = "ecan_data.csv",method = "curl")
system("sed -i 's/a.m./AM/g' ecan_data.csv")
system("sed -i 's/p.m./PM/g' ecan_data.csv")
ecan_data_raw <- read.csv("ecan_data.csv",stringsAsFactors=FALSE)
ecan_data_raw$date<-as.POSIXct(ecan_data_raw$DateTime,format = "%d/%m/%Y %I:%M:%S %p",tz='GMT')
ecan_data<-as.data.frame(ecan_data_raw[,c('date','PM10..ug.m3.','Temperature.2m..DegC.','Temperature.6m..DegC.','Wind.speed..m.s.','Wind.direction..Deg.')])
names(ecan_data)<- c('date','PM10.FDMS','Temperature.2m','Temperature.6m','ws','wd')

# iButton
# DD00000026F32041
iB_DD00000026F32041 <- read.csv("~/data/CONA/iButton/DD00000026F32041_data.txt")
iB_DD00000026F32041$date <- as.POSIXct(iB_DD00000026F32041$Date.Time,format = '%d/%m/%y %I:%M:%S %p',tz = 'NZST')
iB_DD00000026F32041$Date.Time <- NULL
iB_DD00000026F32041$Unit <- NULL
names(iB_DD00000026F32041) <- c('Temperature.DD','date')

# BRANZ
# HUV094
HUV094 <- read.csv("~/data/CONA/BRANZ/HUV094.csv")
HUV094$date <- as.POSIXct(HUV094$Timestamp,format = '%d/%m/%Y %H:%M',tz = 'NZST')
HUV094$Timestamp <- NULL
names(HUV094) <- c('CH1.094','Temp.094','date')

#PACMAN
unitID<-'pacman_C2'
pacman.data <- read.delim(paste0("/home/gustavo/data/CONA/PACMAN/campaign/",unitID,".txt"))
names(pacman.data)<-c('Count','Year','Month','Day','Hour','Minute','Second',
                      'Distance','Temperature_IN_C','Temperature_mV','PM_mV','CO2_mV','CO_mV','Movement','COstatus')
pacman.data$Temperature_mV <- (pacman.data$Temperature_mV/100)-273.15
pacman.data$date<-ISOdatetime(year=pacman.data$Year,
                              month=pacman.data$Month,
                              day=pacman.data$Day,
                              hour=pacman.data$Hour,
                              min=pacman.data$Minute,
                              sec=pacman.data$Second,
                              tz="NZST")
#CO label
nrecs=length(pacman.data$COstatus)
pacman.data$CO_ok <- FALSE
pacman.data$CO_ok[1:nrecs-1] <- (pacman.data$COstatus[-1]==1)&(pacman.data$COstatus[1:nrecs-1]==2)
pacman.data$CO_raw <- pacman.data$CO_mV
pacman.data$CO_mV[!pacman.data$CO_ok] <- NA

# Inverting CO2
pacman.data$CO2_mV <- -1 * pacman.data$CO2_mV

# PM data correction
# BASELINE
pacman.data$PM_mV_drift<-predict(lm(pacman.data$PM_mV~seq(pacman.data$PM_mV)),newdata = pacman.data)
# Remove the baseline drift from the raw data
pacman.data$PM_mV.raw <- pacman.data$PM_mV
pacman.data$PM_mV.detrend<-pacman.data$PM_mV.raw - pacman.data$PM_mV_drift

# Temperature
## Calculate the temperature interference
scatterPlot(pacman.data,x='Temperature_mV','PM_mV',
            main = 'Subject 14\nPACMAN',
            xlab = 'Temperature [C]',
            ylab = 'RAW PM [mV]',
            avg.time = '1 min')
pacman.data$T.bin<-cut(pacman.data$Temperature_mV,breaks = c(16,20,24,28,32),labels = c('18','22','26','30'))
Temp <- c(18,22,26,30)
Dust<-tapply(pacman.data$PM_mV.detrend,pacman.data$T.bin,quantile,0.25)
TC_Dust <- data.frame(PM_mV.detrend = Dust,Temperature_mV = Temp)
summary(odin.02_T<-lm(data = TC_Dust,PM_mV.detrend~Temperature_mV))
pacman.data$Dust.corr.in <- pacman.data$PM_mV.detrend - predict(odin.02_T,newdata = pacman.data)

# ODIN
odin <- read.table("/home/gustavo/data/CONA/ODIN/deployment/odin_07.data",
                   header=T, quote="")

odin$date=as.POSIXct(paste(odin$Date,odin$Time),tz='NZST')
odin$Time<-NULL
odin$Date<-NULL
odin$Batt<-5*odin$Batt/1024

odin$Dust_drift<-predict(lm(odin$Dust~seq(odin$Dust)),newdata = odin)
odin$Dust.raw <- odin$Dust
odin$Dust.detrend<-odin$Dust.raw - odin$Dust_drift
# No drift correction test
odin$Dust.detrend<-odin$Dust.raw
#Temperature correction
odin$Temperature.bin<-cut(odin$Temp,breaks = c(0,5,10,15,20,25),labels = c('2.5','7.5','12.5','17.5','22.5'))
Temp <- c(2.5,7.5,12.5,17.5,22.5)
Dust<-tapply(odin$Dust.detrend,odin$Temperature.bin,quantile,0.25)
TC_Dust <- data.frame(Dust.detrend = Dust,Temp = Temp)
summary(odin_T<-lm(data = TC_Dust,Dust.detrend~Temp))
odin$Dust.corr.out <- odin$Dust.detrend - predict(odin_T, newdata = odin)



# Merging the data

subject.data <- merge(iB_DD00000026F32041,HUV094,by = 'date', all = TRUE)
subject.data <- merge(subject.data,pacman.data, by = 'date', all = TRUE)
subject.data <- merge(subject.data,ecan_data, by = 'date', all = TRUE)
subject.data <- merge(subject.data,odin, by = 'date', all = TRUE)
subject.data.10min <- timeAverage(subject.data,avg.time = '10 min')

# Subject 14

mindate <- format(max(min(iB_DD00000026F32041$date),min(HUV094$date),min(ecan_data$date),min(pacman.data$date)),format = '%Y-%m-%d')
maxdate <- format(min(max(iB_DD00000026F32041$date),max(HUV094$date),max(ecan_data$date),max(pacman.data$date)),format = '%Y-%m-%d')
plot_data <- selectByDate(subject.data.10min, start = mindate, end = maxdate)
timePlot(plot_data,pollutant = c('Temperature.DD',
                                 'Temp.094',
                                 'Temperature_mV',
                                 'Temperature.2m'),
         group = TRUE, main = 'Subject 12',
         name.pol = c('iButton','BRANZ','PACMAN','Outdoor'),
         ylab = 'Temperature [C]')

timePlot(plot_data,pollutant = c('Temp.094','CO2_mV','CO_mV','Dust.corr.in','PM10.FDMS'),avg.time = '1 hour')
timePlot(plot_data,pollutant = c('Temp.094','CO2_mV','CO_mV','Dust.corr.in','PM10.FDMS'),avg.time = '1 day')

timePlot(plot_data,pollutant = c('Dust.corr.in','Dust.corr.out','PM10.FDMS'),avg.time = '1 hour'
         ,group = TRUE
         ,normalise = 'mean'
         ,main = 'Subject 14\nIndoor / Outdoor', ylab = 'PM10 [ug/m3] and Dust [mV]')
timeVariation(plot_data,pollutant = c('Dust.corr.in','Dust.corr.out','PM10.FDMS'),normalise = TRUE, main = 'Subject 14\nIndoor / Outdoor', ylab = 'PM10 [ug/m3] and Dust [mV]')


scatterPlot(plot_data,x='Temperature.DD','Temp.094',
            main = 'Subject 14',
            xlab = 'iButton',
            ylab = 'BRANZ',
            avg.time = '10 min')


scatterPlot(plot_data,x='Temperature_mV','Temp.094',
            main = 'Subject 14',
            xlab = 'PACMAN',
            ylab = 'BRANZ',
            avg.time = '10 min')

diurnal.mov<-try(timeVariation(pacman.data,pollutant='Movement'))
if (class(diurnal.mov)!="try-error"){
  ggplot(diurnal.mov$data$hour)+
    geom_ribbon(aes(x=hour,ymin=Lower,ymax=Upper),fill='red', alpha = 0.3)+
    geom_line(aes(x=hour,y=Mean),colour='red')+
    #    facet_grid(~wkday)+
    #    ggtitle('Movement')+
    xlab('NZST hour')+
    ylab('Movement')+
    ggtitle('Subject 14')
}

diurnal.dust <- timeVariation(plot_data,pollutant = c('Dust.corr.in','PM10.FDMS'),normalise = TRUE, main = 'Indoor / Outdoor', ylab = 'PM10 and Dust [normalised]')
ggplot(diurnal.dust$data$hour)+
  geom_ribbon(aes(x=hour,ymin=Lower,ymax=Upper, fill=variable), alpha = 0.3)+
  geom_line(aes(x=hour,y=Mean,colour = variable))+
  # facet_grid(variable~.)+
  # ggtitle('Dust')+
  xlab('NZST hour')+
  ylab('Dust')+
  ggtitle('Subject 14')

diurnal.temperature <- timeVariation(plot_data,pollutant = c('Temp.094','Temperature.DD','Temperature_mV'), main = 'Temperature of various sensors', ylab = 'Temperature [C]')
ggplot(diurnal.temperature$data$hour)+
  geom_ribbon(aes(x=hour,ymin=Lower,ymax=Upper, fill=variable), alpha = 0.3)+
  geom_line(aes(x=hour,y=Mean,colour = variable))+
  # facet_grid(variable~.)+
  # ggtitle('Dust')+
  xlab('NZST hour')+
  ylab('Dust')+
  ggtitle('Subject 14')

diurnal.pacman <- timeVariation(plot_data,pollutant = c('Temperature_mV','CO_mV','CO2_mV','Dust.corr.in','Movement'), normalise = TRUE, main = 'Temperature of various sensors', ylab = 'Temperature [C]')
ggplot(diurnal.pacman$data$hour)+
  geom_ribbon(aes(x=hour,ymin=Lower,ymax=Upper, fill=variable), alpha = 0.3)+
  geom_line(aes(x=hour,y=Mean,colour = variable))+
  # facet_grid(variable~.)+
  # ggtitle('Dust')+
  xlab('NZST hour')+
  ylab('Dust')+
  ggtitle('Subject 14')

subject14.data.1min <- timeAverage(selectByDate(subject.data, start = mindate, end = maxdate),avg.time = '1 min')
write.csv(subject14.data.1min,'./subject_14.csv')
