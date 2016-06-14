\[code\]

,vent\_group\_1 as

(select distinct

--pop.hadm\_id

pop.icustay\_id

, 1 as flg

--, icud.icustay\_id

--, vent.end\_time

--, vent.begin\_time

, min(vent.begin\_time) as vent\_start\_time

, max(vent.end\_time) as vent\_end\_time

, sum(round((extract(day from (vent.end\_time-vent.begin\_time))+

extract(hour from (vent.end\_time-vent.begin\_time))/24+1/24+

extract(minute from (vent.end\_time-vent.begin\_time))/60/24), 3)) as
vent\_day

, pop.icustay\_outtime

, pop.icustay\_intime

, pop.INITIAL\_ALINE\_FLG

, pop.ALINE\_FLG

, pop.ALINE\_TIME\_DAY

from population pop

--join mimic2v26.icustay\_detail icud on icud.icustay\_id =
pop.icustay\_id

join mimic2devel.ventilation vent on vent.icustay\_id = pop.icustay\_id

group by pop.icustay\_id, pop.icustay\_outtime, pop.icustay\_intime,
pop.INITIAL\_ALINE\_FLG, pop.ALINE\_FLG, pop.ALINE\_TIME\_DAY

order by 1

)

--select \* from vent\_group\_1; ---4161

--select \* from vent\_group where hadm\_id=2798;

, vent\_group\_2 as

(select v.\*

, round(extract(day from (vent\_start\_time-icustay\_intime))

+ extract(hour from (vent\_start\_time-icustay\_intime))/24

+ extract(minute from (vent\_start\_time-icustay\_intime))/24/60,2) as
vent\_start\_day

, round(extract(day from (icustay\_outtime-vent\_end\_time))

+ extract(hour from (icustay\_outtime-vent\_end\_time))/24

+ extract(minute from (icustay\_outtime-vent\_end\_time))/24/60,2) as
vent\_free\_day

, case when vent\_day&gt;=1 then 1 else 0 end as vent\_1day\_flg --no of
days under vent

, case when vent\_day&gt;=0.5 then 1 else 0 end as vent\_12hr\_flg

, case when vent\_day&gt;=0.25 then 1 else 0 end as vent\_6hr\_flg

--, case when vent\_start\_day&lt;=0.125 then 1 else 0 as
vent\_1st\_3hr\_flg

--, case when vent\_start\_day&lt;=0.25 then 1 else 0 as
vent\_1st\_6hr\_flg

--case when vent\_start\_day&lt;=0.5 then 1 else 0 as
vent\_1st\_12hr\_flg

from vent\_group\_1 v

)

, vent\_group as

(select v.\*

, case when v.vent\_start\_day&lt;=(2/24) then 1 else 0 end as
vent\_1st\_2hr\_flg

, case when v.vent\_start\_day&lt;=0.125 then 1 else 0 end as
vent\_1st\_3hr\_flg

, case when v.vent\_start\_day&lt;=0.25 then 1 else 0 end as
vent\_1st\_6hr\_flg

, case when v.vent\_start\_day&lt;=0.5 then 1 else 0 end as
vent\_1st\_12hr\_flg

, case when v.vent\_start\_day&lt;=1 then 1 else 0 end as
vent\_1st\_24hr\_flg

, case when ALINE\_FLG=1 and INITIAL\_ALINE\_FLG =0 and
vent\_start\_day&lt;=ALINE\_TIME\_DAY then 1

when ALINE\_FLG=1 and INITIAL\_ALINE\_FLG =0 and
vent\_start\_day&gt;ALINE\_TIME\_DAY then 0

when ALINE\_FLG=0 and INITIAL\_ALINE\_FLG =0 and
v.vent\_start\_day&lt;=(2/24) then 1

when ALINE\_FLG=0 and INITIAL\_ALINE\_FLG =0 and
v.vent\_start\_day&gt;(2/24) then 0

else NULL

end as vent\_b4\_aline

from vent\_group\_2 v

)
