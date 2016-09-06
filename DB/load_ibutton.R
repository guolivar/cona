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
filepath <- '/home/gustavo/data_gustavo/cona/pacman'
files <- list.files(filepath,pattern = 'PACMAN*')
serialn <- substr(files,1,9)
for (file in files){
  # Extract the serial number from the filenames
  ##### Read the raw odin file ####
  print(pacman_sn <- substr(files[1],1,9))
  pacman_data <- read.delim(paste0(filepath,'/',file))
  pacman_data$date<-ISOdatetime(year=pacman_data$Year,
                                month=pacman_data$Month,
                                day=pacman_data$Day,
                                hour=pacman_data$Hour,
                                min=pacman_data$Minute,
                                sec=pacman_data$Second,
                                tz="NZST")
  pacman_data$Count <- NULL
  pacman_data$Year <- NULL
  pacman_data$Month <- NULL
  pacman_data$Day <- NULL
  pacman_data$Hour <- NULL
  pacman_data$Minute <- NULL
  pacman_data$Second <- NULL
  pacman_data$Day <- strftime(pacman_data$date, format="%Y/%m/%d")
  pacman_data$Time <- strftime(pacman_data$date, format="%H:%M:%S")
  # Find the house ####
  # Use house N1 as dummy site for data upload only
  siteid <- 1
  # Find instrument id
  instrumentid <- dbGetQuery(con,paste0("SELECT id FROM admin.instrument WHERE serialn = '",pacman_sn,"';"))
  # Find sensor ids
  #   c('Day','Time','Distance','TmpOUT','TmpIN','PM','CO2','CO','Movement','COstatus')
  sensornames <- c('Day','Time','Distance','TmpOUT','TmpIN','PM','CO2','CO','Movement','COstatus')
  pacman_data <- pacman_data[c(sensornames,'date')]
  sensorid <- c(1:length(sensornames))
  for (i in (1:length(sensornames))){
    sensorid[i] <- as.numeric(dbGetQuery(con,paste0("SELECT id FROM admin.sensor WHERE instrumentid = ",instrumentid," AND name = '",sensornames[i],"';")))
  }
  # Get dataflag
  dataflag <- as.numeric(dbGetQuery(con,"SELECT id FROM admin.dataflags WHERE definition = 'RAW';"))
  # Push data to the DB ####
  
  for (i in (1:length(pacman_data[,1]))){
    for (j in (1:length(sensorid))){
      ok <- dbGetQuery(con,paste0("INSERT INTO data.indoor_data(id,siteid,recordtime,sensorid,value,flagid)
                                  VALUES(DEFAULT,",
                                  siteid,",'",
                                  pacman_data$date[i]," NZST',",
                                  sensorid[j],",'",
                                  as.character(pacman_data[i,j]),"',",dataflag,");"))
    }
  }
}
dbDisconnect(con)

