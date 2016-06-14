\[code\] \* *missing code for sepsis\_angus sep…couldn’t find this piece
of code on GitHub…*

, sepsis\_group as

(select distinct pop.icustay\_id, pop.hadm\_id, 1 as flg

from population pop

join sepsis\_angus sep on pop.hadm\_id = sep.hadm\_id

)

--select \* from sepsis\_group; --6339
