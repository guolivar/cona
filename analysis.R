# Analysis script
# Calling the data-loading scripts
source('ae51.R')
source('iButton.R')
source('ecan.R')
source('meteorology.R')

# Merge data
# iButtons and ecan Met
ecan_ibuttons <- merge(iButtons,ecan_data,by = 'date',all=TRUE)

# Plot iButtons and ECan Temperatures
timePlot(ecan_ibuttons,pollutant = c('Temperature.1B',
                                'Temperature.3D',
                                'Temperature.88',
                                'Temperature.A5',
                                'Temperature.C2',
                                'Temperature.D2',
                                'Temperature.2m',
                                'Temperature.6m'),
         avg.time = '10 min', group = TRUE,normalise = 'mean')

diurnal.Temperatures<-timeVariation(ecan_ibuttons,pollutant = c(#'Temperature.1B',
                                                                    'Temperature.3D',
                                                                    'Temperature.88',
                                                                    'Temperature.A5',
                                                                    'Temperature.C2',
#                                                                    'Temperature.D2',
                                                                    'Temperature.2m',
                                                                    'Temperature.6m'))
ggplot(diurnal.Temperatures$data$hour)+
  geom_ribbon(aes(x=hour,ymin=Lower,ymax=Upper,colour = variable,fill = variable))+
  #geom_line(aes(x=hour,y=Mean,colour = variable),colour=variable)+
  #scale_colour_discrete()+
  ggtitle('Temperature')+
  xlab('NZST hour')+
  ylab('Temperature [C]')

