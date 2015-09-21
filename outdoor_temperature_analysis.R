# Ambient temperature analysis
# Load libraries
require('openair')
require('tidyr')
# Load data
source('./meteorology.R')
source('./ODIN_CONA_diagnostic.R')
# Merge data
analysis.data <- merge(met_data,all_merged.10min,by='date',all = TRUE)
analysis.data <- analysis.data[,c('date'
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
timePlot(analysis.data,pollutant = c('Tavg.0.1'
                                     ,'Tavg.1.1'
                                     ,'Tavg.2.1'
                                     ,'Tavg.3.1'
                                     # ,'Temperature.02'
                                     # ,'Temperature.03'
                                     # ,'Temperature.04'
                                     # ,'Temperature.05'
                                     # ,'Temperature.06'
                                     # ,'Temperature.07'
                                     )
         ,group = TRUE
         ,avg.time = '10 min')

timeVariation(analysis.data,pollutant = c('Tavg.0.1'
                                          ,'Tavg.1.1'
                                          ,'Tavg.2.1'
                                          ,'Tavg.3.1'
                                          # ,'Temperature.02'
                                          # ,'Temperature.03'
                                          # ,'Temperature.04'
                                          # ,'Temperature.05'
                                          # ,'Temperature.06'
                                          # ,'Temperature.07'
)
)

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
