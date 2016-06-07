-- This query extracts data for the tutorial in the clinical data analytics book chapter. Only the first icu stays from adult patients are extracted.

with static_data as
(select icud.subject_id,
        icud.hadm_id,
        icud.icustay_id,                 
        case
         when icud.icustay_admit_age>150 then 91.4
         else round(icud.icustay_admit_age,1)
        end as icustay_admit_age,
        icud.gender, 
        dd.admission_type_descr as admission_type,
        case
         when icud.icustay_first_service='FICU' then 'MICU'
         else icud.icustay_first_service
        end as icustay_first_service,
        case
         when icud.hospital_expire_flg='Y' or dp.dod-icud.hospital_disch_dt < 30 then 'Y'     
         else 'N'
        end as thirty_day_mort
 from mimic2v26.icustay_detail icud
 left join mimic2v26.demographic_detail dd on icud.hadm_id=dd.hadm_id
 left join mimic2v26.d_patients dp on icud.subject_id=dp.subject_id
 where icud.icustay_age_group = 'adult'    
   and icud.subject_icustay_seq = 1
   and icud.icustay_id is not null
)
--select * from static_data;

-----------------------------
--- BEGIN EXTRACTION OF LABS
-----------------------------
, small_labevents as
(select icustay_id,        
        itemid,
        charttime,
        valuenum
 from mimic2v26.labevents l
 where itemid in (50090,50149,50159,50383,50468,50083,50172,50112,50140,50079,50148,50010)
   and icustay_id in (select icustay_id from static_data) 
   and valuenum is not null
)
--select * from small_labevents;

, labs_raw as
(select distinct icustay_id,        
        itemid,
        first_value(valuenum) over (partition by icustay_id, itemid order by charttime) as first_value
 from small_labevents 
)
--select * from labs_raw;

, labs as
(select *
 from (select * from labs_raw)
      pivot
      (sum(round(first_value,1)) as admit       
       for itemid in 
       ('50090' as cr, 
        '50149' as k,
        '50159' as na,
        '50083' as cl,
        '50172' as bicarb,
        '50383' as hct,
        '50468' as wbc,
        '50112' as glucose,
        '50140' as mg,
        '50079' as ca,
        '50148' as p,
        '50010' as lactate
       )
      )
)
--select * from labs;
------------------------------
--- END OF EXTRACTION OF LABS
------------------------------

------------------------------------
--- BEGIN EXTRACTION OF VITALS
------------------------------------
, small_chartevents as
(select icustay_id,
        case
         when itemid in (211) then 'hr'
         when itemid in (52,456) then 'map'  -- invasive and noninvasive measurements are combined
         when itemid in (51,455) then 'sbp'  -- invasive and noninvasive measurements are combined
         when itemid in (678,679) then 'temp'  -- in Fahrenheit
         when itemid in (646) then 'spo2'     
         when itemid in (618) then 'rr'
        end as type,                
        charttime,
        value1num
 from mimic2v26.chartevents l
 where itemid in (211,51,52,455,456,678,679,646,618)
   and icustay_id in (select icustay_id from static_data) 
   and value1num is not null
)
--select * from small_chartevents;

, vitals_raw as
(select distinct icustay_id,        
        type,
        first_value(value1num) over (partition by icustay_id, type order by charttime) as first_value
 from small_chartevents 
)
--select * from vitals_raw;

, vitals as
(select *
 from (select * from vitals_raw)
      pivot
      (sum(round(first_value,1)) as admit
       for type in 
       ('hr' as hr,
        'map' as map,
        'sbp' as sbp,
        'temp' as temp,
        'spo2' as spo2,
        'rr' as rr
       )
      )
)
--select * from vitals;
------------------------------------
--- END OF EXTRACTION OF VITALS
------------------------------------

-- Assemble final data
, final_data as
(select s.*,
        v.hr_admit,
        v.map_admit,
        v.sbp_admit,
        v.temp_admit,
        v.spo2_admit,       
        v.rr_admit,       
        l.cr_admit, 
        l.k_admit,
        l.na_admit,
        l.cl_admit,
        l.bicarb_admit,
        l.hct_admit,
        l.wbc_admit,
        l.glucose_admit,
        l.mg_admit,
        l.ca_admit,
        l.p_admit,
        l.lactate_admit
 from static_data s
 left join vitals v on s.icustay_id=v.icustay_id 
 left join labs l on s.icustay_id=l.icustay_id 
)
select * from final_data order by 1,2,3;
