# Subject summaries
library('openair')
library('ggplot2')

# ECan
download.file(url = "http://data.ecan.govt.nz/data/29/Air/Air%20quality%20data%20for%20a%20monitored%20site%20(Hourly)/CSV?SiteId=5&StartDate=01%2F08%2F2015&EndDate=27%2F08%2F2015",destfile = "ecan_data.csv",method = "curl")
system("sed -i 's/a.m./AM/g' ecan_data.csv")
system("sed -i 's/p.m./PM/g' ecan_data.csv")
ecan_data_raw <- read.csv("ecan_data.csv",stringsAsFactors=FALSE)
ecan_data_raw$date<-as.POSIXct(ecan_data_raw$DateTime,format = "%d/%m/%Y %I:%M:%S %p",tz='GMT')
ecan_data<-as.data.frame(ecan_data_raw[,c('date','PM10.FDMS','Temperature..2m','Temperature..6m','Wind.Speed','Wind.Direction')])
names(ecan_data)<- c('date','PM10.FDMS','Temperature.2m','Temperature.6m','ws','wd')

# iButton
# C200000026F9BE41
iB_C200000026F9BE41 <- read.csv("~/data/CONA/iButton/C200000026F9BE41_data.txt")
iB_C200000026F9BE41$date <- as.POSIXct(iB_C200000026F9BE41$Date.Time,format = '%d/%m/%y %I:%M:%S %p',tz = 'NZST')
iB_C200000026F9BE41$Date.Time <- NULL
iB_C200000026F9BE41$Unit <- NULL
names(iB_C200000026F9BE41) <- c('Temperature.C2','date')

# BRANZ
# HUV191
HUV191 <- read.csv("~/data/CONA/BRANZ/HUV191.csv")
HUV191$date <- as.POSIXct(HUV191$Timestamp,format = '%d/%m/%Y %H:%M',tz = 'NZST')
HUV191$Timestamp <- NULL
names(HUV191) <- c('CH1.191','Temp.191','date')

#PACMAN
unitID<-'pacman_17'
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
pacman.data$T.bin<-cut(pacman.data$Temperature_mV,breaks = c(25,27,29,31),labels = c('26','28','30'))
Temp <- c(26,28,30)
Dust<-tapply(pacman.data$PM_mV.detrend,pacman.data$T.bin,quantile,0.25)
TC_Dust <- data.frame(PM_mV.detrend = Dust,Temperature_mV = Temp)
summary(odin.02_T<-lm(data = TC_Dust,PM_mV.detrend~Temperature_mV))
pacman.data$Dust.corr <- pacman.data$PM_mV.detrend - predict(odin.02_T,newdata = pacman.data)


# Merging the data

subject.data <- merge(iB_C200000026F9BE41,HUV191,by = 'date', all = TRUE)
subject.data <- merge(subject.data,pacman.data, by = 'date', all = TRUE)
subject.data <- merge(subject.data,ecan_data, by = 'date', all = TRUE)
subject.data.10min <- timeAverage(subject.data,avg.time = '10 min')

# Subject 4

mindate <- format(max(min(iB_C200000026F9BE41$date),min(HUV191$date),min(ecan_data$date),min(pacman.data$date)),format = '%Y-%m-%d')
maxdate <- format(min(max(iB_C200000026F9BE41$date),max(HUV191$date),max(ecan_data$date),max(pacman.data$date)),format = '%Y-%m-%d')
plot_data <- selectByDate(subject.data, start = mindate, end = maxdate)
timePlot(plot_data,pollutant = c('Temperature.C2',
                                 'Temp.191',
                                 'Temperature_mV'),
         avg.time = '10 min',
         #normalise = 'mean',
         group = TRUE, main = 'Subject 4',
         name.pol = c('iButton','BRANZ','PACMAN'),
         ylab = 'Temperature [C]')

timePlot(plot_data,pollutant = c('Temp.191','CO2_mV','CO_mV','Dust.corr','PM10.FDMS'),avg.time = '1 hour')
timePlot(plot_data,pollutant = c('Dust.corr','PM10.FDMS'),avg.time = '1 hour'
         ,group = TRUE
         ,main = 'Indoor / Outdoor', ylab = 'PM10 [ug/m3] and Dust [mV]')
timePlot(plot_data,pollutant = c('Temp.191','Temperature_mV'),avg.time = '1 hour', ylab = 'Temperature [C]', group = TRUE,nname.pol = c('BRANZ','PACMAN'))

timePlot(plot_data,pollutant = c('Temp.191','CO2_mV','CO_mV','Dust.corr','PM10.FDMS'),avg.time = '1 day')
timePlot(plot_data,pollutant = c('Temp.191','CO2_mV','CO_mV','Dust.corr','PM10.FDMS'),avg.time = '1 hour', statistic = 'max', main = 'Hourly MAXIMUM')
timeVariation(plot_data,pollutant = c('Temp.191','CO2_mV','CO_mV'),normalise = TRUE)
timeVariation(plot_data,pollutant = c('Dust.corr','PM10.FDMS'),normalise = TRUE, main = 'Indoor / Outdoor', ylab = 'PM10 [ug/m3] and Dust [mV]')

scatterPlot(plot_data,x='Temperature.C2','Temp.191',
            main = 'Subject 4',
            xlab = 'iButton',
            ylab = 'BRANZ',
            avg.time = '10 min')


scatterPlot(plot_data,x='Temperature_mV','Temp.191',
            main = 'Subject 4',
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
    ylab('Movement')
}


diurnal.temp<-try(timeVariation(plot_data,pollutant = c('Temperature.C2',
                                                   'Temp.191',
                                                   'Temperature_mV',
                                                   'Temperature.2m'),
                           # avg.time = '10 min',
                           #normalise = 'mean',
                           # group = TRUE,
                           main = 'Subject 4',
                           name.pol = c('iButton','BRANZ','PACMAN','Outdoor'),
                           ylab = 'Temperature [C]'))
if (class(diurnal.temp)!="try-error"){
  ggplot(diurnal.temp$data$hour)+
    geom_ribbon(aes(x=hour,ymin=Lower,ymax=Upper, fill=variable), alpha = 0.3)+
    geom_line(aes(x=hour,y=Mean,colour = variable))+
    # facet_grid(variable~.)+
    # ggtitle('Temperature')+
    xlab('NZST hour')+
    ylab('Temperature')
}


subject04.data.1min <- timeAverage(plot_data ,avg.time = '1 min')
write.csv(subject04.data.1min,'./subject_04.csv')



