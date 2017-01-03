-- SQL

CREATE TABLE aline_mimic_cohort_feb14 AS

WITH population AS
    (SELECT subject_id, hadm_id, icustay_id, icustay_intime
     FROM icustay_detail
     WHERE subject_icustay_seq=1
     AND icustay_age_group='adult'
     AND hadm_id IS NOT NULL
)

SELECT *
FROM population
