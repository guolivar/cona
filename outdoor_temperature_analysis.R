# Ambient temperature analysis
# Load libraries
require('openair')
require('reshape2')
# Load data
source('./meteorology.R')
source('./ODIN_CONA.R')
# Merge data
analysis.data <- merge(met_data,all_merged.10min,by='date',all = TRUE)

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
analysis.data.long.ODIN <- reshape(analysis.data[,c('date'
                                                    ,'Temperature.02'
                                                    ,'Temperature.03'
                                                    ,'Temperature.04'
                                                    ,'Temperature.05'
                                                    ,'Temperature.06'
                                                    ,'Temperature.07')],timevar = 'ODIN',varying = c('Temperature.02'
                                                                                                     ,'Temperature.03'
                                                                                                     ,'Temperature.04'
                                                                                                     ,'Temperature.05'
                                                                                                     ,'Temperature.06'
                                                                                                     ,'Temperature.07')
                                   ,idvar = 'date'
                                   ,direction = 'long'
                                   ,ids = analysis.data$date)




