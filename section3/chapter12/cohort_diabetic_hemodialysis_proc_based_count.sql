/******************************
**
** b.      Total number of diabetic patients who underwent hemodialysis based on procedure codes
*******************************/

SELECT COUNT(DISTINCT(PROCEDUREEVENTS.SUBJECT_ID))

FROM MIMIC2V30.ICD9  ICD9t1,
     MIMIC2V30.PROCEDUREEVENTS

WHERE ICD9t1.SUBJECT_ID = PROCEDUREEVENTS.SUBJECT_ID 
AND  lower(PROCEDUREEVENTS.LABEL) LIKE '%hemodial%' -- hemodialysis 
AND (ICD9t1.code LIKE '249%' -- Secondary diabetes mellitus
  OR ICD9t1.code LIKE '250%'  --  Diabetes mellitus
  )
AND CAST(ADMISSIONS.ADMIT_DT AS DATE) - D_PATIENTS.DOB > 18 * 365 -- patients aged 18 and older
;
