# 3.6 Trend Analysis: Evolution of tidal volume over time for patients receiving invasive mechanical ventilation

This directory contains the code and algorithms used in the following publication:

Mehta A. *et al.* **Trend Analysis: Evolution of tidal volume over time for patients receiving invasive mechanical ventilation**, in *Secondary analysis of Electronic Health Record Data*, Springer, [Under Review]

Code is provided in SAS format.

## Summary of Publication

Since the publication of the original landmark trial detailing the mortality benefits of low tidal volume ventilation among patients with the acute respiratory distress syndrome (non-cardiogenic pulmonary edema), epidemiological studies have demonstrated that tidal volumes used for mechanically ventilated patients in medical intensive care units have become lower over time. Because patients with heart failure (cardiogenic pulmonary edema) have been systematically excluded from studies investigating low tidal volume mechanical ventilation, the benefit of a low tidal volume strategy among cardiac patients is unclear. We sought to determine whether evidence supporting use of low tidal volumes in patients with non-cardiogenic edema has been generalized into the care of patients with cardiogenic pulmonary edema.

## Replicating this Publication

The work presented in this case study can be replicated as follows:

_ original files are required for the following code _

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
	
proc freq data=mimic.book;
where ccu=1;
table year*ccu/nocum nopercent norow nocol out=ccun; run;
proc freq data=mimic.book;
where micu=1;
table year*micu/nocum nopercent norow nocol out=micun; run;
proc freq data=mimic.allptsbook;
title 'Percent of MICU patients receiving invasive mechanical ventilation per Year';
where micu=1;
table year*mv/trend;
run;
proc freq data=mimic.allptsbook;
title 'Percent of CCU patients receiving invasive mechanical ventilation per Year';
where ccu=1;
table year*mv/trend;
run;
proc sort data=mimic.book;
by year; run;
proc means data=mimic.book maxdec=0 n mean std clm q1 median q3;
where ccu=1;
title 'Mean TV in CCU by Year';
by year;
var settvavg; run;
proc means data=mimic.book maxdec=0 n mean std clm q1 median q3;
where micu=1;
title 'Mean TV in MICU by Year';
by year;
var settvavg; run;
proc anova data=mimic.book;
title 'Comparing Mean TV in CCU by year';
where ccu=1;
class year;
model settvavg=year; run; quit;
proc anova data=mimic.book plots(maxpoints=10000);
title 'Comparing Mean TV in MICU by year';
where micu=1;
class year;
model settvavg=year; 
run; quit;

proc reg data=mimic.book;
where ccu=1;
title 'Set TV Regression in CCU';
model settvavg = year age female;
run; quit;

proc reg data=mimic.book;
title 'Set TV Regression in MICU';
where micu=1;
model settvavg = year age female;
run; quit;

proc glm data=mimic.book;
title 'Interaction of Unit On TV';
model settvavg = service year age female;
run; quit;

proc sort data=mimic.book;
by service; run;

proc ttest data=mimic.book;
title 'Compare TV by Service in 2002';
where year=2002;
class service;
var settvavg;
run;
proc ttest data=mimic.book;
title 'Compare TV by Service in 2003';
where year=2003;
class service;
var settvavg;
run;
proc ttest data=mimic.book;
title 'Compare TV by Service in 2004';
where year=2004;
class service;
var settvavg;
run;
proc ttest data=mimic.book;
title 'Compare TV by Service in 2005';
where year=2005;
class service;
var settvavg;
run;
proc ttest data=mimic.book;
title 'Compare TV by Service in 2006';
where year=2006;
class service;
var settvavg;
run;
proc ttest data=mimic.book;
title 'Compare TV by Service in 2007';
where year=2007;
class service;
var settvavg;
run;
proc ttest data=mimic.book;
title 'Compare TV by Service in 2008';
where year=2008;
class service;
var settvavg;
run;
proc ttest data=mimic.book;
title 'Compare TV by Service in 2009';
where year=2009;
class service;
var settvavg;
run;
proc ttest data=mimic.book;
title 'Compare TV by Service in 2010';
where year=2010;
class service;
var settvavg;
run;
proc ttest data=mimic.book;
title 'Compare TV by Service in 2011';
where year=2011;
class service;
var settvavg;
run;


***
Part of the wider **[Secondary Analysis of Electronic Health Records](https://github.com/MIT-LCP/critical-data-book)** book
***
