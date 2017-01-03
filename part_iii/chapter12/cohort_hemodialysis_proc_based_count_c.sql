/******************************
** Lists number of patients who underwent hemodialysis based on the procedure label
** Count in MIMIC-III = 1691
*******************************/

-- SELECT COUNT(DISTINCT(PROCEDUREEVENTS.SUBJECT_ID))
SELECT DISTINCT(PROCEDUREEVENTS.SUBJECT_ID)
FROM MIMIC2V30.ICD9  ICD9t1,
     MIMIC2V30.PROCEDUREEVENTS
WHERE ICD9t1.SUBJECT_ID = PROCEDUREEVENTS.SUBJECT_ID 
AND lower(PROCEDUREEVENTS.LABEL) LIKE '%hemodial%' -- hemodialysis 

-- Ensure that the patient was not admitted when he was younger than 18.
AND NOT EXISTS (
SELECT * 
FROM MIMIC2V30.ADMISSIONS adm18, MIMIC2V30.D_PATIENTS
WHERE adm18.SUBJECT_ID = ICD9t1.SUBJECT_ID
AND D_PATIENTS.SUBJECT_ID = adm18.SUBJECT_ID
AND CAST(adm18.ADMIT_DT AS DATE) - D_PATIENTS.DOB < 18 * 365 
)
ORDER BY PROCEDUREEVENTS.SUBJECT_ID ASC;