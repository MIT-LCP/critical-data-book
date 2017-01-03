# Chapter 18. Trend Analysis: Evolution of tidal volume over time for patients receiving invasive mechanical ventilation

This directory contains the code and algorithms used in the following publication:

Mehta A. *et al.* **Trend Analysis: Evolution of tidal volume over time for patients receiving invasive mechanical ventilation**, in *Secondary analysis of Electronic Health Record Data*, Springer, [Under Review]

Code is provided in SAS format.

## Summary of Publication

Since the publication of the original landmark trial detailing the mortality benefits of low tidal volume ventilation among patients with the acute respiratory distress syndrome (non-cardiogenic pulmonary edema), epidemiological studies have demonstrated that tidal volumes used for mechanically ventilated patients in medical intensive care units have become lower over time. Because patients with heart failure (cardiogenic pulmonary edema) have been systematically excluded from studies investigating low tidal volume mechanical ventilation, the benefit of a low tidal volume strategy among cardiac patients is unclear. We sought to determine whether evidence supporting use of low tidal volumes in patients with non-cardiogenic edema has been generalized into the care of patients with cardiogenic pulmonary edema.

## Replicating this Publication

The work presented in this case study can be replicated as follows:

_original files are required for the following code_

Procedure titles for SAS 9.4
*	Proc freq – frequency. Allows determination of count, percentage, or frequency of specific categorical variables.
*	chisq  - option that performs Chisq test between 2 categorical variables
*	trend – performs Cochrane Armitage test for trend
*	Proc sort – sorts database into ascending order by variable indicated
*	Proc means – calculates summary statistics such as mean, median, standard deviation, etc. for a continuous variable
*	Proc ANOVA – performs analysis of variance (ANOVA) test across several categories of a continuous variable
*	Proc reg – performs simple or multivariable linear regression models. Used when outcome/dependent variable is a continuous variable
*	Proc glm – general linearized model procedure
*	Proc ttest – performs Student t test either to a known value or compares means between 2 groups
	



***
Part of the wider **[Secondary Analysis of Electronic Health Records](https://github.com/MIT-LCP/critical-data-book)** book
***
