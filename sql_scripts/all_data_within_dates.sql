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
