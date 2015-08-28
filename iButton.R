#iButtons
# Load Libraries ####
library('openair')
library('ggplot2')
library('reshape2')
# Load the data ####
# 1B000000322E6141
iB_1B000000322E6141 <- read.csv("~/data/CONA/iButton/1B000000322E6141_data.txt")
iB_1B000000322E6141$date <- as.POSIXct(iB_1B000000322E6141$Date.Time,format = '%d/%m/%y %I:%M:%S %p',tz = 'NZST')
iB_1B000000322E6141$Date.Time <- NULL
iB_1B000000322E6141$Unit <- NULL
names(iB_1B000000322E6141) <- c('Temperature.1B','date')

# 3D00000026EEC341
iB_3D00000026EEC341 <- read.csv("~/data/CONA/iButton/3D00000026EEC341_data.txt")
iB_3D00000026EEC341$date <- as.POSIXct(iB_3D00000026EEC341$Date.Time,format = '%d/%m/%y %I:%M:%S %p',tz = 'NZST')
iB_3D00000026EEC341$Date.Time <- NULL
iB_3D00000026EEC341$Unit <- NULL
names(iB_3D00000026EEC341) <- c('Temperature.3D','date')

# 8800000026F06241
iB_8800000026F06241 <- read.csv("~/data/CONA/iButton/8800000026F06241_data.txt")
iB_8800000026F06241$date <- as.POSIXct(iB_8800000026F06241$Date.Time,format = '%d/%m/%y %I:%M:%S %p',tz = 'NZST')
iB_8800000026F06241$Date.Time <- NULL
iB_8800000026F06241$Unit <- NULL
names(iB_8800000026F06241) <- c('Temperature.88','date')

# A500000032322841
iB_A500000032322841 <- read.csv("~/data/CONA/iButton/A500000032322841_data.txt")
iB_A500000032322841$date <- as.POSIXct(iB_A500000032322841$Date.Time,format = '%d/%m/%y %I:%M:%S %p',tz = 'NZST')
iB_A500000032322841$Date.Time <- NULL
iB_A500000032322841$Unit <- NULL
names(iB_A500000032322841) <- c('Temperature.A5','date')

# C200000026F9BE41
iB_C200000026F9BE41 <- read.csv("~/data/CONA/iButton/C200000026F9BE41_data.txt")
iB_C200000026F9BE41$date <- as.POSIXct(iB_C200000026F9BE41$Date.Time,format = '%d/%m/%y %I:%M:%S %p',tz = 'NZST')
iB_C200000026F9BE41$Date.Time <- NULL
iB_C200000026F9BE41$Unit <- NULL
names(iB_C200000026F9BE41) <- c('Temperature.C2','date')

# D200000026F1EE41
iB_D200000026F1EE41 <- read.csv("~/data/CONA/iButton/D200000026F1EE41_data.txt")
iB_D200000026F1EE41$date <- as.POSIXct(iB_D200000026F1EE41$Date.Time,format = '%d/%m/%y %I:%M:%S %p',tz = 'NZST')
iB_D200000026F1EE41$Date.Time <- NULL
iB_D200000026F1EE41$Unit <- NULL
names(iB_D200000026F1EE41) <- c('Temperature.D2','date')

# Merge all data
iButtons <- merge(iB_1B000000322E6141,iB_3D00000026EEC341,by = 'date',all = TRUE)
iButtons <- merge(iButtons,iB_8800000026F06241,by = 'date',all = TRUE)
iButtons <- merge(iButtons,iB_A500000032322841,by = 'date',all = TRUE)
iButtons <- merge(iButtons,iB_C200000026F9BE41,by = 'date',all = TRUE)
iButtons <- merge(iButtons,iB_D200000026F1EE41,by = 'date',all = TRUE)

