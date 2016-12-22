-- Select all PM data from all units while they were at ECan's site (siteid 18) LONG format

SELECT d.recordtime AT TIME ZONE 'UTC' AS date,
                                 i.serialn AS instrument,
                                 s.name AS sensor,
                                 d.value AS value
FROM data.fixed_data AS d,
     admin.sensor AS s,
     admin.instrument AS i
WHERE s.id = d.sensorid
    AND s.instrumentid = i.id
    AND i.name = 'ODIN-SD-3'
    AND d.siteid = 18 -- 18 = ECan's site in Rangiora
    AND d.flagid= 1 -- 1=RAW, 2=PROCESSED, 3=FINAL
    AND (s.name = 'PM2.5'
         OR s.name = 'PM10'
         OR s.name = 'PM1')
ORDER BY date, instrument,
               sensor;
