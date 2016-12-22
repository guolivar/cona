-- Select only PM2.5 data from ODINs at ECan's site
 -- siteid = 18 # ECan site... change to suit your site

SELECT d.recordtime AT TIME ZONE 'UTC' AS date,
                                 d.value AS pm25,
                                 i.serialn AS instrument
FROM data.fixed_data AS d,
     admin.sensor AS s,
     admin.instrument AS i
WHERE s.id = d.sensorid
    AND s.instrumentid = i.id
    AND i.name = 'ODIN-SD-3'
    AND d.siteid = 18
    AND d.flagid= 1 -- 1=RAW, 2=PROCESSED, 3=FINAL
    AND s.name = 'PM2.5';
