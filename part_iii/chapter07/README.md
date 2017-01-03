# 3.7 Comparative effectiveness: Propensity Score Analysis

This directory contains the code used in the following publication:

Chen K. *et al.* **Comparative effectiveness: Propensity Score Analysis**, in *Secondary analysis of Electronic Health Record Data*, Springer, [Under Review]

Code is provided in SQL, Matlab and R format.

## Summary of Publication

In this chapter, we use a case study conducted using the MIMIC-II database, “Efficacy of Rate Control Medications in Atrial Fibrillation with Rapid Ventricular Response (Afib with RVR) amongst Critically Ill Patients”, as an example to demonstrate the concepts of propensity score analysis in EHR data research. In this study we investigated which of the three most commonly used rate control agents performed best as a sole agent to reach rate control for patients with Afib with RVR.

## Replicating this Publication

The work presented in this case study can be replicated as follows:

* Patient Identification: the corresponding code is presented in Section 2.2.

* Calculation of time between onset of Atrial Fibrillation with RVR and RVR resolution : the corresponding code is presented (in truncated version) in Section 2.2. Please see the appendix for complete codes. _this isn't clear: which appendix?_

* `Afib_case_study_database_query.sql` : used to extract data from the MIMIC II database.

* `Afib_case_study_extraction_code.m` : used to extract variables for analysis.

* `propensity_score_analysis.r` : used for propensity score analysis.

* `propensity_score_matching.r` : used for propensity score matching.

* _additional codes are provided in `additional_codes.txt` - it's not clear whether or how these should be used_


***
Part of the wider **[Secondary Analysis of Electronic Health Records](https://github.com/MIT-LCP/critical-data-book)** book
***
