# Plotting PACMAN ####
load("/data/GUSrepos/cona/subject14_1min_data.Rdata.RData")
# Libraries
library(ggplot2)
library(scales)

# Select day
plot_data1 <- selectByDate(subject14.data.1min, start = '2015-09-02', end = '2015-09-02')
plot_data2 <- selectByDate(subject14.data.1min, start = '2015-09-03', end = '2015-09-03')
plot_data3 <- selectByDate(subject14.data.1min, start = '2015-09-04', end = '2015-09-04')
plot_data4 <- selectByDate(subject14.data.1min, start = '2015-09-05', end = '2015-09-05')
plot_data5 <- selectByDate(subject14.data.1min, start = '2015-09-06', end = '2015-09-06')
plot_data6 <- selectByDate(subject14.data.1min, start = '2015-09-07', end = '2015-09-07')
# Bubble plot for the time
f_alpha <- 0.02
f_colour <- 'blue'
ggplot(plot_data1,aes(x=date))+
  geom_point(aes(y=5),
             size = 3*log(plot_data1$Dust.corr.in),
             alpha=f_alpha,
             colour = f_colour)+
  geom_point(aes(y=4),
             size = 3*log(plot_data2$Dust.corr.in),
             alpha=f_alpha,
             colour = f_colour)+
  geom_point(aes(y=3),
             size = 3*log(plot_data3$Dust.corr.in),
             alpha=f_alpha,
             colour = f_colour)+
  geom_point(aes(y=2),
             size = 3*log(plot_data4$Dust.corr.in),
             alpha=f_alpha,
             colour = f_colour)+
  geom_point(aes(y=1),
             size = 3*log(plot_data5$Dust.corr.in),
             alpha=f_alpha,
             colour = f_colour)+
  geom_point(aes(y=0),
             size = 3*log(plot_data6$Dust.corr.in),
             alpha=f_alpha,
             colour = f_colour)+
  scale_x_datetime(name = "Hour", date_format("%H:%M"),breaks=date_breaks("6 hour"))+
  scale_y_continuous(name="",breaks=5:0,labels = c('02-Sep',
                                                  '03-Sep',
                                                  '04-Sep',
                                                  '05-Sep',
                                                  '06-Sep',
                                                  '07-Sep'))



