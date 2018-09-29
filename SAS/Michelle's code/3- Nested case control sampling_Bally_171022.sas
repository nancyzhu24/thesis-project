%put &sysdate9;
%let temps1=%sysfunc(time());
/********************************************************************************************************
* AUTHOR:		Michele Bally (based on Linda Levesque and Sophie Dell'Aniello								*
* CREATED:		July 10, 2014																			*
* UPDATED:																								*
* TITLE:	    NCC sampling_AMI NSAIDs_NCC IPD MA and WCE_RAMQ9304										*
* OBJECTIVE:	Perform nested case-control sampling of base cohort for analysis of RAMQ				*
*				for various analyses: 1) as single study, 2) for inclusion in an individual				*
*				patient data meta-analysis (IPD MA) and 3) for a recency-weighted cumulative exposure	*
* 				(WCE) analysis																			*
*				Using a RAMQ cohort of new NSAID users (no NSAID use in year prior to cohort entry)		*
*				for the time period from 01JAN1993 to 30SEP2004											*
*				Defining case control risk set for AMI outcome											*
*				Controls are matched to cases (10:1) on year and month of cohort entry,					*
*				on age and on gender and are assigned cases' index date (same duration of follow-up)	*
*				Mostly elderly population but age not restricted										*
* PROJECT:		Create RAMQ datasets for re-examining recency, dose, and duration effects of	   		*
*				NSAID exposures on the risk of acute myocardial infarction for all PhD thesis work		*
********************************************************************************************************/



libname data 'C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\NSAIDs2\raw data';
libname ami 'C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami';
libname tables 'C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables';
libname wce 'E:\Michele.Bally\wce';

/* Raw data */
proc contents data=data.admis;run;
proc contents data=data.deces;run;
proc contents data=data.demo;run;
proc contents data=data.hosp;run;
proc contents data=data.rx_x;run;
proc contents data=data.medserv;run;


/* Datasets created for the project */
proc sort data= ami.ramq_basecoh9304; by id; run; * Program Base cohort_AMI NSAIDs_NCC IPD MA and WCE__RAMQ9304;
proc sort data= ami.ramq_coh_ami9304;by id;run; * Program Outcome_AMI NSAIDs_NCC IPD MA and WCE_RAMQ9304;

proc contents data= ami.ramq_basecoh9304; run;
proc contents data= ami.ramq_coh_ami9304; run;

proc freq data=ami.ramq_coh_ami9304; table outcome; run;
21308 AMI OK;


/*****************************
* Case and Controls Datasets *
*****************************/
/*Create 'case' dataset, which contains all AMI event cases and variables needed for matching*/
* From Lévesque 2005, "The index date of each case-patient was used to define the risk sets from which controls were chosen. For each case-patient, we randomly
selected 20 controls matched on month and year of cohort entry and age (+ or - 1 year) and assigned them the case-patient’s index date. Consequently, follow-up time
was identical for case-patients and controls within each risk set."
* From Brophy 2007, "For each case-defining event, up to 20 controls, matched by month and year of cohort entry and age (+ or -1 year),
were randomly selected from the case’s risk set and assigned the same index date.";
* For IPD MA matching is on time in cohort, month and year of cohort entry, age, and gender.
Investigation of interactions in a previous dataset not matched for age or gender indicated  no interaction
with gender and inconclusive evidence of interaction with age (due to categorization of the NSAID exposure and
residual confounding?). 
Matching on age allows not having to define best functional form as FP2 for age. 
10 controls are selected and assigned the case’s index date. Consequently, follow-up time will be was identical for 
cases and controls within each risk set;


data case;
set ami.ramq_coh_ami9304(where=(outcome=1));/*outcome is AMI*/ 
by id; 
keep id outcome t0 t0mth t0yr aget0 male amidate tout FU;
/*amidate is date of AMI, tout is earliest of AMI admission date or cohort exit date*/  
run;

/*Create 'controls' dataset as all cohort members (incl. cases since individuals can be controls before they become a case) and matching variables*/
data controls;
set ami.ramq_coh_ami9304;
by id;
keep id outcome t0 t0mth t0yr aget0 male amidate tout FU;
run;

/* Cases and their matched controls */
proc sql;
 create table risk as
 select c.id as caseid, t.id as id,
		c.t0 as ct0, t.t0 as tt0,
		c.t0yr as ct0yr, t.t0yr as tt0yr, 
		c.t0mth as ct0mth, t.t0mth as tt0mth,
		c.tout as cindex, t.tout as ttout,
		t.t0+(c.tout-c.t0) as tindex format=date9.,/*assigning to controls same index date as cases*/
		c.aget0 as caget0, t.aget0 as taget0,
		(t.aget0+(c.tout-c.t0)/365.25) as tageind,/*creating age at index date from cases' index date*/
		(c.aget0+(c.tout-c.t0)/365.25) as cageind,
		c.male as cmale, t.male as tmale,
		t.outcome as toutcome, 
		(c.tout-c.t0)/365.25 as cfup, (t.tout-t.t0)/365.25 as tfup 
 from case as c, controls as t
 where (c.aget0+((c.tout-c.t0)/365.25)-1)<=(t.aget0+((c.tout-c.t0)/365.25))<=(c.aget0+((c.tout-c.t0)/365.25)+1)
		/* matching on age at index date */ 
        and c.male=t.male
		and t.t0yr=c.t0yr /*matching for year of cohort entry*/ 
		and t.t0mth=c.t0mth  /*matching for month of cohort entry*/
	   	and (t.tout-t.t0)>=(c.tout-c.t0) /* allowing controls to become cases later */
 order by c.id, t.id;
quit;

proc sort data=risk; by caseid; run;

proc contents data=risk; run;

/*Checking that matching on age, gender and same duration of follow-up and same index date criteria were fullfilled*/
data check1;
set risk;
cfu= round(cfup, 0.01);
tfu= round(tfup, 0.01);
agectrl=(taget0+(cindex-ct0))-(caget0+(cindex-ct0));
ageindxctrl=tageind-cageind;
malectrl=tmale-cmale;
t0yrctrl=tt0yr-ct0yr;
t0mthctrl=tt0mth-ct0mth;
fuctrl=((ttout-tt0)-(cindex-ct0))/365.25;
fuctr=tfu-cfu;
run;

proc means data=check1 n nmiss min max;
var agectrl ageindxctrl malectrl t0yrctrl t0mthctrl fuctrl fuctr;
run;
/* t0yr and t0mth differences are 0, age difference is 0 and follow-up time difference is min=0,
max=11.7 yrs*/

/* Removing controls that may be cases the same day */
data riskset;
set risk;
if caseid ne id and tindex=ttout and toutcome=1 then delete; *control is a case the same day;
run; 
* 154 controls were cases on the same day;

/*Check to see how many controls in the riskset were cases on the same day*/
data check2;
set risk;
if caseid ne id and tindex=ttout and toutcome=1 then numc_as_t=1; else numc_as_t=0;
run;

* Also did manual check on numc_as_t=1 that tindex=ttout and toutcome=1;
proc freq data=check2; table toutcome numc_as_t;run;
* 154 controls were cases on the same day; 

data check3 (keep= caseid id cindex ttout tindex); 
set check2; if numc_as_t=1;
run;
* Manually checked that the cases posing as controls in risksets are represented in the case dataset;

/* Confirm number of risksets */
data allcases; 
set riskset;
by caseid; /*caseid represents the riskset strata for each case */
 retain nb;
 if first.caseid then nb=0;
 if caseid ne id then nb=nb+1; /*i.e. if is a control*/
 if last.caseid then output; 
run;
* OK, there are 21308 risksets;

/* Obtain pattern of number of observations per riskset */
proc freq data=allcases; table nb; where nb<=9; run;
* 52 riskets with fewer than 10 controls per riskset;
proc univariate data=allcases; var nb;run;
* min 0 obs and max 1230 of obs per riskset;

/**************************************
* Selecting Controls from the Riskset *
**************************************/

/*Procedure to randomly select controls from a given dataset*/
*** NB: Unlike for Brophy 2007, which has 20 controls per case, selected 10 controls per case;
proc surveyselect data=riskset(where=(caseid ne id)) out=ctrlselect(drop=selectionprob samplingweight)
method=srs sampsize=10 seed=350243001; 
*selectall; /* method "srs" = simple random sampling*/
strata caseid;
run;
* 52 riskets where cannot sample 10 controls (21308-52= 21256)
*  233816 observations and 20 variables.
* Total subject= 233816
* Number of strata (cases)=  21256
* Number of controls= 		212560
* New seed= (date); 
* Old seed= (date);
/*Remove comment "selectall" as it would take all controls if less than specified by samplesize*/

/* Creating case-control dataset matched on t0 month, t0 year, follow-up, age at index date, and gender */
data ccami;
set riskset(where=(caseid=id)) ctrlselect;
by caseid;
if caseid=id then ami=1; else ami=0;
rename tindex=index;
cageindex= round(cageind);
tageindex= round(tageind); 
run;

proc sort data=ccami; by caseid id; run;
proc freq data=ccami; tables ami; run;
* 21308 AMI;

/* Check that case-control criteria are met */
data check3;
set ccami;
ageindxctrl=tageind-cageind;
malectrl=tmale-cmale;
t0yrctrl=tt0yr-ct0yr;
t0mthctrl=tt0mth-ct0mth;
fuctrl=((index-tt0)-(cindex-ct0))/365.25;
run;

proc means data=check3 n nmiss min max;
var fuctrl ageindxctrl malectrl t0yrctrl t0mthctrl;
run;
* Difference in t0 is 0 and FU difference from t0 to index date is 0, difference for male is 0,
difference for age is between -1 and +1, therefore matching was successful;

/* Check that everything is fine with the variables dates of outcome*/
data check4;
set ccami;
ageindxctrl=tageind-cageind;
t0yrctrl=tt0yr-ct0yr;
fuctrl=((ttout-tt0)-(cindex-ct0))/365.25;* difference between control's and case's follow-up=needs to be positive;
run;

proc means data=check4 n nmiss min max;
var ageindxctrl t0yrctrl fuctrl;
run;
* Difference for age is 0, for t0 is 0 and for FU range from 0 to 11.7 yrs indicating where 
control used becomes a case in the future;

/* Taking out cases without controls */
proc sort data=ccami; by caseid id; run;
data controlnb;
set ccami;
by caseid;
retain nb;
 if first.caseid then nb=0;
 if caseid ne id then nb=nb+1;
 if last.caseid then output; 
run;

proc freq data=controlnb; table nb; run;
proc univariate data=controlnb; var nb; run;
* 52 riskets have fewer than 10 controls;

proc sort data=controlnb; by caseid; run;

data ramq_cc;
merge ccami controlnb(keep=caseid nb);
by caseid;
if nb>0;
drop nb;
run;

proc freq data=ramq_cc; tables ami; run;
* N=21256 AMI cases + 212560 controls;


/******************************************************************************************
CREATING PERMANENT DATASET FOR AMI CASE-CONTROL DATASET MATCHED ON t0 and FOLLOW-UP 
******************************************************************************************/

proc contents data=ramq_cc; run;

* Check again that matching conditions are met;
data final_ramq_cc
(keep= id caseid ami ct0 cindex tt0 index ttout fuctrl cmale tmale malectrl cageindex tageindex ageindxctrl ct0yr tt0yr t0yrctrl tt0mth ct0mth t0mthctrl);
set ramq_cc;
ageindxctrl=tageindex-cageindex;
malectrl=tmale-cmale;
t0yrctrl=tt0yr-ct0yr;
t0mthctrl=tt0mth-ct0mth;
fuctrl=((index-tt0)-(cindex-ct0));
run;

ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Test matching NCC sampling.rtf' style=analysis;
title1 'RAMQ nested case control dataset for individual patient data meta-analysis and recency-weighted cumulative exposure analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'Check matching for duration in cohort (fuctrl), gender (malectrl), age (ageindxctrl), year and month of cohort entry (t0yrctrl t0mthctrl)';
proc print data=final_ramq_cc (obs=33);run;
options nodate nonumber;
run;
ods rtf close;

* Finalize dataset;
data ramq_match_cc9304verif (keep=caseid id ami ct0 tt0 ttout cmale tmale cageindex tageindex cindex index); 
retain caseid id ami ct0 tt0 ttout cmale tmale cageindex tageindex cindex index ttout;  
set final_ramq_cc;
run;

data ramq_match_cc9304rename (drop=ct0 cindex cmale cageindex);
rename tt0=t0 ttout=tout index=indexdate tmale=male tageindex=ageindex;
set ramq_match_cc9304verif; 
run;

data ami.ramq_NCC_cc9304; 
retain caseid id ami t0 indexdate male ageindex; 
set ramq_match_cc9304rename; 
run;

proc freq data=ami.ramq_NCC_cc9304; tables ami; run;
* n=21256 AMI cases;

proc sort data=ami.ramq_NCC_cc9304; by caseid id; run;

/* Duration of follow-up */
data duration;
set ami.ramq_NCC_cc9304;
dur=(tout-t0)/365.25;
run;

proc means data=duration N MEAN STD MIN Q1 MEDIAN Q3 MAX; var dur;run;
* N Mean Std Dev Minimum Lower Quartile Median Upper Quartile Maximum 
233816 6.9910936 3.0594369 0.0027379 4.5256674 7.1074606 9.7796030 11.7453799;


/* Back calculate age at t0 */
data age;
set ami.ramq_NCC_cc9304;
dur=(tout-t0)/365.25;
aget0=ageindex-dur;
run;

proc means data=age N MEAN STD MIN Q1 MEDIAN Q3 MAX; var aget0;run;
proc freq data=age; tables aget0; run;
