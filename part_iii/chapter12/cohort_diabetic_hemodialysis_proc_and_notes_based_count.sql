/******************************
**
** Total number of diabetic patients who underwent hemodialysis based on unstructured clinical notes and procedure codes
** Run time: 428 seconds
*******************************/

SELECT COUNT(DISTINCT(NOTEEVENTS.SUBJECT_ID))

FROM MIMIC2V30.ICD9  ICD9t1,
     MIMIC2V30.PROCEDUREEVENTS,
     MIMIC2V30.NOTEEVENTS

WHERE ICD9t1.SUBJECT_ID = PROCEDUREEVENTS.SUBJECT_ID 
AND NOTEEVENTS.SUBJECT_ID = PROCEDUREEVENTS.SUBJECT_ID 
AND NOTEEVENTS.CATEGORY NOT IN ('ECG_REPORT', 'ECHO_REPORT', 'RADIOLOGY_REPORT')
AND (LOWER(NOTEEVENTS.TEXT) LIKE ('%diabetes%') OR NOTEEVENTS.TEXT LIKE ('%DM%'))
AND (
     LOWER(NOTEEVENTS.TEXT) LIKE ('%hemodialysis%') 
  OR LOWER(NOTEEVENTS.TEXT) LIKE ('%haemodialysis%') 
  OR LOWER(NOTEEVENTS.TEXT) LIKE ('%kidney dialysis%') 
  OR LOWER(NOTEEVENTS.TEXT) LIKE ('%renal dialysis%') 
  OR LOWER(NOTEEVENTS.TEXT) LIKE ('%extracorporeal dialysis%') 
  OR NOTEEVENTS.TEXT LIKE ('%on HD%') 
  OR NOTEEVENTS.TEXT LIKE ('%HD today%') 
  OR NOTEEVENTS.TEXT LIKE ('%tunneled HD%') 
  OR NOTEEVENTS.TEXT LIKE ('%continue HD%') 
  OR NOTEEVENTS.TEXT LIKE ('%cont HD%')
)
AND  lower(PROCEDUREEVENTS.LABEL) LIKE '%hemodial%' -- hemodialysis 
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

;