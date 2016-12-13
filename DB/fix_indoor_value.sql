UPDATE data.indoor_data 
SET value = replace(value,'''',' ')::numeric
where sensorid in
(select id from admin.sensor
 where name!='Time' and
 name !='DateTime' and
 name !='Day' and
 name !='Date')
