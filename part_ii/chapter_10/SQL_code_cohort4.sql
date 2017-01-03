-- SQL

, case when ICUSTAY\_FIRST\_SERVICE='SICU' then 1

when ICUSTAY\_FIRST\_SERVICE='CCU' then 2

when ICUSTAY\_FIRST\_SERVICE='CSRU' then 3

else 0 --MICU & FICU

end

as service\_num
