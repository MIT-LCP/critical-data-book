\[Query algorithms for structured data in MIMIC II are performed using
\[Oracle SQL\].

create materialized view ppi\_mag\_cohort as

-- Get the first ICU stay of each adult

with first\_admissions as

(select icud.subject\_id,

icud.hadm\_id as first\_hadm\_id,

icud.icustay\_id as first\_icustay\_id,

icud.hospital\_admit\_dt as first\_hadm\_admit\_dt,

icud.hospital\_disch\_dt as first\_hadm\_disch\_dt,

icud.icustay\_intime as first\_icustay\_intime,

icud.icustay\_outtime as first\_icustay\_outtime,

extract(day from icud.icustay\_intime-icud.hospital\_admit\_dt) as
days\_btw\_hosp\_icu\_admit,

extract(day from icud.hospital\_disch\_dt-icud.icustay\_outtime) as
days\_btw\_hosp\_icu\_disch,

icud.icustay\_expire\_flg as icu\_mort\_first\_admission,

icud.hospital\_expire\_flg as hosp\_mort\_first\_admission,

d.admission\_source\_descr as first\_hadm\_source,

case

when lower(d.admission\_source\_descr) like '%emergency%' then 'Y'

else 'N'

end as ED\_admission,

case

when icud.icustay\_admit\_age&gt;150 then 91.4

else round(icud.icustay\_admit\_age,1)

end as age\_first\_icustay,

icud.gender,

d.ethnicity\_descr as race,

round(icud.icustay\_los/60/24,2) as first\_icustay\_los,

icud.icustay\_first\_service,

icud.sapsi\_first as first\_icustay\_admit\_saps,

case

when msa.hadm\_id is not null then 'Y'

else 'N'

end as first\_hadm\_sepsis

from mimic2v26.icustay\_detail icud

left join mimic2v26.demographic\_detail d on icud.hadm\_id=d.hadm\_id

left join mimic2devel.martin\_sepsis\_admissions msa on
icud.hadm\_id=msa.hadm\_id

where icud.subject\_icustay\_seq=1

and icud.icustay\_age\_group='adult'

and icud.hadm\_id is not null

and icud.icustay\_id is not null

-- and icud.subject\_id &lt; 100

)

--select \* from first\_admissions;

, raw\_icu\_admit\_labs as

(select distinct r.subject\_id,

case

when l.itemid=50090 then 'serum\_cr'

when l.itemid=50159 then 'serum\_sodium'

when l.itemid=50655 then 'urine\_protein'

when l.itemid=50264 then 'urine\_cr'

when l.itemid=50277 then 'urine\_sodium'

when l.itemid=50276 then 'urine\_protein\_cr\_ratio'

when l.itemid=50177 then 'bun'

when l.itemid=50149 then 'potassium'

when l.itemid=50083 then 'chloride'

when l.itemid=50172 then 'bicarb'

when l.itemid=50383 then 'hematocrit'

when l.itemid=50468 then 'wbc'

when l.itemid=50140 then 'magnesium'

when l.itemid=50148 then 'phosphate'

when l.itemid=50079 then 'calcium'

when l.itemid=50010 then 'lactate'

when l.itemid=50018 then 'ph'

when l.itemid=50428 then 'platelets'

when l.itemid=50060 then 'albumin'

when l.itemid=50112 then 'glucose'

when l.itemid=50399 then 'inr'

when l.itemid=50439 then 'pt'

when l.itemid=50440 then 'ptt'

when l.itemid=50115 then 'haptoglobin'

when l.itemid=50134 then 'ldh'

when l.itemid=50370 then 'd-dimer'

end as lab\_type,

first\_value(l.value) over (partition by l.hadm\_id, l.itemid order by
l.charttime) as lab\_value,

first\_value(l.charttime) over (partition by l.hadm\_id order by
l.charttime) as icu\_admit\_lab\_time

from first\_admissions r

join mimic2v26.labevents l

on r.first\_hadm\_id=l.hadm\_id

and l.itemid in
(50090,50159,50655,50264,50277,50276,50177,50149,50083,50172,50383,50468,50140,50148,50079,50010,50018,50428,50060,50112,50399,50439,50440,50115,50134,50370)

and l.charttime between r.first\_icustay\_intime - interval '12' hour
and r.first\_icustay\_intime + interval '12' hour

)

--select \* from raw\_icu\_admit\_labs order by 1,2;

, icu\_admit\_labs as

(select \*

from (select \* from raw\_icu\_admit\_labs)

pivot

(max(lab\_value) for lab\_type in

('serum\_cr' as icu\_admit\_serum\_cr,

'serum\_sodium' as icu\_admit\_serum\_sodium,

'urine\_protein' as icu\_admit\_urine\_protein,

'urine\_cr' as icu\_admit\_urine\_cr,

'urine\_sodium' as icu\_admit\_urine\_sodium,

'urine\_protein\_cr\_ratio' as icu\_admit\_urine\_prot\_cr\_ratio,

'bun' as icu\_admit\_bun,

'potassium' as icu\_admit\_potassium,

'chloride' as icu\_admit\_chloride,

'bicarb' as icu\_admit\_bicarb,

'hematocrit' as icu\_admit\_hematocrit,

'wbc' as icu\_admit\_wbc,

'magnesium' as icu\_admit\_magnesium,

'phosphate' as icu\_admit\_phosphate,

'calcium' as icu\_admit\_calcium,

'lactate' as icu\_admit\_lactate,

'ph' as icu\_admit\_ph,

'platelets' as icu\_admit\_platelets,

'albumin' as icu\_admit\_albumin,

'glucose' as icu\_admit\_glucose,

'inr' as icu\_admit\_inr,

'pt' as icu\_admit\_pt,

'ptt' as icu\_admit\_ptt,

'haptoglobin' as icu\_admit\_haptoglobin,

'ldh' as icu\_admit\_ldh,

'd-dimer' as icu\_admit\_d\_dimer

)

)

)

--select \* from icu\_admit\_labs order by 1;

, raw\_hosp\_admit\_labs as

(select distinct r.subject\_id,

case

when l.itemid=50090 then 'serum\_cr'

when l.itemid=50159 then 'serum\_sodium'

when l.itemid=50655 then 'urine\_protein'

when l.itemid=50264 then 'urine\_cr'

when l.itemid=50277 then 'urine\_sodium'

when l.itemid=50276 then 'urine\_protein\_cr\_ratio'

when l.itemid=50177 then 'bun'

when l.itemid=50149 then 'potassium'

when l.itemid=50083 then 'chloride'

when l.itemid=50172 then 'bicarb'

when l.itemid=50383 then 'hematocrit'

when l.itemid=50468 then 'wbc'

when l.itemid=50140 then 'magnesium'

when l.itemid=50148 then 'phosphate'

when l.itemid=50079 then 'calcium'

when l.itemid=50010 then 'lactate'

when l.itemid=50018 then 'ph'

when l.itemid=50428 then 'platelets'

when l.itemid=50060 then 'albumin'

when l.itemid=50112 then 'glucose'

end as lab\_type,

first\_value(l.value) over (partition by l.hadm\_id, l.itemid order by
l.charttime) as lab\_value,

first\_value(l.charttime) over (partition by l.hadm\_id order by
l.charttime) as hosp\_admit\_lab\_time

from readmissions r

join mimic2v26.labevents l

on r.first\_hadm\_id=l.hadm\_id

and l.itemid in
(50090,50159,50655,50264,50277,50276,50177,50149,50083,50172,50383,50468,50140,50148,50079,50010,50018,50428,50060,50112)

and extract(day from l.charttime-r.first\_hadm\_admit\_dt) = 0

)

--select \* from raw\_hosp\_admit\_labs order by 1,2;

, hosp\_admit\_labs as

(select \*

from (select \* from raw\_hosp\_admit\_labs)

pivot

(max(lab\_value) for lab\_type in

('serum\_cr' as hosp\_admit\_serum\_cr,

'serum\_sodium' as hosp\_admit\_serum\_sodium,

'urine\_protein' as hosp\_admit\_urine\_protein,

'urine\_cr' as hosp\_admit\_urine\_cr,

'urine\_sodium' as hosp\_admit\_urine\_sodium,

'urine\_protein\_cr\_ratio' as hosp\_admit\_urine\_prot\_cr\_ratio,

'bun' as hosp\_admit\_bun,

'potassium' as hosp\_admit\_potassium,

'chloride' as hosp\_admit\_chloride,

'bicarb' as hosp\_admit\_bicarb,

'hematocrit' as hosp\_admit\_hematocrit,

'wbc' as hosp\_admit\_wbc,

'magnesium' as hosp\_admit\_magnesium,

'phosphate' as hosp\_admit\_phosphate,

'calcium' as hosp\_admit\_calcium,

'lactate' as hosp\_admit\_lactate,

'ph' as hosp\_admit\_ph,

'platelets' as hosp\_admit\_platelets,

'albumin' as hosp\_admit\_albumin,

'glucose' as hosp\_admit\_glucose

)

)

)

--select \* from hosp\_admit\_labs order by 1;

, admit\_labs\_first\_icustay as

(select i.subject\_id,

extract(day from i.icu\_admit\_lab\_time-r.first\_hadm\_admit\_dt) as
days\_btw\_icu\_lab\_hosp\_admit,

case

when i.icu\_admit\_lab\_time is null or h.hosp\_admit\_lab\_time is null
then null

when abs(extract(minute from
i.icu\_admit\_lab\_time-h.hosp\_admit\_lab\_time)) &lt; 10 then 'Y'

else 'N'

end as same\_hosp\_icu\_admit\_labs,

case

when LENGTH(TRIM(TRANSLATE(i.icu\_admit\_serum\_cr, ' +-.0123456789', '
'))) &gt; 0 then null

else to\_number(i.icu\_admit\_serum\_cr)

end as icu\_admit\_serum\_cr,

case

when LENGTH(TRIM(TRANSLATE(i.icu\_admit\_serum\_sodium, '
+-.0123456789', ' '))) &gt; 0 then null

else to\_number(i.icu\_admit\_serum\_sodium)

end as icu\_admit\_serum\_sodium,

case

when i.icu\_admit\_urine\_protein in ('N','NEG','NEGATIVE','Neg') then 0

when i.icu\_admit\_urine\_protein in ('TR','Tr') then 1

when i.icu\_admit\_urine\_protein in ('15','25','30') then 30

when i.icu\_admit\_urine\_protein in ('75','100') then 100

when i.icu\_admit\_urine\_protein in ('150','300') then 300

when i.icu\_admit\_urine\_protein in ('&gt;300','&gt;600','500') then
500

else null

end as icu\_admit\_urine\_protein,

case

when LENGTH(TRIM(TRANSLATE(i.icu\_admit\_urine\_cr, ' +-.0123456789', '
'))) &gt; 0 then null

else to\_number(i.icu\_admit\_urine\_cr)

end as icu\_admit\_urine\_cr,

case

when i.icu\_admit\_urine\_sodium='&lt;10' or
(lower(i.icu\_admit\_urine\_sodium) like '%less%' and
i.icu\_admit\_urine\_sodium like '%10%') then 0

when LENGTH(TRIM(TRANSLATE(i.icu\_admit\_urine\_sodium, '
+-.0123456789', ' '))) &gt; 0 then null

else to\_number(i.icu\_admit\_urine\_sodium)

end as icu\_admit\_urine\_sodium,

case

when LENGTH(TRIM(TRANSLATE(i.icu\_admit\_urine\_prot\_cr\_ratio, '
+-.0123456789', ' '))) &gt; 0 then null

else to\_number(i.icu\_admit\_urine\_prot\_cr\_ratio)

end as icu\_admit\_urine\_prot\_cr\_ratio,

i.icu\_admit\_bun,

i.icu\_admit\_potassium,

i.icu\_admit\_chloride,

i.icu\_admit\_bicarb,

i.icu\_admit\_hematocrit,

i.icu\_admit\_wbc,

i.icu\_admit\_magnesium,

i.icu\_admit\_phosphate,

i.icu\_admit\_calcium,

i.icu\_admit\_lactate,

i.icu\_admit\_ph,

i.icu\_admit\_platelets,

i.icu\_admit\_albumin,

i.icu\_admit\_glucose,

i.icu\_admit\_inr,

i.icu\_admit\_pt,

i.icu\_admit\_ptt,

i.icu\_admit\_haptoglobin,

i.icu\_admit\_ldh,

i.icu\_admit\_d\_dimer,

case

when LENGTH(TRIM(TRANSLATE(h.hosp\_admit\_serum\_cr, ' +-.0123456789', '
'))) &gt; 0 then null

else to\_number(h.hosp\_admit\_serum\_cr)

end as hosp\_admit\_serum\_cr,

case

when LENGTH(TRIM(TRANSLATE(h.hosp\_admit\_serum\_sodium, '
+-.0123456789', ' '))) &gt; 0 then null

else to\_number(h.hosp\_admit\_serum\_sodium)

end as hosp\_admit\_serum\_sodium,

case

when h.hosp\_admit\_urine\_protein in ('N','NEG','NEGATIVE','Neg') then
0

when h.hosp\_admit\_urine\_protein in ('TR','Tr') then 1

when h.hosp\_admit\_urine\_protein in ('15','25','30') then 30

when h.hosp\_admit\_urine\_protein in ('75','100') then 100

when h.hosp\_admit\_urine\_protein in ('150','300') then 300

when h.hosp\_admit\_urine\_protein in ('&gt;300','&gt;600','500') then
500

else null

end as hosp\_admit\_urine\_protein,

case

when LENGTH(TRIM(TRANSLATE(h.hosp\_admit\_urine\_cr, ' +-.0123456789', '
'))) &gt; 0 then null

else to\_number(h.hosp\_admit\_urine\_cr)

end as hosp\_admit\_urine\_cr,

case

when h.hosp\_admit\_urine\_sodium='&lt;10' or
(lower(h.hosp\_admit\_urine\_sodium) like '%less%' and
h.hosp\_admit\_urine\_sodium like '%10%') then 0

when LENGTH(TRIM(TRANSLATE(h.hosp\_admit\_urine\_sodium, '
+-.0123456789', ' '))) &gt; 0 then null

else to\_number(h.hosp\_admit\_urine\_sodium)

end as hosp\_admit\_urine\_sodium,

case

when LENGTH(TRIM(TRANSLATE(h.hosp\_admit\_urine\_prot\_cr\_ratio, '
+-.0123456789', ' '))) &gt; 0 then null

else to\_number(h.hosp\_admit\_urine\_prot\_cr\_ratio)

end as hosp\_admit\_urine\_prot\_cr\_ratio,

h.hosp\_admit\_bun,

h.hosp\_admit\_potassium,

h.hosp\_admit\_chloride,

h.hosp\_admit\_bicarb,

h.hosp\_admit\_hematocrit,

h.hosp\_admit\_wbc,

h.hosp\_admit\_magnesium,

h.hosp\_admit\_phosphate,

h.hosp\_admit\_calcium,

h.hosp\_admit\_lactate,

h.hosp\_admit\_ph,

h.hosp\_admit\_platelets,

h.hosp\_admit\_albumin,

h.hosp\_admit\_glucose

from readmissions r

left join icu\_admit\_labs i on r.subject\_id=i.subject\_id

left join hosp\_admit\_labs h on i.subject\_id=h.subject\_id

)

--select \* from admit\_labs\_first\_icustay;

-- Get peak creatinine values from first ICU stays

, peak\_creat\_first\_icustay as

(select distinct r.subject\_id,

count(\*) as num\_cr\_first\_icustay,

max(l.valuenum) as cr\_peak\_first\_icustay

from first\_admissions r

join mimic2v26.labevents l on r.first\_icustay\_id=l.icustay\_id and
l.itemid=50090

group by r.subject\_id

)

--select \* from peak\_creat\_first\_icustay;

-- Get discharge creatinine values from first ICU stays

, disch\_creat\_first\_icustay as

(select distinct r.subject\_id,

first\_value(l.valuenum) over (partition by l.icustay\_id order by
l.charttime desc) as cr\_disch\_first\_icustay

from first\_admissions r

join mimic2v26.labevents l on r.first\_icustay\_id=l.icustay\_id and
l.itemid=50090 and l.charttime between r.first\_icustay\_outtime -
interval '48' hour and r.first\_icustay\_outtime

)

--select \* from disch\_creat\_first\_icustay;

-- Get number of days with at least one creatinine measurement during
the first ICU stay

, days\_with\_cr\_first\_icustay as

(select distinct r.subject\_id,

icud.seq

from first\_admissions r

join mimic2v26.icustay\_days icud on
r.first\_icustay\_id=icud.icustay\_id

join mimic2v26.labevents l on r.first\_icustay\_id=l.icustay\_id and
l.itemid=50090 and l.charttime between icud.begintime and icud.endtime

)

--select \* from days\_with\_cr\_first\_icustay;

, num\_daily\_cr\_first\_icustay as

(select subject\_id,

count(\*) as num\_daily\_cr\_first\_icustay

from days\_with\_cr\_first\_icustay

group by subject\_id

)

--select \* from num\_daily\_cr\_first\_icustay;

-- Get admit creatinine values from second ICU stays

, admit\_labs\_second\_icustay as

(select distinct r.subject\_id,

first\_value(l.valuenum) over (partition by l.icustay\_id order by
l.charttime) as admit\_serum\_cr\_second\_icustay

from first\_admissions r

join mimic2v26.labevents l on r.second\_icustay\_id=l.icustay\_id and
l.itemid=50090 and l.charttime between r.second\_icustay\_intime -
interval '12' hour and r.second\_icustay\_intime + interval '12' hour

)

--select \* from admit\_labs\_second\_icustay;

-- Combine all labs together

, all\_labs as

(select alf.\*,

pcf.cr\_peak\_first\_icustay,

dcf.cr\_disch\_first\_icustay,

pcf.num\_cr\_first\_icustay,

ncf.num\_daily\_cr\_first\_icustay,

als.admit\_serum\_cr\_second\_icustay

from admit\_labs\_first\_icustay alf

left join peak\_creat\_first\_icustay pcf on
alf.subject\_id=pcf.subject\_id

left join disch\_creat\_first\_icustay dcf on
alf.subject\_id=dcf.subject\_id

left join num\_daily\_cr\_first\_icustay ncf on
alf.subject\_id=ncf.subject\_id

left join admit\_labs\_second\_icustay als on
alf.subject\_id=als.subject\_id

)

--select \* from all\_labs;

-- Narrow down Chartevents table

, small\_chartevents as

(select subject\_id,

icustay\_id,

itemid,

charttime,

value1num,

value2num

from mimic2v26.chartevents

where itemid in
(580,581,763,762,920,211,51,52,455,456,678,679,646,834,20001)

and subject\_id in (select subject\_id from first\_admissions)

)

--select \* from small\_chartevents;

-- Get admit weight from first ICU stays

, admit\_weight\_first\_icustay as

(select distinct r.subject\_id,

first\_value(l.value1num) over (partition by l.icustay\_id order by
l.charttime) as weight\_admit\_first\_icustay

from first\_admissions r

join small\_chartevents l on r.first\_icustay\_id=l.icustay\_id and
l.itemid=762 and l.charttime between r.first\_icustay\_intime and
r.first\_icustay\_intime + interval '24' hour

)

--select \* from admit\_weight\_first\_icustay;

-- Get admit height from first ICU stays

, admit\_height\_first\_icustay as

(select distinct r.subject\_id,

first\_value(l.value1num) over (partition by l.icustay\_id order by
l.charttime) as height\_admit\_first\_icustay

from first\_admissions r

join small\_chartevents l on r.first\_icustay\_id=l.icustay\_id and
l.itemid=920 and l.charttime between r.first\_icustay\_intime and
r.first\_icustay\_intime + interval '24' hour

)

--select \* from admit\_height\_first\_icustay;

-- Get discharge weight from first ICU stays

, disch\_weight\_first\_icustay as

(select distinct r.subject\_id,

first\_value(l.value1num) over (partition by l.icustay\_id order by
l.charttime desc) as weight\_disch\_first\_icustay

from first\_admissions r

join small\_chartevents l on r.first\_icustay\_id=l.icustay\_id and
l.itemid in (580,581,763) and l.charttime between
r.first\_icustay\_outtime - interval '48' hour and
r.first\_icustay\_outtime

)

--select \* from disch\_weight\_first\_icustay;

-- Get admit weight from second ICU stays

, admit\_weight\_second\_icustay as

(select distinct r.subject\_id,

first\_value(l.value1num) over (partition by l.icustay\_id order by
l.charttime) as weight\_admit\_second\_icustay

from first\_admissions r

join small\_chartevents l on r.second\_icustay\_id=l.icustay\_id and
l.itemid=762 and l.charttime between r.second\_icustay\_intime and
r.second\_icustay\_intime + interval '24' hour

)

--select \* from admit\_weight\_second\_icustay;

-- Combine all weight and height together

, all\_weight\_height as

(select r.subject\_id,

awf.weight\_admit\_first\_icustay,

ahf.height\_admit\_first\_icustay,

case

when ahf.height\_admit\_first\_icustay &gt; 0 then
round(awf.weight\_admit\_first\_icustay/power(ahf.height\_admit\_first\_icustay\*0.0254,2),2)

else null

end as bmi\_admit\_first\_icustay,

dwf.weight\_disch\_first\_icustay,

aws.weight\_admit\_second\_icustay

from first\_admissions r

left join admit\_weight\_first\_icustay awf on
r.subject\_id=awf.subject\_id

left join admit\_height\_first\_icustay ahf on
r.subject\_id=ahf.subject\_id

left join disch\_weight\_first\_icustay dwf on
r.subject\_id=dwf.subject\_id

left join admit\_weight\_second\_icustay aws on
r.subject\_id=aws.subject\_id

)

--select \* from all\_weight\_height;

-- Get admit heart rate from first ICU stays

, admit\_hr\_first\_icustay as

(select distinct r.subject\_id,

first\_value(l.value1num) over (partition by l.icustay\_id order by
l.charttime) as hr\_admit\_first\_icustay

from first\_admissions r

join small\_chartevents l on r.first\_icustay\_id=l.icustay\_id and
l.itemid in (211) and l.charttime between r.first\_icustay\_intime and
r.first\_icustay\_intime + interval '24' hour

)

--select \* from admit\_hr\_first\_icustay;

-- Get admit heart rate from second ICU stays

, admit\_hr\_second\_icustay as

(select distinct r.subject\_id,

first\_value(l.value1num) over (partition by l.icustay\_id order by
l.charttime) as hr\_admit\_second\_icustay

from first\_admissions r

join small\_chartevents l on r.second\_icustay\_id=l.icustay\_id and
l.itemid in (211) and l.charttime between r.second\_icustay\_intime and
r.second\_icustay\_intime + interval '24' hour

)

--select \* from admit\_hr\_second\_icustay;

-- Get admit mean arterial pressure from first ICU stays

, admit\_map\_first\_icustay as

(select distinct r.subject\_id,

first\_value(l.value1num) over (partition by l.icustay\_id order by
l.charttime) as map\_admit\_first\_icustay,

first\_value(l.itemid) over (partition by l.icustay\_id order by
l.charttime) as map\_type\_first\_icustay

from first\_admissions r

join small\_chartevents l on r.first\_icustay\_id=l.icustay\_id and
l.itemid in (52,456) and l.charttime between r.first\_icustay\_intime
and r.first\_icustay\_intime + interval '24' hour

)

--select \* from admit\_map\_first\_icustay;

-- Get admit mean arterial pressure from second ICU stays

, admit\_map\_second\_icustay as

(select distinct r.subject\_id,

first\_value(l.value1num) over (partition by l.icustay\_id order by
l.charttime) as map\_admit\_second\_icustay,

first\_value(l.itemid) over (partition by l.icustay\_id order by
l.charttime) as map\_type\_second\_icustay

from first\_admissions r

join small\_chartevents l on r.second\_icustay\_id=l.icustay\_id and
l.itemid in (52,456) and l.charttime between r.second\_icustay\_intime
and r.second\_icustay\_intime + interval '24' hour

)

--select \* from admit\_map\_second\_icustay;

-- Get admit systolic and diastolic arterial pressure from first ICU
stays

, admit\_bp\_first\_icustay as

(select distinct r.subject\_id,

first\_value(l.value1num) over (partition by l.icustay\_id order by
l.charttime) as sbp\_admit\_first\_icustay,

first\_value(l.value2num) over (partition by l.icustay\_id order by
l.charttime) as dbp\_admit\_first\_icustay,

first\_value(l.itemid) over (partition by l.icustay\_id order by
l.charttime) as sbp\_dbp\_type\_first\_icustay

from first\_admissions r

join small\_chartevents l on r.first\_icustay\_id=l.icustay\_id and
l.itemid in (51,455) and l.charttime between r.first\_icustay\_intime
and r.first\_icustay\_intime + interval '24' hour

)

--select \* from admit\_bp\_first\_icustay;

-- Get admit systolic and diastolic arterial pressure from second ICU
stays

, admit\_bp\_second\_icustay as

(select distinct r.subject\_id,

first\_value(l.value1num) over (partition by l.icustay\_id order by
l.charttime) as sbp\_admit\_second\_icustay,

first\_value(l.value2num) over (partition by l.icustay\_id order by
l.charttime) as dbp\_admit\_second\_icustay,

first\_value(l.itemid) over (partition by l.icustay\_id order by
l.charttime) as sbp\_dbp\_type\_second\_icustay

from first\_admissions r

join small\_chartevents l on r.second\_icustay\_id=l.icustay\_id and
l.itemid in (51,455) and l.charttime between r.second\_icustay\_intime
and r.second\_icustay\_intime + interval '24' hour

)

--select \* from admit\_bp\_second\_icustay;

-- Get admit temperature from first ICU stays

, admit\_temp\_first\_icustay as

(select distinct r.subject\_id,

first\_value(l.value1num) over (partition by l.icustay\_id order by
l.charttime) as temp\_admit\_first\_icustay

from first\_admissions r

join small\_chartevents l on r.first\_icustay\_id=l.icustay\_id and
l.itemid in (678, 679) and l.charttime between r.first\_icustay\_intime
and r.first\_icustay\_intime + interval '24' hour

)

--select \* from admit\_temp\_first\_icustay;

-- Get admit temperature from second ICU stays

, admit\_temp\_second\_icustay as

(select distinct r.subject\_id,

first\_value(l.value1num) over (partition by l.icustay\_id order by
l.charttime) as temp\_admit\_second\_icustay

from first\_admissions r

join small\_chartevents l on r.second\_icustay\_id=l.icustay\_id and
l.itemid in (678, 679) and l.charttime between r.second\_icustay\_intime
and r.second\_icustay\_intime + interval '24' hour

)

--select \* from admit\_temp\_second\_icustay;

-- Get admit o2sat from first ICU stays

, admit\_o2sat\_first\_icustay as

(select distinct r.subject\_id,

first\_value(l.value1num) over (partition by l.icustay\_id order by
l.charttime) as o2sat\_admit\_first\_icustay

from first\_admissions r

join small\_chartevents l on r.first\_icustay\_id=l.icustay\_id and
l.itemid in (646, 834) and l.charttime between r.first\_icustay\_intime
and r.first\_icustay\_intime + interval '24' hour

)

--select \* from admit\_o2sat\_first\_icustay;

-- Get admit o2sat from second ICU stays

, admit\_o2sat\_second\_icustay as

(select distinct r.subject\_id,

first\_value(l.value1num) over (partition by l.icustay\_id order by
l.charttime) as o2sat\_admit\_second\_icustay

from first\_admissions r

join small\_chartevents l on r.second\_icustay\_id=l.icustay\_id and
l.itemid in (646, 834) and l.charttime between r.second\_icustay\_intime
and r.second\_icustay\_intime + interval '24' hour

)

--select \* from admit\_o2sat\_second\_icustay;

-- Total urine output during the first ICU stay

, uo\_first\_icustay as

(select r.subject\_id,

sum(ie.volume) as urine\_first\_icustay

from first\_admissions r

join mimic2v26.ioevents ie on r.first\_icustay\_id=ie.icustay\_id

where ie.itemid in ( 651, 715, 55, 56, 57, 61, 65, 69, 85, 94, 96, 288,
405, 428, 473, 2042, 2068, 2111, 2119, 2130, 1922, 2810, 2859, 3053,
3462, 3519, 3175, 2366, 2463, 2507, 2510, 2592, 2676, 3966, 3987, 4132,
4253, 5927 )

group by r.subject\_id

)

--select \* from uo\_first\_icustay;

, uo\_first\_icustay\_24h as

(select r.subject\_id,

sum(ie.volume) as urine\_first\_icustay\_24h

from first\_admissions r

join mimic2v26.ioevents ie on r.first\_icustay\_id=ie.icustay\_id and
ie.charttime between r.first\_icustay\_intime and
r.first\_icustay\_intime + interval '24' hour

where ie.itemid in ( 651, 715, 55, 56, 57, 61, 65, 69, 85, 94, 96, 288,
405, 428, 473, 2042, 2068, 2111, 2119, 2130, 1922, 2810, 2859, 3053,
3462, 3519, 3175, 2366, 2463, 2507, 2510, 2592, 2676, 3966, 3987, 4132,
4253, 5927 )

group by r.subject\_id

)

--select \* from uo\_first\_icustay\_24h;

-- Total 1/2 NS during the first ICU stay

, half\_ns\_first\_icustay as

(select r.subject\_id,

sum(ie.volume) as half\_ns\_first\_icustay

from first\_admissions r

join mimic2v26.ioevents ie on r.first\_icustay\_id=ie.icustay\_id

where ie.itemid not in (select itemid from rishi\_kothari.d\_fluiditems)

and ie.itemid in (select itemid from mimic2v26.d\_ioitems where
(lower(label) like '%normal saline%' or lower(label) like '%ns%') and
(lower(label) not like '%d%ns%') and (label like '%1/2%' or label like
'%.45%'))

group by r.subject\_id

)

--select \* from half\_ns\_first\_icustay;

-- Total 1/4 NS during the first ICU stay

, quarter\_ns\_first\_icustay as

(select r.subject\_id,

sum(ie.volume) as quarter\_ns\_first\_icustay

from first\_admissions r

join mimic2v26.ioevents ie on r.first\_icustay\_id=ie.icustay\_id

where ie.itemid not in (select itemid from rishi\_kothari.d\_fluiditems)

and ie.itemid in (select itemid from mimic2v26.d\_ioitems where
(lower(label) like '%normal saline%' or lower(label) like '%ns%') and
(lower(label) not like '%d%ns%') and (label like '%1/4%' or label like
'%.22%'))

group by r.subject\_id

)

--select \* from quarter\_ns\_first\_icustay;

-- Total D5W during the first ICU stay

, d5w\_first\_icustay as

(select r.subject\_id,

sum(ie.volume) as d5w\_first\_icustay

from first\_admissions r

join mimic2v26.ioevents ie on r.first\_icustay\_id=ie.icustay\_id

where ie.itemid not in (select itemid from rishi\_kothari.d\_fluiditems)

and ie.itemid in (select itemid from mimic2v26.d\_ioitems where
lower(label) like '%d5w%' and lower(label) not like '%d5%ns%' and
lower(label) not like '%d5%lr%' and lower(label) not like '%d5%rl%')

group by r.subject\_id

)

--select \* from d5w\_first\_icustay;

-- Total crystalloid volume during the first ICU stay

, cryst\_first\_icustay as

(select r.subject\_id,

sum(ie.volume) as cryst\_first\_icustay

from first\_admissions r

join mimic2v26.ioevents ie on r.first\_icustay\_id=ie.icustay\_id

where ie.itemid in (select itemid from rishi\_kothari.d\_fluiditems)

group by r.subject\_id

)

--select \* from cryst\_first\_icustay;

-- Total colloid volume during the first ICU stay

, colloid\_first\_icustay as

(select r.subject\_id,

sum(ie.volume) as colloid\_first\_icustay

from first\_admissions r

join mimic2v26.ioevents ie on r.first\_icustay\_id=ie.icustay\_id

where ie.itemid in (select itemid from rishi\_kothari.d\_colloids)

group by r.subject\_id

)

--select \* from colloid\_first\_icustay;

-- Total PO intake during the first ICU stay

, pointake\_first\_icustay as

(select r.subject\_id,

sum(t.cumvolume) as po\_intake\_first\_icustay

from first\_admissions r

join mimic2v26.totalbalevents t on r.first\_icustay\_id=t.icustay\_id

where itemid=20

group by r.subject\_id

)

--select \* from pointake\_first\_icustay;

-- Total stool loss during the first ICU stay

, stool\_first\_icustay as

(select r.subject\_id,

sum(t.cumvolume) as stool\_first\_icustay

from first\_admissions r

join mimic2v26.totalbalevents t on r.first\_icustay\_id=t.icustay\_id

where itemid=22

group by r.subject\_id

)

--select \* from pointake\_first\_icustay;

-- Total input during the first ICU stay

, totalin\_first\_icustay as

(select r.subject\_id,

sum(t.cumvolume) as total\_in\_first\_icustay

from first\_admissions r

join mimic2v26.totalbalevents t on r.first\_icustay\_id=t.icustay\_id

where itemid=1

group by r.subject\_id

)

--select \* from totalin\_first\_icustay;

-- Total output during the first ICU stay

, totalout\_first\_icustay as

(select r.subject\_id,

sum(t.cumvolume) as total\_out\_first\_icustay

from first\_admissions r

join mimic2v26.totalbalevents t on r.first\_icustay\_id=t.icustay\_id

where itemid=2

group by r.subject\_id

)

--select \* from totalout\_first\_icustay;

-- Total fluid balance for the first ICU stay

, fluidbal\_first\_icustay as

(select distinct r.subject\_id,

first\_value(t.cumvolume) over (partition by t.icustay\_id order by
t.charttime desc) as fluid\_balance\_first\_icustay

from first\_admissions r

join mimic2v26.totalbalevents t on r.first\_icustay\_id=t.icustay\_id

where itemid=28

)

--select \* from fluidbal\_first\_icustay;

-- ICD9 from first hospital admission

, icd9\_first\_admission as

(select r.subject\_id,

i.code,

i.description

from first\_admissions r

join mimic2v26.icd9 i on r.first\_hadm\_id=i.hadm\_id

where i.sequence = 1

)

--select \* from icd9\_first\_admission;

-- ICD9 from second hospital admission

, icd9\_second\_admission as

(select r.subject\_id,

i.code,

i.description

from first\_admissions r

join mimic2v26.icd9 i on r.second\_hadm\_id=i.hadm\_id

where i.sequence = 1

)

--select \* from icd9\_second\_admission;

------------------------------------

--- Start of dialysis-related data

------------------------------------

, first\_dialysis as

(select distinct r.subject\_id,

r.first\_hadm\_id,

r.first\_icustay\_id,

first\_value(p.proc\_dt) over (partition by p.hadm\_id order by
p.proc\_dt) as first\_dialysis\_dt

from first\_admissions r

join mimic2v26.procedureevents p on r.first\_hadm\_id=p.hadm\_id

where p.itemid in (100977,100622)

)

--select \* from first\_dialysis;

-- Hemodialysis during the first hospital admission

, hd as

(select distinct r.subject\_id

from first\_admissions r

join mimic2v26.procedureevents p on r.first\_hadm\_id=p.hadm\_id

where p.itemid=100622

)

--select \* from hd;

-- Peritoneal dialysis during the first hospital admission

, pd as

(select distinct r.subject\_id

from first\_admissions r

join mimic2v26.procedureevents p on r.first\_hadm\_id=p.hadm\_id

where p.itemid=100977

)

--select \* from pd;

, labs\_proximal\_to\_dialysis as

(select fd.subject\_id,

extract(day from fd.first\_dialysis\_dt-r.first\_icustay\_intime) as
icu\_day\_first\_dialysis,

fd.first\_dialysis\_dt-r.first\_hadm\_admit\_dt as
hosp\_day\_first\_dialysis,

fd.first\_dialysis\_dt,

l.itemid,

l.charttime,

first\_value(l.valuenum) over (partition by fd.subject\_id,l.itemid
order by fd.first\_dialysis\_dt-l.charttime) as proximal\_lab

from first\_dialysis fd

join first\_admissions r on fd.subject\_id=r.subject\_id

join mimic2v26.labevents l on r.first\_hadm\_id=l.hadm\_id and l.itemid
in (50090,50177) and l.charttime &lt; fd.first\_dialysis\_dt

)

--select \* from labs\_proximal\_to\_dialysis;

, labs\_prior\_to\_dialysis as

(select subject\_id,

icu\_day\_first\_dialysis,

hosp\_day\_first\_dialysis,

first\_dialysis\_dt,

cr\_prior\_to\_dialysis,

bun\_prior\_to\_dialysis

from (select distinct subject\_id, icu\_day\_first\_dialysis,
hosp\_day\_first\_dialysis, first\_dialysis\_dt, itemid, proximal\_lab
from labs\_proximal\_to\_dialysis)

pivot

(avg(proximal\_lab) for itemid in

('50090' as cr\_prior\_to\_dialysis,

'50177' as bun\_prior\_to\_dialysis

)

)

)

--select \* from labs\_prior\_to\_dialysis;

, cr\_and\_dialysis as

(select subject\_id,

extract(day from min(first\_dialysis\_dt-charttime)) as
days\_btw\_cr\_and\_dialysis

from labs\_proximal\_to\_dialysis

where itemid=50090

group by subject\_id

)

--select \* from cr\_and\_dialysis;

, fluidbal\_dialysis as

(select distinct f.subject\_id,

first\_value(t.cumvolume) over (partition by t.icustay\_id order by
t.charttime desc) as fluidbal\_prior\_to\_dialysis

from first\_dialysis f

join mimic2v26.totalbalevents t on f.first\_icustay\_id=t.icustay\_id

where t.itemid=28

and t.charttime &lt; f.first\_dialysis\_dt

)

--select \* from fluidbal\_dialysis;

, uo\_dialysis as

(select f.subject\_id,

sum(ie.volume) as urine\_prior\_to\_dialysis

from first\_dialysis f

join mimic2v26.ioevents ie on f.first\_icustay\_id=ie.icustay\_id and
ie.charttime &lt; f.first\_dialysis\_dt

where ie.itemid in ( 651, 715, 55, 56, 57, 61, 65, 69, 85, 94, 96, 288,
405, 428, 473, 2042, 2068, 2111, 2119, 2130, 1922, 2810, 2859, 3053,
3462, 3519, 3175, 2366, 2463, 2507, 2510, 2592, 2676, 3966, 3987, 4132,
4253, 5927 )

and ie.volume &gt; 0

group by f.subject\_id

)

--select \* from uo\_dialysis;

, ivf\_dialysis as

(select f.subject\_id,

sum(ie.volume) as ivf\_prior\_to\_dialysis

from first\_dialysis f

join mimic2v26.ioevents ie on f.first\_icustay\_id=ie.icustay\_id and
ie.charttime &lt; f.first\_dialysis\_dt

where (ie.itemid in (select itemid from rishi\_kothari.d\_fluiditems) or
ie.itemid in (select itemid from rishi\_kothari.d\_colloids))

and ie.volume &gt; 0

group by f.subject\_id

)

--select \* from ivf\_dialysis;

, saps\_dialysis as

(select distinct f.subject\_id,

first\_value(ce.value1num) over (partition by f.subject\_id order by
ce.charttime desc) as saps\_day\_of\_dialysis

from first\_dialysis f

join small\_chartevents ce on f.first\_icustay\_id=ce.icustay\_id and
ce.itemid=20001 and ce.charttime&gt;=f.first\_dialysis\_dt and
extract(day from ce.charttime-f.first\_dialysis\_dt)=0

)

--select \* from saps\_dialysis;

, all\_dialysis\_data as

(select f.\*,

case

when hd.subject\_id is null then 'N'

else 'Y'

end as hd\_first\_hadm,

case

when pd.subject\_id is null then 'N'

else 'Y'

end as pd\_first\_hadm,

l.icu\_day\_first\_dialysis,

l.hosp\_day\_first\_dialysis,

l.cr\_prior\_to\_dialysis,

cd.days\_btw\_cr\_and\_dialysis,

l.bun\_prior\_to\_dialysis,

fd.fluidbal\_prior\_to\_dialysis,

ud.urine\_prior\_to\_dialysis,

ivfd.ivf\_prior\_to\_dialysis,

s.saps\_day\_of\_dialysis

from first\_dialysis f

left join hd on f.subject\_id=hd.subject\_id

left join pd on f.subject\_id=pd.subject\_id

left join labs\_prior\_to\_dialysis l on f.subject\_id=l.subject\_id

left join cr\_and\_dialysis cd on f.subject\_id=cd.subject\_id

left join fluidbal\_dialysis fd on f.subject\_id=fd.subject\_id

left join uo\_dialysis ud on f.subject\_id=ud.subject\_id

left join ivf\_dialysis ivfd on f.subject\_id=ivfd.subject\_id

left join saps\_dialysis s on f.subject\_id=s.subject\_id

)

--select \* from all\_dialysis\_data;

---------------------------------

--- End of dialysis-related data

---------------------------------

-- daily SAPS scores

, daily\_saps as

(select r.subject\_id,

sum(ce.value1num) as total\_saps\_first\_icustay,

count(\*) as num\_saps\_scores\_first\_icustay,

max(ce.value1num) as peak\_saps\_first\_icustay

from first\_admissions r

join small\_chartevents ce on r.first\_icustay\_id=ce.icustay\_id and
ce.itemid=20001

group by r.subject\_id

)

--select \* from daily\_saps;

-- mechanical ventilation

, mech\_vent as

(select distinct icustay\_id

from mimic2devel.ventilation

)

--select \* from mech\_vent

-- Get home diuretics

, count\_home\_diuretics as

(select r.subject\_id,

case

when hm.hadm\_id is null then null

when pm.name is not null then 1

else 0

end diuretic\_flg

from first\_admissions r

left join lilehman.pt\_with\_home\_meds hm on
r.first\_hadm\_id=hm.hadm\_id

left join lilehman.ppi\_admission\_drugs2 p on
r.first\_hadm\_id=p.hadm\_id

left join djscott.ppi\_med\_groups pm on
instr(pm.name,p.medication)&gt;0 and pm.med\_category='DIURETIC'

)

--select \* from count\_home\_diuretics;

-- Tally the number of home diuretics

, home\_diuretics as

(select subject\_id,

sum(diuretic\_flg) as num\_home\_diuretics

from count\_home\_diuretics

group by subject\_id

)

--select \* from home\_diuretics;

-- Vasopressors during the first 24 hours in the ICU

, icu\_admit\_pressors as

(SELECT DISTINCT r.subject\_id

FROM first\_admissions r

JOIN mimic2v26.medevents m

on r.first\_icustay\_id=m.icustay\_id

WHERE m.itemid in (42, 43, 44, 46, 47, 51, 119, 120, 125, 127, 128, 306,
307, 309)

and m.dose &gt; 0

and m.charttime between r.first\_icustay\_intime and
r.first\_icustay\_intime + interval '24' hour

)

--select \* from icu\_admit\_pressors;

-- Assemble final data

, final\_data as

(select r.subject\_id,

r.first\_hadm\_id,

r.first\_icustay\_id,

r.days\_btw\_hosp\_icu\_admit,

r.days\_btw\_hosp\_icu\_disch,

r.icu\_mort\_first\_admission,

r.hosp\_mort\_first\_admission,

r.first\_hadm\_source,

r.ED\_admission,

r.age\_first\_icustay,

r.gender,

r.race,

r.first\_icustay\_los,

r.icustay\_first\_service,

r.first\_icustay\_admit\_saps,

r.first\_hadm\_sepsis,

r.second\_hadm\_id,

r.second\_icustay\_id,

r.readmission\_90d,

r.readmission\_1yr,

r.days\_to\_readmission,

r.mortality\_90d,

r.mortality\_1yr,

r.survival\_2yr\_hadm\_disch,

r.survival\_2yr\_icu\_disch,

r.days\_icu\_disch\_to\_hosp\_mort,

al.days\_btw\_icu\_lab\_hosp\_admit,

al.same\_hosp\_icu\_admit\_labs,

al.icu\_admit\_serum\_cr,

al.icu\_admit\_serum\_sodium,

al.icu\_admit\_urine\_protein,

al.icu\_admit\_urine\_cr,

al.icu\_admit\_urine\_sodium,

al.icu\_admit\_urine\_prot\_cr\_ratio,

al.icu\_admit\_bun,

al.icu\_admit\_potassium,

al.icu\_admit\_chloride,

al.icu\_admit\_bicarb,

al.icu\_admit\_hematocrit,

al.icu\_admit\_wbc,

al.icu\_admit\_magnesium,

al.icu\_admit\_phosphate,

al.icu\_admit\_calcium,

al.icu\_admit\_lactate,

al.icu\_admit\_ph,

al.icu\_admit\_platelets,

al.icu\_admit\_albumin,

al.icu\_admit\_glucose,

al.icu\_admit\_inr,

al.icu\_admit\_pt,

al.icu\_admit\_ptt,

al.icu\_admit\_haptoglobin,

al.icu\_admit\_ldh,

al.icu\_admit\_d\_dimer,

al.hosp\_admit\_serum\_cr,

al.hosp\_admit\_serum\_sodium,

al.hosp\_admit\_urine\_protein,

al.hosp\_admit\_urine\_cr,

al.hosp\_admit\_urine\_sodium,

al.hosp\_admit\_urine\_prot\_cr\_ratio,

al.hosp\_admit\_bun,

al.hosp\_admit\_potassium,

al.hosp\_admit\_chloride,

al.hosp\_admit\_bicarb,

al.hosp\_admit\_hematocrit,

al.hosp\_admit\_wbc,

al.hosp\_admit\_magnesium,

al.hosp\_admit\_phosphate,

al.hosp\_admit\_calcium,

al.hosp\_admit\_lactate,

al.hosp\_admit\_ph,

al.hosp\_admit\_platelets,

al.hosp\_admit\_albumin,

al.hosp\_admit\_glucose,

al.cr\_peak\_first\_icustay,

al.cr\_disch\_first\_icustay,

al.num\_cr\_first\_icustay,

al.num\_daily\_cr\_first\_icustay,

al.admit\_serum\_cr\_second\_icustay,

CASE

WHEN r.gender='F' AND (r.race LIKE '%AFRICAN%' OR r.race LIKE '%BLACK%')
THEN ROUND(186
\*POWER(al.cr\_disch\_first\_icustay,-1.154)\*POWER(r.age\_first\_icustay,-0.203)
\* 1.212 \* 0.742 ,2)

WHEN r.gender='M' AND (r.race LIKE '%AFRICAN%' OR r.race LIKE '%BLACK%')
THEN ROUND(186
\*POWER(al.cr\_disch\_first\_icustay,-1.154)\*POWER(r.age\_first\_icustay,-0.203)
\* 1.212 ,2)

WHEN r.gender='F' AND (r.race NOT LIKE '%AFRICAN%' AND r.race NOT LIKE
'%BLACK%') THEN ROUND(186
\*POWER(al.cr\_disch\_first\_icustay,-1.154)\*POWER(r.age\_first\_icustay,-0.203)
\* 0.742 ,2)

WHEN r.gender='M' AND (r.race NOT LIKE '%AFRICAN%' AND r.race NOT LIKE
'%BLACK%') THEN ROUND(186
\*POWER(al.cr\_disch\_first\_icustay,-1.154)\*POWER(r.age\_first\_icustay,-0.203)
,2)

END as mdrd\_disch\_first\_icustay,

awh.weight\_admit\_first\_icustay,

awh.height\_admit\_first\_icustay,

awh.bmi\_admit\_first\_icustay,

awh.weight\_disch\_first\_icustay,

awh.weight\_admit\_second\_icustay,

ahf.hr\_admit\_first\_icustay,

ahs.hr\_admit\_second\_icustay,

round(amf.map\_admit\_first\_icustay,2) as map\_admit\_first\_icustay,

case

when amf.map\_type\_first\_icustay=52 then 'invasive'

when amf.map\_type\_first\_icustay=456 then 'non-invasive'

else null

end as map\_type\_first\_icustay,

round(ams.map\_admit\_second\_icustay,2) as map\_admit\_second\_icustay,

case

when ams.map\_type\_second\_icustay=52 then 'invasive'

when ams.map\_type\_second\_icustay=456 then 'non-invasive'

else null

end as map\_type\_second\_icustay,

abf.sbp\_admit\_first\_icustay,

abs.sbp\_admit\_second\_icustay,

abf.dbp\_admit\_first\_icustay,

abs.dbp\_admit\_second\_icustay,

case

when abf.sbp\_dbp\_type\_first\_icustay=51 then 'invasive'

when abf.sbp\_dbp\_type\_first\_icustay=455 then 'non-invasive'

else null

end as sbp\_dbp\_type\_first\_icustay,

case

when abs.sbp\_dbp\_type\_second\_icustay=51 then 'invasive'

when abs.sbp\_dbp\_type\_second\_icustay=455 then 'non-invasive'

else null

end as sbp\_dbp\_type\_second\_icustay,

round(atf.temp\_admit\_first\_icustay,2) as temp\_admit\_first\_icustay,

round(ats.temp\_admit\_second\_icustay,2) as
temp\_admit\_second\_icustay,

aof.o2sat\_admit\_first\_icustay,

aos.o2sat\_admit\_second\_icustay,

ufi.urine\_first\_icustay,

ufi24.urine\_first\_icustay\_24h,

case

when hnf.half\_ns\_first\_icustay is null then 0

else hnf.half\_ns\_first\_icustay

end as half\_ns\_first\_icustay,

case

when qnf.quarter\_ns\_first\_icustay is null then 0

else qnf.quarter\_ns\_first\_icustay

end as quarter\_ns\_first\_icustay,

case

when dwf.d5w\_first\_icustay is null then 0

else dwf.d5w\_first\_icustay

end as d5w\_first\_icustay,

case

when crf.cryst\_first\_icustay is null then 0

else crf.cryst\_first\_icustay

end as iso\_cryst\_first\_icustay,

case

when cof.colloid\_first\_icustay is null then 0

else cof.colloid\_first\_icustay

end as colloid\_first\_icustay,

case

when crf.cryst\_first\_icustay is null and cof.colloid\_first\_icustay
is null then 0

when crf.cryst\_first\_icustay is null and cof.colloid\_first\_icustay
is not null then cof.colloid\_first\_icustay

when crf.cryst\_first\_icustay is not null and
cof.colloid\_first\_icustay is null then crf.cryst\_first\_icustay

else crf.cryst\_first\_icustay+cof.colloid\_first\_icustay

end as ivf\_first\_icustay,

case

when pif.po\_intake\_first\_icustay is null then 0

else pif.po\_intake\_first\_icustay

end as po\_intake\_first\_icustay,

case

when sf.stool\_first\_icustay is null then 0

else sf.stool\_first\_icustay

end as stool\_first\_icustay,

round(tif.total\_in\_first\_icustay,1) as total\_in\_first\_icustay,

round(tof.total\_out\_first\_icustay,1) as total\_out\_first\_icustay,

round(ff.fluid\_balance\_first\_icustay,1) as
fluid\_balance\_first\_icustay,

ad.first\_dialysis\_dt,

ad.hd\_first\_hadm,

ad.pd\_first\_hadm,

ad.icu\_day\_first\_dialysis,

ad.hosp\_day\_first\_dialysis,

ad.cr\_prior\_to\_dialysis,

ad.days\_btw\_cr\_and\_dialysis,

ad.bun\_prior\_to\_dialysis,

ad.fluidbal\_prior\_to\_dialysis,

ad.urine\_prior\_to\_dialysis,

ad.ivf\_prior\_to\_dialysis,

ad.saps\_day\_of\_dialysis,

d.esrd,

d.preadmit\_ckd,

d.preadmit\_base\_cr,

case

when iap.subject\_id is null then 'N'

else 'Y'

end as first\_icu\_day\_vasopressor,

case

when vc.icustay\_id is null then 'N'

else 'Y'

end as vasopressor\_first\_icustay,

case

when mv.icustay\_id is null then 'N'

else 'Y'

end as mech\_vent\_first\_icustay,

ds.total\_saps\_first\_icustay,

ds.num\_saps\_scores\_first\_icustay,

ds.peak\_saps\_first\_icustay,

ifa.code as icd9\_code\_first\_icustay,

ifa.description as icd9\_descr\_first\_icustay,

isa.code as icd9\_code\_second\_icustay,

isa.description as icd9\_descr\_second\_icustay,

case

when hdr.num\_home\_diuretics is null then 'N'

else 'Y'

end as preadmit\_med\_section,

case

when hdr.num\_home\_diuretics is null then null

when hdr.num\_home\_diuretics&gt;0 then 'Y'

else 'N'

end as preadmit\_diuretics,

er.CONGESTIVE\_HEART\_FAILURE,

er.CARDIAC\_ARRHYTHMIAS,

er.VALVULAR\_DISEASE,

er.PULMONARY\_CIRCULATION,

er.PERIPHERAL\_VASCULAR,

er.HYPERTENSION,

er.PARALYSIS,

er.OTHER\_NEUROLOGICAL,

er.CHRONIC\_PULMONARY,

er.DIABETES\_UNCOMPLICATED,

er.DIABETES\_COMPLICATED,

er.HYPOTHYROIDISM,

er.RENAL\_FAILURE,

er.LIVER\_DISEASE,

er.PEPTIC\_ULCER,

er.AIDS,

er.LYMPHOMA,

er.METASTATIC\_CANCER,

er.SOLID\_TUMOR,

er.RHEUMATOID\_ARTHRITIS,

er.COAGULOPATHY,

er.OBESITY,

er.WEIGHT\_LOSS,

er.FLUID\_ELECTROLYTE,

er.BLOOD\_LOSS\_ANEMIA,

er.DEFICIENCY\_ANEMIAS,

er.ALCOHOL\_ABUSE,

er.DRUG\_ABUSE,

er.PSYCHOSES,

er.DEPRESSION

from first\_admissions r

left join all\_labs al on r.subject\_id=al.subject\_id

left join all\_weight\_height awh on r.subject\_id=awh.subject\_id

left join admit\_hr\_first\_icustay ahf on r.subject\_id=ahf.subject\_id

left join admit\_hr\_second\_icustay ahs on
r.subject\_id=ahs.subject\_id

left join admit\_map\_first\_icustay amf on
r.subject\_id=amf.subject\_id

left join admit\_map\_second\_icustay ams on
r.subject\_id=ams.subject\_id

left join admit\_bp\_first\_icustay abf on r.subject\_id=abf.subject\_id

left join admit\_bp\_second\_icustay abs on
r.subject\_id=abs.subject\_id

left join admit\_temp\_first\_icustay atf on
r.subject\_id=atf.subject\_id

left join admit\_temp\_second\_icustay ats on
r.subject\_id=ats.subject\_id

left join admit\_o2sat\_first\_icustay aof on
r.subject\_id=aof.subject\_id

left join admit\_o2sat\_second\_icustay aos on
r.subject\_id=aos.subject\_id

left join uo\_first\_icustay ufi on r.subject\_id=ufi.subject\_id

left join uo\_first\_icustay\_24h ufi24 on
r.subject\_id=ufi24.subject\_id

left join half\_ns\_first\_icustay hnf on r.subject\_id=hnf.subject\_id

left join quarter\_ns\_first\_icustay qnf on
r.subject\_id=qnf.subject\_id

left join d5w\_first\_icustay dwf on r.subject\_id=dwf.subject\_id

left join cryst\_first\_icustay crf on r.subject\_id=crf.subject\_id

left join colloid\_first\_icustay cof on r.subject\_id=cof.subject\_id

left join pointake\_first\_icustay pif on r.subject\_id=pif.subject\_id

left join stool\_first\_icustay sf on r.subject\_id=sf.subject\_id

left join totalin\_first\_icustay tif on r.subject\_id=tif.subject\_id

left join totalout\_first\_icustay tof on r.subject\_id=tof.subject\_id

left join fluidbal\_first\_icustay ff on r.subject\_id=ff.subject\_id

left join icd9\_first\_admission ifa on r.subject\_id=ifa.subject\_id

left join icd9\_second\_admission isa on r.subject\_id=isa.subject\_id

left join mimic2devel.elixhauser\_revised er on
r.first\_hadm\_id=er.hadm\_id

left join all\_dialysis\_data ad on r.subject\_id=ad.subject\_id

left join daily\_saps ds on r.subject\_id=ds.subject\_id

left join joonlee.vasopressor\_use\_cohort vc on
r.first\_icustay\_id=vc.icustay\_id

left join mech\_vent mv on r.first\_icustay\_id=mv.icustay\_id

left join home\_diuretics hdr on r.subject\_id=hdr.subject\_id

left join num\_daily\_cr\_first\_icustay ndc on
r.subject\_id=ndc.subject\_id

left join joonlee.dialysis\_manual\_review\_john d on
r.first\_hadm\_id=d.hadm\_id

left join icu\_admit\_pressors iap on r.subject\_id=iap.subject\_id

)

select \* from final\_data;
