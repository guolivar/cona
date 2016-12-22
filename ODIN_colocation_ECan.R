# Set the seed ####
set.seed(2001)
##### Load relevant packages #####
library(RPostgreSQL)
library(reshape2)
library(ggplot2)
library(openair)
##### Set the working directory DB ####
setwd("~/repositories/cona/DB")
##### Set the path where location info is #####
filepath <- '~/data/CONA/2016'
##### Read the credentials file (hidden file not on the GIT repository) ####
access <- read.delim("./.cona_login", stringsAsFactors = FALSE)
##### Open DATA connection to the DB ####
p <- dbDriver("PostgreSQL")
con<-dbConnect(p,
               user=access$user[1],
               password=access$pwd[1],
               host='penap-data.dyndns.org',
               dbname='cona',
               port=5432)
# Load only data from ODINs at ECan's site
siteid = 18 # ECan site
data <- dbGetQuery(con," SELECT d.recordtime at time zone 'NZST' as date,
                          d.value::numeric as pm25, i.serialn as instrument
                         FROM data.fixed_data as d, admin.sensor as s, admin.instrument as i
                         WHERE s.id = d.sensorid AND
                           s.instrumentid = i.id AND
                           i.name = 'ODIN-SD-3' AND
                           d.siteid = 18 AND
                           s.name = 'PM2.5';")
data$ODIN.PM2.5 <- data$pm25
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
timePlot(wide_data.1hr,pollutant = names(wide_data.1hr)[c(2:18,29)],group = TRUE, avg.time = '1 hour')
fit_coeffs <- data.frame(snumber=NA*(1:17),inter.lwr=NA,inter=NA,inter.upr=NA,slope.lwr=NA,slope=NA,slope.upr=NA)

# Linear fit for ODIN-109
summary(lm_109 <- lm(data = wide_data.1hr,PM2.5.FDMS ~ ODIN.109))
fit_coeffs$snumber[1]<-'ODIN-109'
fit_coeffs$inter[1] <- coefficients(lm_109)[1]
fit_coeffs$slope[1] <- coefficients(lm_109)[2]
fit_coeffs$inter.lwr[1] <- confint(lm_109)[1]
fit_coeffs$inter.upr[1] <- confint(lm_109)[3]
fit_coeffs$slope.lwr[1] <- confint(lm_109)[2]
fit_coeffs$slope.upr[1] <- confint(lm_109)[4]

# Linear fit for all ODINs
j=2
for (i in c('100',
            '101',
            '102',
            '103',
            '104',
            '105',
            '106',
            '107',
            '108',
            '110',
            '111',
            '112',
            '113',
            '114',
            '115',
            '117'))
{
  eval(parse(text=paste0('summary(lm_',i,' <- lm(data = wide_data.1hr,ODIN.109 ~ ODIN.',i,'))')))
  fit_coeffs$snumber[j]<-paste0('ODIN-',i)
  eval(parse(text=paste0('fit_coeffs$inter[j] <- coefficients(lm_',i,')[1]')))
  eval(parse(text=paste0('fit_coeffs$slope[j] <- coefficients(lm_',i,')[2]')))
  eval(parse(text=paste0('fit_coeffs$inter.lwr[j] <- confint(lm_',i,')[1]')))
  eval(parse(text=paste0('fit_coeffs$inter.upr[j] <- confint(lm_',i,')[3]')))
  eval(parse(text=paste0('fit_coeffs$slope.lwr[j] <- confint(lm_',i,')[2]')))
  eval(parse(text=paste0('fit_coeffs$slope.upr[j] <- confint(lm_',i,')[4]')))
  j=j+1
}

ggplot(fit_coeffs)+
  geom_bar(aes(x=snumber,y=slope.upr,fill=snumber),stat = 'identity') +
  geom_bar(aes(x=snumber,y=slope.lwr),fill='white',stat = 'identity')

ggplot(fit_coeffs)+
  geom_bar(aes(x=snumber,y=inter.upr,fill=snumber),stat = 'identity') +
  geom_bar(aes(x=snumber,y=inter.lwr),alpha=0,stat = 'identity')

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
ODIN.109.first3 <- predict(lm_109.first3,newdata = data.fit109,interval = 'confidence')
ODIN.109.last3 <- predict(lm_109.last3,newdata = data.fit109,interval = 'confidence')
ODIN.109.rnd3 <- predict(lm_109.rnd3,newdata = data.fit109,interval = 'confidence')

data.fit109$ODIN.109.whole <- ODIN.109.whole[,1]
data.fit109$ODIN.109.whole.lwr <- ODIN.109.whole[,2]
data.fit109$ODIN.109.whole.upr <- ODIN.109.whole[,3]
data.fit109$ODIN.109.first3 <- ODIN.109.first3[,1]
data.fit109$ODIN.109.first3.lwr <- ODIN.109.first3[,2]
data.fit109$ODIN.109.first3.upr <- ODIN.109.first3[,3]
data.fit109$ODIN.109.last3 <- ODIN.109.last3[,1]
data.fit109$ODIN.109.last3.lwr <- ODIN.109.last3[,2]
data.fit109$ODIN.109.last3.upr <- ODIN.109.last3[,3]
data.fit109$ODIN.109.rnd3 <- ODIN.109.rnd3[,1]
data.fit109$ODIN.109.rnd3.lwr <- ODIN.109.rnd3[,2]
data.fit109$ODIN.109.rnd3.upr <- ODIN.109.rnd3[,3]

ggplot(data.fit109,aes(x=date)) +
  geom_line(aes(y=ODIN.109.last3),colour='red')+
  geom_line(aes(y=PM2.5.FDMS),colour='black')+
  geom_line(aes(y=ODIN.109.last3.lwr),colour='red',linetype=3)+
  geom_line(aes(y=ODIN.109.last3.upr),colour='red',linetype=3)



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

# Update metadata table with calibration data ####
sensor_id <- dbGetQuery(con, "SELECT i.serialn, s.id
                              FROM admin.sensor s,
                                admin.instrument i
                              WHERE s.instrumentid = i.id AND
                                i.name='ODIN-SD-3' AND
                                s.name = 'PM2.5';")
for (i in (1:nrow(sensor_id))){
  iserial <- sensor_id$serialn[i]
  sid <- sensor_id$id[i]
  idx_coeffs <- which(fit_coeffs$snumber==iserial)
  if (length(idx_coeffs)==1) {
    st <- dbGetQuery(con,paste0("UPDATE metadata.odin_sd_calibration
                                 SET slope=",fit_coeffs$slope[idx_coeffs],", intercept=",fit_coeffs$inter[idx_coeffs],
                                " WHERE sensorid = ",sid,";"))

  }
}







