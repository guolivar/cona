##### Load relevant packages #####
library("RPostgreSQL")
##### Set the working directory DB ####
setwd("~/repositories/cona/DB")
##### Read the credentials file (hidden) ####
access <- read.delim("./.cona_login")
##### Open the connection to the DB ####
p <- dbDriver("PostgreSQL")
con<-dbConnect(p,
               user=as.character(access$usr[1]),
               password=as.character(access$pwd[1]),
               host='localhost',
               dbname='cona',
               port=5432)
##### ADD Institutions #####
# Read info from file
# Check if empty file
if (file.size("./institutions.txt")>1){
  institutions <- read.delim("./institutions.txt")
  nrecs<-length(institutions[,1])
  # Run SQL queries on the DB
  for (i in 1:nrecs){
    rs<-dbGetQuery(con,paste0("insert into admin.institution
                              values(DEFAULT,'",institutions[i,1],"','",institutions[i,2],"');"))
  }
}

##### ADD Woodburner #####
# Read info from file
if (file.size("./woodburners.txt")>1){
  woodburners <- read.delim("./woodburners.txt")
  nrecs<-length(woodburners[,1])
  # Run inserts to the DB
  for (i in 1:nrecs){
    rs<-dbGetQuery(con,paste0("insert into woodburner
                              values(DEFAULT,'",woodburners$makemodel[i],"');"))
  }
}
##### ADD Instruments #####
# Read info from file
if (file.size("./instruments.txt")>1){
  instruments <- read.delim("./instruments.txt")
  nrecs<-length(instruments[,1])
  # Run SQL queries on the DB
  for (i in 1:nrecs){
    institutionid<-dbGetQuery(con,paste0("select id from admin.institution as ins
                                         where ins.name='",instruments$OwnerName[i],"';"))
    rs<-dbGetQuery(con,paste0("insert into admin.instrument
                 values(DEFAULT,'",instruments$SN[i],"','",instruments$Name[i],"','",instruments$Notes[i],"',",institutionid,");"))
  }
}

##### ADD Sensors #####
# Read info from file
# Run SQL queries on the DB
# Get instrument IDs
inst_idName<-dbGetQuery(con,"select id, name from admin.instrument")
ninst<-length(inst_idName$id)
for (i in 1:ninst){
# i=inst_idName$id[1]
  # For each instrument, load the sensors info from the file
  if (file.size(paste0("./",inst_idName$name[i],".txt"))>1){
    sensors <- read.delim(paste0("./",inst_idName$name[i],".txt"))
    nrecs<-length(sensors[,1])
    for (j in 1:nrecs){
      rs<-dbGetQuery(con,paste0("insert into admin.sensor
                              values(DEFAULT,'",sensors$Name[j],"','",sensors$Units[j],"',",inst_idName$id[i],");"))
    }
  }
}

##### Add Participant ####
# Read info from file (file is hidden)
participant <- read.delim('./participants.txt')
nrecs<-length(participant[,1])
# Run inserts to the DB
for (i in 1:nrecs){
  rs<-dbGetQuery(con,paste0("insert into confidential.participant(id,name,houseid,email,phone,address)
    values(DEFAULT,'",
        as.character(participant$Name[i]),"',1,'",
        as.character(participant$Email[i]),"','",
        as.character(participant$Phone[i]),"','",
        as.character(participant$Address[i]),"');"))
}

##### Add homes

point_locations <- read.delim('./to_link_mb.txt')
mb2013id <- 0*(1:nrow(point_locations))
for (i in (1:nrow(point_locations))){
  mb2013id[i] <- as.numeric(dbGetQuery(con,paste0("select mb2013
                                      from external.meshblock
                                      where ST_Contains(geom, ST_SetSRID(ST_MakePoint(",
                                    point_locations$Lon[i],",",point_locations$Lat[i],"),4326));")))
}
point_locations$mbid <- mb2013id









dbDisconnect(con)




