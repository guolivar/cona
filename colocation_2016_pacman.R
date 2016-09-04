# Subject summaries
library('openair')
library('ggplot2')
basepath <- "/home/gustavo/data/CONA/2016/PACMAN_co-location/"

#PACMAN
unitID<-c('11','12','13','16','18','C2')
for (id in unitID){
  pacman.data <- read.delim(paste0(basepath,'PACMAN/pacman_',id,".txt"))
  names(pacman.data)<-c('Count','Year','Month','Day','Hour','Minute','Second',
                        'Distance','Temperature_IN_C','Temperature_mV','PM_mV','CO2_mV','CO_mV','Movement','COstatus')
  pacman.data$Temperature_mV <- (pacman.data$Temperature_mV/100)-273.15
  pacman.data$date<-ISOdatetime(year=pacman.data$Year,
                                month=pacman.data$Month,
                                day=pacman.data$Day,
                                hour=pacman.data$Hour,
                                min=pacman.data$Minute,
                                sec=pacman.data$Second,
                                tz="Etc/GMT+12")
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
  pacman.data$T.bin<-cut(pacman.data$Temperature_mV,breaks = c(16,20,24,28,32),labels = c('18','22','26','30'))
  Temp <- c(18,22,26,30)
  Dust<-tapply(pacman.data$PM_mV.detrend,pacman.data$T.bin,quantile,0.25)
  TC_Dust <- data.frame(PM_mV.detrend = Dust,Temperature_mV = Temp)
  summary(odin.02_T<-lm(data = TC_Dust,PM_mV.detrend~Temperature_mV))
  pacman.data$Dust.corr.in <- pacman.data$PM_mV.detrend - predict(odin.02_T,newdata = pacman.data)
  
  names(pacman.data) <- c(paste0(names(pacman.data)[c(1:15)],".",id),'date',paste0(names(pacman.data)[c(17:23)],".",id))
  assign(paste0("pacman.data.",id),pacman.data)
  rm(pacman.data)
}


# Merging the data
pacman.data <- eval(as.symbol(paste0("pacman.data.",unitID[1])))
for (id in unitID[2:6]){
  pacman.data <- merge(pacman.data,eval(as.symbol(paste0("pacman.data.",id))),by='date', all = TRUE)
}

# 1 minute average
pacman.data.1min <- timeAverage(pacman.data,avg.time = '1 min')

# Some Plots

# Temperature
timePlot(pacman.data.1min,pollutant =  grep("Temperature_mV",names(pacman.data),value=TRUE),group = TRUE)

# Corrected Dust
timePlot(pacman.data.1min,pollutant =  grep("Dust.corr.in",names(pacman.data),value=TRUE),group = TRUE)

# CO2
timePlot(pacman.data.1min,pollutant =  grep("CO2",names(pacman.data),value=TRUE),group = TRUE)

# CO
timePlot(pacman.data.1min,pollutant =  grep("CO_mV",names(pacman.data),value=TRUE),group = TRUE,avg.time = '10 min')

# Movement
timePlot(pacman.data.1min,pollutant =  grep("Movement",names(pacman.data),value=TRUE),group = TRUE,avg.time = '10 min')

# QTrak
qtrak.data <- read.csv(paste0(basepath,'Qtrak/qtrak.txt'))
qtrak.data$date <- as.POSIXct(paste(qtrak.data$Date,qtrak.data$Time),format = '%d/%m/%Y %H:%M:%S',tz='GMT')

# Merge with PACMAN
merged.data <- merge(pacman.data,qtrak.data,by = 'date', all = TRUE)
merged.data.10min <- timeAverage(merged.data, avg.time = '10 min')
# CO
timePlot(merged.data.10min,pollutant = c('CO2',grep("CO_mV",names(pacman.data),value=TRUE)),group = TRUE,avg.time = '60 min',normalise = 'mean')

