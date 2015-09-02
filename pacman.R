# PACMAN
library('openair')
library('ggplot2')
unitID<-'pacman_18'
pacman.data <- read.delim(paste0("/home/gustavo/data/CONA/PACMAN/campaign/",unitID,".txt"))
names(pacman.data)<-c('Count','Year','Month','Day','Hour','Minute','Second',
                      'Distance','Temperature_IN_C','Temperature_mV','PM_mV','CO2_mV','CO_mV','Movement','COstatus')
pacman.data$Temperature_mV <- pacman.data$Temperature_mV/1000
pacman.data$date<-ISOdatetime(year=pacman.data$Year,
                              month=pacman.data$Month,
                              day=pacman.data$Day,
                              hour=pacman.data$Hour,
                              min=pacman.data$Minute,
                              sec=pacman.data$Second,
                              tz="GMT")

#CO label
nrecs=length(pacman.data$COstatus)
pacman.data$CO_ok <- FALSE
pacman.data$CO_ok[1:nrecs-1] <- (pacman.data$COstatus[-1]==1)&(pacman.data$COstatus[1:nrecs-1]==2)
pacman.data$CO_raw <- pacman.data$CO_mV
pacman.data$CO_mV[!pacman.data$CO_ok] <- NA

# Inverting CO2
pacman.data$CO2_mV <- -1 * pacman.data$CO2_mV