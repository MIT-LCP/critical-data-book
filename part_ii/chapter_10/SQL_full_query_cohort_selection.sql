-- SQL

create materialized view ppi_mag_cohort AS

-- Get the first ICU stay of each adult

WITH first_admissions AS
    
    (SELECT icud.subject_id,
        icud.hadm_id AS first_hadm_id,
        icud.icustay_id AS first_icustay_id
        icud.hospital_admit_dt AS first_hadm_admit_dt
        icud.hospital_disch_dt AS first_hadm_disch_dt
        icud.icustay_intime AS first_icustay_intime
        icud.icustay_outtime AS first_icustay_outtime,
        EXTRACT(DAY FROM icud.icustay_intime-icud.hospital_admit_dt) AS days_btw_hosp_icu_admit,
        EXTRACT(DAY FROM icud.hospital_disch_dt-icud.icustay_outtime) AS days_btw_hosp_icu_disch,
        icud.icustay_expire_flg AS icu_mort_first_admission,
        icud.hospital_expire_flg AS hosp_mort_first_admission,
        d.admission_source_descr AS first_hadm_source,
        CASE WHEN lower(d.admission_source_descr) like '%emergency%' THEN 'Y'
            ELSE 'N' END AS ED_admission,
        CASE WHEN icud.icustay_admit_age>150 THEN 91.4
            ELSE ROUND(icud.icustay_admit_age,1) END AS age_first_icustay,
        icud.gender,
        d.ethnicity_descr AS race,
        ROUND(icud.icustay_los/60/24,2) AS first_icustay_los,
        icud.icustay_first_service,
        icud.sapsi_first AS first_icustay_admit_saps,
        CASE WHEN msa.hadm_id IS NOT NULL THEN 'Y'
            ELSE 'N' END AS first_hadm_sepsis
    FROM mimic2v26.icustay_detail icud
    LEFT JOIN mimic2v26.demographic_detail d ON icud.hadm_id=d.hadm_id
    LEFT JOIN mimic2devel.martin_sepsis_admissions msa ON icud.hadm_id=msa.hadm_id
    WHERE icud.subject_icustay_seq=1
        AND icud.icustay_age_group='adult'
        AND icud.hadm_id IS NOT NULL
        AND icud.icustay_id IS NOT NULL
        -- AND icud.subject_id < 100
    )

--SELECT * FROM first_admissions;

, raw_icu_admit_labs AS

    (SELECT DISTINCT r.subject_id,
        CASE WHEN l.itemid=50090 THEN 'serum_cr'
             WHEN l.itemid=50159 THEN 'serum_sodium'
             WHEN l.itemid=50655 THEN 'urine_protein'
             WHEN l.itemid=50264 THEN 'urine_cr'
             WHEN l.itemid=50277 THEN 'urine_sodium'
             WHEN l.itemid=50276 THEN 'urine_protein_cr_ratio'
             WHEN l.itemid=50177 THEN 'bun'
             WHEN l.itemid=50149 THEN 'potassium'
             WHEN l.itemid=50083 THEN 'chloride'
             WHEN l.itemid=50172 THEN 'bicarb'
             WHEN l.itemid=50383 THEN 'hematocrit'
             WHEN l.itemid=50468 THEN 'wbc'
             WHEN l.itemid=50140 THEN 'magnesium'
             WHEN l.itemid=50148 THEN 'phosphate'
             WHEN l.itemid=50079 THEN 'calcium'
             WHEN l.itemid=50010 THEN 'lactate'
             WHEN l.itemid=50018 THEN 'ph'
             WHEN l.itemid=50428 THEN 'platelets'
             WHEN l.itemid=50060 THEN 'albumin'
             WHEN l.itemid=50112 THEN 'glucose'
             WHEN l.itemid=50399 THEN 'inr'
             WHEN l.itemid=50439 THEN 'pt'
             WHEN l.itemid=50440 THEN 'ptt'
             WHEN l.itemid=50115 THEN 'haptoglobin'
             WHEN l.itemid=50134 THEN 'ldh'
             WHEN l.itemid=50370 THEN 'd-dimer' END AS lab_type,
        FIRST_VALUE(l.value) over (PARTITION by l.hadm_id, l.itemid ORDER BY l.charttime) AS lab_value,
        FIRST_VALUE(l.charttime) over (PARTITION by l.hadm_id ORDER BY l.charttime) AS icu_admit_lab_time
    FROM first_admissions r
    INNER JOIN mimic2v26.labevents l
    ON r.first_hadm_id=l.hadm_id
    AND l.itemid IN
    (50090,50159,50655,50264,50277,50276,50177,50149,50083,50172,50383,50468,50140,50148,50079,50010,50018,50428,50060,50112,50399,50439,50440,50115,50134,50370)
    AND l.charttime BETWEEN r.first_icustay_intime - interval '12' hour
    AND r.first_icustay_intime + interval '12' hour
    )

--SELECT * FROM raw_icu_admit_labs ORDER BY 1,2;

, icu_admit_labs AS

    (SELECT *
     FROM (SELECT * FROM raw_icu_admit_labs)
    PIVOT
    (MAX(lab_value) for lab_type IN
        ('serum_cr' AS icu_admit_serum_cr,
         'serum_sodium' AS icu_admit_serum_sodium,
         'urine_protein' AS icu_admit_urine_protein,
         'urine_cr' AS icu_admit_urine_cr,
         'urine_sodium' AS icu_admit_urine_sodium,
         'urine_protein_cr_ratio' AS icu_admit_urine_prot_cr_ratio,
         'bun' AS icu_admit_bun,
         'potassium' AS icu_admit_potassium,
         'chloride' AS icu_admit_chloride,
         'bicarb' AS icu_admit_bicarb,
         'hematocrit' AS icu_admit_hematocrit,
         'wbc' AS icu_admit_wbc,
         'magnesium' AS icu_admit_magnesium,
         'phosphate' AS icu_admit_phosphate,
         'calcium' AS icu_admit_calcium,
         'lactate' AS icu_admit_lactate,
         'ph' AS icu_admit_ph,
         'platelets' AS icu_admit_platelets,
         'albumin' AS icu_admit_albumin,
         'glucose' AS icu_admit_glucose,
         'inr' AS icu_admit_inr,
         'pt' AS icu_admit_pt,
         'ptt' AS icu_admit_ptt,
         'haptoglobin' AS icu_admit_haptoglobin,
         'ldh' AS icu_admit_ldh,
         'd-dimer' AS icu_admit_d_dimer)
        )
    )

--SELECT * FROM icu_admit_labs ORDER BY 1;

, raw_hosp_admit_labs AS

    (SELECT DISTINCT r.subject_id,
        CASE WHEN l.itemid=50090 THEN 'serum_cr'
            WHEN l.itemid=50159 THEN 'serum_sodium'
            WHEN l.itemid=50655 THEN 'urine_protein'
            WHEN l.itemid=50264 THEN 'urine_cr'
            WHEN l.itemid=50277 THEN 'urine_sodium'
            WHEN l.itemid=50276 THEN 'urine_protein_cr_ratio'
            WHEN l.itemid=50177 THEN 'bun'
            WHEN l.itemid=50149 THEN 'potassium'
            WHEN l.itemid=50083 THEN 'chloride'
            WHEN l.itemid=50172 THEN 'bicarb'
            WHEN l.itemid=50383 THEN 'hematocrit'
            WHEN l.itemid=50468 THEN 'wbc'
            WHEN l.itemid=50140 THEN 'magnesium'
            WHEN l.itemid=50148 THEN 'phosphate'
            WHEN l.itemid=50079 THEN 'calcium'
            WHEN l.itemid=50010 THEN 'lactate'
            WHEN l.itemid=50018 THEN 'ph'
            WHEN l.itemid=50428 THEN 'platelets'
            WHEN l.itemid=50060 THEN 'albumin'
            WHEN l.itemid=50112 THEN 'glucose' END AS lab_type,
        FIRST_VALUE(l.value) over (PARTITION by l.hadm_id, l.itemid ORDER BY l.charttime) AS lab_value,
        FIRST_VALUE(l.charttime) over (PARTITION by l.hadm_id ORDER BY l.charttime) AS hosp_admit_lab_time
    FROM readmissions r
    INNER JOIN mimic2v26.labevents l
    ON r.first_hadm_id=l.hadm_id
    AND l.itemid IN (50090,50159,50655,50264,50277,50276,50177,50149,50083,50172,50383,50468,50140,50148,50079,50010,50018,50428,50060,50112)
    AND EXTRACT(DAY FROM l.charttime-r.first_hadm_admit_dt) = 0
    )

--SELECT * FROM raw_hosp_admit_labs ORDER BY 1,2;

, hosp_admit_labs AS

    (SELECT *
    FROM (SELECT * FROM raw_hosp_admit_labs)
    PIVOT
    (MAX(lab_value) for lab_type IN
        ('serum_cr' AS hosp_admit_serum_cr,
        'serum_sodium' AS hosp_admit_serum_sodium,
        'urine_protein' AS hosp_admit_urine_protein,
        'urine_cr' AS hosp_admit_urine_cr,
        'urine_sodium' AS hosp_admit_urine_sodium,
        'urine_protein_cr_ratio' AS hosp_admit_urine_prot_cr_ratio,
        'bun' AS hosp_admit_bun,
        'potassium' AS hosp_admit_potassium,
        'chloride' AS hosp_admit_chloride,
        'bicarb' AS hosp_admit_bicarb,
        'hematocrit' AS hosp_admit_hematocrit,
        'wbc' AS hosp_admit_wbc,
        'magnesium' AS hosp_admit_magnesium,
        'phosphate' AS hosp_admit_phosphate,
        'calcium' AS hosp_admit_calcium,
        'lactate' AS hosp_admit_lactate,
        'ph' AS hosp_admit_ph,
        'platelets' AS hosp_admit_platelets,
        'albumin' AS hosp_admit_albumin,
        'glucose' AS hosp_admit_glucose)
        )
    )

--SELECT * FROM hosp_admit_labs ORDER BY 1;

, admit_labs_first_icustay AS

    (SELECT i.subject_id,
        EXTRACT(DAY FROM i.icu_admit_lab_time-r.first_hadm_admit_dt) AS days_btw_icu_lab_hosp_admit,
        CASE WHEN i.icu_admit_lab_time IS NULL OR h.hosp_admit_lab_time IS null THEN null
             WHEN abs(EXTRACT(minute FROM i.icu_admit_lab_time-h.hosp_admit_lab_time)) < 10 THEN 'Y'
             ELSE 'N' END AS same_hosp_icu_admit_labs,
        CASE WHEN LENGTH(TRIM(TRANSLATE(i.icu_admit_serum_cr, '+-.0123456789', ''))) > 0 THEN null
             ELSE to_number(i.icu_admit_serum_cr) END AS icu_admit_serum_cr,
        CASE WHEN LENGTH(TRIM(TRANSLATE(i.icu_admit_serum_sodium, '+-.0123456789', ' '))) > 0 THEN null
             ELSE to_number(i.icu_admit_serum_sodium) END AS icu_admit_serum_sodium,
        CASE WHEN i.icu_admit_urine_protein IN ('N','NEG','NEGATIVE','Neg') THEN 0
             WHEN i.icu_admit_urine_protein IN ('TR','Tr') THEN 1
             WHEN i.icu_admit_urine_protein IN ('15','25','30') THEN 30
             WHEN i.icu_admit_urine_protein IN ('75','100') THEN 100
             WHEN i.icu_admit_urine_protein IN ('150','300') THEN 300
             WHEN i.icu_admit_urine_protein IN ('>300','>600','500') THEN 500 
             ELSE NULL END AS icu_admit_urine_protein,
        CASE WHEN LENGTH(TRIM(TRANSLATE(i.icu_admit_urine_cr, '+-.0123456789', ''))) > 0 THEN null
             ELSE to_number(i.icu_admit_urine_cr) END AS icu_admit_urine_cr,
        CASE WHEN i.icu_admit_urine_sodium='<10' 
             OR (lower(i.icu_admit_urine_sodium) LIKE '%less%' AND i.icu_admit_urine_sodium LIKE '%10%') THEN 0
             WHEN LENGTH(TRIM(TRANSLATE(i.icu_admit_urine_sodium, '+-.0123456789', ' '))) > 0 THEN null
             ELSE to_number(i.icu_admit_urine_sodium) END AS icu_admit_urine_sodium,
        CASE WHEN LENGTH(TRIM(TRANSLATE(i.icu_admit_urine_prot_cr_ratio, '+-.0123456789', ' '))) > 0 THEN null
             ELSE to_number(i.icu_admit_urine_prot_cr_ratio) END AS icu_admit_urine_prot_cr_ratio,
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
        CASE WHEN LENGTH(TRIM(TRANSLATE(h.hosp_admit_serum_cr, ' +-.0123456789', ' '))) > 0 THEN null
             ELSE to_number(h.hosp_admit_serum_cr) END AS hosp_admit_serum_cr,
        CASE WHEN LENGTH(TRIM(TRANSLATE(h.hosp_admit_serum_sodium, ' +-.0123456789', ' '))) > 0 THEN null
             ELSE to_number(h.hosp_admit_serum_sodium) END AS hosp_admit_serum_sodium,
        CASE WHEN h.hosp_admit_urine_protein IN ('N','NEG','NEGATIVE','Neg') THEN 0
             WHEN h.hosp_admit_urine_protein IN ('TR','Tr') THEN 1
             WHEN h.hosp_admit_urine_protein IN ('15','25','30') THEN 30
             WHEN h.hosp_admit_urine_protein IN ('75','100') THEN 100
             WHEN h.hosp_admit_urine_protein IN ('150','300') THEN 300
             WHEN h.hosp_admit_urine_protein IN ('>300','>600','500') THEN 500
             ELSE NULL END AS hosp_admit_urine_protein,
        CASE WHEN LENGTH(TRIM(TRANSLATE(h.hosp_admit_urine_cr, ' +-.0123456789', ' '))) > 0 THEN null
             ELSE to_number(h.hosp_admit_urine_cr) END AS hosp_admit_urine_cr,
        CASE WHEN h.hosp_admit_urine_sodium='<10' 
                OR (lower(h.hosp_admit_urine_sodium) like '%less%' 
                AND h.hosp_admit_urine_sodium like '%10%') THEN 0
             WHEN LENGTH(TRIM(TRANSLATE(h.hosp_admit_urine_sodium, ' +-.0123456789', ' '))) > 0 THEN null
             ELSE to_number(h.hosp_admit_urine_sodium) END AS hosp_admit_urine_sodium,
        CASE WHEN LENGTH(TRIM(TRANSLATE(h.hosp_admit_urine_prot_cr_ratio, ' +-.0123456789', ' '))) > 0 THEN null
             ELSE to_number(h.hosp_admit_urine_prot_cr_ratio) END AS hosp_admit_urine_prot_cr_ratio,
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

    FROM readmissions r
    LEFT JOIN icu_admit_labs i ON r.subject_id=i.subject_id
    LEFT JOIN hosp_admit_labs h ON i.subject_id=h.subject_id
    )

--SELECT * FROM admit_labs_first_icustay;

-- Get peak creatinine values FROM first ICU stays

, peak_creat_first_icustay AS

    (SELECT DISTINCT r.subject_id,
        COUNT(*) AS num_cr_first_icustay,
        MAX(l.valuenum) AS cr_peak_first_icustay
    FROM first_admissions r
    INNER JOIN mimic2v26.labevents l ON r.first_icustay_id=l.icustay_id AND l.itemid=50090
    GROUP BY r.subject_id
    )

--SELECT * FROM peak_creat_first_icustay;

-- Get discharge creatinine values FROM first ICU stays

, disch_creat_first_icustay AS

    (SELECT DISTINCT r.subject_id,
        FIRST_VALUE(l.valuenum) over (PARTITION by l.icustay_id ORDER BY
        l.charttime desc) AS cr_disch_first_icustay
    FROM first_admissions r
    INNER JOIN mimic2v26.labevents l ON r.first_icustay_id=l.icustay_id 
        AND l.itemid=50090 
        AND l.charttime BETWEEN r.first_icustay_outtime - interval '48' hour AND r.first_icustay_outtime
    )

--SELECT * FROM disch_creat_first_icustay;

-- Get number of days with at leASt ONe creatinine meASurement during the first ICU stay

, days_with_cr_first_icustay AS

    (SELECT DISTINCT r.subject_id,
        icud.seq
    FROM first_admissions r
    INNER JOIN mimic2v26.icustay_days icud ON r.first_icustay_id=icud.icustay_id
    INNER JOIN mimic2v26.labevents l ON r.first_icustay_id=l.icustay_id 
        AND l.itemid=50090 AND l.charttime BETWEEN icud.begintime AND icud.endtime
    )

--SELECT * FROM days_with_cr_first_icustay;

, num_daily_cr_first_icustay AS

    (SELECT subject_id,
        COUNT(*) AS num_daily_cr_first_icustay
    FROM days_with_cr_first_icustay
    GROUP BY subject_id
    )

--SELECT * FROM num_daily_cr_first_icustay;

-- Get admit creatinine values FROM second ICU stays

, admit_labs_second_icustay AS

    (SELECT DISTINCT r.subject_id,
        FIRST_VALUE(l.valuenum) over (PARTITION by l.icustay_id ORDER BY l.charttime) AS admit_serum_cr_second_icustay
    FROM first_admissions r
    INNER JOIN mimic2v26.labevents l ON r.second_icustay_id=l.icustay_id AND
    l.itemid=50090 AND l.charttime BETWEEN r.second_icustay_intime -
    interval '12' hour AND r.second_icustay_intime + interval '12' hour
    )

--SELECT * FROM admit_labs_second_icustay;

-- Combine all labs together

, all_labs AS

    (SELECT alf.*,
        pcf.cr_peak_first_icustay,
        dcf.cr_disch_first_icustay,
        pcf.num_cr_first_icustay,
        ncf.num_daily_cr_first_icustay,
        als.admit_serum_cr_second_icustay
    FROM admit_labs_first_icustay alf
    LEFT JOIN peak_creat_first_icustay pcf ON alf.subject_id=pcf.subject_id
    LEFT JOIN disch_creat_first_icustay dcf ON alf.subject_id=dcf.subject_id
    LEFT JOIN num_daily_cr_first_icustay ncf ON alf.subject_id=ncf.subject_id
    LEFT JOIN admit_labs_second_icustay als ON alf.subject_id=als.subject_id
    )

--SELECT * FROM all_labs;

-- Narrow down Chartevents table

, small_chartevents AS

    (SELECT subject_id,
        icustay_id,
        itemid,
        charttime,
        value1num,
        value2num
    FROM mimic2v26.chartevents
    WHERE itemid IN (580,581,763,762,920,211,51,52,455,456,678,679,646,834,20001)
        AND subject_id IN (SELECT subject_id FROM first_admissions)
    )

--SELECT * FROM small_chartevents;

    -- Get admit weight FROM first ICU stays

    , admit_weight_first_icustay AS

    (SELECT DISTINCT r.subject_id,
        FIRST_VALUE(l.value1num) over (PARTITION by l.icustay_id ORDER BY l.charttime) AS weight_admit_first_icustay
    FROM first_admissions r
    INNER JOIN small_chartevents l ON r.first_icustay_id=l.icustay_id 
        AND l.itemid=762 
        AND l.charttime BETWEEN r.first_icustay_intime AND r.first_icustay_intime + interval '24' hour
    )

--SELECT * FROM admit_weight_first_icustay;

-- Get admit height FROM first ICU stays

, admit_height_first_icustay AS

    (SELECT DISTINCT r.subject_id,
        FIRST_VALUE(l.value1num) over (PARTITION by l.icustay_id ORDER BY l.charttime) AS height_admit_first_icustay
    FROM first_admissions r
    INNER JOIN small_chartevents l ON r.first_icustay_id=l.icustay_id 
    AND l.itemid=920 
    AND l.charttime BETWEEN r.first_icustay_intime AND r.first_icustay_intime + interval '24' hour
    )

--SELECT * FROM admit_height_first_icustay;

-- Get discharge weight FROM first ICU stays

, disch_weight_first_icustay AS

    (SELECT DISTINCT r.subject_id,

    FIRST_VALUE(l.value1num) over (PARTITION by l.icustay_id ORDER BY
    l.charttime desc) AS weight_disch_first_icustay

    FROM first_admissions r

    JOIN small_chartevents l ON r.first_icustay_id=l.icustay_id AND
    l.itemid IN (580,581,763) AND l.charttime BETWEEN
    r.first_icustay_outtime - interval '48' hour AND
    r.first_icustay_outtime

    )

--SELECT * FROM disch_weight_first_icustay;

-- Get admit weight FROM second ICU stays

, admit_weight_second_icustay AS

    (SELECT DISTINCT r.subject_id,

    FIRST_VALUE(l.value1num) over (PARTITION by l.icustay_id ORDER BY
    l.charttime) AS weight_admit_second_icustay

    FROM first_admissions r

    JOIN small_chartevents l ON r.second_icustay_id=l.icustay_id AND
    l.itemid=762 AND l.charttime BETWEEN r.second_icustay_intime AND
    r.second_icustay_intime + interval '24' hour

    )

--SELECT * FROM admit_weight_second_icustay;

-- Combine all weight AND height together

, all_weight_height AS

    (SELECT r.subject_id,

    awf.weight_admit_first_icustay,

    ahf.height_admit_first_icustay,

    CASE

    WHEN ahf.height_admit_first_icustay > 0 THEN
    ROUND(awf.weight_admit_first_icustay/power(ahf.height_admit_first_icustay*0.0254,2),2)

    ELSE NULL

    END AS bmi_admit_first_icustay,

    dwf.weight_disch_first_icustay,

    aws.weight_admit_second_icustay

    FROM first_admissions r

    LEFT JOIN admit_weight_first_icustay awf ON
    r.subject_id=awf.subject_id

    LEFT JOIN admit_height_first_icustay ahf ON
    r.subject_id=ahf.subject_id

    LEFT JOIN disch_weight_first_icustay dwf ON
    r.subject_id=dwf.subject_id

    LEFT JOIN admit_weight_second_icustay aws ON
    r.subject_id=aws.subject_id

    )

--SELECT * FROM all_weight_height;

-- Get admit heart rate FROM first ICU stays

, admit_hr_first_icustay AS

    (SELECT DISTINCT r.subject_id,

    FIRST_VALUE(l.value1num) over (PARTITION by l.icustay_id ORDER BY
    l.charttime) AS hr_admit_first_icustay

    FROM first_admissions r

    INNER JOIN small_chartevents l ON r.first_icustay_id=l.icustay_id AND
    l.itemid IN (211) AND l.charttime BETWEEN r.first_icustay_intime AND
    r.first_icustay_intime + interval '24' hour

    )

--SELECT * FROM admit_hr_first_icustay;

-- Get admit heart rate FROM second ICU stays

, admit_hr_second_icustay AS

    (SELECT DISTINCT r.subject_id,

    FIRST_VALUE(l.value1num) over (PARTITION by l.icustay_id ORDER BY
    l.charttime) AS hr_admit_second_icustay

    FROM first_admissions r

    INNER JOIN small_chartevents l ON r.second_icustay_id=l.icustay_id AND
    l.itemid IN (211) AND l.charttime BETWEEN r.second_icustay_intime AND
    r.second_icustay_intime + interval '24' hour

    )

--SELECT * FROM admit_hr_second_icustay;

-- Get admit mean arterial pressure FROM first ICU stays

, admit_map_first_icustay AS

    (SELECT DISTINCT r.subject_id,

    FIRST_VALUE(l.value1num) over (PARTITION by l.icustay_id ORDER BY
    l.charttime) AS map_admit_first_icustay,

    FIRST_VALUE(l.itemid) over (PARTITION by l.icustay_id ORDER BY
    l.charttime) AS map_type_first_icustay

    FROM first_admissions r

    INNER JOIN small_chartevents l ON r.first_icustay_id=l.icustay_id AND
    l.itemid IN (52,456) AND l.charttime BETWEEN r.first_icustay_intime
    AND r.first_icustay_intime + interval '24' hour

    )

--SELECT * FROM admit_map_first_icustay;

-- Get admit mean arterial pressure FROM second ICU stays

, admit_map_second_icustay AS

    (SELECT DISTINCT r.subject_id,

    FIRST_VALUE(l.value1num) over (PARTITION by l.icustay_id ORDER BY
    l.charttime) AS map_admit_second_icustay,

    FIRST_VALUE(l.itemid) over (PARTITION by l.icustay_id ORDER BY
    l.charttime) AS map_type_second_icustay

    FROM first_admissions r

    INNER JOIN small_chartevents l ON r.second_icustay_id=l.icustay_id AND
    l.itemid IN (52,456) AND l.charttime BETWEEN r.second_icustay_intime
    AND r.second_icustay_intime + interval '24' hour

    )

--SELECT * FROM admit_map_second_icustay;

-- Get admit systolic AND diAStolic arterial pressure FROM first ICU stays

, admit_bp_first_icustay AS

    (SELECT DISTINCT r.subject_id,

    FIRST_VALUE(l.value1num) over (PARTITION by l.icustay_id ORDER BY
    l.charttime) AS sbp_admit_first_icustay,

    FIRST_VALUE(l.value2num) over (PARTITION by l.icustay_id ORDER BY
    l.charttime) AS dbp_admit_first_icustay,

    FIRST_VALUE(l.itemid) over (PARTITION by l.icustay_id ORDER BY
    l.charttime) AS sbp_dbp_type_first_icustay

    FROM first_admissions r

    INNER JOIN small_chartevents l ON r.first_icustay_id=l.icustay_id AND
    l.itemid IN (51,455) AND l.charttime BETWEEN r.first_icustay_intime
    AND r.first_icustay_intime + interval '24' hour

    )

--SELECT * FROM admit_bp_first_icustay;

-- Get admit systolic AND diAStolic arterial pressure FROM second ICU stays

, admit_bp_second_icustay AS

    (SELECT DISTINCT r.subject_id,

    FIRST_VALUE(l.value1num) over (PARTITION by l.icustay_id ORDER BY
    l.charttime) AS sbp_admit_second_icustay,

    FIRST_VALUE(l.value2num) over (PARTITION by l.icustay_id ORDER BY
    l.charttime) AS dbp_admit_second_icustay,

    FIRST_VALUE(l.itemid) over (PARTITION by l.icustay_id ORDER BY
    l.charttime) AS sbp_dbp_type_second_icustay

    FROM first_admissions r

    INNER JOIN small_chartevents l ON r.second_icustay_id=l.icustay_id AND
    l.itemid IN (51,455) AND l.charttime BETWEEN r.second_icustay_intime
    AND r.second_icustay_intime + interval '24' hour

    )

--SELECT * FROM admit_bp_second_icustay;

-- Get admit temperature FROM first ICU stays

, admit_temp_first_icustay AS

    (SELECT DISTINCT r.subject_id,

    FIRST_VALUE(l.value1num) over (PARTITION by l.icustay_id ORDER BY
    l.charttime) AS temp_admit_first_icustay

    FROM first_admissions r

    INNER JOIN small_chartevents l ON r.first_icustay_id=l.icustay_id AND
    l.itemid IN (678, 679) AND l.charttime BETWEEN r.first_icustay_intime
    AND r.first_icustay_intime + interval '24' hour

    )

--SELECT * FROM admit_temp_first_icustay;

-- Get admit temperature FROM second ICU stays

, admit_temp_second_icustay AS

    (SELECT DISTINCT r.subject_id,

    FIRST_VALUE(l.value1num) over (PARTITION by l.icustay_id ORDER BY
    l.charttime) AS temp_admit_second_icustay

    FROM first_admissions r

    INNER JOIN small_chartevents l ON r.second_icustay_id=l.icustay_id AND
    l.itemid IN (678, 679) AND l.charttime BETWEEN r.second_icustay_intime
    AND r.second_icustay_intime + interval '24' hour

    )

--SELECT * FROM admit_temp_second_icustay;

-- Get admit o2sat FROM first ICU stays

, admit_o2sat_first_icustay AS

    (SELECT DISTINCT r.subject_id,

    FIRST_VALUE(l.value1num) over (PARTITION by l.icustay_id ORDER BY
    l.charttime) AS o2sat_admit_first_icustay

    FROM first_admissions r

    INNER JOIN small_chartevents l ON r.first_icustay_id=l.icustay_id AND
    l.itemid IN (646, 834) AND l.charttime BETWEEN r.first_icustay_intime
    AND r.first_icustay_intime + interval '24' hour

    )

--SELECT * FROM admit_o2sat_first_icustay;

-- Get admit o2sat FROM second ICU stays

, admit_o2sat_second_icustay AS

    (SELECT DISTINCT r.subject_id,

    FIRST_VALUE(l.value1num) over (PARTITION by l.icustay_id ORDER BY
    l.charttime) AS o2sat_admit_second_icustay

    FROM first_admissions r

    INNER JOIN small_chartevents l ON r.second_icustay_id=l.icustay_id AND
    l.itemid IN (646, 834) AND l.charttime BETWEEN r.second_icustay_intime
    AND r.second_icustay_intime + interval '24' hour

    )

--SELECT * FROM admit_o2sat_second_icustay;

-- Total urine output during the first ICU stay

, uo_first_icustay AS

    (SELECT r.subject_id,

    SUM(ie.volume) AS urine_first_icustay

    FROM first_admissions r

    INNER JOIN mimic2v26.ioevents ie ON r.first_icustay_id=ie.icustay_id

    WHERE ie.itemid IN ( 651, 715, 55, 56, 57, 61, 65, 69, 85, 94, 96, 288,
    405, 428, 473, 2042, 2068, 2111, 2119, 2130, 1922, 2810, 2859, 3053,
    3462, 3519, 3175, 2366, 2463, 2507, 2510, 2592, 2676, 3966, 3987, 4132,
    4253, 5927 )

    GROUP BY r.subject_id

    )

--SELECT * FROM uo_first_icustay;

, uo_first_icustay_24h AS

    (SELECT r.subject_id,

    SUM(ie.volume) AS urine_first_icustay_24h

    FROM first_admissions r

    INNER JOIN mimic2v26.ioevents ie ON r.first_icustay_id=ie.icustay_id AND
    ie.charttime BETWEEN r.first_icustay_intime AND
    r.first_icustay_intime + interval '24' hour

    WHERE ie.itemid IN ( 651, 715, 55, 56, 57, 61, 65, 69, 85, 94, 96, 288,
    405, 428, 473, 2042, 2068, 2111, 2119, 2130, 1922, 2810, 2859, 3053,
    3462, 3519, 3175, 2366, 2463, 2507, 2510, 2592, 2676, 3966, 3987, 4132,
    4253, 5927 )

    GROUP BY r.subject_id

    )

--SELECT * FROM uo_first_icustay_24h;

-- Total 1/2 NS during the first ICU stay

, half_ns_first_icustay AS

    (SELECT r.subject_id,

    SUM(ie.volume) AS half_ns_first_icustay

    FROM first_admissions r

    INNER JOIN mimic2v26.ioevents ie ON r.first_icustay_id=ie.icustay_id

    WHERE ie.itemid not IN (SELECT itemid FROM rishi_kothari.d_fluiditems)

    AND ie.itemid IN (SELECT itemid FROM mimic2v26.d_ioitems WHERE
    (lower(label) like '%normal saline%' or lower(label) like '%ns%') AND
    (lower(label) not like '%d%ns%') AND (label like '%1/2%' or label like
    '%.45%'))

    GROUP BY r.subject_id

    )

--SELECT * FROM half_ns_first_icustay;

-- Total 1/4 NS during the first ICU stay

, quarter_ns_first_icustay AS

    (SELECT r.subject_id,

    SUM(ie.volume) AS quarter_ns_first_icustay

    FROM first_admissions r

    INNER JOIN mimic2v26.ioevents ie ON r.first_icustay_id=ie.icustay_id

    WHERE ie.itemid not IN (SELECT itemid FROM rishi_kothari.d_fluiditems)

    AND ie.itemid IN (SELECT itemid FROM mimic2v26.d_ioitems WHERE
    (lower(label) like '%normal saline%' or lower(label) like '%ns%') AND
    (lower(label) not like '%d%ns%') AND (label like '%1/4%' or label like
    '%.22%'))

    GROUP BY r.subject_id

    )

--SELECT * FROM quarter_ns_first_icustay;

-- Total D5W during the first ICU stay

, d5w_first_icustay AS

    (SELECT r.subject_id,

    SUM(ie.volume) AS d5w_first_icustay

    FROM first_admissions r

    INNER JOIN mimic2v26.ioevents ie ON r.first_icustay_id=ie.icustay_id

    WHERE ie.itemid not IN (SELECT itemid FROM rishi_kothari.d_fluiditems)

    AND ie.itemid IN (SELECT itemid FROM mimic2v26.d_ioitems WHERE
    lower(label) like '%d5w%' AND lower(label) not like '%d5%ns%' AND
    lower(label) not like '%d5%lr%' AND lower(label) not like '%d5%rl%')

    GROUP BY r.subject_id

    )

--SELECT * FROM d5w_first_icustay;

-- Total crystalloid volume during the first ICU stay

, cryst_first_icustay AS

    (SELECT r.subject_id,

    SUM(ie.volume) AS cryst_first_icustay

    FROM first_admissions r

    INNER JOIN mimic2v26.ioevents ie ON r.first_icustay_id=ie.icustay_id

    WHERE ie.itemid IN (SELECT itemid FROM rishi_kothari.d_fluiditems)

    GROUP BY r.subject_id

    )

--SELECT * FROM cryst_first_icustay;

-- Total colloid volume during the first ICU stay

, colloid_first_icustay AS

    (SELECT r.subject_id,

    SUM(ie.volume) AS colloid_first_icustay

    FROM first_admissions r

    INNER JOIN mimic2v26.ioevents ie ON r.first_icustay_id=ie.icustay_id

    WHERE ie.itemid IN (SELECT itemid FROM rishi_kothari.d_colloids)

    GROUP BY r.subject_id

    )

--SELECT * FROM colloid_first_icustay;

-- Total PO INtake during the first ICU stay

, pointake_first_icustay AS

    (SELECT r.subject_id,

    SUM(t.cumvolume) AS po_intake_first_icustay

    FROM first_admissions r

    INNER JOIN mimic2v26.totalbalevents t ON r.first_icustay_id=t.icustay_id

    WHERE itemid=20

    GROUP BY r.subject_id

    )

--SELECT * FROM pointake_first_icustay;

-- Total stool loss during the first ICU stay

, stool_first_icustay AS

    (SELECT r.subject_id,

    SUM(t.cumvolume) AS stool_first_icustay

    FROM first_admissions r

    INNER JOIN mimic2v26.totalbalevents t ON r.first_icustay_id=t.icustay_id

    WHERE itemid=22

    GROUP BY r.subject_id

    )

--SELECT * FROM pointake_first_icustay;

-- Total INput during the first ICU stay

, totalin_first_icustay AS

    (SELECT r.subject_id,

    SUM(t.cumvolume) AS total_in_first_icustay

    FROM first_admissions r

    INNER JOIN mimic2v26.totalbalevents t ON r.first_icustay_id=t.icustay_id

    WHERE itemid=1

    GROUP BY r.subject_id

    )

--SELECT * FROM totalin_first_icustay;

-- Total output during the first ICU stay

, totalout_first_icustay AS

    (SELECT r.subject_id,
    SUM(t.cumvolume) AS total_out_first_icustay
    FROM first_admissions r
    INNER JOIN mimic2v26.totalbalevents t ON r.first_icustay_id=t.icustay_id
    WHERE itemid=2
    GROUP BY r.subject_id

    )

--SELECT * FROM totalout_first_icustay;

-- Total fluid balance for the first ICU stay

, fluidbal_first_icustay AS

    (SELECT DISTINCT r.subject_id,
        FIRST_VALUE(t.cumvolume) over (PARTITION by t.icustay_id ORDER BY t.charttime desc) AS fluid_balance_first_icustay
    FROM first_admissions r
    INNER JOIN mimic2v26.totalbalevents t ON r.first_icustay_id=t.icustay_id
    WHERE itemid=28
    )

--SELECT * FROM fluidbal_first_icustay;

-- ICD9 FROM first hospital admission

, icd9_first_admissiON AS

    (SELECT r.subject_id,
        i.code,
        i.description
    FROM first_admissions r
    JOIN mimic2v26.icd9 i ON r.first_hadm_id=i.hadm_id
    WHERE i.sequence = 1
    )

--SELECT * FROM icd9_first_admission;

-- ICD9 FROM second hospital admission

, icd9_second_admissiON AS

    (SELECT r.subject_id,
        i.code,
        i.description
    FROM first_admissions r
    JOIN mimic2v26.icd9 i ON r.second_hadm_id=i.hadm_id
    WHERE i.sequence = 1

    )

--SELECT * FROM icd9_second_admission;

------------------------------------

--- Start of dialysis-related data

------------------------------------

, first_dialysis AS

    (SELECT DISTINCT r.subject_id,

    r.first_hadm_id,

    r.first_icustay_id,

    FIRST_VALUE(p.proc_dt) over (PARTITION by p.hadm_id ORDER BY
    p.proc_dt) AS first_dialysis_dt

    FROM first_admissions r

    JOIN mimic2v26.procedureevents p ON r.first_hadm_id=p.hadm_id

    WHERE p.itemid IN (100977,100622)

    )

--SELECT * FROM first_dialysis;

-- Hemodialysis during the first hospital admission

, hd AS

    (SELECT DISTINCT r.subject_id

    FROM first_admissions r

    JOIN mimic2v26.procedureevents p ON r.first_hadm_id=p.hadm_id

    WHERE p.itemid=100622

    )

--SELECT * FROM hd;

-- Peritoneal dialysis during the first hospital admission

, pd AS

    (SELECT DISTINCT r.subject_id

    FROM first_admissions r

    JOIN mimic2v26.procedureevents p ON r.first_hadm_id=p.hadm_id

    WHERE p.itemid=100977

    )

--SELECT * FROM pd;

, labs_proximal_to_dialysis AS

    (SELECT fd.subject_id,

    EXTRACT(DAY FROM fd.first_dialysis_dt-r.first_icustay_intime) AS
    icu_day_first_dialysis,

    fd.first_dialysis_dt-r.first_hadm_admit_dt AS
    hosp_day_first_dialysis,

    fd.first_dialysis_dt,

    l.itemid,

    l.charttime,

    FIRST_VALUE(l.valuenum) over (PARTITION by fd.subject_id,l.itemid
    ORDER BY fd.first_dialysis_dt-l.charttime) AS proximal_lab

    FROM first_dialysis fd

    JOIN first_admissions r ON fd.subject_id=r.subject_id

    JOIN mimic2v26.labevents l ON r.first_hadm_id=l.hadm_id AND l.itemid
    IN (50090,50177) AND l.charttime < fd.first_dialysis_dt

    )

--SELECT * FROM labs_proximal_to_dialysis;

, labs_prior_to_dialysis AS

    (SELECT subject_id,

    icu_day_first_dialysis,

    hosp_day_first_dialysis,

    first_dialysis_dt,

    cr_prior_to_dialysis,

    bun_prior_to_dialysis

    FROM (SELECT DISTINCT subject_id, icu_day_first_dialysis,
    hosp_day_first_dialysis, first_dialysis_dt, itemid, proximal_lab
    FROM labs_proximal_to_dialysis)

    PIVOT

    (avg(proximal_lab) for itemid IN

    ('50090' AS cr_prior_to_dialysis,

    '50177' AS bun_prior_to_dialysis

    )

    )

    )

    --SELECT * FROM labs_prior_to_dialysis;

    , cr_and_dialysis AS

    (SELECT subject_id,

    EXTRACT(DAY FROM min(first_dialysis_dt-charttime)) AS
    days_btw_cr_and_dialysis

    FROM labs_proximal_to_dialysis

    WHERE itemid=50090

    GROUP BY subject_id

    )

--SELECT * FROM cr_and_dialysis;

, fluidbal_dialysis AS

    (SELECT DISTINCT f.subject_id,

    FIRST_VALUE(t.cumvolume) over (PARTITION by t.icustay_id ORDER BY
    t.charttime desc) AS fluidbal_prior_to_dialysis

    FROM first_dialysis f

    JOIN mimic2v26.totalbalevents t ON f.first_icustay_id=t.icustay_id

    WHERE t.itemid=28

    AND t.charttime < f.first_dialysis_dt

    )

--SELECT * FROM fluidbal_dialysis;

, uo_dialysis AS

    (SELECT f.subject_id,

    SUM(ie.volume) AS urine_prior_to_dialysis

    FROM first_dialysis f

    JOIN mimic2v26.ioevents ie ON f.first_icustay_id=ie.icustay_id AND
    ie.charttime < f.first_dialysis_dt

    WHERE ie.itemid IN ( 651, 715, 55, 56, 57, 61, 65, 69, 85, 94, 96, 288,
    405, 428, 473, 2042, 2068, 2111, 2119, 2130, 1922, 2810, 2859, 3053,
    3462, 3519, 3175, 2366, 2463, 2507, 2510, 2592, 2676, 3966, 3987, 4132,
    4253, 5927 )

    AND ie.volume > 0

    GROUP BY f.subject_id

    )

--SELECT * FROM uo_dialysis;

, ivf_dialysis AS

    (SELECT f.subject_id,

    SUM(ie.volume) AS ivf_prior_to_dialysis

    FROM first_dialysis f

    JOIN mimic2v26.ioevents ie ON f.first_icustay_id=ie.icustay_id AND
    ie.charttime < f.first_dialysis_dt

    WHERE (ie.itemid IN (SELECT itemid FROM rishi_kothari.d_fluiditems) or
    ie.itemid IN (SELECT itemid FROM rishi_kothari.d_colloids))

    AND ie.volume > 0

    GROUP BY f.subject_id

    )

--SELECT * FROM ivf_dialysis;

, saps_dialysis AS

    (SELECT DISTINCT f.subject_id,

    FIRST_VALUE(ce.value1num) over (PARTITION by f.subject_id ORDER BY
    ce.charttime desc) AS saps_day_of_dialysis

    FROM first_dialysis f

    JOIN small_chartevents ce ON f.first_icustay_id=ce.icustay_id AND
    ce.itemid=20001 AND ce.charttime>=f.first_dialysis_dt AND
    EXTRACT(DAY FROM ce.charttime-f.first_dialysis_dt)=0

    )

--SELECT * FROM saps_dialysis;

, all_dialysis_data AS

    (SELECT f.*,

    CASE

    WHEN hd.subject_id IS NULL THEN 'N'

    ELSE 'Y'

    END AS hd_first_hadm,

    CASE

    WHEN pd.subject_id IS NULL THEN 'N'

    ELSE 'Y'

    END AS pd_first_hadm,

    l.icu_day_first_dialysis,

    l.hosp_day_first_dialysis,

    l.cr_prior_to_dialysis,

    cd.days_btw_cr_and_dialysis,

    l.bun_prior_to_dialysis,

    fd.fluidbal_prior_to_dialysis,

    ud.urine_prior_to_dialysis,

    ivfd.ivf_prior_to_dialysis,

    s.saps_day_of_dialysis

    FROM first_dialysis f

    LEFT JOIN hd ON f.subject_id=hd.subject_id

    LEFT JOIN pd ON f.subject_id=pd.subject_id

    LEFT JOIN labs_prior_to_dialysis l ON f.subject_id=l.subject_id

    LEFT JOIN cr_and_dialysis cd ON f.subject_id=cd.subject_id

    LEFT JOIN fluidbal_dialysis fd ON f.subject_id=fd.subject_id

    LEFT JOIN uo_dialysis ud ON f.subject_id=ud.subject_id

    LEFT JOIN ivf_dialysis ivfd ON f.subject_id=ivfd.subject_id

    LEFT JOIN saps_dialysis s ON f.subject_id=s.subject_id

    )

--SELECT * FROM all_dialysis_data;

---------------------------------

--- END of dialysis-related data

---------------------------------

-- daily SAPS scores

, daily_saps AS

    (SELECT r.subject_id,

    SUM(ce.value1num) AS total_saps_first_icustay,

    COUNT(*) AS num_saps_scores_first_icustay,

    MAX(ce.value1num) AS peak_saps_first_icustay

    FROM first_admissions r

    JOIN small_chartevents ce ON r.first_icustay_id=ce.icustay_id AND
    ce.itemid=20001

    GROUP BY r.subject_id

    )

--SELECT * FROM daily_saps;

-- mechanical ventilation

, mech_vent AS

    (SELECT DISTINCT icustay_id

    FROM mimic2devel.ventilation

    )

--SELECT * FROM mech_vent

-- Get home diuretics

, count_home_diuretics AS

    (SELECT r.subject_id,

    CASE

    WHEN hm.hadm_id IS NULL THEN null

    WHEN pm.name IS NOT NULL THEN 1

    ELSE 0

    END diuretic_flg

    FROM first_admissions r

    LEFT JOIN lilehman.pt_with_home_meds hm ON
    r.first_hadm_id=hm.hadm_id

    LEFT JOIN lilehman.ppi_admission_drugs2 p ON
    r.first_hadm_id=p.hadm_id

    LEFT JOIN djscott.ppi_med_groups pm ON
    instr(pm.name,p.medication)>0 AND pm.med_category='DIURETIC'

    )

--SELECT * FROM count_home_diuretics;

-- Tally the number of home diuretics

, home_diuretics AS

    (SELECT subject_id,

    SUM(diuretic_flg) AS num_home_diuretics

    FROM count_home_diuretics

    GROUP BY subject_id

    )

--SELECT * FROM home_diuretics;

-- VASopressors during the first 24 hours IN the ICU

, icu_admit_pressors AS

    (SELECT DISTINCT r.subject_id

    FROM first_admissions r

    JOIN mimic2v26.medevents m

    ON r.first_icustay_id=m.icustay_id

    WHERE m.itemid IN (42, 43, 44, 46, 47, 51, 119, 120, 125, 127, 128, 306,
    307, 309)

    AND m.dose > 0

    AND m.charttime BETWEEN r.first_icustay_intime AND
    r.first_icustay_intime + interval '24' hour

    )

--SELECT * FROM icu_admit_pressors;

-- ASsemble final data

, final_data AS

    (SELECT r.subject_id,

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

    WHEN r.gender='F' AND (r.race LIKE '%AFRICAN%' OR r.race LIKE '%BLACK%')
    THEN ROUND(186
    *POWER(al.cr_disch_first_icustay,-1.154)*POWER(r.age_first_icustay,-0.203)
    * 1.212 * 0.742 ,2)

    WHEN r.gender='M' AND (r.race LIKE '%AFRICAN%' OR r.race LIKE '%BLACK%')
    THEN ROUND(186
    *POWER(al.cr_disch_first_icustay,-1.154)*POWER(r.age_first_icustay,-0.203)
    * 1.212 ,2)

    WHEN r.gender='F' AND (r.race NOT LIKE '%AFRICAN%' AND r.race NOT LIKE
    '%BLACK%') THEN ROUND(186
    *POWER(al.cr_disch_first_icustay,-1.154)*POWER(r.age_first_icustay,-0.203)
    * 0.742 ,2)

    WHEN r.gender='M' AND (r.race NOT LIKE '%AFRICAN%' AND r.race NOT LIKE
    '%BLACK%') THEN ROUND(186
    *POWER(al.cr_disch_first_icustay,-1.154)*POWER(r.age_first_icustay,-0.203)
    ,2)

    END AS mdrd_disch_first_icustay,

    awh.weight_admit_first_icustay,

    awh.height_admit_first_icustay,

    awh.bmi_admit_first_icustay,

    awh.weight_disch_first_icustay,

    awh.weight_admit_second_icustay,

    ahf.hr_admit_first_icustay,

    ahs.hr_admit_second_icustay,

    ROUND(amf.map_admit_first_icustay,2) AS map_admit_first_icustay,

    CASE

    WHEN amf.map_type_first_icustay=52 THEN 'invASive'

    WHEN amf.map_type_first_icustay=456 THEN 'non-invASive'

    ELSE NULL

    END AS map_type_first_icustay,

    ROUND(ams.map_admit_second_icustay,2) AS map_admit_second_icustay,

    CASE

    WHEN ams.map_type_second_icustay=52 THEN 'invASive'

    WHEN ams.map_type_second_icustay=456 THEN 'non-invASive'

    ELSE NULL

    END AS map_type_second_icustay,

    abf.sbp_admit_first_icustay,

    abs.sbp_admit_second_icustay,

    abf.dbp_admit_first_icustay,

    abs.dbp_admit_second_icustay,

    CASE

    WHEN abf.sbp_dbp_type_first_icustay=51 THEN 'invASive'

    WHEN abf.sbp_dbp_type_first_icustay=455 THEN 'non-invASive'

    ELSE NULL

    END AS sbp_dbp_type_first_icustay,

    CASE

    WHEN abs.sbp_dbp_type_second_icustay=51 THEN 'invASive'

    WHEN abs.sbp_dbp_type_second_icustay=455 THEN 'non-invASive'

    ELSE NULL

    END AS sbp_dbp_type_second_icustay,

    ROUND(atf.temp_admit_first_icustay,2) AS temp_admit_first_icustay,

    ROUND(ats.temp_admit_second_icustay,2) AS
    temp_admit_second_icustay,

    aof.o2sat_admit_first_icustay,

    aos.o2sat_admit_second_icustay,

    ufi.urine_first_icustay,

    ufi24.urine_first_icustay_24h,

    CASE

    WHEN hnf.half_ns_first_icustay IS NULL THEN 0

    ELSE hnf.half_ns_first_icustay

    END AS half_ns_first_icustay,

    CASE

    WHEN qnf.quarter_ns_first_icustay IS NULL THEN 0

    ELSE qnf.quarter_ns_first_icustay

    END AS quarter_ns_first_icustay,

    CASE

    WHEN dwf.d5w_first_icustay IS NULL THEN 0

    ELSE dwf.d5w_first_icustay

    END AS d5w_first_icustay,

    CASE

    WHEN crf.cryst_first_icustay IS NULL THEN 0

    ELSE crf.cryst_first_icustay

    END AS iso_cryst_first_icustay,

    CASE

    WHEN cof.colloid_first_icustay IS NULL THEN 0

    ELSE cof.colloid_first_icustay

    END AS colloid_first_icustay,

    CASE

    WHEN crf.cryst_first_icustay IS NULL AND cof.colloid_first_icustay
    IS NULL THEN 0

    WHEN crf.cryst_first_icustay IS NULL AND cof.colloid_first_icustay
    IS NOT NULL THEN cof.colloid_first_icustay

    WHEN crf.cryst_first_icustay IS NOT NULL AND
    cof.colloid_first_icustay IS NULL THEN crf.cryst_first_icustay

    ELSE crf.cryst_first_icustay+cof.colloid_first_icustay

    END AS ivf_first_icustay,

    CASE

    WHEN pif.po_intake_first_icustay IS NULL THEN 0

    ELSE pif.po_intake_first_icustay

    END AS po_intake_first_icustay,

    CASE

    WHEN sf.stool_first_icustay IS NULL THEN 0

    ELSE sf.stool_first_icustay

    END AS stool_first_icustay,

    ROUND(tif.total_in_first_icustay,1) AS total_in_first_icustay,

    ROUND(tof.total_out_first_icustay,1) AS total_out_first_icustay,

    ROUND(ff.fluid_balance_first_icustay,1) AS
    fluid_balance_first_icustay,

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

    d.preadmit_bASe_cr,

    CASE

    WHEN iap.subject_id IS NULL THEN 'N'

    ELSE 'Y'

    END AS first_icu_day_vASopressor,

    CASE

    WHEN vc.icustay_id IS NULL THEN 'N'

    ELSE 'Y'

    END AS vASopressor_first_icustay,

    CASE

    WHEN mv.icustay_id IS NULL THEN 'N'

    ELSE 'Y'

    END AS mech_vent_first_icustay,

    ds.total_saps_first_icustay,

    ds.num_saps_scores_first_icustay,

    ds.peak_saps_first_icustay,

    ifa.code AS icd9_code_first_icustay,

    ifa.descriptiON AS icd9_descr_first_icustay,

    isa.code AS icd9_code_second_icustay,

    isa.descriptiON AS icd9_descr_second_icustay,

    CASE

    WHEN hdr.num_home_diuretics IS NULL THEN 'N'

    ELSE 'Y'

    END AS preadmit_med_section,

    CASE

    WHEN hdr.num_home_diuretics IS NULL THEN null

    WHEN hdr.num_home_diuretics>0 THEN 'Y'

    ELSE 'N'

    END AS preadmit_diuretics,

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

    FROM first_admissions r

    LEFT JOIN all_labs al ON r.subject_id=al.subject_id

    LEFT JOIN all_weight_height awh ON r.subject_id=awh.subject_id

    LEFT JOIN admit_hr_first_icustay ahf ON r.subject_id=ahf.subject_id

    LEFT JOIN admit_hr_second_icustay ahs ON
    r.subject_id=ahs.subject_id

    LEFT JOIN admit_map_first_icustay amf ON
    r.subject_id=amf.subject_id

    LEFT JOIN admit_map_second_icustay ams ON
    r.subject_id=ams.subject_id

    LEFT JOIN admit_bp_first_icustay abf ON r.subject_id=abf.subject_id

    LEFT JOIN admit_bp_second_icustay abs ON
    r.subject_id=abs.subject_id

    LEFT JOIN admit_temp_first_icustay atf ON
    r.subject_id=atf.subject_id

    LEFT JOIN admit_temp_second_icustay ats ON
    r.subject_id=ats.subject_id

    LEFT JOIN admit_o2sat_first_icustay aof ON
    r.subject_id=aof.subject_id

    LEFT JOIN admit_o2sat_second_icustay aos ON
    r.subject_id=aos.subject_id

    LEFT JOIN uo_first_icustay ufi ON r.subject_id=ufi.subject_id

    LEFT JOIN uo_first_icustay_24h ufi24 ON
    r.subject_id=ufi24.subject_id

    LEFT JOIN half_ns_first_icustay hnf ON r.subject_id=hnf.subject_id

    LEFT JOIN quarter_ns_first_icustay qnf ON
    r.subject_id=qnf.subject_id

    LEFT JOIN d5w_first_icustay dwf ON r.subject_id=dwf.subject_id

    LEFT JOIN cryst_first_icustay crf ON r.subject_id=crf.subject_id

    LEFT JOIN colloid_first_icustay cof ON r.subject_id=cof.subject_id

    LEFT JOIN pointake_first_icustay pif ON r.subject_id=pif.subject_id

    LEFT JOIN stool_first_icustay sf ON r.subject_id=sf.subject_id

    LEFT JOIN totalin_first_icustay tif ON r.subject_id=tif.subject_id

    LEFT JOIN totalout_first_icustay tof ON r.subject_id=tof.subject_id

    LEFT JOIN fluidbal_first_icustay ff ON r.subject_id=ff.subject_id

    LEFT JOIN icd9_first_admissiON ifa ON r.subject_id=ifa.subject_id

    LEFT JOIN icd9_second_admissiON isa ON r.subject_id=isa.subject_id

    LEFT JOIN mimic2devel.elixhauser_revised er ON
    r.first_hadm_id=er.hadm_id

    LEFT JOIN all_dialysis_data ad ON r.subject_id=ad.subject_id

    LEFT JOIN daily_saps ds ON r.subject_id=ds.subject_id

    LEFT JOIN joonlee.vASopressor_use_cohort vc ON
    r.first_icustay_id=vc.icustay_id

    LEFT JOIN mech_vent mv ON r.first_icustay_id=mv.icustay_id

    LEFT JOIN home_diuretics hdr ON r.subject_id=hdr.subject_id

    LEFT JOIN num_daily_cr_first_icustay ndc ON
    r.subject_id=ndc.subject_id

    LEFT JOIN joonlee.dialysis_manual_review_john d ON
    r.first_hadm_id=d.hadm_id

    LEFT JOIN icu_admit_pressors iap ON r.subject_id=iap.subject_id

    )

SELECT * 
FROM final_data;
