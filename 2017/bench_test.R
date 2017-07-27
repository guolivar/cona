# libraries
library(readr)
library(openair)
library(ggplot2)
# Load data
# Date corrections
time_corrections <- read_delim("~/data/CONA/2017/ODIN/bench_test/time_corrections.txt",
                               "\t")
time_corrections$X3 <- NULL
time_corrections$real_time <- as.POSIXct(as.character(time_corrections$real_time),tz='NZST')

# ODIN data
odin_100 <- read_delim("~/data/CONA/2017/ODIN/bench_test/odin_100.txt", 
                       "\t", escape_double = FALSE, col_types = cols(Day = col_character(), 
                                                                     Time = col_character()), trim_ws = TRUE)
odin_100$date <- as.POSIXct(paste(odin_100$Day,odin_100$Time), tz='GMT')
dt <- time_corrections$real_time[1] - odin_100$date[1]
odin_100$date <- odin_100$date + dt
odin_100$serialn <- 'ODIN-100'
all_odin <- odin_100
odin_101 <- read_delim("~/data/CONA/2017/ODIN/bench_test/odin_101.txt", 
                       "\t", escape_double = FALSE, col_types = cols(Day = col_character(), 
                                                                     Time = col_character()), trim_ws = TRUE)
odin_101$date <- as.POSIXct(paste(odin_101$Day,odin_101$Time), tz='GMT')
dt <- time_corrections$real_time[2] - odin_101$date[1]
odin_101$date <- odin_101$date + dt
odin_101$serialn <- 'ODIN-101'
all_odin <- rbind(all_odin,odin_101)
odin_102 <- read_delim("~/data/CONA/2017/ODIN/bench_test/odin_102.txt", 
                       "\t", escape_double = FALSE, col_types = cols(Day = col_character(), 
                                                                     Time = col_character()), trim_ws = TRUE)
odin_102$date <- as.POSIXct(paste(odin_102$Day,odin_102$Time), tz='GMT')
dt <- time_corrections$real_time[3] - odin_102$date[1]
odin_102$serialn <- 'ODIN-102'
odin_102$date <- odin_102$date + dt
all_odin <- rbind(all_odin,odin_102)
odin_106 <- read_delim("~/data/CONA/2017/ODIN/bench_test/odin_106.txt", 
                       "\t", escape_double = FALSE, col_types = cols(Day = col_character(), 
                                                                     Time = col_character()), trim_ws = TRUE)
odin_106$date <- as.POSIXct(paste(odin_106$Day,odin_106$Time), tz='GMT')
dt <- time_corrections$real_time[4] - odin_106$date[1]
odin_106$date <- odin_106$date + dt
odin_106$serialn <- 'ODIN-106'
all_odin <- rbind(all_odin,odin_106)
odin_107 <- read_delim("~/data/CONA/2017/ODIN/bench_test/odin_107.txt", 
                       "\t", escape_double = FALSE, col_types = cols(Day = col_character(), 
                                                                     Time = col_character()), trim_ws = TRUE)
odin_107$date <- as.POSIXct(paste(odin_107$Day,odin_107$Time), tz='GMT')
dt <- time_corrections$real_time[5] - odin_107$date[1]
odin_107$date <- odin_107$date + dt
odin_107$serialn <- 'ODIN-107'
all_odin <- rbind(all_odin,odin_107)
odin_109 <- read_delim("~/data/CONA/2017/ODIN/bench_test/odin_109.txt", 
                       "\t", escape_double = FALSE, col_types = cols(Day = col_character(), 
                                                                     Time = col_character()), trim_ws = TRUE)
odin_109$date <- as.POSIXct(paste(odin_109$Day,odin_109$Time), tz='GMT')
dt <- time_corrections$real_time[6] - odin_109$date[1]
odin_109$date <- odin_109$date + dt
odin_109$serialn <- 'ODIN-109'
all_odin <- rbind(all_odin,odin_109)
odin_114 <- read_delim("~/data/CONA/2017/ODIN/bench_test/odin_114.txt", 
                       "\t", escape_double = FALSE, col_types = cols(Day = col_character(), 
                                                                     Time = col_character()), trim_ws = TRUE)
odin_114$date <- as.POSIXct(paste(odin_114$Day,odin_114$Time), tz='GMT')
dt <- time_corrections$real_time[7] - odin_114$date[1]
odin_114$date <- odin_114$date + dt
odin_114$serialn <- 'ODIN-114'
all_odin <- rbind(all_odin,odin_114)
odin_115 <- read_delim("~/data/CONA/2017/ODIN/bench_test/odin_115.txt", 
                       "\t", escape_double = FALSE, col_types = cols(Day = col_character(), 
                                                                     Time = col_character()), trim_ws = TRUE)
odin_115$date <- as.POSIXct(paste(odin_115$Day,odin_115$Time), tz='GMT')
dt <- time_corrections$real_time[8] - odin_115$date[1]
odin_115$date <- odin_115$date + dt
odin_115$serialn <- 'ODIN-115'
all_odin <- rbind(all_odin,odin_115)
odin_116 <- read_delim("~/data/CONA/2017/ODIN/bench_test/odin_116.txt", 
                       "\t", escape_double = FALSE, col_types = cols(Day = col_character(), 
                                                                     Time = col_character()), trim_ws = TRUE)
odin_116$date <- as.POSIXct(paste(odin_116$Day,odin_116$Time), tz='GMT')
dt <- time_corrections$real_time[9] - odin_116$date[1]
odin_116$date <- odin_116$date + dt
odin_116$serialn <- 'ODIN-116'
all_odin <- rbind(all_odin,odin_116)
odin_120 <- read_delim("~/data/CONA/2017/ODIN/bench_test/odin_120.txt", 
                       "\t", escape_double = FALSE, col_types = cols(Day = col_character(), 
                                                                     Time = col_character()), trim_ws = TRUE)
odin_120$date <- as.POSIXct(paste(odin_120$Day,odin_120$Time), tz='GMT')
dt <- time_corrections$real_time[10] - odin_120$date[1]
odin_120$date <- odin_120$date + dt
odin_120$serialn <- 'ODIN-120'
all_odin <- rbind(all_odin,odin_120)
odin_121 <- read_delim("~/data/CONA/2017/ODIN/bench_test/odin_121.txt", 
                       "\t", escape_double = FALSE, col_types = cols(Day = col_character(), 
                                                                     Time = col_character()), trim_ws = TRUE)
odin_121$date <- as.POSIXct(paste(odin_121$Day,odin_121$Time), tz='GMT')
dt <- time_corrections$real_time[11] - odin_121$date[1]
odin_121$date <- odin_121$date + dt
odin_121$serialn <- 'ODIN-121'
all_odin <- rbind(all_odin,odin_121)
odin_122 <- read_delim("~/data/CONA/2017/ODIN/bench_test/odin_122.txt", 
                       "\t", escape_double = FALSE, col_types = cols(Day = col_character(), 
                                                                     Time = col_character()), trim_ws = TRUE)
odin_122$date <- as.POSIXct(paste(odin_122$Day,odin_122$Time), tz='GMT')
dt <- time_corrections$real_time[12] - odin_122$date[1]
odin_122$date <- odin_122$date + dt
odin_122$serialn <- 'ODIN-122'
all_odin <- rbind(all_odin,odin_122)
odin_123 <- read_delim("~/data/CONA/2017/ODIN/bench_test/odin_123.txt", 
                       "\t", escape_double = FALSE, col_types = cols(Day = col_character(), 
                                                                     Time = col_character()), trim_ws = TRUE)
odin_123$date <- as.POSIXct(paste(odin_123$Day,odin_123$Time), tz='GMT')
dt <- time_corrections$real_time[13] - odin_123$date[1]
odin_123$date <- odin_123$date + dt
odin_123$serialn <- 'ODIN-123'
all_odin <- rbind(all_odin,odin_123)

# Plot summaries
ggplot(data=all_odin) +
  geom_point(aes(x=date,y=PM1,color = serialn)) +
  ggtitle("PM1","Bench test")
ggplot(data=all_odin) +
  geom_point(aes(x=date,y=PM2.5,color = serialn)) +
  ggtitle("PM2.5","Bench test")
ggplot(data=all_odin) +
  geom_point(aes(x=date,y=PM10,color = serialn)) +
  ggtitle("PM10","Bench test")


