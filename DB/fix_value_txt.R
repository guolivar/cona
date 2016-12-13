# Fix the mess of ' in the value fields of data tables
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

# Update in-line
st <- dbGetQuery(con, paste0("UPDATE data.indoor_data ",
                             "SET value = replace(value,",
                             "',,)",
                             "WHERE sensorid in ",
                             "(select id from admin.sensor",
                             " where name!='Time' and",
                             " name !='DateTime' and",
                             " name !='Day' and",
                             " name !='Date'"))
  }
}
close(con)
