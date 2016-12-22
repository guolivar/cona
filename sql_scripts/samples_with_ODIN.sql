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
    AND s.name = 'PM2.5';

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
    AND d.siteid = 18
    AND (s.name = 'PM2.5'
         OR s.name = 'PM10'
         OR s.name = 'PM1')
ORDER BY date, instrument,
               sensor;

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
         AND s.name = 'PM2.5') AS d1,

    (SELECT d.recordtime AT TIME ZONE 'UTC' AS recordtime,
                                      d.value AS pm10,
     FROM data.fixed_data AS d,
          admin.sensor AS s,
          admin.instrument AS i
     WHERE s.id = d.sensorid
         AND s.instrumentid = i.id
         AND i.serialn = 'ODIN-109'
         AND s.name = 'PM10') AS d2,

    (SELECT d.recordtime AT TIME ZONE 'UTC' AS recordtime,
                                      d.value AS Temperature,
     FROM data.fixed_data AS d,
          admin.sensor AS s,
          admin.instrument AS i
     WHERE s.id = d.sensorid
         AND s.instrumentid = i.id
         AND i.serialn = 'ODIN-109'
         AND s.name = 'Temperature') AS d3,

    (SELECT d.recordtime AT TIME ZONE 'UTC' AS recordtime,
                                      d.value AS RH,
     FROM data.fixed_data AS d,
          admin.sensor AS s,
          admin.instrument AS i
     WHERE s.id = d.sensorid
         AND s.instrumentid = i.id
         AND i.serialn = 'ODIN-109'
         AND s.name = 'RH') AS d4
WHERE d1.recordtime = d2.recordtime
    AND d2.recordtime = d3.recordtime
    AND d3.recordtime = d4.recordtime;

 -- Select all sites where there was an ODIN-SD-3 located at some point in the campaign

SELECT d.siteid AS siteid,
       fs.name AS name,
       min(d.recordtime) AS datefrom,
       max(d.recordtime) AS dateto
FROM data.fixed_data AS d,
     admin.sensor AS s,
     admin.instrument AS i,
     admin.fixedsites AS fs
WHERE s.id = d.sensorid
    AND s.instrumentid = i.id
    AND i.name = 'ODIN-SD-3'
    AND d.siteid = fd.id
GROUP BY siteid,
         name;

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
ORDER BY date;

-- Select data from all units, with location, within two dates and within a radius of ECan's site
SELECT fs.id,
       avg(d.value::numeric) AS pm25,
       ST_X(ST_TRANSFORM(fs.geom::geometry,2193)) AS x,
       ST_Y(ST_TRANSFORM(fs.geom::geometry,2193)) AS y,
       ST_TRANSFORM(fs.geom::geometry,2193) AS geom
FROM data.fixed_data AS d,
     admin.sensor AS s,
     admin.instrument AS i,
     admin.fixedsites AS fs
WHERE s.id = d.sensorid
    AND s.instrumentid = i.id
    AND fs.id = d.siteid
    AND i.name = 'ODIN-SD-3'
    AND s.name = 'PM2.5'
    AND fs.id != 27
    AND d.recordtime < timestamptz '2016-08-10 00:00 NZST'
    AND d.recordtime < timestamptz '2016-08-11 00:00 NZST'
    AND ST_WITHIN(fs.geom::geometry, ST_BUFFER(
                                                   (SELECT x.geom::geometry
                                                    FROM admin.fixedsites AS x
                                                    WHERE x.id=18),0.032))
GROUP BY fs.id;
