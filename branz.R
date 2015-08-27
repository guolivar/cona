#iButtons
# Load Libraries ####
library('openair')
library('ggplot2')
library('reshape2')
# Load the data ####
# HUV118
HUV118 <- read.csv("~/data/CONA/BRANZ/HUV118.csv")
HUV118$date <- as.POSIXct(HUV118$Timestamp,format = '%d/%m/%Y %H:%M')
HUV118$Timestamp <- NULL
names(HUV118) <- c('CH1.118','Temp.118','date')

# HUV123
HUV123 <- read.csv("~/data/CONA/BRANZ/HUV123.csv")
HUV123$date <- as.POSIXct(HUV123$Timestamp,format = '%d/%m/%Y %H:%M')
HUV123$Timestamp <- NULL
names(HUV123) <- c('CH1.123','Temp.123','date')

# HUV141
HUV141 <- read.csv("~/data/CONA/BRANZ/HUV141.csv")
HUV141$date <- as.POSIXct(HUV141$Timestamp,format = '%d/%m/%Y %H:%M')
HUV141$Timestamp <- NULL
names(HUV141) <- c('CH1.141','Temp.141','date')

# HUV149
HUV149 <- read.csv("~/data/CONA/BRANZ/HUV149.csv")
HUV149$date <- as.POSIXct(HUV149$Timestamp,format = '%d/%m/%Y %H:%M')
HUV149$Timestamp <- NULL
names(HUV149) <- c('CH1.149','Temp.149','date')

# HUV154
HUV154 <- read.csv("~/data/CONA/BRANZ/HUV154.csv")
HUV154$date <- as.POSIXct(HUV154$Timestamp,format = '%d/%m/%Y %H:%M')
HUV154$Timestamp <- NULL
names(HUV154) <- c('CH1.154','Temp.154','date')

# HUV166
HUV166 <- read.csv("~/data/CONA/BRANZ/HUV166.csv")
HUV166$date <- as.POSIXct(HUV166$Timestamp,format = '%d/%m/%Y %H:%M')
HUV166$Timestamp <- NULL
names(HUV166) <- c('CH1.166','Temp.166','date')

# HUV186
HUV186 <- read.csv("~/data/CONA/BRANZ/HUV186.csv")
HUV186$date <- as.POSIXct(HUV186$Timestamp,format = '%d/%m/%Y %H:%M')
HUV186$Timestamp <- NULL
names(HUV186) <- c('CH1.186','Temp.186','date')

# HUV191
HUV191 <- read.csv("~/data/CONA/BRANZ/HUV191.csv")
HUV191$date <- as.POSIXct(HUV191$Timestamp,format = '%d/%m/%Y %H:%M')
HUV191$Timestamp <- NULL
names(HUV191) <- c('CH1.191','Temp.191','date')

# Merge all data
branz <- merge(HUV191,HUV186,by = 'date', all = TRUE)
branz <- merge(branz,HUV166,by = 'date', all = TRUE)
branz <- merge(branz,HUV154,by = 'date', all = TRUE)
branz <- merge(branz,HUV149,by = 'date', all = TRUE)
branz <- merge(branz,HUV141,by = 'date', all = TRUE)
branz <- merge(branz,HUV123,by = 'date', all = TRUE)
branz <- merge(branz,HUV118,by = 'date', all = TRUE)

