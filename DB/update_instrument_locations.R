##### Load relevant packages #####
library(RPostgreSQL)
##### Set the working directory DB ####
setwd("~/repositories/cona/DB")
##### Set the path where location info is #####
filepath <- '/home/gustavo/data_gustavo/cona'
##### Read the credentials file (hidden file not on the GIT repository) ####
access <- read.delim("./.cona_login")
##### Open ADMIN connection to the DB ####
p <- dbDriver("PostgreSQL")
con<-dbConnect(p,
               user=as.character(access$user[1]),
               password=as.character(access$pwd[1]),
               host='penap-data.dyndns.org',
               dbname='cona',
               port=5432)


##### Read parameters ####
deployment <- read.delim(paste0(filepath,'/indoor_deployment.txt'))
nchanges = length(deployment$serialn)
for (i in (1:nchanges)){
  serialn = as.character(deployment$serialn[i])
  date1 = as.character(deployment$date1[i])
  date2 = as.character(deployment$date2[i])
  site = deployment$house[i]
  print(serialn)
  print(date1)
  print(date2)
  print(site)
  data <- dbGetQuery(con,paste0("UPDATE data.indoor_data
                              SET houseid = ",
                              site,
                              " WHERE id in
                              (select d.id from data.indoor_data as d, admin.sensor as s, admin.instrument as i
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
}
### Close the connection ####
dbDisconnect(con)
