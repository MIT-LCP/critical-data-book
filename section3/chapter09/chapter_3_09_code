/** Code by Yijun Yang **/
PROC IMPORT OUT= WORK.bpdata
        	DATAFILE= "C:\Users\user\aki_data.xls"
        	DBMS=EXCEL REPLACE;
 	RANGE="'Export Worksheet$'";
 	GETNAMES=YES;
 	MIXED=NO;
 	SCANTEXT=YES;
 	USEDATE=YES;
 	SCANTIME=YES;
RUN;

data case;
 set bpdata;
 eid=icustay_id; mv=mv_case_flg; vaso=vaso_case_flg; hr=hr_case; t=t_case; spo2=spo2_case; wbc=wbc_case;
 creatinine=creatinine_case; mbp1=case_mbp_1hr; mbp2=case_mbp_2hr; mbp3=case_mbp_3hr; mbpmin=case_min_mbp;
 case=1;
 keep eid case mv vaso hr t spo2 wbc creatinine mbp1 mbp2 mbp3 mbpmin;
 run;

 data control;
 set bpdata;
 eid=icustay_id; mv=mv_control_flg; vaso=vaso_control_flg; hr=hr_control; t=t_control; spo2=spo2_control; wbc=wbc_control;
 creatinine=creatinine_control; mbp1=control_mbp_1hr; mbp2=control_mbp_2hr;   mbp3=control_mbp_3hr; mbpmin=control_min_mbp;
 case=0;
 keep eid case mv vaso hr t spo2 wbc creatinine mbp1 mbp2 mbp3 mbpmin;
 run;

   	/**conditional logistic regression with multiple covariates**/
  PROC LOGISTIC data=co descending;
  MODEL case = mv vaso hr spo2 wbc creatinine mbpmin ;
  STRATA eid;
  run;
    	/**univariate conditional logistic regression**/
  PROC LOGISTIC data=co descending;
  MODEL case = mbpmin ;
  STRATA eid;
  run;
