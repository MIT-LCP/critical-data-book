-- SQL 

, vaso\_group\_1 as

(select

distinct

--pop.hadm\_id

pop.icustay\_id

, pop.icustay\_intime

, pop.icustay\_outtime

--, pop.icustay\_outtime-pop.icustay\_intime as temp

, pop.icu\_los\_day

, first\_value(med.charttime) over (partition by pop.icustay\_id order
by med.charttime asc) as begin\_time

, first\_value(med.charttime) over (partition by pop.icustay\_id order
by med.charttime desc) as end\_time

, 1 as flg

, pop.INITIAL\_ALINE\_FLG

, pop.ALINE\_FLG

, pop.ALINE\_TIME\_DAY

from population pop

--join mimic2v26.icustay\_detail icud on icud.hadm\_id = pop.hadm\_id

join mimic2v26.medevents med on med.icustay\_id=pop.icustay\_id and
med.itemid in (46,47,120,43,307,44,119,309,51,127,128)

where med.charttime is not null

)

--select extract(day from temp) as temp\_day from vaso\_group\_1 where
icustay\_id=2613;

--select count(distinct icustay\_id) from vaso\_group;

, vaso\_group\_2 as

(select distinct

--hadm\_id

--icustay\_id

v.\*

, round(extract(day from (begin\_time-icustay\_intime))

+ extract(hour from (begin\_time-icustay\_intime))/24

+ extract(minute from (begin\_time-icustay\_intime))/24/60,2) as
vaso\_start\_day

, round(extract(day from (icustay\_outtime-end\_time))

+ extract(hour from (icustay\_outtime-end\_time))/24

+ extract(minute from (icustay\_outtime-end\_time))/60/24, 2) as
vaso\_free\_day

, round(extract(day from (end\_time-begin\_time))

+ extract(hour from (end\_time-begin\_time))/24 +1/24 --- add additional
1 hour

+ extract(minute from (end\_time-begin\_time))/60/24, 2) as vaso\_day

--, icu\_los\_day

--, round(extract(day from (icustay\_outtime-icustay\_intime))

-- + extract(hour from (icustay\_outtime-icustay\_intime))/24

-- + extract(minute from (icustay\_outtime-icustay\_intime))/60/24, 2)
as temp

--, flg

from vaso\_group\_1 v

)

, vaso\_group as

(select v.\*

--, case when

, case when v.vaso\_start\_day&lt;=0.125 then 1 else 0 end as
vaso\_1st\_3hr\_flg

, case when v.vaso\_start\_day&lt;=0.25 then 1 else 0 end as
vaso\_1st\_6hr\_flg

, case when v.vaso\_start\_day&lt;=0.5 then 1 else 0 end as
vaso\_1st\_12hr\_flg

, case when ALINE\_FLG=1 and INITIAL\_ALINE\_FLG =0 and
vaso\_start\_day&lt;=ALINE\_TIME\_DAY then 1

when ALINE\_FLG=1 and INITIAL\_ALINE\_FLG =0 and
vaso\_start\_day&gt;ALINE\_TIME\_DAY then 0

when ALINE\_FLG=0 and INITIAL\_ALINE\_FLG =0 and
v.vaso\_start\_day&lt;=(2/24) then 1

when ALINE\_FLG=0 and INITIAL\_ALINE\_FLG =0 and
v.vaso\_start\_day&gt;(2/24) then 0

else NULL

end as vaso\_b4\_aline

from vaso\_group\_2 v

)
