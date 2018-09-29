libname data 'C:\Users\Nancy Zhu\OneDrive - McGill University\Code for thesis';

PROC IMPORT OUT= DATA.CASE_FINAL 
            DATAFILE= "C:\Users\Nancy Zhu\OneDrive - McGill University\Code for thesis\Case_control_files\as_death2.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;


PROC IMPORT OUT= DATA.COMPLETE_SET 
            DATAFILE= "C:\Users\Nancy Zhu\OneDrive - McGill University\Code for thesis\Case_control_files\complete_as_death2.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

PROC contents data=data.case_final;
run;


PROC contents data=data.complete_set;
run;
data data.complete_set;
set data.complete_set;
entry_date2=input(entry_date,yymmdd10.);
exit_date2=input(exit_date,yymmdd10.) ;
format entry_date2 yymmdd10.
       exit_date2 yymmdd10.;
run;

proc print data=data.complete_set(OBS=20);
run;

data data.complete_set(drop=entry_date exit_date);
set data.complete_set;
rename entry_date2=entry_date
       exit_date2=exit_date;
run;

proc sort data=data.case_final;by nam;run;
data case;
set data.case_final;
by nam;
run;

proc sort data=data.complete_set;by nam;run;
data controls;
set data.complete_set;
by nam;
run;

proc sql;
 create table risk as
 select c.nam as caseid, t.nam as id,
        c.entry_date as centry_date,t.entry_date as tentry_date,
		c.exit_date as cexit_date, t.exit_date as texit_date,
		(t.age+(c.exit_date-c.entry_date)/365.25) as tageind,
		(c.age+(c.exit_date-c.entry_date)/365.25) as cageind,
		t.case as tcase,
        t.exit_date-t.entry_date as tfu,
        c.exit_date-c.entry_date as cfu
 from case as c, controls as t
 where (c.age+((c.exit_date-c.entry_date)/365.25)-1)<=(t.age+((c.exit_date-c.entry_date)/365.25))<=(c.age+((c.exit_date-c.entry_date)/365.25)+1)
		/* matching on age at index date */ 
        and ((c.exit_date-c.entry_date)-30)<=(t.exit_date-t.entry_date)<=((c.exit_date-c.entry_date)+30) /*matching follow up time*/ 
	   	and (t.exit_date-t.entry_date)>=(c.exit_date-c.entry_date) /* allowing controls to become cases later */
 order by c.nam, t.nam;
quit;

proc sort data=risk; by caseid; run;
proc contents data=risk;run;


/*Checking that matching on age,and same duration of follow-up and same index date criteria were fullfilled*/
data check1;
set risk;
cfu= round(cfu, 0.01);
tfu= round(tfu, 0.01);
agectrl=tage-cage;
fuctrl=(texit_date-tentry_date)-(cexit_date-centry_date);
fuctr=tfu-cfu;
run;

proc means data=check1 n nmiss min max;
run;

data allcases; 
set risk;
by caseid; /*caseid represents the riskset strata for each case */
 retain nb;
 if first.caseid then nb=0;
 if caseid ne id then nb=nb+1; /*i.e. if is a control*/
 if last.caseid then output; 
run;

proc freq data=allcases; table nb; where nb<=9; run;

proc univariate data=allcases; var nb;run;



proc surveyselect data=risk(where=(caseid ne id)) out=ctrlselect(drop=selectionprob samplingweight)
method=srs sampsize=10 seed=350243001
selectall;
strata caseid;
run;

/* Creating case-control dataset matched follow-up, age at index date*/
data ccami;
set risk(where=(caseid=id)) ctrlselect;
by caseid;
if caseid=id then status=1; else status=0;
run;

proc sort data=ccami; by caseid id; run;
proc freq data=ccami; tables status; run;

data controlnb;
set ccami;
by caseid;
retain nb;
 if first.caseid then nb=0;
 if caseid ne id then nb=nb+1;
 if last.caseid then output; 
run;

data data.ramq_cc;
merge ccami controlnb(keep=caseid nb);
by caseid;
if nb>0;
drop nb;
run;

proc freq data=data.ramq_cc; tables status; run;
proc freq data=data.ramq_cc; table nb; where nb<=9; run;

