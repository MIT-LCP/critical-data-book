\[code\]

create table aline\_mimic\_cohort\_feb14 as

with population as

(select subject\_id, hadm\_id, icustay\_id, icustay\_intime

from mimic2v26.icustay\_detail

where SUBJECT\_ICUSTAY\_SEQ=1

and ICUSTAY\_AGE\_GROUP='adult'

and hadm\_id is not null

)
