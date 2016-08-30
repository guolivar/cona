##### Load relevant packages #####
library("RPostgreSQL")
##### Open the connection to the DB ####
p <- dbDriver("PostgreSQL")
con<-dbConnect(p,user='adm_penap',password='p3n@p@dm',host='localhost',dbname='didactic',port=5432)
#con<-dbConnect(p,user='penap',password='p3n@p',host='localhost',dbname='didactic',port=5432)
##### Update Institutions #####
# Read info from file
institutions <- read.delim("./institutions.txt")
nrecs<-length(institutions[,1])
# Run SQL queries on the DB
for (i in 1:nrecs){
  rs<-dbGetQuery(con,paste0("insert into admin.institutions
               values(DEFAULT,'",institutions[i,1],"','",institutions[i,2],"');"))
}

##### Update PEOPLE #####
# Read info from file
people <- read.delim("./people.txt")
nrecs<-length(people[,1])
# Run inserts to the DB
for (i in 1:nrecs){
  institutionid<-dbGetQuery(con,paste0("select id from admin.institutions as ins
                                       where ins.name='",people$InstitutionName[i],"' and
                                       ins.notes='",people$InstitutionNotes[i],"';"))
  rs<-dbGetQuery(con,paste0("insert into admin.people
               values(DEFAULT,'",people$Name[i],"',",institutionid,",'",people$Notes,"');"))
}
##### Update Instruments #####
# Read info from file
instruments <- read.delim("./instruments.txt")
nrecs<-length(instruments[,1])
# Run SQL queries on the DB
for (i in 1:nrecs){
  institutionid<-dbGetQuery(con,paste0("select id from admin.institutions as ins
                                       where ins.name='",instruments$OwnerName[i],"' and
                                       ins.notes='",instruments$OwnerNotes[i],"';"))
  rs<-dbGetQuery(con,paste0("insert into admin.instruments
               values(DEFAULT,'",instruments$SN[i],"','",instruments$Name[i],"','",instruments$Notes[i],"',",institutionid,");"))
}

##### Update Sensors #####
# Read info from file
# Run SQL queries on the DB
# Get instrument IDs
inst_idName<-dbGetQuery(con,"select id, name from admin.instruments")
ninst<-length(inst_idName$id)
for (i in 1:ninst){
# i=inst_idName$id[1]
  # For each instrument, load the sensors info from the file
  sensors <- read.delim(paste0("./",inst_idName$name[i],".txt"))
  nrecs<-length(sensors[,1])
  for (j in 1:nrecs){
    rs<-dbGetQuery(con,paste0("insert into admin.sensors
                            values(DEFAULT,'",sensors$Name[j],"','",sensors$Units[j],"',",inst_idName$id[i],");"))
  }
}
dbDisconnect(con)