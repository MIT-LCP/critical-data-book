# Section 2 chapter 3

*Note: the dataset (aline.mat) was not committed.*  

This file describes how to perform the different tests.  
  
There are two types of possibles tests:  
A. Performance comparison using logistic regressions  
B. Histograms of the age variable comparing all the imputation methods   
  
  
Note: Due to code both in Matlab and in R this approach can be a little cumbersome.   

Variable meaning:  
'univar' - univariate missingness (in just one variable)  
'multi'  - multivariate missingness (in all the variables except the output)  

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%  
%                  Test A - Performance  
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  
Follow each step to create the figures of the Missing data chapter:   
  
1. Add to the matlab path the folder named : "code"  
2. Open the function "pass2csv.m" and select the variable 'dataset' ('IAC' or 'NON_IAC') and  'type' of missingness ('univar' or 'multi') and run the file. Description: The file will create a folder called 'CSV' that will contain  all the data that is going to be used in R  
3. Open Rstudio (or R) and chose the the file "RcodeImputation_multivar" or 
"RcodeImputation_univar" to perform the multivariate or univariate missingness
4. Return to Matlab open the file 'main_missing_data_comparison' and 
add to the path the folder called "CSV". Select the 'dataset' and the 'type' of 
missingness.   
5. Open the 'main_missing_plots' select the 'dataset' and the 'type' of missingness
and run.  
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%  
%                  Test B  - Histograms (it only works for 'univar'  
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
  
Follow each step to create the figures of the Missing data chapter:  
  
1. Add to the matlab path the folder named : "code"  
2. Open the function "pass2csv.m" and select the variable 'dataset' ('IAC' or 'NON_IAC')  
and  'type' of missingness ('univar') and run the file. Description: The file will create a folder called 'CSV' that will contain all the data that is going to be used in R  
3. Open Rstudio (or R) and chose the the file "RcodeImputation_univar" to perform the univariate missingness  
4. Return to Matlab open the file 'main_data_histograms' and  add to the path the folder called "CSV". Select the 'dataset' and the 'type' of missingness.  
5. Open the 'make_histograms' select the 'dataset' and the 'type' of missingness and run.  
