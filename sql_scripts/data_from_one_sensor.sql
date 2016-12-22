 -- Select PM2.5 and PM10, Temperature and RH from ODIN ODIN-109 in long format (FAST)

SELECT d.recordtime AT TIME ZONE 'UTC' AS date,
                                 i.serialn AS instrument,
                                 s.name AS sensor,
                                 d.value AS value
FROM data.fixed_data AS d,
     admin.sensor AS s,
     admin.instrument AS i
WHERE s.id = d.sensorid
    AND s.instrumentid = i.id
    AND i.serialn = 'ODIN-109'
    AND (s.name = 'PM2.5'
         OR s.name = 'PM10'
         OR s.name = 'Temperature'
         OR s.name = 'RH')
ORDER BY date, sensor;

 -- Select PM2.5 and PM10, Temperature and RH from ODIN ODIN-109 in wide format (SLOW)

SELECT d1.recordtime AS date,
       d1.value AS pm25,
       d2.pm10 AS pm10,
       d3.Temperature AS Temperature. d4.RH AS RH
FROM
    (SELECT d.recordtime AT TIME ZONE 'UTC' AS recordtime,
                                      d.value AS pm25,
     FROM data.fixed_data AS d,
          admin.sensor AS s,
          admin.instrument AS i
     WHERE s.id = d.sensorid
         AND s.instrumentid = i.id
         AND i.serialn = 'ODIN-109'
         AND d.flagid= 1 -- 1=RAW, 2=PROCESSED, 3=FINAL
         AND s.name = 'PM2.5') AS d1,

    (SELECT d.recordtime AT TIME ZONE 'UTC' AS recordtime,
                                      d.value AS pm10,
     FROM data.fixed_data AS d,
          admin.sensor AS s,
          admin.instrument AS i
     WHERE s.id = d.sensorid
         AND s.instrumentid = i.id
         AND i.serialn = 'ODIN-109'
         AND d.flagid= 1 -- 1=RAW, 2=PROCESSED, 3=FINAL
         AND s.name = 'PM10') AS d2,

    (SELECT d.recordtime AT TIME ZONE 'UTC' AS recordtime,
                                      d.value AS Temperature,
     FROM data.fixed_data AS d,
          admin.sensor AS s,
          admin.instrument AS i
     WHERE s.id = d.sensorid
         AND s.instrumentid = i.id
         AND i.serialn = 'ODIN-109'
         AND d.flagid= 1 -- 1=RAW, 2=PROCESSED, 3=FINAL
         AND s.name = 'Temperature') AS d3,

    (SELECT d.recordtime AT TIME ZONE 'UTC' AS recordtime,
                                      d.value AS RH,
     FROM data.fixed_data AS d,
          admin.sensor AS s,
          admin.instrument AS i
     WHERE s.id = d.sensorid
         AND s.instrumentid = i.id
         AND i.serialn = 'ODIN-109'
         AND d.flagid= 1 -- 1=RAW, 2=PROCESSED, 3=FINAL
         AND s.name = 'RH') AS d4
WHERE d1.recordtime = d2.recordtime
    AND d2.recordtime = d3.recordtime
    AND d3.recordtime = d4.recordtime;
