/******************************
** List of diabetic patients based on the ICD-9 codes
** Count in MIMIC-III = 10494
*******************************/

-- SELECT COUNT(DISTINCT(ADMISSIONS.SUBJECT_ID))
SELECT DISTINCT(ADMISSIONS.SUBJECT_ID)
FROM MIMIC2V30.ICD9  ICD9t1,
     MIMIC2V30.ADMISSIONS
WHERE ICD9t1.SUBJECT_ID = ADMISSIONS.SUBJECT_ID 
AND (ICD9t1.code LIKE '249%' -- Secondary diabetes mellitus
  OR ICD9t1.code LIKE '250%'  --  Diabetes mellitus
  )
  
-- Ensure that the patient was not admitted when he was younger than 18.
AND NOT EXISTS (
SELECT * 
FROM MIMIC2V30.ADMISSIONS adm18, MIMIC2V30.D_PATIENTS
WHERE adm18.SUBJECT_ID = ICD9t1.SUBJECT_ID
AND D_PATIENTS.SUBJECT_ID = adm18.SUBJECT_ID
AND CAST(adm18.ADMIT_DT AS DATE) - D_PATIENTS.DOB < 18 * 365 
)
ORDER BY ADMISSIONS.SUBJECT_ID ASC;