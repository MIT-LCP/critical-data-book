# Chapter 28. Improving Patient Cohort Identification Using Natural Language Processing

This directory contains the code and algorithms used in the following publication:

Sarmiento R.F. and Dernoncourt F. **Improving Patient Cohort Identification Using Natural Language Processing
**, in *Secondary analysis of Electronic Health Record Data*, Springer, [Under Review]

Code is provided in SQL format.


## Summary of Publication

Retrieving information from structured data tables in a large database may be performed with little to no difficulty, but structured data may not always contain all that is needed to retrieve accurate information compared to narratives from clinical notes. The large volume of clinical notes, however, requires special processing to access the information contained in their unstructured format. In this case study, we present a comparison of two techniques (structured data extraction and natural language processing) and we evaluate their utility in identifying a specific patient cohort from a large clinical database.

## Replicating this Publication

All the SQL queries to count the number of patients per cohorts as well as the cTAKES XML configuration file used to analyze the notes are provided. Specifically:

* `cohort_diabetic_hemodialysis_icd9_based_count.sql` : Total number of diabetic patients who underwent hemodialysis based on diagnosis codes.

* `cohort_diabetic_hemodialysis_notes_based_count.sql` : List of diabetic patients who underwent hemodialysis based on unstructured clinical notes.

* `cohort_diabetic_hemodialysis_proc_and_notes_based_count.sql` : Total number of diabetic patients who underwent hemodialysis based on unstructured clinical notes and procedure codes.

* `cohort_diabetic_hemodialysis_proc_based_count.sql` : Total number of diabetic patients who underwent hemodialysis based on procedure codes.

* `cohort_diabetic_icd9_based_count_a.sql` : List of diabetic patients based on the ICD-9 codes.

* `cohort_hemodialysis_icd9_based_count_b.sql` : List of patients who underwent hemodialysis based on the ICD-9 codes.

* `cohort_hemodialysis_proc_based_count_c.sql` : Lists number of patients who underwent hemodialysis based on the procedure label.

* `CPE_physician_notes.xml` : cTAKES XML configuration file to process patients' notes. Some paths need to be adapted to the developer's configuration.

* _Python script needs uploading_


***
Part of the wider **[Secondary Analysis of Electronic Health Records](https://github.com/MIT-LCP/critical-data-book)** book
***
