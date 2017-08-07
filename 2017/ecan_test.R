# libraries
library(readr)
library(openair)
library(ggplot2)
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
# Compare ODIN data against ECan
for (i in (1:nfiles)){
  odin <- subset(all_odin,subset = serialn == serials[i])
  odin.1hr <- timeAverage(odin,avg.time = '1 hour')
  # PM10
  pm <- 'PM10'
  odin.1hr.pm <- odin.1hr[,c('date',pm)]
  names(odin.1hr.pm) <- c('date',paste0(pm,serials[i]))
  ecan_data.1hr.pm <- ecan_data.1hr[,c('date',pm)]
  merged_data <- merge(ecan_data.1hr.pm,odin.1hr.pm, by='date')
  if (length(merged_data$date) < 5){
    print("Too few datapoints")
    next
  }
  timePlot(selectByDate(merged_data,start = '2017-06-06',end = '2017-06-21'),
           pollutant = names(merged_data)[2:3],
           group = TRUE,
           main = serials[i])
  # PM2.5
  pm <- 'PM2.5'
  odin.1hr.pm <- odin.1hr[,c('date',pm)]
  names(odin.1hr.pm) <- c('date',paste0(pm,serials[i]))
  ecan_data.1hr.pm <- ecan_data.1hr[,c('date',pm)]
  merged_data <- merge(ecan_data.1hr.pm,odin.1hr.pm, by='date')
  timePlot(selectByDate(merged_data,start = '2017-06-06',end = '2017-06-21'),
           pollutant = names(merged_data)[2:3],
           group = TRUE,
           main = serials[i])
  
  # Temperature
  odin.1hr.pm <- odin.1hr[,c('date','Temperature')]
  names(odin.1hr.pm) <- c('date',paste0('Temperature-',serials[i]))
  ecan_data.1hr.pm <- ecan_data.1hr[,c('date','T2m','T6m','T')]
  merged_data <- merge(ecan_data.1hr.pm,odin.1hr.pm, by='date')
  timePlot(selectByDate(merged_data,start = '2017-06-01',end = '2017-06-21'),
           pollutant = names(merged_data)[2:5],
           group = TRUE,
           main = serials[i])
}