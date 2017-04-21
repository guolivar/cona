
select i.serialn, dup.recordtime
from admin.instrument as i,
	admin.sensor as s,
(select fd.sensorid, fd.recordtime, count(*)
from data.fixed_data as fd, admin.sensor as s, admin.instrument as i
where fd.sensorid=s.id AND
	s.instrumentid=i.id
group by fd.sensorid, fd.recordtime HAVING count(*)>1) as dup
where dup.sensorid = s.id AND
	s.instrumentid = i.id;