## Load iButton data
##### Load relevant packages #####
library("RPostgreSQL")

##### Set the working directory DB ####
#setwd("~/repositories/cona/DB")
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
for (file in files){
  # Extract the serial number from the filenames
  ##### Read the raw ibutton file ####
  len <- nchar(file)
  print(ibutton_sn <- substr(file,1,len-6))
  ibuton <- read.csv(paste0(filepath,'/',file),skip = 19)
  ibuton$date <- as.POSIXct(ibuton$Date.Time,format = '%d/%m/%y %I:%M:%S %p',tz = 'Etc/GMT-12')
  ibuton$Unit <- NULL
  names(ibuton) <- c('DateTime','Temperature','date')

  # Find the site ####
  # Use house N1 as dummy site for data upload only
  siteid <- 1
  # Find instrument id
  instrumentid <- dbGetQuery(con,paste0("SELECT id FROM admin.instrument WHERE serialn = '",ibutton_sn,"';"))
  if (length(instrumentid)==0){
    print(paste("Instrument",ibutton_sn,"not found on database"))
    next
  }
  # Find sensor ids
  #   c('Day','Time','Distance','TmpOUT','TmpIN','PM','CO2','CO','Movement','COstatus')
  sensornames <- c('DateTime','Temperature')
  ibuton <- ibuton[c(sensornames,'date')]
  sensorid <- c(1:length(sensornames))
  for (i in (1:length(sensornames))){
    sensorid[i] <- as.numeric(dbGetQuery(con,paste0("SELECT id FROM admin.sensor
                                                    WHERE instrumentid = ",instrumentid,
                                                    " AND name = '",sensornames[i],"' order by id limit 1;")))
  }
  # Get dataflag
  dataflag <- as.numeric(dbGetQuery(con,"SELECT id FROM admin.dataflags WHERE definition = 'RAW';"))
  # Write the insert queriesPush data to the DB ####
  psqlscript <- file(paste0(filepath,"/sql/",file),open = "wt")
  for (i in (1:length(ibuton[,1]))){
    for (j in (1:length(sensorid))){
      writeLines(paste0(siteid,"\t'",
                        strftime(ibuton$date[i],format = '%Y-%m-%d %H:%M:%S', usetz = TRUE),"'\t",
                        sensorid[j],"\t",
                        as.character(ibuton[i,j]),"\t",dataflag),psqlscript)
    }
  }
  close(psqlscript)
}
dbDisconnect(con)
