-- SQL  

-- The following SQL code is composed of separate small tables queried
-- FROM the main relational database(MIMIC-II) by the “SELECT-from-WHERE”
-- statements. Each small tables SELECT a sub-cohort by imposing conditions
-- IN the “WHERE” statement, i.e. narrowing down to the target study
-- population according to the study questions raised by clinicians. Each
-- small tables can interact WITH each other or the main tables IN the
-- database by being the source of the “from” statement.

-- The following query is a truncated version showing only key steps is
-- cohort SELECTion.

-- Get the first ICU stay of each adult by imposing conditions ON time
-- stamps of hospital admission or ICU admission, some structured
-- demographic data were also SELECTed

WITH first_admissions AS

    (SELECT icud.subject_id,
        icud.hadm_id AS first_hadm_id,
        icud.icustay_id AS first_icustay_id,
        icud.hospital_admit_dt AS first_hadm_admit_dt,
        icud.hospital_disch_dt AS first_hadm_disch_dt,
        icud.icustay_intime AS first_icustay_intime,
        icud.icustay_outtime AS first_icustay_outtime,
        extract(day FROM icud.icustay_intime-icud.hospital_admit_dt) AS days_btw_hosp_icu_admit,
        extract(day FROM icud.hospital_disch_dt-icud.icustay_outtime) AS days_btw_hosp_icu_disch,
        CASE WHEN LOWER(d.admission_source_descr) LIKE '%emergency%' THEN 'Y'
            ELSE 'N' END AS ED_admission,
        CASE WHEN icud.icustay_admit_age&gt;150 THEN 91.4
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
    WHERE icud.subject_icustay_seq=1 AND icud.icustay_age_group='adult'
    )

--SELECT * FROM first_admissions;

-- several covariates were SELECTed IN the following step. These
-- covariates can THEN be used IN the regression model for adjustment if
-- clinicians feel LIKE these covariates are possible confounders for the
-- study outcome. Besides using clinicians’ subjective judgment, there are
-- other objective methods to determine if a covariate is a possible
-- confounder, which is beyond the scope of this chapter.

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
             WHEN l.itemid=50370 THEN 'd-dimer' 
            END AS lab_type,
        first_value(l.value) over (partition by l.hadm_id, l.itemid ORDER by l.charttime) AS lab_value,
        first_value(l.charttime) over (partition by l.hadm_id ORDER BY l.charttime) AS icu_admit_lab_time
    FROM first_admissions r
    INNER JOIN mimic2v26.labevents l
    ON r.first_hadm_id=l.hadm_id
    AND l.itemid in (50090,50159,50655,50264,50277,50276,50177,50149,50083,50172,50383,50468,50140,50148,50079,50010,50018,50428,50060,50112,50399,50439,50440,50115,50134,50370)
    AND l.charttime BETWEEN r.first_icustay_intime - interval '12' hour
    AND r.first_icustay_intime + interval '12' hour
    )

--SELECT * FROM raw_icu_admit_labs ORDER by 1,2;

-- Get peak creatinine values FROM first ICU stays, This is an example
-- that certain variables, although stored AS structured data IN the
-- database, might require multiple conditions being imposed IN multiple
-- steps IN ORDER to SELECT the desired value that’s relevant to the study
-- question. For example, each patient would have multiple creatinine
-- values being measured during each ICU course. The study question might
-- call for the first available value or the highest numeric value for
-- research purpose.

, peak_creat_first_icustay AS

    (SELECT DISTINCT r.subject_id,
        COUNT(*) AS num_cr_first_icustay,
        MAX(l.valuenum) AS cr_peak_first_icustay
    FROM first_admissions r
    INNER JOIN mimic2v26.labevents l ON r.first_icustay_id=l.icustay_id AND l.itemid=50090
    GROUP BY r.subject_id
    )

--SELECT * FROM peak_creat_first_icustay;

-- Sometimes, the variable required by the study question does not exist
-- AS either structured or unstructured data, but rather AS a calculated
-- result of available data. One example would be “acute kidney injury(AKI)
-- stage by hourly urine output.” IN this CASE, it would require additional
-- algorithm to calculate hourly urine output AND determine if a patient
-- sustained AKI AND was IN what stage of the AKI. Using database language
-- LIKE SQL to compose these algorithms could be extremely complicated AND
-- buggy. We would recommEND using other interpreted language LIKE Matlab
-- to accomplish such task, AND using SQL to export filtered raw data for
-- further processing.

-- Total urine output during the first ICU stay

, uo_first_icustay AS

    (SELECT r.subject_id,
        SUM(ie.volume) AS urine_first_icustay
    FROM first_admissions r
    INNER JOIN mimic2v26.ioevents ie ON r.first_icustay_id=ie.icustay_id
    WHERE ie.itemid IN ( 651, 715, 55, 56, 57, 61, 65, 69, 85, 94, 96, 288, 405, 428, 473, 2042, 2068, 2111, 2119, 2130, 1922, 2810, 2859, 3053, 3462, 3519, 3175, 2366, 2463, 2507, 2510, 2592, 2676, 3966, 3987, 4132, 4253, 5927 )
    GROUP BY r.subject_id
    )

-- SELECT * FROM uo_first_icustay;

, uo_first_icustay_24h AS

    (SELECT r.subject_id,
        SUM(ie.volume) AS urine_first_icustay_24h
    FROM first_admissions r
    INNER JOIN mimic2v26.ioevents ie ON r.first_icustay_id=ie.icustay_id 
        AND ie.charttime BETWEEN r.first_icustay_intime 
        AND r.first_icustay_intime + interval '24' hour
    WHERE ie.itemid IN ( 651, 715, 55, 56, 57, 61, 65, 69, 85, 94, 96, 288, 405, 428, 473, 2042, 2068, 2111, 2119, 2130, 1922, 2810, 2859, 3053, 3462, 3519, 3175, 2366, 2463, 2507, 2510, 2592, 2676, 3966, 3987, 4132, 4253, 5927 )
    GROUP BY r.subject_id
    )

--SELECT * FROM uo_first_icustay_24h;

