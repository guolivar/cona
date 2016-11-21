## Load ODIN-SD-3 data
##### Load relevant packages #####
library("RPostgreSQL")

##### Set the working directory DB ####
setwd("~/repositories/cona/DB")
##### Read the credentials file (hidden) ####
access <- read.delim("./.cona_login")
##### Open the connection to the DB ####
p <- dbDriver("PostgreSQL")
con<-dbConnect(p,
               user=as.character(access$user[1]),
               password=as.character(access$pwd[1]),
               host='localhost',
               dbname='cona',
               port=5432)
## Find the files to process ####
filepath <- '/home/gustavo/data_gustavo/cona'
files <- list.files(filepath,pattern = 'ODIN*')
time_corrections <- read.delim(paste0(filepath,'/time_corrections.txt'))
time_corrections$real_time <- as.POSIXct(time_corrections$real_time,tz = 'Etc/GMT-12')
serialn <- substr(files,1,8)
time_corrections

for (file in files){
  # Extract the serial number from the filenames
  ##### Read the raw odin file ####
  odin_sn <- substr(file,1,8)
  # Get the right time
  time_id <- max(1,which(time_corrections$serialn == odin_sn))
  odin_data <- read.delim(paste0(filepath,'/',file))
  odin_data$date <- as.POSIXct(paste(odin_data$Day,odin_data$Time),tz='Etc/GMT-12')
  Real_time <- time_corrections$real_time[time_id]
  print(odin_sn)
  print(Real_time)
  tdiff = (as.POSIXct(Real_time,format = "%Y-%m-%d %H:%M:%S") - odin_data$date[1])
  print(tdiff)
  odin_data$date <- odin_data$date + tdiff
  print(strftime(odin_data$date[1],format = '%Y-%m-%d %H:%M:%S %Z'))
  odin_data$FrameLength <- NULL
  # # Get last record (date) to upload only newer data
  last_date <- dbGetQuery(con,paste0("SELECT max(fd.recordtime) at time zone 'NZST' as date
                              FROM data.fixed_data fd, admin.instrument i, admin.sensor s
                              WHERE
                        i.id = s.instrumentid AND
                        fd.sensorid = s.id AND
                        i.serialn = '",odin_sn,"';"))
  # Subset the data to only use data not already uploaded
  if (!is.na(last_date$date)){
    new_odin_data <- subset(odin_data, date>last_date$date)
  }
  else {
    new_odin_data <- odin_data
  }
  
  # Find the site ####
  # Use NIWA chch as dummy site for data upload only
  siteid <- dbGetQuery(con,"SELECT id FROM admin.fixedsites WHERE type = 'dummy';" )
  # Find instrument id
  instrumentid <- dbGetQuery(con,paste0("SELECT id FROM admin.instrument WHERE serialn = '",odin_sn,"';"))
  # Find sensor ids
  # PM1,PM2.5,PM10,xPM1,xPM2.5,xPM10,Data7,Data8,Data9,Temperature,RH
  sensornames <- c('Day','Time','PM1','PM2.5','PM10','xPM1','XPM2.5','xPM10','Data7','Data8','Data9','Temperature','RH')
  sensorid <- c(1:length(sensornames))
  for (i in (1:length(sensornames))){
    sensorid[i] <- as.numeric(dbGetQuery(con,paste0("SELECT id FROM admin.sensor WHERE instrumentid = ",instrumentid," AND name = '",sensornames[i],"';")))
  }
  # Get dataflag
  dataflag <- as.numeric(dbGetQuery(con,"SELECT id FROM admin.dataflags WHERE definition = 'RAW';"))
  # Write the table to copy ####
  psqlscript <- file(paste0(filepath,"/sql/",odin_sn,".csv"),open = "wt")
  for (i in (1:length(new_odin_data[,1]))){
    for (j in (1:length(sensorid))){
      writeLines(paste0(siteid,"\t'",
                        strftime(new_odin_data$date[i],format = '%Y-%m-%d %H:%M:%S %Z'),"'\t",
                        sensorid[j],"\t'",
                        as.character(new_odin_data[i,j]),"'\t",dataflag),psqlscript)
    }
  }
  close(psqlscript)
  print(length(new_odin_data[,1]))
}
dbDisconnect(con)
