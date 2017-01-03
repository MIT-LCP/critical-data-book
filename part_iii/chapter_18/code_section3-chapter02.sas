proc freq data=mimic.book;
where ccu=1;
table year*ccu/nocum nopercent norow nocol out=ccun; 
run;

proc freq data=mimic.book;
where micu=1;
table year*micu/nocum nopercent norow nocol out=micun;
run;

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
by year; 
run;

proc means data=mimic.book maxdec=0 n mean std clm q1 median q3;
where ccu=1;
title 'Mean TV in CCU by Year';
by year;
var settvavg; 
run;

proc means data=mimic.book maxdec=0 n mean std clm q1 median q3;
where micu=1;
title 'Mean TV in MICU by Year';
by year;
var settvavg; 
run;

proc anova data=mimic.book;
title 'Comparing Mean TV in CCU by year';
where ccu=1;
class year;
model settvavg=year; 
run; 
quit;

proc anova data=mimic.book plots(maxpoints=10000);
title 'Comparing Mean TV in MICU by year';
where micu=1;
class year;
model settvavg=year; 
run; 
quit;

proc reg data=mimic.book;
where ccu=1;
title 'Set TV Regression in CCU';
model settvavg = year age female;
run; 
quit;

proc reg data=mimic.book;
title 'Set TV Regression in MICU';
where micu=1;
model settvavg = year age female;
run; 
quit;

proc glm data=mimic.book;
title 'Interaction of Unit On TV';
model settvavg = service year age female;
run; 
quit;

proc sort data=mimic.book;
by service; 
run;

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
