######## Analyse ODIN #####





odin <- selectByDate(odin_raw,start = '2015-09-09',end = '2015-10-10')
odin.10min<-timeAverage(odin,avg.time='10 min')
all_merged.1min<-merge(odin,ecan_data,by='date',all=TRUE)
all_merged.10min<-timeAverage(all_merged.1min,avg.time = '10 min')
all_merged.10min <- selectByDate(all_merged.10min,start = '2015-09-09',end = '2015-10-10')
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
all_merged.10min <- selectByDate(all_merged.10min,start = '2015-09-09',end = '2015-10-10')
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
                                        #'Dust.02.corr',
                                        #'Dust.03.corr',
                                        'Dust.04.corr',
                                        'Dust.05.corr',
                                        'Dust.06.corr',
                                        'Dust.07.corr'
)
,group = FALSE
,main = '10 min')

timebase = '1 hour'
timePlot(all_merged.10min,pollutant = c('PM10.FDMS',
#                                        'Dust.02.corr',
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
                                                      #  ,'Dust.02.corr'
                                                      #  ,'Dust.03.corr'
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


timePlot(all_merged.10min,pollutant = c('Temperature.04','Dust.04.raw','Dust.04.corr'))




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
                                        #,'Dust.02.corr'
                                      #,'Dust.03.corr'
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

mean(odin_raw$Dust.02[51000:90000],na.rm = TRUE)
mean(odin_raw$Dust.02[11000:50000],na.rm = TRUE)

mean(odin_raw$Dust.03[51000:90000],na.rm = TRUE)
mean(odin_raw$Dust.03[11000:50000],na.rm = TRUE)

mean(odin_raw$Dust.04[51000:90000],na.rm = TRUE)
mean(odin_raw$Dust.04[11000:50000],na.rm = TRUE)

mean(odin_raw$Dust.05[51000:90000],na.rm = TRUE)
mean(odin_raw$Dust.05[11000:50000],na.rm = TRUE)

mean(odin_raw$Dust.06[51000:90000],na.rm = TRUE)
mean(odin_raw$Dust.06[11000:50000],na.rm = TRUE)

mean(odin_raw$Dust.07[51000:90000],na.rm = TRUE)
mean(odin_raw$Dust.07[11000:50000],na.rm = TRUE)

