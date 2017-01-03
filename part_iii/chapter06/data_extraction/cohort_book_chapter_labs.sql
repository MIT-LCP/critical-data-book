--created by mpimentel, MIT book chapter project 
-- Last Updated: June 2015

--drop materialized view cohort_book_chapter_labs;
--create materialized view cohort_book_chapter_labs as

with cohort as (
  select *
  from cohort_book_chapter
)
--select count(*) from cohort;

-- Datatype:
-- 1 - sodium, 2 - potassium, 3 - bicarbonate,
-- 4 - IBP Systolic, 5 - IBP Diastolic, 6 - IBP MAP
-- 7 - HR, 8 - SpO2, 9 - RR, 10 - temperature, 11 - GCS

, sodium as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime
         , extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) as min_post_adm
         , ce.valuenum val
         , ce.valueuom unit
         , '1' datatype
    from mimic2v26.labevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (50012, 50159)
      and ce.valuenum is not null
      order by subject_id, icustay_id, min_post_adm
)
--select * from sodium;
--select count(distinct icustay_id) from sodium; -- 29785

, potassium as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime
         , extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) as min_post_adm
         , ce.valuenum val
         , ce.valueuom unit
         , '1' datatype
    from mimic2v26.labevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (50009, 50149)
      and ce.valuenum is not null
      order by subject_id, icustay_id, min_post_adm
)
--select * from potassium;
--select count(distinct icustay_id) from sodium; -- 29785

, bicarbonate as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime
         , extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) as min_post_adm
         , ce.valuenum val
         , ce.valueuom unit
         , '1' datatype
    from mimic2v26.labevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (50022, 50025, 50172)
      and ce.valuenum is not null
      order by subject_id, icustay_id, min_post_adm
)
--select * from bicarbonate;

, aniongap as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime
         , extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) as min_post_adm
         , ce.valuenum val
         , ce.valueuom unit
         , '1' datatype
    from mimic2v26.labevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (50068)
      and ce.valuenum is not null
      order by subject_id, icustay_id, min_post_adm
)
--select * from aniongap;

, bun as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime
         , extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) as min_post_adm
         , ce.valuenum val
         , ce.valueuom unit
         , '1' datatype
    from mimic2v26.labevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (50177)
      and ce.valuenum is not null
      order by subject_id, icustay_id, min_post_adm
)
--select * from bun;

, creatinine as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime
         , extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) as min_post_adm
         , ce.valuenum val
         , ce.valueuom unit
         , '1' datatype
    from mimic2v26.labevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (50090)
      and ce.valuenum is not null
      order by subject_id, icustay_id, min_post_adm
)
--select * from creatinine;

, glucose as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime
         , extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) as min_post_adm
         , ce.valuenum val
         , ce.valueuom unit
         , '1' datatype
    from mimic2v26.labevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (50006, 50112)
      and ce.valuenum is not null
      order by subject_id, icustay_id, min_post_adm
)
--select * from glucose;

, calcium as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime
         , extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) as min_post_adm
         , ce.valuenum val
         , ce.valueuom unit
         , '1' datatype
    from mimic2v26.labevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (50079)
      and ce.valuenum is not null
      order by subject_id, icustay_id, min_post_adm
)
--select * from calcium;

, wbcc as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime
         , extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) as min_post_adm
         , ce.valuenum val
         , ce.valueuom unit
         , '1' datatype
    from mimic2v26.labevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (50316, 50468)
      and ce.valuenum is not null
      order by subject_id, icustay_id, min_post_adm
)
--select * from wbcc;

, hemoglobin as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime
         , extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) as min_post_adm
         , ce.valuenum val
         , ce.valueuom unit
         , '1' datatype
    from mimic2v26.labevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (50386)
      and ce.valuenum is not null
      order by subject_id, icustay_id, min_post_adm
)
--select * from hemoglobin;

, pco2 as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime
         , extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) as min_post_adm
         , ce.valuenum val
         , ce.valueuom unit
         , '1' datatype
    from mimic2v26.labevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (50016)
      and ce.valuenum is not null
      order by subject_id, icustay_id, min_post_adm
)
--select * from pco2;

, albumin as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime
         , extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) as min_post_adm
         , ce.valuenum val
         , ce.valueuom unit
         , '1' datatype
    from mimic2v26.labevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (50060)
      and ce.valuenum is not null
      order by subject_id, icustay_id, min_post_adm
)
--select * from albumin;

, totalbilirubin as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime
         , extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) as min_post_adm
         , ce.valuenum val
         , ce.valueuom unit
         , '1' datatype
    from mimic2v26.labevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (50170)
      and ce.valuenum is not null
      order by subject_id, icustay_id, min_post_adm
)
--select * from totalbilirubin;

, ast as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime
         , extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) as min_post_adm
         , ce.valuenum val
         , ce.valueuom unit
         , '1' datatype
    from mimic2v26.labevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (50073)
      and ce.valuenum is not null
      order by subject_id, icustay_id, min_post_adm
)
--select * from ast;

, arterialph as (
  select fc.subject_id
         , fc.icustay_id
         , fc.hadm_id
         , fc.icustay_intime
         , extract(day from ce.charttime - fc.icustay_intime)*1440 + extract(hour from ce.charttime - fc.icustay_intime)*60 + extract(minute from ce.charttime - fc.icustay_intime) as min_post_adm
         , ce.valuenum val
         , ce.valueuom unit
         , '1' datatype
    from mimic2v26.labevents ce 
    join cohort fc 
      on ce.icustay_id = fc.icustay_id
      where ce.itemid in (50018)
      and ce.valuenum is not null
      order by subject_id, icustay_id, min_post_adm
)
--select * from arterialph;
