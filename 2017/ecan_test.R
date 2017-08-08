# libraries
library(readr)
library(openair)
library(ggplot2)
library(RPostgreSQL)
# Quiet down warnings
oldw <- getOption("warn")
options(warn = -1)
# Paths and constants
data_folder <- "~/data/CONA/2017/WORKING/odin/ecan_test/"
ecan_data_file <- "RangioraJune2017.txt"
data_file <- dir(data_folder,'ODIN*')
nfiles <- length(data_file)
serials <- gsub('.TXT','',gsub('_','-',toupper(data_file))) # get serialn from file names

# Load data
# Date corrections
time_corrections <- read_delim(paste0(data_folder,"time_corrections.txt"),
                               "\t", escape_double = FALSE,
                               col_types = cols(real_time = col_character()),
                               trim_ws = TRUE)
time_corrections$real_time <- as.POSIXct(time_corrections$real_time, tz='UTC') - 12*3600

# Go through files
for (i in (1:nfiles)){
  t_idx <- which(time_corrections$serialn==serials[i])
  odin <- read_delim(paste0(data_folder,data_file[i]),
                     "\t", escape_double = FALSE, col_types = cols(Day = col_character(),
                                                                   Time = col_character()), trim_ws = TRUE)
  odin$date <- as.POSIXct(paste(odin$Day,odin$Time), tz='UTC') - 12*3600
  dt <- time_corrections$real_time[t_idx] - odin$date[1]
  odin$date <- odin$date + dt
  odin$serialn <- serials[i]
  if (i==1){
    all_odin <- odin
  } else {
    all_odin <- rbind(all_odin,odin)
  }
}

# Plot summaries
ggplot(data=all_odin) +
  geom_point(aes(x=date,y=PM1,color = serialn)) +
  ggtitle("PM1","ECan test")
ggplot(data=all_odin) +
  geom_point(aes(x=date,y=PM2.5,color = serialn)) +
  ggtitle("PM2.5","ECan test")
ggplot(data=all_odin) +
  geom_point(aes(x=date,y=PM10,color = serialn)) +
  ggtitle("PM10","ECan test")

# Load ECan's data
ecan_data <- read_delim(paste0(data_folder,ecan_data_file),
                        "\t", escape_double = FALSE, trim_ws = TRUE)
ecan_data$date <- as.POSIXct(ecan_data$DateTime,format = "%d/%m/%Y %H:%M", tz='UTC') - 12*3600
ecan_data$DateTime <- NULL
names(ecan_data) <- c('ws_max','ws','wd','CO','PM10','PM2.5','PMc','T2m','T6m','T','date')
ecan_data.1hr <- timeAverage(ecan_data,avg.time = '1 hour')
rm(odin)
correction.coeffs <- time_corrections
correction.coeffs$real_time <- NULL
correction.coeffs$PM10.slope <- NA
correction.coeffs$PM10.intrcpt <- NA
correction.coeffs$PM10.rsqrd <- NA
correction.coeffs$PM10.slope.old <- NA
correction.coeffs$PM10.intrcpt.old <- NA
correction.coeffs$PM2.5.slope <- NA
correction.coeffs$PM2.5.intrcpt <- NA
correction.coeffs$PM2.5.rsqrd <- NA
correction.coeffs$PM2.5.slope.old <- NA
correction.coeffs$PM2.5.intrcpt.old <- NA

# Compare ODIN data against ECan
for (i in (1:nfiles)){
  c_idx <- which(correction.coeffs$serialn==serials[i])
  odin <- subset(all_odin,subset = serialn == serials[i])
  odin.1hr <- timeAverage(odin,avg.time = '1 hour')
  # PM10
  pm <- 'PM10'
  odin.1hr.pm <- odin.1hr[,c('date',pm)]
  names(odin.1hr.pm) <- c('date',paste0(pm,serials[i]))
  ecan_data.1hr.pm <- ecan_data.1hr[,c('date',pm)]
  merged_data <- selectByDate(merge(ecan_data.1hr.pm,odin.1hr.pm, by='date'),start = '2017-06-01',end = '2017-06-20')
  if (length(merged_data$date) < 5){
    print("Too few datapoints")
    next
  }

  # Correction factors
  summary(eval(parse(text=paste0("correction_fit <- lm(data=merged_data, ",pm," ~`",pm,serials[i],"`)"))))
  sum_fit <- summary(correction_fit)
  slope <- sprintf("%0.2f",correction_fit$coefficients[2])
  intrcpt <- sprintf("%0.2f",correction_fit$coefficients[1])
  rsq <- sprintf("%0.2f",sum_fit$r.squared)
  eval(parse(text = paste0("correction.coeffs$",pm,".slope[c_idx] <- correction_fit$coefficients[2]")))
  eval(parse(text = paste0("correction.coeffs$",pm,".intrcpt[c_idx] <- correction_fit$coefficients[1]")))
  eval(parse(text = paste0("correction.coeffs$",pm,".rsqrd[c_idx] <- sum_fit$r.squared")))
  eval(parse(text=paste0("merged_data$",pm,"fitted <- predict(correction_fit,merged_data)")))
  timePlot(selectByDate(merged_data,start = '2017-06-01',end = '2017-06-20'),
           pollutant = names(merged_data)[2:4],
           group = TRUE,
           main = paste0(serials[i],
                         ' (R2 = ',rsq,')\n',
                         slope,' * ODIN + ',
                         intrcpt))
  # PM2.5
  pm <- 'PM2.5'
  odin.1hr.pm <- odin.1hr[,c('date',pm)]
  names(odin.1hr.pm) <- c('date',paste0(pm,serials[i]))
  ecan_data.1hr.pm <- ecan_data.1hr[,c('date',pm)]
  merged_data <- selectByDate(merge(ecan_data.1hr.pm,odin.1hr.pm, by='date'),start = '2017-06-01',end = '2017-06-20')
  # Correction factors
  summary(eval(parse(text=paste0("correction_fit <- lm(data=merged_data, ",pm," ~`",pm,serials[i],"`)"))))
  sum_fit <- summary(correction_fit)
  slope <- sprintf("%0.2f",correction_fit$coefficients[2])
  intrcpt <- sprintf("%0.2f",correction_fit$coefficients[1])
  rsq <- sprintf("%0.2f",sum_fit$r.squared)
  eval(parse(text = paste0("correction.coeffs$",pm,".slope[c_idx] <- correction_fit$coefficients[2]")))
  eval(parse(text = paste0("correction.coeffs$",pm,".intrcpt[c_idx] <- correction_fit$coefficients[1]")))
  eval(parse(text = paste0("correction.coeffs$",pm,".rsqrd[c_idx] <- sum_fit$r.squared")))
  eval(parse(text=paste0("merged_data$",pm,"fitted <- predict(correction_fit,merged_data)")))
  timePlot(selectByDate(merged_data,start = '2017-06-01',end = '2017-06-20'),
           pollutant = names(merged_data)[2:4],
           group = TRUE,
           main = paste0(serials[i],
                         ' (R2 = ',rsq,')\n',
                         slope,' * ODIN + ',
                         intrcpt))

  # Temperature
  odin.1hr.pm <- odin.1hr[,c('date','Temperature')]
  names(odin.1hr.pm) <- c('date',paste0('Temperature-',serials[i]))
  ecan_data.1hr.pm <- ecan_data.1hr[,c('date','T2m','T6m','T')]
  merged_data <- selectByDate(merge(ecan_data.1hr.pm,odin.1hr.pm, by='date'),start = '2017-06-01',end = '2017-06-20')
  timePlot(selectByDate(merged_data,start = '2017-06-01',end = '2017-06-20'),
           pollutant = names(merged_data)[2:5],
           group = TRUE,
           main = serials[i])
}

# Get correction factors from last year
access <- read.delim("~/repositories/cona/DB/.cona_login", stringsAsFactors = FALSE)
##### Open DATA connection to the DB ####
p <- dbDriver("PostgreSQL")
con<-dbConnect(p,
               user=access$user[1],
               password=access$pwd[1],
               host='penap-data.dyndns.org',
               dbname='cona',
               port=5432)
data <- dbGetQuery(con,"select i.serialn, s.name, md.slope, md.intercept
from 	admin.sensor as s,
	metadata.odin_sd_calibration as md,
	admin.instrument as i
where 	(s.name = 'PM10' OR s.name = 'PM2.5') AND
	s.instrumentid = i.id AND
	md.sensorid = s.id;")
dbDisconnect(con)
for (i in (1:nfiles)){
  c_idx <- which(correction.coeffs$serialn==serials[i])
  pm <- 'PM10'
  idx <- which((data$serialn==serials[i])&(data$name==pm))
  if (length(idx)<1){
    next
  }
  correction.coeffs$PM10.slope.old[c_idx] <- data$slope[idx]
  correction.coeffs$PM10.intrcpt.old[c_idx] <- data$intercept[idx]
  pm <- 'PM2.5'
  idx <- which((data$serialn==serials[i])&(data$name==pm))
  correction.coeffs$PM2.5.slope.old[c_idx] <- data$slope[idx]
  correction.coeffs$PM2.5.intrcpt.old[c_idx] <- data$intercept[idx]
}

knitr::kable(correction.coeffs[,c('serialn',
                                  'PM10.rsqrd',
                                  'PM10.slope',
                                  'PM10.slope.old',
                                  'PM10.intrcpt',
                                  'PM10.intrcpt.old')], digits = 2)
readr::write_csv(correction.coeffs[,c('serialn',
                                      'PM10.rsqrd',
                                      'PM10.slope',
                                      'PM10.slope.old',
                                      'PM10.intrcpt',
                                      'PM10.intrcpt.old')],path = paste0(data_folder,'odin_corrections_pm10.csv'))

knitr::kable(correction.coeffs[,c('serialn',
                                  'PM2.5.rsqrd',
                                  'PM2.5.slope',
                                  'PM2.5.slope.old',
                                  'PM2.5.intrcpt',
                                  'PM2.5.intrcpt.old')], digits = 2)
readr::write_csv(correction.coeffs[,c('serialn',
                                      'PM2.5.rsqrd',
                                      'PM2.5.slope',
                                      'PM2.5.slope.old',
                                      'PM2.5.intrcpt',
                                      'PM2.5.intrcpt.old')],path = paste0(data_folder,'odin_corrections_pm2.5.csv'))

nrecs <- length(all_odin$date)
odin_final <- all_odin[,c('date','serialn','PM1','PM2.5','PM10','Temperature','RH')]
odin_final$PM2.5.corr <- odin_final$PM2.5
odin_final$PM10.corr <- odin_final$PM10
for (i in (1:length(correction.coeffs$serialn))){
  c_idx <- which(odin_final$serialn==correction.coeffs$serialn[i])
  odin_final$PM2.5.corr[c_idx] <- correction.coeffs$PM2.5.intrcpt[i] + correction.coeffs$PM2.5.slope[i]*odin_final$PM2.5
  odin_final$PM10.corr[c_idx] <- correction.coeffs$PM10.intrcpt[i] + correction.coeffs$PM10.slope[i]*odin_final$PM10
}


#re-enable warnings to continue the session
options(warn = oldw)