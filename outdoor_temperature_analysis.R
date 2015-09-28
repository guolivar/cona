# Ambient temperature analysis
# Load libraries
require('openair')
require('tidyr')
require('data.table')
# Load data
source('./meteorology.R')
source('./ODIN_CONA_diagnostic.R')
# Merge data
analysis.data <- merge(met_data,all_merged.10min,by='date',all = TRUE)
analysis.data <- analysis.data[,c('date'
                                  ,'Temperature..2m'
                                  ,'Temperature..6m'
                                  ,'Tavg.0.1'
                                  ,'Tavg.1.1'
                                  ,'Tavg.2.1'
                                  ,'Tavg.3.1'
                                  ,'Temperature.02'
                                  ,'Temperature.03'
                                  ,'Temperature.04'
                                  ,'Temperature.05'
                                  ,'Temperature.06'
                                  ,'Temperature.07'
                                  )]
# Plots
timePlot(analysis.data,pollutant = c('Temperature..2m'
#                                      ,'Tavg.0.1'
#                                      ,'Tavg.1.1'
#                                      ,'Tavg.2.1'
#                                      ,'Tavg.3.1'
                                     ,'Temperature.02'
                                     ,'Temperature.03'
                                     ,'Temperature.04'
                                     ,'Temperature.05'
                                     ,'Temperature.06'
                                     ,'Temperature.07'
                                     )
         ,group = TRUE
         ,avg.time = '10 min')

timeVariation(analysis.data,pollutant = c('Temperature..2m'
#                                           ,'Tavg.0.1'
#                                           ,'Tavg.1.1'
#                                           ,'Tavg.2.1'
#                                           ,'Tavg.3.1'
                                          ,'Temperature.02'
                                          ,'Temperature.03'
                                          ,'Temperature.04'
                                          ,'Temperature.05'
                                          ,'Temperature.06'
                                          ,'Temperature.07'
)
)


# Extract daytime, nighttime datasets

analysis.data.nighttime <- selectByDate(analysis.data,hour = c(19,20,21,22,23,0,1,2,3,4,5,6,7))
analysis.data.daytime <- selectByDate(analysis.data,hour = 8:18)

summary_manual <- matrix(NA,2,12)
summary_manual[1,] <- apply(analysis.data.nighttime[,-1],2,mean,na.rm = TRUE)
summary_manual[2,] <- apply(analysis.data.daytime[,-1],2,mean,na.rm = TRUE)


# Reshape the dataframe to compare ODIN against Weather station data
analysis.data.long <- gather(analysis.data
                             ,odin_site
                             ,Temperature_ODIN
                             ,Temperature.02
                             ,Temperature.03
                             ,Temperature.04
                             ,Temperature.05
                             ,Temperature.06
                             ,Temperature.07)

analysis.data.long <- gather(analysis.data.long
                             ,met_site
                             ,Temperature_MET
                             ,Tavg.0.1
                             ,Tavg.1.1
                             ,Tavg.2.1
                             ,Tavg.3.1)

max_long <- timeAverage(analysis.data.long
                        ,avg.time = '30 min'
                        ,statistic = 'max')

min_long <- timeAverage(analysis.data.long
                        ,avg.time = '30 min'
                        ,statistic = 'min')

delta_long <- max_long
delta_long$Temperature_MET <- max_long$Temperature_MET - min_long$Temperature_MET
delta_long$Temperature_ODIN <- max_long$Temperature_ODIN - min_long$Temperature_ODIN


timeVariation(delta_long,pollutant = c('Temperature_ODIN','Temperature_MET'))
analysis.data.long <- selectByDate(analysis.data.long,start = '2015-08-17',end = '2015-09-07')


tv_1 <- timeVariation(analysis.data.long,pollutant = c('Temperature_ODIN','Temperature_MET'))
ggplot(tv_1$data$hour)+
  geom_ribbon(aes(x=hour,ymin=Lower,ymax=Upper,fill = variable), alpha = 0.3)+
  geom_line(aes(x=hour,y=Mean,colour = variable))+
  theme(legend.position = "top",legend.title=element_blank())+
  ggtitle('Average diurnal variation')+
  xlab('NZST hour')+
  ylab('Temperature [C]')

tv_1 <- timeVariation(analysis.data.long,pollutant = c('Temperature_ODIN','Temperature_MET','Temperature..2m','Temperature..6m'))
ggplot(tv_1$data$hour)+
  geom_ribbon(aes(x=hour,ymin=Lower,ymax=Upper,fill = variable), alpha = 0.3)+
  geom_line(aes(x=hour,y=Mean,colour = variable))+
  theme(legend.position = "top",legend.title=element_blank())+
  ggtitle('Average diurnal variation')+
  xlab('NZST hour')+
  ylab('Temperature [C]')

tv_1 <- timeVariation(analysis.data.long,pollutant = c('Temperature_ODIN','Temperature_MET','Temperature..2m'))
ggplot(tv_1$data$hour)+
  geom_ribbon(aes(x=hour,ymin=Lower,ymax=Upper,fill = variable), alpha = 0.3)+
  geom_line(aes(x=hour,y=Mean,colour = variable))+
  theme(legend.position = "top",legend.title=element_blank())+
  xlab('NZST hour')+
  ylab('Temperature [C]')



timeVariation(analysis.data.long,pollutant = c('Temperature_ODIN','Temperature_MET','Temperature..2m','Temperature..6m'))
timePlot(analysis.data.long,pollutant = c('Temperature_ODIN','Temperature_MET','Temperature..2m','Temperature..6m'),group = TRUE, avg.time = '3 day')

