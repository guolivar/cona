# AE51 diagnostic ####
# Load Libraries ####
library('openair')
library('ggplot2')
library('reshape2')
# Load the data ####
ae51 <- read.csv("~/data/CONA/Helikite/ae51.dat", sep=";")
ae51$date <- as.POSIXct(paste(ae51$Day,ae51$Time))
timePlot(ae51,pollutant = c('Ref','Sen'))
