# 3.6 Data Fusion Techniques for Early Warning of Clinical Deterioration

This directory contains the code and algorithms used in the following publication:

Charlton P.H. *et al.* **Data Fusion Techniques for Early Warning of Clinical Deterioration**, in *Secondary analysis of Electronic Health Record Data*, Springer, [Under Review]

Code is provided for extraction of physiological data from the MIMIC II database in SQL format. This is accompanied by algorithms for detection of deteriorations from this data in Matlab &reg; format.

## Summary of Publication

Algorithms for identification of deteriorating patients from electronic health records (EHRs) fuse vital sign data, which can be measured at the bedside, with additional physiological data from the EHR. It has been observed that these algorithms provide improved performance over traditional early warning scores (EWSs), which are restricted to the use of vital signs alone. This case study demonstrates the development of an algorithm which uses logistic regression to fuse vital signs with additional physiological parameters commonly found in an EHR to predict deterioration.

## Replicating this Publication

The work presented in this case study can be replicated as follows:

*   Extract data from the MIMIC II dataset using the SQL scripts provided <a href="https://github.com/peterhcharlton/detect/tree/master/MIMICII_Tutorial/data_extraction">here</a>.
*   Perform the analysis using the algorithms provided <a href="https://github.com/peterhcharlton/detect/tree/master/MIMICII_Tutorial/data_processing">here</a>. Call the main script using the following command: *RunFusionAnalysis*


***
Part of the wider **[Secondary Analysis of Electronic Health Records](https://github.com/MIT-LCP/critical-data-book)** book
***
