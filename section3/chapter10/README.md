# 3.10 Waveform Analysis to Estimate Respiratory Rate

This directory contains the code and algorithms used in the following publication:

Charlton P.H. *et al.* [**Waveform analysis to estimate respiratory rate**](http://peterhcharlton.github.io/RRest/waveform_analysis.html), in *Secondary analysis of Electronic Health Record Data*, Springer, [Under Review]

Code is provided for extraction of waveform data from the MIMIC II database in Matlab &reg; format. 
The algorithms for estimation of respiratory rate are also in Matlab &reg; format.

## Summary of Publication

Several techniques have been developed for estimation of respiratory rate (RR) from physiological waveforms.
This case study presents a comparison of exemplary techniques for estimation of RR from the electrocardiogram (ECG) and photoplethysmogram (PPG) waveforms.
Both the database and code used to evaluate the techniques are publicly available, equipping the reader with tools to develop and test their own RR algorithms for estimation of RR from physiological waveforms.

## Replicating this Publication

The work presented in this case study can be replicated as follows:

*   Download the code for the book from [here](https://github.com/MIT-LCP/critical-data-book/archive/master.zip). Extract the files by unzipping the directory. Navigate to the _section3/chapter10/_ directory.
*   Locate the [_MIMICII_data_importer.m_](https://raw.githubusercontent.com/peterhcharlton/RRest/master/RRest_v1.0/Data_Import_Scripts/MIMICII_data_importer.m) script contained within this directory. Modify the _universal parameters_ specified within this script (starting on line 64) to choose the directories where data should be stored.
*   Ensure that you have the WFDB Toolbox for Matlab installed. Installation instructions are available [here](https://physionet.org/physiotools/matlab/wfdb-app-matlab/).
*   Run this script to download data from the MIMIC II dataset. Note that the data will total XX GB, so this will require sufficient disk space and may take some time.
*   Perform the analysis using Version 1 of the _RRest_ toolbox of algorithms contained within this directory. To perform the analysis call the main script using the following command: *RRest('mimicii')*

## Further Resources

The accompanying [Wiki](https://github.com/peterhcharlton/RRest/wiki) acts as a user manual for the _RRest_ algorithms presented in this repository.

For those interested in estimating respiratory rate from physiological signals, the wider [Respiratory Rate Estimation project](http://peterhcharlton.github.io/RRest/), of which this is a part, will be of interest. It also contains additional material such as data to use with the algorithms, publications arising from the project, and details of how to contribute.


***
Part of the wider **[Secondary Analysis of Electronic Health Records](https://github.com/MIT-LCP/critical-data-book)** book
***
