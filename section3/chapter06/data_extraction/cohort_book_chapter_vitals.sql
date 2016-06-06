--created by mpimentel, MIT book chapter project 
-- Last Updated: June 2015

--drop materialized view cohort_book_chapter_vitals;
--create materialized view cohort_book_chapter_vitals as

with cohort as (
  select *
  from cohort_book_chapter
)
--select count(*) from cohort;

-- Datatype:
-- 1 - NBP Systolic, 2 - NBP Diastolic, 3 - NBP MAP,
-- 4 - IBP Systolic, 5 - IBP Diastolic, 6 - IBP MAP
-- 7 - HR, 8 - SpO2, 9 - RR, 10 - temperature, 11 - GCS

, sysbp as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime
         , extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) as min_post_adm
         , ce.value1num val
         , ce.value1uom unit
         , '1' datatype
    from mimic2v26.chartevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (442, 455) --noninvasive (442, 455) & invasive blood pressure (51)
      and ce.value1num <> 0
      and ce.value1num is not null
      order by subject_id, icustay_id, min_post_adm
)
--select * from sysbp;
--select count(distinct icustay_id) from sysbp; -- 29785

, diabp as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value2num val,
          ce.value2uom unit,
          '2' datatype
    from mimic2v26.chartevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (442,455) --noninvasive & invasive blood pressure
      and ce.value2num <> 0
      and ce.value2num is not null
      order by subject_id, icustay_id, min_post_adm
      --and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from diabp;
--select count(distinct icustay_id) from diabp; --29780

-- get mean arterial blood pressure blood prssure
, mbp as ( 
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value1num val, 
          ce.value1uom unit,
          '3' datatype
    from mimic2v26.chartevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where itemid in (443, 456) -- invasive (52, 224)
      and ce.value1num <> 0
      and ce.value1num is not null
      order by subject_id, icustay_id, min_post_adm
      --and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from mbp;
--select count(distinct icustay_id) from mbp; --29765

, sysibp as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value1num val,
          ce.value1uom unit,
          '4' datatype
    from mimic2v26.chartevents ce
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (51) --invasive blood pressure (51)
      and ce.value1num <> 0
      and ce.value1num is not null
      order by subject_id, icustay_id, min_post_adm
      --and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from sysibp;
--select * from sysibp order by 5;

, diaibp as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value2num val,
          ce.value2uom unit,
          '5' datatype
    from mimic2v26.chartevents ce
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (51) --invasive blood pressure
      and ce.value2num <> 0
      and ce.value2num is not null
      order by subject_id, icustay_id, min_post_adm
      --and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from diaibp;

-- get mean arterial blood pressure blood prssure
, mibp as ( 
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value1num val, 
          ce.value1uom unit,
          '6' datatype
    from mimic2v26.chartevents ce
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where itemid in (52) -- invasive
      and ce.value1num <> 0
      and ce.value1num is not null
      order by subject_id, icustay_id, min_post_adm
      --and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from mibp;
--select * from mibp order by 5;

-- get heart rate for icustay
, hr as ( 
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value1num val, 
          ce.value1uom unit,
          '7' datatype
    from mimic2v26.chartevents ce
    join cohort fc 
    on ce.icustay_id = fc.icustay_id
      where itemid = 211 --heart rate
      and ce.value1num <> 0
      and ce.value1num is not null
      order by subject_id, icustay_id, min_post_adm
      --and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from hr;

-- get peripheral oxygen saturation for icustay
, spo2 as ( 
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value1num val, 
          ce.value1uom unit,
          '8' datatype
    from mimic2v26.chartevents ce
    join cohort fc 
    on ce.icustay_id = fc.icustay_id
      where itemid in (646, 834) -- spo2
      and ce.value1num <> 0
      and ce.value1num is not null
      order by subject_id, icustay_id, min_post_adm
      --and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from spo2;

-- get respiration/breathing rate for icustay
, br as ( 
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value1num val, 
          ce.value1uom unit,
          '9' datatype
    from mimic2v26.chartevents ce
    join cohort fc 
    on ce.icustay_id = fc.icustay_id
      where itemid in (614, 615, 618, 1635, 1884, 3603, 3337) 
      -- resp. rate (1635 only appears for one patient; 
      --             1884 values are crazy and only appears for 2 or 3 patients)
      --             3603 values look somehow elevated (check if it corresponds to neonates)
      and ce.value1num <> 0
      and ce.value1num is not null
      order by subject_id, icustay_id, min_post_adm
      --and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from br;

-- get temperature for icustay (NOT CONVERTED)
, temp as ( 
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value1num val, 
          ce.value1uom unit,
          '10' datatype
    from mimic2v26.chartevents ce
    join cohort fc 
    on ce.icustay_id = fc.icustay_id
      where itemid in (676, 677, 678, 679) -- temperature
      and ce.value1num <> 0
      and ce.value1num is not null
      order by subject_id, icustay_id, min_post_adm
      --and extract(day from ce.charttime - fc.icustay_intime) < 4
)
--select * from temp;

-- get level of consciousness for icustay
, consciousness as ( 
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime,
          extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) min_post_adm, 
          ce.value1num val, 
          ce.value1uom unit,
          '11' datatype
    from mimic2v26.chartevents ce
    join cohort fc 
    on ce.icustay_id = fc.icustay_id
      where itemid in (198) -- gcs
      and ce.value1num <> 0
      and ce.value1num is not null
      order by subject_id, icustay_id, min_post_adm
      --and extract(day from ce.charttime - fc.icustay_intime) < 4
)
select * from consciousness;

-- finally, assemble
  select * from sysbp 
   union
  select * from diabp
   union
  select * from mbp
   union 
  select * from sysibp 
   union
  select * from diaibp
   union
  select * from mibp
   union
  select * from hr 
   union 
  select * from spo2
   union 
  select * from br 
   union 
  select * from temp
   union
  select * from consciousness;