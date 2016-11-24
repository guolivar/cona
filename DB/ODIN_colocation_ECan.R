# Set the seed ####
set.seed(2001)
##### Load relevant packages #####
library(RPostgreSQL)
##### Set the working directory DB ####
setwd("~/repositories/cona/DB")
##### Set the path where location info is #####
filepath <- '/home/gustavo/data_gustavo/cona'
##### Read the credentials file (hidden file not on the GIT repository) ####
access <- read.delim("./.cona_login")
##### Open DATA connection to the DB ####
p <- dbDriver("PostgreSQL")
con<-dbConnect(p,
               user=as.character(access$user[1]),
               password=as.character(access$pwd[1]),
               host='penap-data.dyndns.org',
               dbname='cona',
               port=5432)
# Load only data from ODINs at ECan's site
siteid = 18 # ECan site
data <- dbGetQuery(con," SELECT d.recordtime at time zone 'UTC' as date, d.value as pm25, i.serialn as instrument
                   FROM data.fixed_data as d, admin.sensor as s, admin.instrument as i
                   WHERE s.id = d.sensorid AND
                   s.instrumentid = i.id AND
                   i.name = 'ODIN-SD-3' AND
                   d.siteid = 18 AND
                   s.name = 'PM2.5';")
data$ODIN.PM2.5 <- as.numeric(gsub("'","",data$pm25))
data$pm25 <- NULL
wide_data <- dcast(data,date~instrument,value.var = 'ODIN.PM2.5',fun.aggregate = mean)

# Load ECan's data
ecan.data <- read.csv(paste0(filepath,'/RangioraWinter2016.csv'))
ecan.data$date <- as.POSIXct(ecan.data$Date,format = '%d/%m/%Y %H:%M', tz='Etc/GMT-13')
ecan.data$X <- NULL
names(ecan.data) <- c('Date','Time','ws','wd','wdsd','wssd','wmx','co','dT','T2m','T6m','PM10.FDMS','PM2.5.FDMS','PMcoarse','date')




# Select time frames
min_date <- max(min(data$date),min(ecan.data$date))
max_date <- min(max(data$date),max(ecan.data$date))

# Merge ECan data
alldata <- subset(merge(wide_data,ecan.data,by='date',all = TRUE),(date >= min_date & date <= max_date))
wide_data.1hr <- timeAverage(alldata,avg.time = '1 hour')
timePlot(wide_data.1hr,pollutant = names(wide_data.1hr)[c(2:18,29)],group = FALSE, avg.time = '1 hour')


# Linear fit for all ODINs
summary(lm_100 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.100))
summary(lm_101 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.101))
summary(lm_102 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.102))
summary(lm_103 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.103))
summary(lm_104 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.104))
summary(lm_105 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.105))
summary(lm_106 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.106))
summary(lm_107 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.107))
summary(lm_108 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.108))
summary(lm_109 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.109))
summary(lm_110 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.110))
summary(lm_111 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.111))
summary(lm_112 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.112))
summary(lm_113 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.113))
summary(lm_114 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.114))
summary(lm_115 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.115))
summary(lm_116 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.116))
summary(lm_117 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.117))


# Linear fit of ODIN-109 against FDMS ####
data.fit109 <- as.data.frame(wide_data.1hr[,c('date','PM2.5.FDMS','ODIN.109')])
# Whole dataset
summary(lm_109.whole <- lm(data = timeAverage(data.fit109,avg.time = '1 hour'),PM2.5.FDMS ~ ODIN.109))
# First 1/4
summary(lm_109.first3 <- lm(data = timeAverage(data.fit109[1:920,],avg.time = '1 hour'),PM2.5.FDMS ~ ODIN.109))
# Third 1/4
summary(lm_109.last3 <- lm(data = timeAverage(data.fit109[1840:2760,],avg.time = '1 hour'),PM2.5.FDMS ~ ODIN.109))
# Random 30%
summary(lm_109.rnd3 <- lm(data = timeAverage(data.fit109[sample(nrow(wide_data.1hr),920),],avg.time = '1 hour'),PM2.5.FDMS ~ ODIN.109))

# Calculate fit and confidence interval estimates according to the previous segmentation

ODIN.109.whole <- predict(lm_109.whole,newdata = data.fit109,interval = 'confidence')
ODIN.109.firstQ <- predict(lm_109.firstQ,newdata = data.fit109,interval = 'confidence')
ODIN.109.thirdQ <- predict(lm_109.thirdQ,newdata = data.fit109,interval = 'confidence')
ODIN.109.rnd3 <- predict(lm_109.rnd3,newdata = data.fit109,interval = 'confidence')

data.fit109$ODIN.109.whole <- ODIN.109.whole[,1]
data.fit109$ODIN.109.whole.lwr <- ODIN.109.whole[,2]
data.fit109$ODIN.109.whole.upr <- ODIN.109.whole[,3]
data.fit109$ODIN.109.firstQ <- ODIN.109.firstQ[,1]
data.fit109$ODIN.109.firstQ.lwr <- ODIN.109.firstQ[,2]
data.fit109$ODIN.109.firstQ.upr <- ODIN.109.firstQ[,3]
data.fit109$ODIN.109.thirdQ <- ODIN.109.thirdQ[,1]
data.fit109$ODIN.109.thirdQ.lwr <- ODIN.109.thirdQ[,2]
data.fit109$ODIN.109.thirdQ.upr <- ODIN.109.thirdQ[,3]
data.fit109$ODIN.109.rnd3 <- ODIN.109.rnd3[,1]
data.fit109$ODIN.109.rnd3.lwr <- ODIN.109.rnd3[,2]
data.fit109$ODIN.109.rnd3.upr <- ODIN.109.rnd3[,3]

ggplot(data.fit109,aes(x=date)) +
  geom_line(aes(y=ODIN.109.thirdQ),colour='red')+
  geom_line(aes(y=PM2.5.FDMS),colour='black')+
  geom_line(aes(y=ODIN.109.thirdQ.lwr),colour='red',linetype=3)+
  geom_line(aes(y=ODIN.109.thirdQ.upr),colour='red',linetype=3)



# Plot the corrections ####
# Hourly data
timePlot(data.fit109,pollutant = names(data.fit109)[2:7],group = TRUE,avg.time = '1 hour')
# Daily data
timePlot(data.fit109,pollutant = names(data.fit109)[2:7],group = TRUE,avg.time = '1 day')




timePlot(wide_data.1hr[sample(nrow(wide_data.1hr),920),],pollutant = c('PM2.5.FDMS','ODIN.109'),group = TRUE, avg.time = '1 day')

ggplot(data)+
  geom_line(aes(x=date,y=ODIN.PM2.5,colour = instrument))+
  ggtitle('ODIN colocation')+
  xlab('Local Date')+
  ylab(expression(paste('PM2.5 [',mu,'g/',m^3)))











