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
