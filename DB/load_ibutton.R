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
filepath <- '/home/gustavo/data_gustavo/cona/ibutton'
files <- list.files(filepath,pattern = '*.csv')
serialn <- substr(files,1,9)
for (file in files){
  # Extract the serial number from the filenames
  ##### Read the raw ibutton file ####
  # Deal with the _X files that randoml
  print(ibutton_sn <- substr(file,1,9))
  ibuton <- read.csv(paste0(filepath,'/',file),skip = 19)
  ibuton$date <- as.POSIXct(ibuton$Date.Time,format = '%d/%m/%y %I:%M:%S %p',tz = 'Etc/GMT-12')
  ibuton$Unit <- NULL
  names(ibuton) <- c('Datetime','Temperature','date')

  # Find the site ####
  # Use house N1 as dummy site for data upload only
  siteid <- 1
  # Find instrument id
  instrumentid <- dbGetQuery(con,paste0("SELECT id FROM admin.instrument WHERE serialn = '",ibutton_sn,"';"))
  # Find sensor ids
  #   c('Day','Time','Distance','TmpOUT','TmpIN','PM','CO2','CO','Movement','COstatus')
  sensornames <- c('DateTime','Temperature')
  ibuton <- pacman_data[c(sensornames,'date')]
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
  step <- floor(length(ibuton[,1])/nblocks)
  for (s in (1:(nblocks-1))){
    print(s)
    psqlscript <- file(paste0(ibutton_sn,"_",s,".csv"),open = "wt")
    writeLines("houseid\trecordtime\tsensorid\tvalue\tflagid",psqlscript)
    for (i in ((1+(s-1)*step):((s*step)))){
      for (j in (1:length(sensorid))){
        writeLines(paste0(siteid,"\t'",
                          strftime(ibuton$date[1],format = '%Y-%m-%d %H:%M:%S', usetz = TRUE),"'\t",
                          sensorid[j],"\t'",
                          as.character(ibuton[i,j]),"'\t",dataflag),psqlscript)
      }
    }
    close(psqlscript)
  }
  s<-nblocks
  psqlscript <- file(paste0(ibuton,"_",s,".csv"),open = "wt")
  writeLines("houseid\trecordtime\tsensorid\tvalue\tflagid",psqlscript)
  for (i in ((1+(s-1)*step):((s*step)))){
    for (j in (1:length(sensorid))){
      writeLines(paste0(siteid,"\t'",
                        strftime(ibuton$date[1],format = '%Y-%m-%d %H:%M:%S %Z'),"'\t",
                        sensorid[j],"\t'",
                        as.character(ibuton[i,j]),"'\t",dataflag),psqlscript)
    }
  }
  close(psqlscript)
}
dbDisconnect(con)
