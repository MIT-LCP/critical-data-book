--created by mpimentel, MIT book chapter project 
-- Last Updated: June 2015

--drop materialized view cohort_book_chapter;
create materialized view cohort_book_chapter as

with cohort as (
  select distinct
    id.subject_id
    , id.hadm_id
    , id.icustay_id
    , id.subject_icustay_total_num
    , id.dob
    , id.icustay_intime
    , id.icustay_outtime
    , id.dod
    , extract(day from id.icustay_outtime - id.icustay_intime)*1440 + extract(hour from id.icustay_outtime - id.icustay_intime)*60 + extract(minute from id.icustay_outtime - id.icustay_intime) minstodischarge 
    , id.gender
    , id.weight_first
    , id.height
    , round(id.icustay_admit_age,2) as age
    , round(id.icustay_los/(60*24),2) as ilos
    , id.icustay_first_careunit as careunit
    , id.icustay_first_service as servtype
    from mimic2v26.icustay_detail id
      where id.icustay_age_group = 'adult'
      and id.subject_icustay_seq = 1
      and id.hadm_id is not null
      and id.icustay_id < 1200
  )
--select count(*) from cohort;

, outcomes as (
  select distinct
    fc.icustay_id, 
    id.icustay_intime, 
    EXTRACT(DAY FROM id.dod - id.icustay_intime) death_after_icustay,
      CASE WHEN EXTRACT(DAY FROM id.dod - id.icustay_intime) < 29 
    THEN 1 ELSE 0 END AS mort_28d,
    CASE WHEN EXTRACT(DAY FROM id.dod - id.icustay_intime) < 366 
      THEN 1 ELSE 0 END AS mort_1y,
    CASE WHEN EXTRACT(DAY FROM id.dod - id.icustay_intime) < 731 
      THEN 1 ELSE 0 END AS mort_2y,
    CASE WHEN hospital_expire_flg = 'Y'
      THEN 1 ELSE 0 END AS mort_hos, 
    CASE WHEN icustay_expire_flg = 'Y'
      THEN 1 ELSE 0 END AS mort_icu
    from cohort fc
  join mimic2v26.icustay_detail id
    on fc.icustay_id = id.icustay_id
)
--select sum(MORT_ICU) from outcomes;

, assemble as (
  select distinct
      co.*
      , out1.mort_icu
      from cohort co
        left join outcomes out1 on out1.icustay_id = co.icustay_id
        where (out1.mort_hos = 0 and out1.mort_28d = 0 and out1.mort_icu = 0) 
          or (out1.mort_icu = 1)
)
--select count(*) from assemble order by icustay_id; -- 557
--select sum(mort_icu) from assemble;
select * from assemble order by icustay_id;
