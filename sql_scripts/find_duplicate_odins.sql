select min(te.id), te.recordtime
from (select fd.id,i.serialn,fd.recordtime, s.name
from admin.instrument as i,
admin.sensor as s,
data.fixed_data as fd,
(select fd.sensorid, fd.recordtime, count(*)
from data.fixed_data as fd, admin.sensor as s, admin.instrument as i
where fd.sensorid=s.id AND
	s.instrumentid=i.id
group by fd.sensorid, fd.recordtime HAVING count(*)>1) as dup
where
fd.recordtime = dup.recordtime AND
s.instrumentid = i.id AND
fd.sensorid = s.id AND
fd.sensorid = dup.sensorid) as te
group by te.recordtime;