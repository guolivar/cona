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
files <- list.files(filepath,pattern = '*.txt')
serialn <- substr(files,1,8)
for (file in files){
  # Extract the serial number from the filenames
  ##### Read the raw odin file ####
  odin_sn <- substr(file,1,8)
  odin_data <- read.delim(paste0(filepath,'/',file))
  odin_data$date <- as.POSIXct(paste(odin_data$Day,odin_data$Time),tz='Etc/GMT+12')
  Real_time <- "2016-07-12 09:32:00"
  tdiff = (as.POSIXct(Real_time,format = "%Y-%m-%d %H:%M:%S") - odin_data$date[1])
  odin_data$date <- odin_data$date + tdiff
  odin_data$FrameLength <- NULL
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
  # Push data to the DB ####
  
  for (i in (1:length(odin_data[,1]))){
    for (j in (1:length(sensorid))){
      ok <- dbGetQuery(con,paste0("INSERT INTO data.fixed_data(id,siteid,recordtime,sensorid,value,flagid)
                                  VALUES(DEFAULT,",
                                  siteid,",'",
                                  odin_data$date[i],"+12',",
                                  sensorid[1],",'",
                                  as.character(odin_data[i,j]),"',",dataflag,");"))
    }
  }
}
dbDisconnect(con)

