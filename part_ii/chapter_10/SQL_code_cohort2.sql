-- SQL

, invasivebp\_all as

(select distinct p.icustay\_id

, first\_value(ch.charttime) over (partition by p.icustay\_id order by
ch.charttime asc) as aline\_time

--, ch.charttime

, p.icustay\_intime

from population p

join mimic2v26.chartevents ch

on p.icustay\_id=ch.icustay\_id

and ch.itemid in (51,52)

and (ch.value1num is not null or ch.value2num is not null)

--order by 1

)

--select \* from invasivebp\_all; --17104

, aline as

(select icustay\_id

--, aline\_time-icustay\_intime as time\_diff

, round((extract(day from aline\_time-icustay\_intime)

+extract(hour from aline\_time-icustay\_intime)/24

+extract(minute from aline\_time-icustay\_intime)/24/60),3) as
aline\_time\_day

, 1 as flg

from invasivebp\_all

order by 3 asc

)

--select \* from aline; --13416

, cohort as

(select p.\*

, case when a.flg =1 and a.aline\_time\_day&lt;=1/24 then 1 else 0 end
as initial\_aline\_flg

, coalesce(a.flg,0) as aline\_flg

, a.aline\_time\_day

from population p

--left join initial\_aline i on p.icustay\_id=i.icustay\_id

left join aline a on p.icustay\_id=a.icustay\_id

)

select \* from cohort;

--select count(distinct icustay\_id) from cohort;

--select count(\*) from cohort where initial\_aline\_flg=1; --6676
