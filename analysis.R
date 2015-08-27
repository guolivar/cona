# Analysis script
# Calling the data-loading scripts
source('iButton.R')
source('ecan.R')
source('branz.R')

# Merge data
# iButtons and ecan Met
ecan_ibuttons <- merge(iButtons,ecan_data,by = 'date',all=TRUE)
# ecan_ibuttons with BRANZ
all_temp <- merge(ecan_ibuttons,branz,by = 'date', all = TRUE)
all_temp.10min <- timeAverage(all_temp,avg.time = '10 min')

# Plot data by address

# 22 Church Street
mindate <- format(max(min(iB_3D00000026EEC341$date),min(HUV186$date),min(ecan_data$date)),format = '%Y-%m-%d')
maxdate <- format(min(max(iB_3D00000026EEC341$date),max(HUV186$date),max(ecan_data$date)),format = '%Y-%m-%d')
plot_data <- selectByDate(all_temp.10min, start = mindate, end = maxdate)
timePlot(plot_data,pollutant = c('Temperature.3D',
                                'Temp.186',
                                'Temperature.2m'),
         group = TRUE, main = '22 Church Street',
         name.pol = c('iButton','BRANZ','Outdoor'),
         ylab = 'Temperature [C]')
scatterPlot(plot_data,x='Temperature.3D','Temp.186',
            main = '22 Church Street',
            xlab = 'iButton',
            ylab = 'BRANZ')

# 161 Lehmans Road

mindate <- format(max(min(iB_A500000032322841$date),min(HUV141$date),min(ecan_data$date)),format = '%Y-%m-%d')
maxdate <- format(min(max(iB_A500000032322841$date),max(HUV141$date),max(ecan_data$date)),format = '%Y-%m-%d')
plot_data <- selectByDate(all_temp.10min, start = mindate, end = maxdate)
timePlot(plot_data,pollutant = c('Temperature.A5',
                                'Temp.141',
                                'Temperature.2m'),
         group = TRUE, main = '161 Lehmans Road',
         name.pol = c('iButton','BRANZ','Outdoor'),
         ylab = 'Temperature [C]')
scatterPlot(plot_data,x='Temperature.A5','Temp.141',
            main = '161 Lehmans Road',
            xlab = 'iButton',
            ylab = 'BRANZ')

# 296 Kensington Ave

mindate <- format(max(min(iB_8800000026F06241$date),min(HUV123$date),min(ecan_data$date)),format = '%Y-%m-%d')
maxdate <- format(min(max(iB_8800000026F06241$date),max(HUV123$date),max(ecan_data$date)),format = '%Y-%m-%d')
plot_data <- selectByDate(all_temp.10min, start = mindate, end = maxdate)
timePlot(plot_data,pollutant = c('Temperature.88',
                                 'Temp.123',
                                 'Temperature.2m'),
         group = TRUE, main = '296 Kensington Ave',
         name.pol = c('iButton','BRANZ','Outdoor'),
         ylab = 'Temperature [C]')
scatterPlot(plot_data,x='Temperature.88','Temp.123',
            main = '296 Kensington Ave',
            xlab = 'iButton',
            ylab = 'BRANZ')

# 2589 South Eyre Road

mindate <- format(max(min(iB_1B000000322E6141$date),min(HUV166$date),min(ecan_data$date)),format = '%Y-%m-%d')
maxdate <- format(min(max(iB_1B000000322E6141$date),max(HUV166$date),max(ecan_data$date)),format = '%Y-%m-%d')
plot_data <- selectByDate(all_temp.10min, start = mindate, end = maxdate)
timePlot(plot_data,pollutant = c('Temperature.1B',
                                 'Temp.166',
                                 'Temperature.2m'),
         group = TRUE, main = '2589 South Eyre Road',
         name.pol = c('iButton','BRANZ','Outdoor'),
         ylab = 'Temperature [C]')
scatterPlot(plot_data,x='Temperature.1B','Temp.166',
            main = '2589 South Eyre Road',
            xlab = 'iButton',
            ylab = 'BRANZ')

# 4 Duke Street

mindate <- format(max(min(iB_C200000026F9BE41$date),min(HUV191$date),min(ecan_data$date)),format = '%Y-%m-%d')
maxdate <- format(min(max(iB_C200000026F9BE41$date),max(HUV191$date),max(ecan_data$date)),format = '%Y-%m-%d')
plot_data <- selectByDate(all_temp.10min, start = mindate, end = maxdate)
timePlot(plot_data,pollutant = c('Temperature.C2',
                                 'Temp.191',
                                 'Temperature.2m'),
         group = TRUE, main = '4 Duke Street',
         name.pol = c('iButton','BRANZ','Outdoor'),
         ylab = 'Temperature [C]')
scatterPlot(plot_data,x='Temperature.C2','Temp.191',
            main = '4 Duke Street',
            xlab = 'iButton',
            ylab = 'BRANZ')


diurnal.Temperatures<-timeVariation(all_temp.10min,pollutant = c(#'Temperature.1B',
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

