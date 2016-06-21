# PM2.5 spectrometer tests
library('ggplot2')
library('openair')
library('lubridate')
library('corrgram')
library('corrplot')

# GRIMM 107 data
grimm.107 <- read.csv("/home/gustavo/data/CONA/2016/PACMAN_co-location/Grimm/parsed_grimm.txt", sep="")
grimm.107$date <- ISOdatetime(year = 2016,
                              month = grimm.107$Month, 
                              day = grimm.107$Day,
                              hour = grimm.107$Hour,
                              min = grimm.107$Minute, 
                              sec = grimm.107$Second, tz = "UTC")
# Convert counts data into pt/cc (raw comes as pt/1000cc)
grimm.107[,17:47] <- grimm.107[,17:47] / 1000

# Plotting

timePlot(grimm.107,pollutant = c('n265','n424','n1140','n2739','n9220'))

# Save data
write.csv(grimm.107,file = '/home/gustavo/data/CONA/2016/PACMAN_co-location/Grimm/parsed_grimm.csv')

#+ fig.width=10, fig.height=5
timePlot(grimm.107,pollutant = c('n265',
                                   'n290',
                                   'n324',
                                   'n374',
                                   'n424',
                                   'n539',
                                   'n614')
         ,avg.time = '5 min'
         ,normalise = 'mean'
         ,group = TRUE)


#+ fig.width=10, fig.height=5
for_correl <- grimm.107[,c(17:47)]
find_channels <- cor(for_correl,use = 'pairwise')

corrplot(find_channels,method = 'circle')

