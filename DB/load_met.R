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
filepath <- '/data/data_gustavo/from_niwa/Met/'
## Rangiora Long Term weather EWS
print(file <- 'rangiora.csv')
# Extract the serial number from the filenames
met_sn <- '2125'
siteid <- 19
met_data <- read.csv(paste0(filepath,file))
met_data$date <- as.POSIXct(paste(met_data$Date,met_data$Time),format = '%d/%m/%Y %H:%M:%S',tz='Etc/GMT-12')

# Find instrument id
instrumentid <- dbGetQuery(con,paste0("SELECT id FROM admin.instrument WHERE serialn = '",met_sn,"';"))
# Find sensor ids
# Name	Units
# Date	DD/MM/YYYY
# Time	HH:MM:SS
# ws	m/s         Mean.WS.RAW...m.s.
# wd	degN        Mean.WD.RAW...degN..
# Temperature	C   Temperature.AVG...degC..
# RH	%           RH.AVG......
# Rain	mm        Rain.TOT...mm..
# Pressure	hPa   Barometric.Pressure.AVG...Hpa..
# Srad	w/m2      Solar.Radiation.AVG...W.m2..

met_data <- met_data[,c('Mean.WS.RAW...m.s.',
                        'Mean.WD.RAW...degN..',
                        'Temperature.AVG...degC..',
                        'RH.AVG......',
                        'Rain.TOT...mm..',
                        'Barometric.Pressure.AVG...Hpa..',
                        'Solar.Radiation.AVG...W.m2..',
                        'date')]
names(met_data) <- c('ws',
                     'wd',
                     'Temperature',
                     'RH',
                     'Rain',
                     'Pressure',
                     'Srad',
                     'date')

sensornames <- c('ws',
                 'wd',
                 'Temperature',
                 'RH',
                 'Rain',
                 'Pressure',
                 'Srad')
sensorid <- c(1:length(sensornames))
for (i in (1:length(sensornames))){
  sensorid[i] <- as.numeric(dbGetQuery(con,paste0("SELECT id FROM admin.sensor
                                                  WHERE instrumentid = ",instrumentid[[1]],
                                                  " AND name = '",sensornames[i],"';")))
}
# Get dataflag
dataflag <- as.numeric(dbGetQuery(con,"SELECT id FROM admin.dataflags WHERE definition = 'RAW';"))
# Write the insert queries ####

psqlscript <- file(paste0("./sql_met_",met_sn,".csv"),open = "wt")
for (i in (1:length(met_data$date))){
  for (j in (1:length(sensorid))){
    writeLines(paste0(siteid,"\t'",
                      strftime(met_data$date[i],format = '%Y-%m-%d %H:%M:%S %Z'),"'\t",
                      sensorid[j],"\t'",
                      as.character(met_data[i,j]),"'\t",dataflag),psqlscript)
  }
}
close(psqlscript)


## Rangiora AQ1 ####
print(file <- 'rangiora_AQ1.csv')
# Extract the serial number from the filenames
met_sn <- '2742'
siteid <- 16
met_data <- read.csv(paste0(filepath,file))
met_data$date <- as.POSIXct(paste(met_data$Date,met_data$Time),format = '%d/%m/%Y %H:%M:%S',tz='Etc/GMT-12')
# No rain data so added empty column
met_data$Rain <- NA
# Find instrument id
instrumentid <- dbGetQuery(con,paste0("SELECT id FROM admin.instrument WHERE serialn = '",met_sn,"';"))
# Find sensor ids
# Name	Units
# Date	DD/MM/YYYY
# Time	HH:MM:SS
# ws	m/s         Mean.WS.RAW...m.s..
# wd	degN        Mean.WD.RAW...degN.
# Temperature	C   Temperature.AVG...degC..
# RH	%           RH.AVG...pct..
# Rain	mm        Rain
# Pressure	hPa   Barometric.Pressure.AVG...hPa..
# Srad	w/m2      Solar.Radiation.RAW...W.m...

met_data <- met_data[,c('Mean.WS.RAW...m.s..',
                        'Mean.WD.RAW...degN.',
                        'Temperature.AVG...degC..',
                        'RH.AVG...pct..',
                        'Rain',
                        'Barometric.Pressure.AVG...hPa..',
                        'Solar.Radiation.RAW...W.m...',
                        'date')]
names(met_data) <- c('ws',
                     'wd',
                     'Temperature',
                     'RH',
                     'Rain',
                     'Pressure',
                     'Srad',
                     'date')

sensornames <- c('ws',
                 'wd',
                 'Temperature',
                 'RH',
                 'Rain',
                 'Pressure',
                 'Srad')
sensorid <- c(1:length(sensornames))
for (i in (1:length(sensornames))){
  sensorid[i] <- as.numeric(dbGetQuery(con,paste0("SELECT id FROM admin.sensor
                                                  WHERE instrumentid = ",instrumentid[[1]],
                                                  " AND name = '",sensornames[i],"';")))
}
# Get dataflag
dataflag <- as.numeric(dbGetQuery(con,"SELECT id FROM admin.dataflags WHERE definition = 'RAW';"))
# Write the insert queries ####

psqlscript <- file(paste0("./sql_met_",met_sn,".csv"),open = "wt")
for (i in (1:length(met_data$date))){
  for (j in (1:length(sensorid))){
    writeLines(paste0(siteid,"\t'",
                      strftime(met_data$date[i],format = '%Y-%m-%d %H:%M:%S %Z'),"'\t",
                      sensorid[j],"\t'",
                      as.character(met_data[i,j]),"'\t",dataflag),psqlscript)
  }
}
close(psqlscript)

## Rangiora AQ2 ####
print(file <- 'rangiora_AQ2.csv')
# Extract the serial number from the filenames
met_sn <- '3179'
siteid <- 15
met_data <- read.csv(paste0(filepath,file))
met_data$date <- as.POSIXct(paste(met_data$Date,met_data$Time),format = '%d/%m/%Y %H:%M:%S',tz='Etc/GMT-12')
# No rain data so added empty column
met_data$Rain <- NA
# Find instrument id
instrumentid <- dbGetQuery(con,paste0("SELECT id FROM admin.instrument WHERE serialn = '",met_sn,"';"))
# Find sensor ids
# Name	Units
# Date	DD/MM/YYYY
# Time	HH:MM:SS
# ws	m/s         Mean.WS.RAW...m.s..
# wd	degN        Mean.WD.RAW...degN..
# Temperature	C   Temperature.AVG...degC.
# RH	%           RH.AVG...pct..
# Rain	mm        Rain
# Pressure	hPa   Barometric.Pressure.AVG...hPa..
# Srad	w/m2      Solar.Radiation.RAW...W.m...

met_data <- met_data[,c('Mean.WS.RAW...m.s..',
                        'Mean.WD.RAW...degN..',
                        'Temperature.AVG...degC.',
                        'RH.AVG...pct..',
                        'Rain',
                        'Barometric.Pressure.AVG...hPa..',
                        'Solar.Radiation.RAW...W.m...',
                        'date')]
names(met_data) <- c('ws',
                     'wd',
                     'Temperature',
                     'RH',
                     'Rain',
                     'Pressure',
                     'Srad',
                     'date')

sensornames <- c('ws',
                 'wd',
                 'Temperature',
                 'RH',
                 'Rain',
                 'Pressure',
                 'Srad')
sensorid <- c(1:length(sensornames))
for (i in (1:length(sensornames))){
  sensorid[i] <- as.numeric(dbGetQuery(con,paste0("SELECT id FROM admin.sensor
                                                  WHERE instrumentid = ",instrumentid[[1]],
                                                  " AND name = '",sensornames[i],"';")))
}
# Get dataflag
dataflag <- as.numeric(dbGetQuery(con,"SELECT id FROM admin.dataflags WHERE definition = 'RAW';"))
# Write the insert queries ####

psqlscript <- file(paste0("./sql_met_",met_sn,".csv"),open = "wt")
for (i in (1:length(met_data$date))){
  for (j in (1:length(sensorid))){
    writeLines(paste0(siteid,"\t'",
                      strftime(met_data$date[i],format = '%Y-%m-%d %H:%M:%S %Z'),"'\t",
                      sensorid[j],"\t'",
                      as.character(met_data[i,j]),"'\t",dataflag),psqlscript)
  }
}
close(psqlscript)

## Rangiora AQ3 ####
print(file <- 'rangiora_AQ3.csv')
# Extract the serial number from the filenames
met_sn <- '2744'
siteid <- 17
met_data <- read.csv(paste0(filepath,file))
met_data$date <- as.POSIXct(paste(met_data$Date,met_data$Time),format = '%d/%m/%Y %H:%M:%S',tz='Etc/GMT-12')
# No rain data so added empty column
met_data$Rain <- NA
# Find instrument id
instrumentid <- dbGetQuery(con,paste0("SELECT id FROM admin.instrument WHERE serialn = '",met_sn,"';"))
# Find sensor ids
# Name	Units
# Date	DD/MM/YYYY
# Time	HH:MM:SS
# ws	m/s         Mean.WS.RAW...m.s..
# wd	degN        Mean.WD.RAW...degN..
# Temperature	C   Temperature.AVG...degC.
# RH	%           RH.AVG...pct..
# Rain	mm        Rain
# Pressure	hPa   Barometric.Pressure.AVG...hPa..
# Srad	w/m2      Solar.Radiation.RAW...W.m...

met_data <- met_data[,c('Mean.WS.RAW...m.s..',
                        'Mean.WD.RAW...degN..',
                        'Temperature.AVG...degC.',
                        'RH.AVG...pct..',
                        'Rain',
                        'Barometric.Pressure.AVG...hPa..',
                        'Solar.Radiation.RAW...W.m...',
                        'date')]
names(met_data) <- c('ws',
                     'wd',
                     'Temperature',
                     'RH',
                     'Rain',
                     'Pressure',
                     'Srad',
                     'date')

sensornames <- c('ws',
                 'wd',
                 'Temperature',
                 'RH',
                 'Rain',
                 'Pressure',
                 'Srad')
sensorid <- c(1:length(sensornames))
for (i in (1:length(sensornames))){
  sensorid[i] <- as.numeric(dbGetQuery(con,paste0("SELECT id FROM admin.sensor
                                                  WHERE instrumentid = ",instrumentid[[1]],
                                                  " AND name = '",sensornames[i],"';")))
}
# Get dataflag
dataflag <- as.numeric(dbGetQuery(con,"SELECT id FROM admin.dataflags WHERE definition = 'RAW';"))
# Write the insert queries ####

psqlscript <- file(paste0("./sql_met_",met_sn,".csv"),open = "wt")
for (i in (1:length(met_data$date))){
  for (j in (1:length(sensorid))){
    writeLines(paste0(siteid,"\t'",
                      strftime(met_data$date[i],format = '%Y-%m-%d %H:%M:%S %Z'),"'\t",
                      sensorid[j],"\t'",
                      as.character(met_data[i,j]),"'\t",dataflag),psqlscript)
  }
}
close(psqlscript)


dbDisconnect(con)

