## Load PACMANv5 data
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
for (file in files){
  # Extract the serial number from the filenames
  ##### Read the raw odin file ####
  print(pacman_sn <- substr(file,1,9))
  pacman_data <- read.delim(paste0(filepath,'/',file))
  pacman_data$date<-ISOdatetime(year=pacman_data$Year,
                                month=pacman_data$Month,
                                day=pacman_data$Day,
                                hour=pacman_data$Hour,
                                min=pacman_data$Minute,
                                sec=pacman_data$Second,
                                tz='Etc/GMT-12')
  pacman_data$Count <- NULL
  pacman_data$Year <- NULL
  pacman_data$Month <- NULL
  pacman_data$Day <- NULL
  pacman_data$Hour <- NULL
  pacman_data$Minute <- NULL
  pacman_data$Second <- NULL
  pacman_data$Day <- strftime(pacman_data$date, format="%Y/%m/%d")
  pacman_data$Time <- strftime(pacman_data$date, format="%H:%M:%S")
  # Find the site ####
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
    sensorid[i] <- as.numeric(dbGetQuery(con,paste0("SELECT id FROM admin.sensor
                                                    WHERE instrumentid = ",instrumentid,
                                                    " AND name = '",sensornames[i],"';")))
  }
  # Get dataflag
  dataflag <- as.numeric(dbGetQuery(con,"SELECT id FROM admin.dataflags WHERE definition = 'RAW';"))
  # Write the insert queriesPush data to the DB ####
  nblocks <- 9
  step <- floor(length(pacman_data[,1])/nblocks)
  for (s in (1:(nblocks-1))){
    print(s)
    psqlscript <- file(paste0(pacman_sn,"_",s,".csv"),open = "wt")
    writeLines("houseid\trecordtime\tsensorid\tvalue\tflagid",psqlscript)
    for (i in ((1+(s-1)*step):((s*step)))){
      for (j in (1:length(sensorid))){
        writeLines(paste0(siteid,"\t'",
                          strftime(pacman_data$date[i],format = '%Y-%m-%d %H:%M:%S %Z'),"'\t",
                          sensorid[j],"\t'",
                          as.character(pacman_data[i,j]),"'\t",dataflag),psqlscript)
      }
    }
    close(psqlscript)
  }
  s<-nblocks
  psqlscript <- file(paste0(pacman_sn,"_",s,".csv"),open = "wt")
  writeLines("houseid\trecordtime\tsensorid\tvalue\tflagid",psqlscript)
  for (i in ((1+(s-1)*step):((s*step)))){
    for (j in (1:length(sensorid))){
      writeLines(paste0(siteid,"\t'",
                        strftime(pacman_data$date[i],format = '%Y-%m-%d %H:%M:%S %Z'),"'\t",
                        sensorid[j],"\t'",
                        as.character(pacman_data[i,j]),"'\t",dataflag),psqlscript)
    }
  }
  close(psqlscript)
}
dbDisconnect(con)

