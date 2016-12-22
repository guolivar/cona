-- Select all PM2.5 data and the geographic location of the sites

SELECT d.recordtime AT TIME ZONE 'UTC' AS date,
                                 d.value AS pm25,
                                 i.serialn AS instrument,
                                 fs.geom AS geom
FROM data.fixed_data AS d,
     admin.sensor AS s,
     admin.instrument AS i,
     admin.fixedsites AS fs
WHERE s.id = d.sensorid
    AND s.instrumentid = i.id
    AND i.name = 'ODIN-SD-3'
    AND d.siteid = fs.id
    AND s.name = 'PM2.5'
    AND d.flagid= 1 -- 1=RAW, 2=PROCESSED, 3=FINAL
ORDER BY date;
