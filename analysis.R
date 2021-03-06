12# Analysis script
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

# Subject 12
mindate <- format(max(min(iB_3D00000026EEC341$date),min(HUV186$date),min(ecan_data$date)),format = '%Y-%m-%d')
maxdate <- format(min(max(iB_3D00000026EEC341$date),max(HUV186$date),max(ecan_data$date)),format = '%Y-%m-%d')
plot_data <- selectByDate(all_temp.10min, start = mindate, end = maxdate)
timePlot(plot_data,pollutant = c('Temperature.3D',
                                'Temp.186',
                                'Temperature.2m'),
         group = TRUE, main = 'Subject 12',
         name.pol = c('iButton','BRANZ','Outdoor'),
         ylab = 'Temperature [C]')
scatterPlot(plot_data,x='Temperature.3D','Temp.186',
            main = 'Subject 12',
            xlab = 'iButton',
            ylab = 'BRANZ')

# Subject 10

mindate <- format(max(min(iB_A500000032322841$date),min(HUV141$date),min(ecan_data$date)),format = '%Y-%m-%d')
maxdate <- format(min(max(iB_A500000032322841$date),max(HUV141$date),max(ecan_data$date)),format = '%Y-%m-%d')
plot_data <- selectByDate(all_temp.10min, start = mindate, end = maxdate)
timePlot(plot_data,pollutant = c('Temperature.A5',
                                'Temp.141',
                                'Temperature.2m'),
         group = TRUE, main = 'Subject 10',
         name.pol = c('iButton','BRANZ','Outdoor'),
         ylab = 'Temperature [C]')
scatterPlot(plot_data,x='Temperature.A5','Temp.141',
            main = 'Subject 10',
            xlab = 'iButton',
            ylab = 'BRANZ')

# Subject 09

mindate <- format(max(min(iB_8800000026F06241$date),min(HUV123$date),min(ecan_data$date)),format = '%Y-%m-%d')
maxdate <- format(min(max(iB_8800000026F06241$date),max(HUV123$date),max(ecan_data$date)),format = '%Y-%m-%d')
plot_data <- selectByDate(all_temp.10min, start = mindate, end = maxdate)
timePlot(plot_data,pollutant = c('Temperature.88',
                                 'Temp.123',
                                 'Temperature.2m'),
         group = TRUE, main = 'Subject 09',
         name.pol = c('iButton','BRANZ','Outdoor'),
         ylab = 'Temperature [C]')
scatterPlot(plot_data,x='Temperature.88','Temp.123',
            main = 'Subject 09',
            xlab = 'iButton',
            ylab = 'BRANZ')

# Subject 05

mindate <- format(max(min(iB_1B000000322E6141$date),min(HUV166$date),min(ecan_data$date)),format = '%Y-%m-%d')
maxdate <- format(min(max(iB_1B000000322E6141$date),max(HUV166$date),max(ecan_data$date)),format = '%Y-%m-%d')
plot_data <- selectByDate(all_temp.10min, start = mindate, end = maxdate)
timePlot(plot_data,pollutant = c('Temperature.1B',
                                 'Temp.166',
                                 'Temperature.2m'),
         group = TRUE, main = 'Subject 05',
         name.pol = c('iButton','BRANZ','Outdoor'),
         ylab = 'Temperature [C]')
scatterPlot(plot_data,x='Temperature.1B','Temp.166',
            main = 'Subject 05',
            xlab = 'iButton',
            ylab = 'BRANZ')

# Subject 04

mindate <- format(max(min(iB_C200000026F9BE41$date),min(HUV191$date),min(ecan_data$date)),format = '%Y-%m-%d')
maxdate <- format(min(max(iB_C200000026F9BE41$date),max(HUV191$date),max(ecan_data$date)),format = '%Y-%m-%d')
plot_data <- selectByDate(all_temp.10min, start = mindate, end = maxdate)
plot_data$deltaC2_out <- plot_data$Temperature.C2 - plot_data$Temperature.2m
plot_data$delta191_out <- plot_data$Temp.191 - plot_data$Temperature.2m
timePlot(plot_data,pollutant = c('Temperature.C2',
                                 'Temp.191',
                                 'Temperature.2m'),
         group = TRUE, main = 'Subject 04',
         name.pol = c('iButton','BRANZ','Outdoor'),
         ylab = 'Temperature [C]')

timePlot(plot_data,pollutant = c('deltaC2_out','delta191_out')
         ,group = TRUE, main = 'Subject 04'
         ,name.pol = c('iButton - out','BRANZ - out')
         ,ylab = 'Temperature [C]')

timeVariation(plot_data,pollutant = c('deltaC2_out','delta191_out')
         ,main = 'Subject 04'
         ,name.pol = c('iButton - out','BRANZ - out')
         )



scatterPlot(plot_data,x='Temperature.C2','Temp.191',
            main = 'Subject 04',
            xlab = 'iButton',
            ylab = 'BRANZ')


# Reshape the data to long format

iButtons.long <- melt(iButtons,
                  id.vars=c("date"),
                  measure.vars=names(iButtons)[2:7],
                  variable.name="iButtonID",
                  value.name="Temperature"
)

branz.long <- melt(branz,
                   id.vars=c("date"),
                   measure.vars=names(branz)[2:9],
                   variable.name="BRANZ.id",
                   value.name="Temperature"
)

long_temperature <- merge(iButtons.long,branz.long,by = 'date', all = TRUE)
names(long_temperature) <- c('date','iB.id','T.iButtons','BRANZ.id','T.BRANZ')
long_temperature <- merge(long_temperature,ecan_data,by = 'date',all = TRUE)
names(long_temperature) <- c('date','iB.id','T.iButtons','BRANZ.id','T.BRANZ','PM10','T.2m','T.6m','ws','wd')
long_temperature.10min <- timeAverage(long_temperature,avg.time = '10 min')

timeVariation(long_temperature.10min,pollutant = c('T.iButtons','T.BRANZ','T.2m','T.6m'))

diurnal.Temperatures<-timeVariation(long_temperature.10min,pollutant = c('T.iButtons','T.BRANZ','T.2m'),statistic = 'median', conf.int = 0.75)

ggplot(diurnal.Temperatures$data$hour)+
  geom_ribbon(aes(x=hour,ymin=Lower, ymax = Upper,fill = variable, colour = variable), alpha = 0.3) +
  #,colour = variable,fill  = variable))+
  #geom_line(aes(x=hour,y=Mean,colour r a = variable),colour=variable)+
  #scale_colour_discrete()+
  ggtitle('Temperature')+
  xlab('NZST hour')+
  ylab('Temperature [C]')

timePlot(selectByDate(all_temp.10min,start = '2015-08-15',end = '2015-08-31')
         ,pollutant = c('Temperature.2m',
                        'Temp.191',
                        'Temp.186',
                        'Temp.166',
                        'Temp.154',
                        'Temp.149',
                        'Temp.141',
                        'Temp.123',
                        'Temp.118')
         ,group = TRUE
         ,avg.time = '10 min'
         ,name.pol = c('Temp.1',
                       'Temp.2',
                       'Temp.3',
                       'Temp.4',
                       'Temp.5',
                       'Temp.6',
                       'Temp.7',
                       'Temp.8',
                       'Temp.out')
         ,ylab = 'Temperature [C]'
         )

timePlot(long_temperature,pollutant = c('T.iButtons','T.BRANZ','T.2m','T.6m')
         ,group = TRUE
         ,smooth = TRUE
         ,ci = TRUE
         )

ggplot(selectByDate(long_temperature,start = '2015-08-15',end = '2015-08-31'),aes(x=date)) +
  geom_point(aes(y=T.iButtons,colour = 'iButtons')) +
  geom_point(aes(y=T.BRANZ,colour = 'BRANZ')) +
  geom_point(aes(y=T.2m,colour = 'Outdoor')) +
  ylab('Temperature [C]') +
  xlab('Local Time') +
  scale_color_discrete(name = '')


ggplot(selectByDate(subset(all_temp,subset = (Temperature.2m > 10)),start = '2015-08-15',end = '2015-08-31'),aes(x=date)) +
  geom_point(aes(y=Temperature.C2,colour = 'iButton')) +
  geom_point(aes(y=Temp.191,colour = 'BRANZ')) +
  geom_point(aes(y=Temperature.2m,colour = 'Outdoor')) +
  ylab('Temperature [C]') +
  xlab('Local Time') +
  scale_color_discrete(name = '')

ggplot(selectByDate(subset(all_temp.10min,subset = (Temperature.2m > 10)),start = '2015-08-15',end = '2015-08-31'),aes(x=date)) +
  geom_point(aes(y=Temperature.C2,colour = 'iButton')) +
  geom_point(aes(y=Temp.191,colour = 'BRANZ')) +
  geom_point(aes(y=Temperature.2m,colour = 'Outdoor')) +
  ylab('Temperature [C]') +
  xlab('Local Time') +
  scale_color_discrete(name = '')




