library(RPostgreSQL)
#library(reshape2) # - got it from Gus's script - but I don't think it is required for what I'm doing.

# Database connection
### no indoor data for house id = 10 and 7

p <- dbDriver("PostgreSQL")

con<-dbConnect(p,
               user='cona_data',
               password='conauser',
               host='penap-data.dyndns.org',
               dbname='cona',
               port=5432)


##########################################################################

## Columnwise PACMAN data access (ONLY columns - [PM, CO, CO2, Movement]) - columnwise - 
## extremely slow

PACMAN_data <- dbGetQuery(con," SELECT d1.recordtime at time zone 'NZST' as date,
                           d1.value::numeric as pm, d2.value::numeric as co, d3.value::numeric as co2,
                           d4.value as Movement,
                           d1.instrument as instrument, d1.house as house
                           
                           from (SELECT d.recordtime at time zone 'NZST' as recordtime, d.value as value, 
                           i.serialn as instrument, h.id as house
                           FROM data.indoor_data as d, admin.sensor as s, admin.instrument as i,admin.house as h
                           WHERE s.id = d.sensorid AND
                           s.instrumentid = i.id AND
                           d.houseid = h.id AND
                           i.serialn = 'PACMAN-16' AND
                           s.name = 'PM') as d1,
                           
                           (SELECT d.recordtime at time zone 'NZST' as recordtime, d.value as value
                           FROM data.indoor_data as d, admin.sensor as s, admin.instrument as i, admin.house as h
                           WHERE s.id = d.sensorid AND
                           s.instrumentid = i.id AND
                           d.houseid = h.id AND
                           i.serialn = 'PACMAN-16' AND
                           s.name = 'CO') as d2,
                           
                           (SELECT d.recordtime at time zone 'NZST' as recordtime, d.value as value
                           FROM data.indoor_data as d, admin.sensor as s, admin.instrument as i, admin.house as h
                           WHERE s.id = d.sensorid AND
                           s.instrumentid = i.id AND
                           d.houseid = h.id AND
                           i.serialn = 'PACMAN-16' AND
                           s.name = 'CO2') as d3,

                           (SELECT d.recordtime at time zone 'NZST' as recordtime, d.value as value
                           FROM data.indoor_data as d, admin.sensor as s, admin.instrument as i, admin.house as h
                           WHERE s.id = d.sensorid AND
                           s.instrumentid = i.id AND
                           d.houseid = h.id AND
                           i.serialn = 'PACMAN-16' AND
                           s.name = 'Movement') as d4
                           WHERE
                           d1.recordtime = d2.recordtime AND
                           d1.recordtime = d3.recordtime AND
                           d1.recordtime = d4.recordtime;")


## Split data housewise.

HOUSEIDS <- unique(PACMAN_data$house)
f <- data.frame()

for (i in 1:length(HOUSEIDS)) {
  current_house <- HOUSEIDS[i]
  pacman_name <- PACMAN_data$instrument[1]
  f <- PACMAN_data[which(PACMAN_data$house == current_house),]
  write.csv(f, paste("S:/kachharaa/CONA/PACMAN/",pacman_name,"_house_",current_house,".csv"))
}

