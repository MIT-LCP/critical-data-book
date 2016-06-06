drop materialized view renal_readmission_cohort_v5;

create materialized view renal_readmission_cohort_v5 as

-- Get the first ICU stay of each adult
with first_admissions as
(select icud.subject_id,
        icud.hadm_id as first_hadm_id,
        icud.icustay_id as first_icustay_id,
        icud.hospital_admit_dt as first_hadm_admit_dt,  
        icud.hospital_disch_dt as first_hadm_disch_dt,
        icud.icustay_intime as first_icustay_intime,
        icud.icustay_outtime as first_icustay_outtime,
        extract(day from icud.icustay_intime-icud.hospital_admit_dt) as days_btw_hosp_icu_admit,
        extract(day from icud.hospital_disch_dt-icud.icustay_outtime) as days_btw_hosp_icu_disch,
        icud.icustay_expire_flg as icu_mort_first_admission,
        icud.hospital_expire_flg as hosp_mort_first_admission,
        d.admission_source_descr as first_hadm_source,
        case
         when lower(d.admission_source_descr) like '%emergency%' then 'Y'
         else 'N'
        end as ED_admission,
        case
         when icud.icustay_admit_age>150 then 91.4
         else round(icud.icustay_admit_age,1)
        end as age_first_icustay,
        icud.gender,        
        d.ethnicity_descr as race,        
        round(icud.icustay_los/60/24,2) as first_icustay_los,
        icud.icustay_first_service,
        icud.sapsi_first as first_icustay_admit_saps,
        case
         when msa.hadm_id is not null then 'Y'
         else 'N'
        end as first_hadm_sepsis
 from mimic2v26.icustay_detail icud
 left join mimic2v26.demographic_detail d on icud.hadm_id=d.hadm_id
 left join mimic2devel.martin_sepsis_admissions msa on icud.hadm_id=msa.hadm_id
 where icud.subject_icustay_seq=1 
   and icud.icustay_age_group='adult'
   and icud.hadm_id is not null
   and icud.icustay_id is not null   
--   and icud.subject_id < 100
)
--select * from first_admissions;  --23,455 rows

-- Get all repeat ICU admissions following the first hospital admissions
, readmissions as
(select fa.*,
        icud.hadm_id as second_hadm_id,
        icud.icustay_id as second_icustay_id,
        icud.hospital_admit_dt as second_hadm_admit_dt,
        icud.icustay_intime as second_icustay_intime,        
        case
         when icud.icustay_id is null or icud.hospital_admit_dt-fa.first_hadm_disch_dt > 90 then 'N'
         else 'Y'
        end as readmission_90d,
        case
         when icud.icustay_id is null or icud.hospital_admit_dt-fa.first_hadm_disch_dt > 365 then 'N'
         else 'Y'
        end as readmission_1yr,
        icud.hospital_admit_dt-fa.first_hadm_disch_dt as days_to_readmission,
        case
         when hosp_mort_first_admission='Y' or dp.dod-fa.first_hadm_disch_dt <= 0 then null
         when dp.dod-fa.first_hadm_disch_dt between 1 and 90 then 'Y'
         else 'N'
        end as mortality_90d,
        case
         when hosp_mort_first_admission='Y' or dp.dod-fa.first_hadm_disch_dt <= 0 then null
         when dp.dod-fa.first_hadm_disch_dt between 1 and 365 then 'Y'
         else 'N'
        end as mortality_1yr,
        case
         when dp.dod-fa.first_hadm_disch_dt < 0 then null
         when hosp_mort_first_admission='Y' then 0
         when dp.dod is null or dp.dod-fa.first_hadm_disch_dt > 730 then 730
         else dp.dod-fa.first_hadm_disch_dt 
        end as survival_2yr_hadm_disch,
        case
         when extract(day from dp.dod-fa.first_icustay_outtime) < 0 then null         
         when dp.dod is null or extract(day from dp.dod-fa.first_icustay_outtime) > 730 then 730
         else extract(day from dp.dod-fa.first_icustay_outtime) 
        end as survival_2yr_icu_disch,
        case
         when fa.hosp_mort_first_admission='Y' then extract(day from dp.dod-fa.first_icustay_outtime)
         else null
        end as days_icu_disch_to_hosp_mort
 from first_admissions fa
 left join mimic2v26.icustay_detail icud 
        on fa.subject_id=icud.subject_id
       and icud.hospital_seq=2
       and icud.icustay_seq=1
       and icud.hadm_id is not null
       and icud.icustay_id is not null
 left join mimic2devel.d_patients dp on fa.subject_id=dp.subject_id
)
--select * from readmissions;

, raw_icu_admit_labs as
(select distinct r.subject_id,        
        case
         when l.itemid=50090 then 'serum_cr'
         when l.itemid=50159 then 'serum_sodium'
         when l.itemid=50655 then 'urine_protein'
         when l.itemid=50264 then 'urine_cr'
         when l.itemid=50277 then 'urine_sodium'
         when l.itemid=50276 then 'urine_protein_cr_ratio'
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
        end as lab_type,
        first_value(l.value) over (partition by l.hadm_id, l.itemid order by l.charttime) as lab_value,
        first_value(l.charttime) over (partition by l.hadm_id order by l.charttime) as icu_admit_lab_time
 from readmissions r
 join mimic2v26.labevents l 
   on r.first_hadm_id=l.hadm_id 
  and l.itemid in (50090,50159,50655,50264,50277,50276,50177,50149,50083,50172,50383,50468,50140,50148,50079,50010,50018,50428,50060,50112,50399,50439,50440,50115,50134,50370) 
  and l.charttime between r.first_icustay_intime - interval '12' hour and r.first_icustay_intime + interval '12' hour 
)
--select * from raw_icu_admit_labs order by 1,2;

, icu_admit_labs as
(select *
 from (select * from raw_icu_admit_labs)
      pivot
      (max(lab_value) for lab_type in
       ('serum_cr' as icu_admit_serum_cr,
        'serum_sodium' as icu_admit_serum_sodium,
        'urine_protein' as icu_admit_urine_protein,
        'urine_cr' as icu_admit_urine_cr,
        'urine_sodium' as icu_admit_urine_sodium,
        'urine_protein_cr_ratio' as icu_admit_urine_prot_cr_ratio,
        'bun' as icu_admit_bun,
        'potassium' as icu_admit_potassium,
        'chloride' as icu_admit_chloride,
        'bicarb' as icu_admit_bicarb,
        'hematocrit' as icu_admit_hematocrit,
        'wbc' as icu_admit_wbc,
        'magnesium' as icu_admit_magnesium,
        'phosphate' as icu_admit_phosphate,
        'calcium' as icu_admit_calcium,        
        'lactate' as icu_admit_lactate,
        'ph' as icu_admit_ph,
        'platelets' as icu_admit_platelets,
        'albumin' as icu_admit_albumin,
        'glucose' as icu_admit_glucose,
        'inr' as icu_admit_inr,
        'pt' as icu_admit_pt,
        'ptt' as icu_admit_ptt,
        'haptoglobin' as icu_admit_haptoglobin,
        'ldh' as icu_admit_ldh,
        'd-dimer' as icu_admit_d_dimer
       )
      )
)
--select * from icu_admit_labs order by 1;

, raw_hosp_admit_labs as
(select distinct r.subject_id,        
        case
         when l.itemid=50090 then 'serum_cr'
         when l.itemid=50159 then 'serum_sodium'
         when l.itemid=50655 then 'urine_protein'
         when l.itemid=50264 then 'urine_cr'
         when l.itemid=50277 then 'urine_sodium'
         when l.itemid=50276 then 'urine_protein_cr_ratio'
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
        end as lab_type,                
        first_value(l.value) over (partition by l.hadm_id, l.itemid order by l.charttime) as lab_value,
        first_value(l.charttime) over (partition by l.hadm_id order by l.charttime) as hosp_admit_lab_time
 from readmissions r
 join mimic2v26.labevents l 
   on r.first_hadm_id=l.hadm_id 
  and l.itemid in (50090,50159,50655,50264,50277,50276,50177,50149,50083,50172,50383,50468,50140,50148,50079,50010,50018,50428,50060,50112) 
  and extract(day from l.charttime-r.first_hadm_admit_dt) = 0
)
--select * from raw_hosp_admit_labs order by 1,2;

, hosp_admit_labs as
(select *
 from (select * from raw_hosp_admit_labs)
      pivot
      (max(lab_value) for lab_type in
       ('serum_cr' as hosp_admit_serum_cr,
        'serum_sodium' as hosp_admit_serum_sodium,
        'urine_protein' as hosp_admit_urine_protein,
        'urine_cr' as hosp_admit_urine_cr,
        'urine_sodium' as hosp_admit_urine_sodium,
        'urine_protein_cr_ratio' as hosp_admit_urine_prot_cr_ratio,
        'bun' as hosp_admit_bun,
        'potassium' as hosp_admit_potassium,
        'chloride' as hosp_admit_chloride,
        'bicarb' as hosp_admit_bicarb,
        'hematocrit' as hosp_admit_hematocrit,
        'wbc' as hosp_admit_wbc,
        'magnesium' as hosp_admit_magnesium,
        'phosphate' as hosp_admit_phosphate,
        'calcium' as hosp_admit_calcium,        
        'lactate' as hosp_admit_lactate,
        'ph' as hosp_admit_ph,
        'platelets' as hosp_admit_platelets,
        'albumin' as hosp_admit_albumin,
        'glucose' as hosp_admit_glucose
       )
      )
)
--select * from hosp_admit_labs order by 1;

, admit_labs_first_icustay as
(select i.subject_id,    
        extract(day from i.icu_admit_lab_time-r.first_hadm_admit_dt) as days_btw_icu_lab_hosp_admit,
        case
         when i.icu_admit_lab_time is null or h.hosp_admit_lab_time is null then null
         when abs(extract(minute from i.icu_admit_lab_time-h.hosp_admit_lab_time)) < 10 then 'Y'
         else 'N'
        end as same_hosp_icu_admit_labs,           
        case
         when LENGTH(TRIM(TRANSLATE(i.icu_admit_serum_cr, ' +-.0123456789', ' '))) > 0 then null         
         else to_number(i.icu_admit_serum_cr)
        end as icu_admit_serum_cr,
        case
         when LENGTH(TRIM(TRANSLATE(i.icu_admit_serum_sodium, ' +-.0123456789', ' '))) > 0 then null         
         else to_number(i.icu_admit_serum_sodium)
        end as icu_admit_serum_sodium,        
        case 
         when i.icu_admit_urine_protein in ('N','NEG','NEGATIVE','Neg') then 0
         when i.icu_admit_urine_protein in ('TR','Tr') then 1
         when i.icu_admit_urine_protein in ('15','25','30') then 30
         when i.icu_admit_urine_protein in ('75','100') then 100
         when i.icu_admit_urine_protein in ('150','300') then 300
         when i.icu_admit_urine_protein in ('>300','>600','500') then 500
         else null
        end as icu_admit_urine_protein,
        case
         when LENGTH(TRIM(TRANSLATE(i.icu_admit_urine_cr, ' +-.0123456789', ' '))) > 0 then null         
         else to_number(i.icu_admit_urine_cr)
        end as icu_admit_urine_cr,        
        case
         when i.icu_admit_urine_sodium='<10' or (lower(i.icu_admit_urine_sodium) like '%less%' and i.icu_admit_urine_sodium like '%10%') then 0
         when LENGTH(TRIM(TRANSLATE(i.icu_admit_urine_sodium, ' +-.0123456789', ' '))) > 0 then null 
         else to_number(i.icu_admit_urine_sodium)
        end as icu_admit_urine_sodium,   
        case 
         when LENGTH(TRIM(TRANSLATE(i.icu_admit_urine_prot_cr_ratio, ' +-.0123456789', ' '))) > 0 then null         
         else to_number(i.icu_admit_urine_prot_cr_ratio)
        end as icu_admit_urine_prot_cr_ratio,   
        i.icu_admit_bun,
        i.icu_admit_potassium,
        i.icu_admit_chloride,
        i.icu_admit_bicarb,
        i.icu_admit_hematocrit,
        i.icu_admit_wbc,
        i.icu_admit_magnesium,
        i.icu_admit_phosphate,
        i.icu_admit_calcium,        
        i.icu_admit_lactate,
        i.icu_admit_ph,
        i.icu_admit_platelets,
        i.icu_admit_albumin,
        i.icu_admit_glucose,
        i.icu_admit_inr,
        i.icu_admit_pt,
        i.icu_admit_ptt,
        i.icu_admit_haptoglobin,
        i.icu_admit_ldh,
        i.icu_admit_d_dimer,
        case
         when LENGTH(TRIM(TRANSLATE(h.hosp_admit_serum_cr, ' +-.0123456789', ' '))) > 0 then null         
         else to_number(h.hosp_admit_serum_cr)
        end as hosp_admit_serum_cr,
        case
         when LENGTH(TRIM(TRANSLATE(h.hosp_admit_serum_sodium, ' +-.0123456789', ' '))) > 0 then null         
         else to_number(h.hosp_admit_serum_sodium)
        end as hosp_admit_serum_sodium,        
        case 
         when h.hosp_admit_urine_protein in ('N','NEG','NEGATIVE','Neg') then 0
         when h.hosp_admit_urine_protein in ('TR','Tr') then 1
         when h.hosp_admit_urine_protein in ('15','25','30') then 30
         when h.hosp_admit_urine_protein in ('75','100') then 100
         when h.hosp_admit_urine_protein in ('150','300') then 300
         when h.hosp_admit_urine_protein in ('>300','>600','500') then 500
         else null
        end as hosp_admit_urine_protein,
        case
         when LENGTH(TRIM(TRANSLATE(h.hosp_admit_urine_cr, ' +-.0123456789', ' '))) > 0 then null         
         else to_number(h.hosp_admit_urine_cr)
        end as hosp_admit_urine_cr,        
        case
         when h.hosp_admit_urine_sodium='<10' or (lower(h.hosp_admit_urine_sodium) like '%less%' and h.hosp_admit_urine_sodium like '%10%') then 0
         when LENGTH(TRIM(TRANSLATE(h.hosp_admit_urine_sodium, ' +-.0123456789', ' '))) > 0 then null 
         else to_number(h.hosp_admit_urine_sodium)
        end as hosp_admit_urine_sodium,   
        case 
         when LENGTH(TRIM(TRANSLATE(h.hosp_admit_urine_prot_cr_ratio, ' +-.0123456789', ' '))) > 0 then null         
         else to_number(h.hosp_admit_urine_prot_cr_ratio)
        end as hosp_admit_urine_prot_cr_ratio,   
        h.hosp_admit_bun,
        h.hosp_admit_potassium,
        h.hosp_admit_chloride,
        h.hosp_admit_bicarb,
        h.hosp_admit_hematocrit,
        h.hosp_admit_wbc,
        h.hosp_admit_magnesium,
        h.hosp_admit_phosphate,
        h.hosp_admit_calcium,        
        h.hosp_admit_lactate,
        h.hosp_admit_ph,
        h.hosp_admit_platelets,
        h.hosp_admit_albumin,
        h.hosp_admit_glucose
 from readmissions r
 left join icu_admit_labs i on r.subject_id=i.subject_id
 left join hosp_admit_labs h on i.subject_id=h.subject_id 
)
--select * from admit_labs_first_icustay;

-- Get peak creatinine values from first ICU stays
, peak_creat_first_icustay as
(select distinct r.subject_id,        
        count(*) as num_cr_first_icustay,
        max(l.valuenum) as cr_peak_first_icustay        
 from readmissions r
 join mimic2v26.labevents l on r.first_icustay_id=l.icustay_id and l.itemid=50090
 group by r.subject_id
)
--select * from peak_creat_first_icustay;

-- Get discharge creatinine values from first ICU stays
, disch_creat_first_icustay as
(select distinct r.subject_id,        
        first_value(l.valuenum) over (partition by l.icustay_id order by l.charttime desc) as cr_disch_first_icustay        
 from readmissions r
 join mimic2v26.labevents l on r.first_icustay_id=l.icustay_id and l.itemid=50090 and l.charttime between r.first_icustay_outtime - interval '48' hour and r.first_icustay_outtime
)
--select * from disch_creat_first_icustay;

-- Get number of days with at least one creatinine measurement during the first ICU stay
, days_with_cr_first_icustay as
(select distinct r.subject_id,
        icud.seq        
 from readmissions r
 join mimic2v26.icustay_days icud on r.first_icustay_id=icud.icustay_id
 join mimic2v26.labevents l on r.first_icustay_id=l.icustay_id and l.itemid=50090 and l.charttime between icud.begintime and icud.endtime 
)
--select * from days_with_cr_first_icustay;

, num_daily_cr_first_icustay as
(select subject_id,
        count(*) as num_daily_cr_first_icustay        
 from days_with_cr_first_icustay 
 group by subject_id
)
--select * from num_daily_cr_first_icustay;

-- Get admit creatinine values from second ICU stays
, admit_labs_second_icustay as
(select distinct r.subject_id,   
        first_value(l.valuenum) over (partition by l.icustay_id order by l.charttime) as admit_serum_cr_second_icustay
 from readmissions r
 join mimic2v26.labevents l on r.second_icustay_id=l.icustay_id and l.itemid=50090 and l.charttime between r.second_icustay_intime - interval '12' hour and r.second_icustay_intime + interval '12' hour  
)
--select * from admit_labs_second_icustay;

-- Combine all labs together
, all_labs as
(select alf.*,
        pcf.cr_peak_first_icustay,
        dcf.cr_disch_first_icustay,
        pcf.num_cr_first_icustay,
        ncf.num_daily_cr_first_icustay,
        als.admit_serum_cr_second_icustay
 from admit_labs_first_icustay alf 
 left join peak_creat_first_icustay pcf on alf.subject_id=pcf.subject_id 
 left join disch_creat_first_icustay dcf on alf.subject_id=dcf.subject_id 
 left join num_daily_cr_first_icustay ncf on alf.subject_id=ncf.subject_id 
 left join admit_labs_second_icustay als on alf.subject_id=als.subject_id 
)
--select * from all_labs;
       
-- Narrow down Chartevents table
, small_chartevents as
(select subject_id,        
        icustay_id,
        itemid,
        charttime,
        value1num,
        value2num
 from mimic2v26.chartevents
 where itemid in (580,581,763,762,920,211,51,52,455,456,678,679,646,834,20001)
   and subject_id in (select subject_id from readmissions)
)
--select * from small_chartevents;

-- Get admit weight from first ICU stays
, admit_weight_first_icustay as
(select distinct r.subject_id,        
        first_value(l.value1num) over (partition by l.icustay_id order by l.charttime) as weight_admit_first_icustay        
 from readmissions r
 join small_chartevents l on r.first_icustay_id=l.icustay_id and l.itemid=762 and l.charttime between r.first_icustay_intime and r.first_icustay_intime + interval '24' hour  
)
--select * from admit_weight_first_icustay;

-- Get admit height from first ICU stays
, admit_height_first_icustay as
(select distinct r.subject_id,        
        first_value(l.value1num) over (partition by l.icustay_id order by l.charttime) as height_admit_first_icustay        
 from readmissions r
 join small_chartevents l on r.first_icustay_id=l.icustay_id and l.itemid=920 and l.charttime between r.first_icustay_intime and r.first_icustay_intime + interval '24' hour  
)
--select * from admit_height_first_icustay;

-- Get discharge weight from first ICU stays
, disch_weight_first_icustay as
(select distinct r.subject_id,        
        first_value(l.value1num) over (partition by l.icustay_id order by l.charttime desc) as weight_disch_first_icustay        
 from readmissions r
 join small_chartevents l on r.first_icustay_id=l.icustay_id and l.itemid in (580,581,763) and l.charttime between r.first_icustay_outtime - interval '48' hour and r.first_icustay_outtime
)
--select * from disch_weight_first_icustay;

-- Get admit weight from second ICU stays
, admit_weight_second_icustay as
(select distinct r.subject_id,        
        first_value(l.value1num) over (partition by l.icustay_id order by l.charttime) as weight_admit_second_icustay        
 from readmissions r
 join small_chartevents l on r.second_icustay_id=l.icustay_id and l.itemid=762 and l.charttime between r.second_icustay_intime and r.second_icustay_intime + interval '24' hour
)
--select * from admit_weight_second_icustay;

-- Combine all weight and height together
, all_weight_height as
(select r.subject_id,
        awf.weight_admit_first_icustay,
        ahf.height_admit_first_icustay,
        case
         when ahf.height_admit_first_icustay > 0 then round(awf.weight_admit_first_icustay/power(ahf.height_admit_first_icustay*0.0254,2),2) 
         else null 
        end as bmi_admit_first_icustay,
        dwf.weight_disch_first_icustay,
        aws.weight_admit_second_icustay        
 from readmissions r 
 left join admit_weight_first_icustay awf on r.subject_id=awf.subject_id
 left join admit_height_first_icustay ahf on r.subject_id=ahf.subject_id 
 left join disch_weight_first_icustay dwf on r.subject_id=dwf.subject_id 
 left join admit_weight_second_icustay aws on r.subject_id=aws.subject_id  
)
--select * from all_weight_height;

-- Get admit heart rate from first ICU stays
, admit_hr_first_icustay as
(select distinct r.subject_id,        
        first_value(l.value1num) over (partition by l.icustay_id order by l.charttime) as hr_admit_first_icustay        
 from readmissions r
 join small_chartevents l on r.first_icustay_id=l.icustay_id and l.itemid in (211) and l.charttime between r.first_icustay_intime and r.first_icustay_intime + interval '24' hour
)
--select * from admit_hr_first_icustay;

-- Get admit heart rate from second ICU stays
, admit_hr_second_icustay as
(select distinct r.subject_id,        
        first_value(l.value1num) over (partition by l.icustay_id order by l.charttime) as hr_admit_second_icustay        
 from readmissions r
 join small_chartevents l on r.second_icustay_id=l.icustay_id and l.itemid in (211) and l.charttime between r.second_icustay_intime and r.second_icustay_intime + interval '24' hour
)
--select * from admit_hr_second_icustay;

-- Get admit mean arterial pressure from first ICU stays
, admit_map_first_icustay as
(select distinct r.subject_id,        
        first_value(l.value1num) over (partition by l.icustay_id order by l.charttime) as map_admit_first_icustay,
        first_value(l.itemid) over (partition by l.icustay_id order by l.charttime) as map_type_first_icustay        
 from readmissions r
 join small_chartevents l on r.first_icustay_id=l.icustay_id and l.itemid in (52,456) and l.charttime between r.first_icustay_intime and r.first_icustay_intime + interval '24' hour
)
--select * from admit_map_first_icustay;

-- Get admit mean arterial pressure from second ICU stays
, admit_map_second_icustay as
(select distinct r.subject_id,        
        first_value(l.value1num) over (partition by l.icustay_id order by l.charttime) as map_admit_second_icustay,
        first_value(l.itemid) over (partition by l.icustay_id order by l.charttime) as map_type_second_icustay        
 from readmissions r
 join small_chartevents l on r.second_icustay_id=l.icustay_id and l.itemid in (52,456) and l.charttime between r.second_icustay_intime and r.second_icustay_intime + interval '24' hour
)
--select * from admit_map_second_icustay;

-- Get admit systolic and diastolic arterial pressure from first ICU stays
, admit_bp_first_icustay as
(select distinct r.subject_id,        
        first_value(l.value1num) over (partition by l.icustay_id order by l.charttime) as sbp_admit_first_icustay,
        first_value(l.value2num) over (partition by l.icustay_id order by l.charttime) as dbp_admit_first_icustay,
        first_value(l.itemid) over (partition by l.icustay_id order by l.charttime) as sbp_dbp_type_first_icustay                
 from readmissions r
 join small_chartevents l on r.first_icustay_id=l.icustay_id and l.itemid in (51,455) and l.charttime between r.first_icustay_intime and r.first_icustay_intime + interval '24' hour
)
--select * from admit_bp_first_icustay;

-- Get admit systolic and diastolic arterial pressure from second ICU stays
, admit_bp_second_icustay as
(select distinct r.subject_id,        
        first_value(l.value1num) over (partition by l.icustay_id order by l.charttime) as sbp_admit_second_icustay,
        first_value(l.value2num) over (partition by l.icustay_id order by l.charttime) as dbp_admit_second_icustay,
        first_value(l.itemid) over (partition by l.icustay_id order by l.charttime) as sbp_dbp_type_second_icustay        
 from readmissions r
 join small_chartevents l on r.second_icustay_id=l.icustay_id and l.itemid in (51,455) and l.charttime between r.second_icustay_intime and r.second_icustay_intime + interval '24' hour
)
--select * from admit_bp_second_icustay;

-- Get admit temperature from first ICU stays
, admit_temp_first_icustay as
(select distinct r.subject_id,        
        first_value(l.value1num) over (partition by l.icustay_id order by l.charttime) as temp_admit_first_icustay        
 from readmissions r
 join small_chartevents l on r.first_icustay_id=l.icustay_id and l.itemid in (678, 679) and l.charttime between r.first_icustay_intime and r.first_icustay_intime + interval '24' hour
)
--select * from admit_temp_first_icustay;

-- Get admit temperature from second ICU stays
, admit_temp_second_icustay as
(select distinct r.subject_id,        
        first_value(l.value1num) over (partition by l.icustay_id order by l.charttime) as temp_admit_second_icustay        
 from readmissions r
 join small_chartevents l on r.second_icustay_id=l.icustay_id and l.itemid in (678, 679) and l.charttime between r.second_icustay_intime and r.second_icustay_intime + interval '24' hour
)
--select * from admit_temp_second_icustay;

-- Get admit o2sat from first ICU stays
, admit_o2sat_first_icustay as
(select distinct r.subject_id,        
        first_value(l.value1num) over (partition by l.icustay_id order by l.charttime) as o2sat_admit_first_icustay        
 from readmissions r
 join small_chartevents l on r.first_icustay_id=l.icustay_id and l.itemid in (646, 834) and l.charttime between r.first_icustay_intime and r.first_icustay_intime + interval '24' hour
)
--select * from admit_o2sat_first_icustay;

-- Get admit o2sat from second ICU stays
, admit_o2sat_second_icustay as
(select distinct r.subject_id,        
        first_value(l.value1num) over (partition by l.icustay_id order by l.charttime) as o2sat_admit_second_icustay        
 from readmissions r
 join small_chartevents l on r.second_icustay_id=l.icustay_id and l.itemid in (646, 834) and l.charttime between r.second_icustay_intime and r.second_icustay_intime + interval '24' hour
)
--select * from admit_o2sat_second_icustay;

-- Total urine output during the first ICU stay
, uo_first_icustay as
(select r.subject_id,
        sum(ie.volume) as urine_first_icustay
 from readmissions r
 join mimic2v26.ioevents ie on r.first_icustay_id=ie.icustay_id
 where ie.itemid in ( 651, 715, 55, 56, 57, 61, 65, 69, 85, 94, 96, 288, 405, 428, 473, 2042, 2068, 2111, 2119, 2130, 1922, 2810, 2859, 3053, 3462, 3519, 3175, 2366, 2463, 2507, 2510, 2592, 2676, 3966, 3987, 4132, 4253, 5927 )
 group by r.subject_id
)
--select * from uo_first_icustay;

, uo_first_icustay_24h as
(select r.subject_id,
        sum(ie.volume) as urine_first_icustay_24h
 from readmissions r
 join mimic2v26.ioevents ie on r.first_icustay_id=ie.icustay_id and ie.charttime between r.first_icustay_intime and r.first_icustay_intime + interval '24' hour
 where ie.itemid in ( 651, 715, 55, 56, 57, 61, 65, 69, 85, 94, 96, 288, 405, 428, 473, 2042, 2068, 2111, 2119, 2130, 1922, 2810, 2859, 3053, 3462, 3519, 3175, 2366, 2463, 2507, 2510, 2592, 2676, 3966, 3987, 4132, 4253, 5927 )
 group by r.subject_id
)
--select * from uo_first_icustay_24h;

-- Total 1/2 NS during the first ICU stay
, half_ns_first_icustay as
(select r.subject_id,
        sum(ie.volume) as half_ns_first_icustay
 from readmissions r
 join mimic2v26.ioevents ie on r.first_icustay_id=ie.icustay_id
 where ie.itemid not in (select itemid from rishi_kothari.d_fluiditems) 
   and ie.itemid in (select itemid from mimic2v26.d_ioitems where (lower(label) like '%normal saline%' or lower(label) like '%ns%') and (lower(label) not like '%d%ns%') and (label like '%1/2%' or label like '%.45%'))       
 group by r.subject_id
)
--select * from half_ns_first_icustay;

-- Total 1/4 NS during the first ICU stay
, quarter_ns_first_icustay as
(select r.subject_id,
        sum(ie.volume) as quarter_ns_first_icustay
 from readmissions r
 join mimic2v26.ioevents ie on r.first_icustay_id=ie.icustay_id
 where ie.itemid not in (select itemid from rishi_kothari.d_fluiditems) 
   and ie.itemid in (select itemid from mimic2v26.d_ioitems where (lower(label) like '%normal saline%' or lower(label) like '%ns%') and (lower(label) not like '%d%ns%') and (label like '%1/4%' or label like '%.22%'))       
 group by r.subject_id
)
--select * from quarter_ns_first_icustay;

-- Total D5W during the first ICU stay
, d5w_first_icustay as
(select r.subject_id,
        sum(ie.volume) as d5w_first_icustay
 from readmissions r
 join mimic2v26.ioevents ie on r.first_icustay_id=ie.icustay_id
 where ie.itemid not in (select itemid from rishi_kothari.d_fluiditems) 
   and ie.itemid in (select itemid from mimic2v26.d_ioitems where lower(label) like '%d5w%' and lower(label) not like '%d5%ns%' and lower(label) not like '%d5%lr%' and lower(label) not like '%d5%rl%')       
 group by r.subject_id
)
--select * from d5w_first_icustay;

-- Total crystalloid volume during the first ICU stay
, cryst_first_icustay as
(select r.subject_id,
        sum(ie.volume) as cryst_first_icustay
 from readmissions r
 join mimic2v26.ioevents ie on r.first_icustay_id=ie.icustay_id
 where ie.itemid in (select itemid from rishi_kothari.d_fluiditems)
 group by r.subject_id
)
--select * from cryst_first_icustay;

-- Total colloid volume during the first ICU stay
, colloid_first_icustay as
(select r.subject_id,
        sum(ie.volume) as colloid_first_icustay
 from readmissions r
 join mimic2v26.ioevents ie on r.first_icustay_id=ie.icustay_id
 where ie.itemid in (select itemid from rishi_kothari.d_colloids)
 group by r.subject_id
)
--select * from colloid_first_icustay;

-- Total PO intake during the first ICU stay
, pointake_first_icustay as
(select r.subject_id,
        sum(t.cumvolume) as po_intake_first_icustay
 from readmissions r
 join mimic2v26.totalbalevents t on r.first_icustay_id=t.icustay_id
 where itemid=20
 group by r.subject_id
)
--select * from pointake_first_icustay;

-- Total stool loss during the first ICU stay
, stool_first_icustay as
(select r.subject_id,
        sum(t.cumvolume) as stool_first_icustay
 from readmissions r
 join mimic2v26.totalbalevents t on r.first_icustay_id=t.icustay_id
 where itemid=22
 group by r.subject_id
)
--select * from pointake_first_icustay;

-- Total input during the first ICU stay
, totalin_first_icustay as
(select r.subject_id,
        sum(t.cumvolume) as total_in_first_icustay
 from readmissions r
 join mimic2v26.totalbalevents t on r.first_icustay_id=t.icustay_id
 where itemid=1
 group by r.subject_id
)
--select * from totalin_first_icustay;

-- Total output during the first ICU stay
, totalout_first_icustay as
(select r.subject_id,
        sum(t.cumvolume) as total_out_first_icustay
 from readmissions r
 join mimic2v26.totalbalevents t on r.first_icustay_id=t.icustay_id
 where itemid=2
 group by r.subject_id
)
--select * from totalout_first_icustay;

-- Total fluid balance for the first ICU stay
, fluidbal_first_icustay as
(select distinct r.subject_id,
        first_value(t.cumvolume) over (partition by t.icustay_id order by t.charttime desc) as fluid_balance_first_icustay
 from readmissions r
 join mimic2v26.totalbalevents t on r.first_icustay_id=t.icustay_id
 where itemid=28
)
--select * from fluidbal_first_icustay;

-- ICD9 from first hospital admission
, icd9_first_admission as
(select r.subject_id,        
        i.code,
        i.description
 from readmissions r
 join mimic2v26.icd9 i on r.first_hadm_id=i.hadm_id
 where i.sequence = 1
)
--select * from icd9_first_admission;

-- ICD9 from second hospital admission
, icd9_second_admission as
(select r.subject_id,        
        i.code,
        i.description
 from readmissions r
 join mimic2v26.icd9 i on r.second_hadm_id=i.hadm_id
 where i.sequence = 1
)
--select * from icd9_second_admission;

------------------------------------
--- Start of dialysis-related data
------------------------------------

, first_dialysis as
(select distinct r.subject_id,
        r.first_hadm_id,
        r.first_icustay_id,
        first_value(p.proc_dt) over (partition by p.hadm_id order by p.proc_dt) as first_dialysis_dt        
 from readmissions r
 join mimic2v26.procedureevents p on r.first_hadm_id=p.hadm_id
 where p.itemid in (100977,100622)
)
--select * from first_dialysis;

-- Hemodialysis during the first hospital admission
, hd as
(select distinct r.subject_id        
 from readmissions r
 join mimic2v26.procedureevents p on r.first_hadm_id=p.hadm_id
 where p.itemid=100622
)
--select * from hd;

--  Peritoneal dialysis during the first hospital admission
, pd as
(select distinct r.subject_id        
 from readmissions r
 join mimic2v26.procedureevents p on r.first_hadm_id=p.hadm_id
 where p.itemid=100977
)
--select * from pd;

, labs_proximal_to_dialysis as
(select fd.subject_id,
        extract(day from fd.first_dialysis_dt-r.first_icustay_intime) as icu_day_first_dialysis,
        fd.first_dialysis_dt-r.first_hadm_admit_dt as hosp_day_first_dialysis,
        fd.first_dialysis_dt,        
        l.itemid,
        l.charttime,
        first_value(l.valuenum) over (partition by fd.subject_id,l.itemid order by fd.first_dialysis_dt-l.charttime) as proximal_lab
 from first_dialysis fd
 join readmissions r on fd.subject_id=r.subject_id
 join mimic2v26.labevents l on r.first_hadm_id=l.hadm_id and l.itemid in (50090,50177) and l.charttime < fd.first_dialysis_dt
)
--select * from labs_proximal_to_dialysis;

, labs_prior_to_dialysis as
(select subject_id,
        icu_day_first_dialysis,
        hosp_day_first_dialysis,
        first_dialysis_dt,
        cr_prior_to_dialysis,
        bun_prior_to_dialysis
 from (select distinct subject_id, icu_day_first_dialysis, hosp_day_first_dialysis, first_dialysis_dt, itemid, proximal_lab from labs_proximal_to_dialysis)
      pivot
      (avg(proximal_lab) for itemid in
       ('50090' as cr_prior_to_dialysis,
        '50177' as bun_prior_to_dialysis        
       )
      )
)
--select * from labs_prior_to_dialysis;

, cr_and_dialysis as
(select subject_id,
        extract(day from min(first_dialysis_dt-charttime)) as days_btw_cr_and_dialysis
 from labs_proximal_to_dialysis
 where itemid=50090
 group by subject_id
)
--select * from cr_and_dialysis;

, fluidbal_dialysis as
(select distinct f.subject_id,
        first_value(t.cumvolume) over (partition by t.icustay_id order by t.charttime desc) as fluidbal_prior_to_dialysis
 from first_dialysis f
 join mimic2v26.totalbalevents t on f.first_icustay_id=t.icustay_id
 where t.itemid=28
   and t.charttime < f.first_dialysis_dt
)
--select * from fluidbal_dialysis;

, uo_dialysis as
(select f.subject_id,
        sum(ie.volume) as urine_prior_to_dialysis
 from first_dialysis f
 join mimic2v26.ioevents ie on f.first_icustay_id=ie.icustay_id and ie.charttime < f.first_dialysis_dt
 where ie.itemid in ( 651, 715, 55, 56, 57, 61, 65, 69, 85, 94, 96, 288, 405, 428, 473, 2042, 2068, 2111, 2119, 2130, 1922, 2810, 2859, 3053, 3462, 3519, 3175, 2366, 2463, 2507, 2510, 2592, 2676, 3966, 3987, 4132, 4253, 5927 )
   and ie.volume > 0
 group by f.subject_id
)
--select * from uo_dialysis;

, ivf_dialysis as
(select f.subject_id,
        sum(ie.volume) as ivf_prior_to_dialysis
 from first_dialysis f
 join mimic2v26.ioevents ie on f.first_icustay_id=ie.icustay_id and ie.charttime < f.first_dialysis_dt
 where (ie.itemid in (select itemid from rishi_kothari.d_fluiditems) or ie.itemid in (select itemid from rishi_kothari.d_colloids))
   and ie.volume > 0
 group by f.subject_id
)
--select * from ivf_dialysis;

, saps_dialysis as
(select distinct f.subject_id,
        first_value(ce.value1num) over (partition by f.subject_id order by ce.charttime desc) as saps_day_of_dialysis              
 from first_dialysis f
 join small_chartevents ce on f.first_icustay_id=ce.icustay_id and ce.itemid=20001 and ce.charttime>=f.first_dialysis_dt and extract(day from ce.charttime-f.first_dialysis_dt)=0 
)
--select * from saps_dialysis;

, all_dialysis_data as
(select f.*,
        case
         when hd.subject_id is null then 'N'
         else 'Y'
        end as hd_first_hadm,
        case
         when pd.subject_id is null then 'N'
         else 'Y'
        end as pd_first_hadm, 
        l.icu_day_first_dialysis,
        l.hosp_day_first_dialysis,        
        l.cr_prior_to_dialysis,
        cd.days_btw_cr_and_dialysis,
        l.bun_prior_to_dialysis,        
        fd.fluidbal_prior_to_dialysis,
        ud.urine_prior_to_dialysis,
        ivfd.ivf_prior_to_dialysis,
        s.saps_day_of_dialysis
 from first_dialysis f
 left join hd on f.subject_id=hd.subject_id
 left join pd on f.subject_id=pd.subject_id
 left join labs_prior_to_dialysis l on f.subject_id=l.subject_id
 left join cr_and_dialysis cd on f.subject_id=cd.subject_id
 left join fluidbal_dialysis fd on f.subject_id=fd.subject_id
 left join uo_dialysis ud on f.subject_id=ud.subject_id
 left join ivf_dialysis ivfd on f.subject_id=ivfd.subject_id
 left join saps_dialysis s on f.subject_id=s.subject_id
 )
 --select * from all_dialysis_data;

---------------------------------
--- End of dialysis-related data
---------------------------------

-- daily SAPS scores
, daily_saps as
(select r.subject_id,
        sum(ce.value1num) as total_saps_first_icustay,
        count(*) as num_saps_scores_first_icustay,
        max(ce.value1num) as peak_saps_first_icustay
 from readmissions r
 join small_chartevents ce on r.first_icustay_id=ce.icustay_id and ce.itemid=20001
 group by r.subject_id
)
--select * from daily_saps;

-- mechanical ventilation
, mech_vent as
(select distinct icustay_id
 from mimic2devel.ventilation
)
--select * from mech_vent

-- Get home diuretics
, count_home_diuretics as
(select r.subject_id,        
        case
         when hm.hadm_id is null then null
         when pm.name is not null then 1
         else 0
        end diuretic_flg        
 from readmissions r
 left join lilehman.pt_with_home_meds hm on r.first_hadm_id=hm.hadm_id
 left join lilehman.ppi_admission_drugs2 p on r.first_hadm_id=p.hadm_id
 left join djscott.ppi_med_groups pm on instr(pm.name,p.medication)>0 and pm.med_category='DIURETIC'
)
--select * from count_home_diuretics;

-- Tally the number of home diuretics
, home_diuretics as
(select subject_id,        
        sum(diuretic_flg) as num_home_diuretics
 from count_home_diuretics
 group by subject_id
)
--select * from home_diuretics;

-- Vasopressors during the first 24 hours in the ICU
, icu_admit_pressors as
(SELECT DISTINCT r.subject_id    
FROM readmissions r
JOIN mimic2v26.medevents m 
  on r.first_icustay_id=m.icustay_id
WHERE m.itemid in (42, 43, 44, 46, 47, 51, 119, 120, 125, 127, 128, 306, 307, 309)
  and m.dose > 0
  and m.charttime between r.first_icustay_intime and r.first_icustay_intime + interval '24' hour
)
--select * from icu_admit_pressors;

-- Assemble final data
, final_data as
(select r.subject_id,
        r.first_hadm_id,
        r.first_icustay_id,                      
        r.days_btw_hosp_icu_admit,
        r.days_btw_hosp_icu_disch,
        r.icu_mort_first_admission,
        r.hosp_mort_first_admission,
        r.first_hadm_source,
        r.ED_admission,
        r.age_first_icustay,
        r.gender,        
        r.race,        
        r.first_icustay_los,
        r.icustay_first_service,
        r.first_icustay_admit_saps, 
        r.first_hadm_sepsis,
        r.second_hadm_id,
        r.second_icustay_id,        
        r.readmission_90d,
        r.readmission_1yr,
        r.days_to_readmission,
        r.mortality_90d,
        r.mortality_1yr,
        r.survival_2yr_hadm_disch,
        r.survival_2yr_icu_disch,
        r.days_icu_disch_to_hosp_mort,
        al.days_btw_icu_lab_hosp_admit,
        al.same_hosp_icu_admit_labs,           
        al.icu_admit_serum_cr,
        al.icu_admit_serum_sodium,        
        al.icu_admit_urine_protein,
        al.icu_admit_urine_cr,        
        al.icu_admit_urine_sodium,   
        al.icu_admit_urine_prot_cr_ratio,   
        al.icu_admit_bun,
        al.icu_admit_potassium,
        al.icu_admit_chloride,
        al.icu_admit_bicarb,
        al.icu_admit_hematocrit,
        al.icu_admit_wbc,
        al.icu_admit_magnesium,
        al.icu_admit_phosphate,
        al.icu_admit_calcium,        
        al.icu_admit_lactate,
        al.icu_admit_ph,
        al.icu_admit_platelets,
        al.icu_admit_albumin,
        al.icu_admit_glucose,
        al.icu_admit_inr,
        al.icu_admit_pt,
        al.icu_admit_ptt,
        al.icu_admit_haptoglobin,
        al.icu_admit_ldh,
        al.icu_admit_d_dimer,
        al.hosp_admit_serum_cr,
        al.hosp_admit_serum_sodium,        
        al.hosp_admit_urine_protein,
        al.hosp_admit_urine_cr,        
        al.hosp_admit_urine_sodium,   
        al.hosp_admit_urine_prot_cr_ratio,   
        al.hosp_admit_bun,
        al.hosp_admit_potassium,
        al.hosp_admit_chloride,
        al.hosp_admit_bicarb,
        al.hosp_admit_hematocrit,
        al.hosp_admit_wbc,
        al.hosp_admit_magnesium,
        al.hosp_admit_phosphate,
        al.hosp_admit_calcium,        
        al.hosp_admit_lactate,
        al.hosp_admit_ph,           
        al.hosp_admit_platelets,  
        al.hosp_admit_albumin,  
        al.hosp_admit_glucose,  
        al.cr_peak_first_icustay,
        al.cr_disch_first_icustay,
        al.num_cr_first_icustay,
        al.num_daily_cr_first_icustay,
        al.admit_serum_cr_second_icustay,
        CASE
         WHEN r.gender='F' AND (r.race LIKE '%AFRICAN%' OR r.race LIKE '%BLACK%') THEN ROUND(186 *POWER(al.cr_disch_first_icustay,-1.154)*POWER(r.age_first_icustay,-0.203) * 1.212 * 0.742 ,2)
         WHEN r.gender='M' AND (r.race LIKE '%AFRICAN%' OR r.race LIKE '%BLACK%') THEN ROUND(186 *POWER(al.cr_disch_first_icustay,-1.154)*POWER(r.age_first_icustay,-0.203) * 1.212 ,2)
         WHEN r.gender='F' AND (r.race NOT LIKE '%AFRICAN%' AND r.race NOT LIKE '%BLACK%') THEN ROUND(186 *POWER(al.cr_disch_first_icustay,-1.154)*POWER(r.age_first_icustay,-0.203) * 0.742 ,2)
         WHEN r.gender='M' AND (r.race NOT LIKE '%AFRICAN%' AND r.race NOT LIKE '%BLACK%') THEN ROUND(186 *POWER(al.cr_disch_first_icustay,-1.154)*POWER(r.age_first_icustay,-0.203) ,2)
        END as mdrd_disch_first_icustay,
        awh.weight_admit_first_icustay,
        awh.height_admit_first_icustay,
        awh.bmi_admit_first_icustay,
        awh.weight_disch_first_icustay,
        awh.weight_admit_second_icustay,         
        ahf.hr_admit_first_icustay,
        ahs.hr_admit_second_icustay,
        round(amf.map_admit_first_icustay,2) as map_admit_first_icustay,
        case
         when amf.map_type_first_icustay=52 then 'invasive'
         when amf.map_type_first_icustay=456 then 'non-invasive'
         else null
        end as map_type_first_icustay,
        round(ams.map_admit_second_icustay,2) as map_admit_second_icustay,
        case
         when ams.map_type_second_icustay=52 then 'invasive'
         when ams.map_type_second_icustay=456 then 'non-invasive'
         else null
        end as map_type_second_icustay,
        abf.sbp_admit_first_icustay,
        abs.sbp_admit_second_icustay,
        abf.dbp_admit_first_icustay,        
        abs.dbp_admit_second_icustay,
        case
         when abf.sbp_dbp_type_first_icustay=51 then 'invasive'
         when abf.sbp_dbp_type_first_icustay=455 then 'non-invasive'
         else null
        end as sbp_dbp_type_first_icustay,
        case
         when abs.sbp_dbp_type_second_icustay=51 then 'invasive'
         when abs.sbp_dbp_type_second_icustay=455 then 'non-invasive'
         else null
        end as sbp_dbp_type_second_icustay,
        round(atf.temp_admit_first_icustay,2) as temp_admit_first_icustay,
        round(ats.temp_admit_second_icustay,2) as temp_admit_second_icustay,
        aof.o2sat_admit_first_icustay,
        aos.o2sat_admit_second_icustay,
        ufi.urine_first_icustay,
        ufi24.urine_first_icustay_24h,        
        case
         when hnf.half_ns_first_icustay is null then 0
         else hnf.half_ns_first_icustay
        end as half_ns_first_icustay,
        case
         when qnf.quarter_ns_first_icustay is null then 0
         else qnf.quarter_ns_first_icustay
        end as quarter_ns_first_icustay,
        case
         when dwf.d5w_first_icustay is null then 0
         else dwf.d5w_first_icustay
        end as d5w_first_icustay,        
        case
         when crf.cryst_first_icustay is null then 0
         else crf.cryst_first_icustay
        end as iso_cryst_first_icustay,
        case
         when cof.colloid_first_icustay is null then 0
         else cof.colloid_first_icustay
        end as colloid_first_icustay,
        case
         when crf.cryst_first_icustay is null and cof.colloid_first_icustay is null then 0
         when crf.cryst_first_icustay is null and cof.colloid_first_icustay is not null then cof.colloid_first_icustay
         when crf.cryst_first_icustay is not null and cof.colloid_first_icustay is null then crf.cryst_first_icustay
         else crf.cryst_first_icustay+cof.colloid_first_icustay 
        end as ivf_first_icustay,
        case
         when pif.po_intake_first_icustay is null then 0
         else pif.po_intake_first_icustay
        end as po_intake_first_icustay,
        case
         when sf.stool_first_icustay is null then 0
         else sf.stool_first_icustay
        end as stool_first_icustay,
        round(tif.total_in_first_icustay,1) as total_in_first_icustay,
        round(tof.total_out_first_icustay,1) as total_out_first_icustay,
        round(ff.fluid_balance_first_icustay,1) as fluid_balance_first_icustay,
        ad.first_dialysis_dt,
        ad.hd_first_hadm,
        ad.pd_first_hadm, 
        ad.icu_day_first_dialysis,
        ad.hosp_day_first_dialysis,        
        ad.cr_prior_to_dialysis,
        ad.days_btw_cr_and_dialysis,
        ad.bun_prior_to_dialysis,        
        ad.fluidbal_prior_to_dialysis,
        ad.urine_prior_to_dialysis,
        ad.ivf_prior_to_dialysis,
        ad.saps_day_of_dialysis,
        d.esrd,
        d.preadmit_ckd,
        d.preadmit_base_cr,
        case
         when iap.subject_id is null then 'N'
         else 'Y'
        end as first_icu_day_vasopressor,
        case
         when vc.icustay_id is null then 'N'
         else 'Y'
        end as vasopressor_first_icustay,
        case
         when mv.icustay_id is null then 'N'
         else 'Y'
        end as mech_vent_first_icustay,
        ds.total_saps_first_icustay,
        ds.num_saps_scores_first_icustay,
        ds.peak_saps_first_icustay,        
        ifa.code as icd9_code_first_icustay,
        ifa.description as icd9_descr_first_icustay,
        isa.code as icd9_code_second_icustay,
        isa.description as icd9_descr_second_icustay,
        case
         when hdr.num_home_diuretics is null then 'N'
         else 'Y'
        end as preadmit_med_section,
        case
         when hdr.num_home_diuretics is null then null
         when hdr.num_home_diuretics>0 then 'Y'
         else 'N'
        end as preadmit_diuretics,       
        er.CONGESTIVE_HEART_FAILURE,
        er.CARDIAC_ARRHYTHMIAS, 
        er.VALVULAR_DISEASE, 
        er.PULMONARY_CIRCULATION, 
        er.PERIPHERAL_VASCULAR, 
        er.HYPERTENSION, 
        er.PARALYSIS, 
        er.OTHER_NEUROLOGICAL, 
        er.CHRONIC_PULMONARY, 
        er.DIABETES_UNCOMPLICATED, 
        er.DIABETES_COMPLICATED, 
        er.HYPOTHYROIDISM, 
        er.RENAL_FAILURE, 
        er.LIVER_DISEASE, 
        er.PEPTIC_ULCER, 
        er.AIDS, 
        er.LYMPHOMA, 
        er.METASTATIC_CANCER, 
        er.SOLID_TUMOR, 
        er.RHEUMATOID_ARTHRITIS, 
        er.COAGULOPATHY, 
        er.OBESITY, 
        er.WEIGHT_LOSS, 
        er.FLUID_ELECTROLYTE, 
        er.BLOOD_LOSS_ANEMIA, 
        er.DEFICIENCY_ANEMIAS, 
        er.ALCOHOL_ABUSE, 
        er.DRUG_ABUSE, 
        er.PSYCHOSES,
        er.DEPRESSION
 from readmissions r
 left join all_labs al on r.subject_id=al.subject_id 
 left join all_weight_height awh on r.subject_id=awh.subject_id 
 left join admit_hr_first_icustay ahf on r.subject_id=ahf.subject_id
 left join admit_hr_second_icustay ahs on r.subject_id=ahs.subject_id
 left join admit_map_first_icustay amf on r.subject_id=amf.subject_id
 left join admit_map_second_icustay ams on r.subject_id=ams.subject_id
 left join admit_bp_first_icustay abf on r.subject_id=abf.subject_id
 left join admit_bp_second_icustay abs on r.subject_id=abs.subject_id
 left join admit_temp_first_icustay atf on r.subject_id=atf.subject_id
 left join admit_temp_second_icustay ats on r.subject_id=ats.subject_id
 left join admit_o2sat_first_icustay aof on r.subject_id=aof.subject_id
 left join admit_o2sat_second_icustay aos on r.subject_id=aos.subject_id 
 left join uo_first_icustay ufi on r.subject_id=ufi.subject_id
 left join uo_first_icustay_24h ufi24 on r.subject_id=ufi24.subject_id  
 left join half_ns_first_icustay hnf on r.subject_id=hnf.subject_id
 left join quarter_ns_first_icustay qnf on r.subject_id=qnf.subject_id
 left join d5w_first_icustay dwf on r.subject_id=dwf.subject_id 
 left join cryst_first_icustay crf on r.subject_id=crf.subject_id
 left join colloid_first_icustay cof on r.subject_id=cof.subject_id
 left join pointake_first_icustay pif on r.subject_id=pif.subject_id
 left join stool_first_icustay sf on r.subject_id=sf.subject_id
 left join totalin_first_icustay tif on r.subject_id=tif.subject_id
 left join totalout_first_icustay tof on r.subject_id=tof.subject_id
 left join fluidbal_first_icustay ff on r.subject_id=ff.subject_id
 left join icd9_first_admission ifa on r.subject_id=ifa.subject_id
 left join icd9_second_admission isa on r.subject_id=isa.subject_id
 left join mimic2devel.elixhauser_revised er on r.first_hadm_id=er.hadm_id
 left join all_dialysis_data ad on r.subject_id=ad.subject_id 
 left join daily_saps ds on r.subject_id=ds.subject_id 
 left join joonlee.vasopressor_use_cohort vc on r.first_icustay_id=vc.icustay_id
 left join mech_vent mv on r.first_icustay_id=mv.icustay_id
 left join home_diuretics hdr on r.subject_id=hdr.subject_id
 left join num_daily_cr_first_icustay ndc on r.subject_id=ndc.subject_id
 left join joonlee.dialysis_manual_review_john d on r.first_hadm_id=d.hadm_id
 left join icu_admit_pressors iap on r.subject_id=iap.subject_id
)
select * from final_data;  -- should be 23,455 rows



-- extract discharge summaries of those who received dialysis (either HD or PD) in order to manually determine acute/chronic renal failure
select r.first_hadm_id, n.text
from JOONLEE.renal_readmission_study_cohort r
join mimic2v26.noteevents n on r.first_hadm_id=n.hadm_id
where (r.hd_first_hadm='Y' or r.pd_first_hadm='Y')
  and n.category='DISCHARGE_SUMMARY'
order by r.first_hadm_id; 

