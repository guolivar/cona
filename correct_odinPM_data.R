# Set the seed ####
set.seed(2001)
##### Load relevant packages #####
library(RPostgreSQL)
library(reshape2)
library(ggplot2)
library(openair)
##### Set the working directory DB ####
setwd("~/repositories/cona/DB")
##### Set the path where location info is #####
filepath <- '~/data/CONA/2016'
##### Read the credentials file (hidden file not on the GIT repository) ####
access <- read.delim("./.cona_login", stringsAsFactors = FALSE)
##### Open DATA connection to the DB ####
p <- dbDriver("PostgreSQL")
con<-dbConnect(p,
               user=access$usr[1],
               password=access$pwd[1],
               host='penap-data.dyndns.org',
               dbname='cona',
               port=5432)
# Load correction factors (slope and intercept) from Database for each sensor ####
fit_coeffs <- dbGetQuery(con,"SELECT * FROM metadata.odin_sd_calibration")
# Correct the data sensor by sensor ####
for (i in (1:nrow(fit_coeffs))){
  sensorid <- fit_coeffs$sensorid[i]
  slope <-fit_coeffs$slope[i]
  inter <- fit_coeffs$intercept[i]
  st <- dbGetQuery(con,paste0("UPDATE data.fixed_data
                              SET flagid=3, value = value*",slope," + ",inter,
                              " WHERE sensorid=",sensorid,";"))
}
dbDisconnect(con)