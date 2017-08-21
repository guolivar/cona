##### Load relevant packages #####
library(RPostgreSQL)
library(readr)
library(doParallel)
##### Set the working directory DB ####
setwd("~/repositories/cona/DB")
##### Set the path where location info is #####
filepath <- '~/data/CONA/2017/RAW/odin'
##### Read the credentials file (hidden file not on the GIT repository) ####
access <- read.delim("./.cona_login")

##### Read parameters ####
deployment <- read.delim(paste0(filepath,'/Instrument_Deployment_Register_ODIN.csv'))
nchanges = length(deployment$serialn)
#all_trajectories <- foreach(i=1:nchanges,.packages=c("RPostgreSQL"),.combine=rbind) %dopar% {
  ##### Open ADMIN connection to the DB ####
p <- dbDriver("PostgreSQL")
con<-dbConnect(p,
               user=as.character(access$usr[1]),
               password=as.character(access$pwd[1]),
               host='penap-data.dyndns.org',
               dbname='cona',
               port=5432)
for (i in (1:nchanges)){
  serialn = as.character(deployment$serialn[i])
  date1 = as.character(deployment$date1[i])
  date2 = as.character(deployment$date2[i])
  site = deployment$site[i]
  if (nchar(date1)<5){
    date1 <- "2017-01-01 00:00:00 NZST"
  }
  if (nchar(date2)<5){
    date2 <- "2018-01-01 00:00:00 NZST"
  }
  print(serialn)
  print(date1)
  print(date2)
  print(site)
  
  data <- dbGetQuery(con,paste0("UPDATE data.fixed_data
                              SET siteid = ",
                              site,
                              " WHERE id in
                              (select d.id from data.fixed_data as d, admin.sensor as s, admin.instrument as i
                              where
                              	d.recordtime > '",
                                date1,
                                "' AND
                              	d.recordtime < '",
                                date2,
                                "' AND
                              	s.id = d.sensorid AND
                              	s.instrumentid = i.id AND
                              	i.serialn = '",serialn,"')"))
  #}
  ### Close the connection ####
  print(data)
}
dbDisconnect(con)
