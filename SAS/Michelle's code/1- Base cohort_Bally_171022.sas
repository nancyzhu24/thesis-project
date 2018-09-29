%put &sysdate9;
%let temps1=%sysfunc(time());

/********************************************************************************************************
* AUTHOR:	 	Michele Bally (based on Linda Levesque and Sophie Dell'Aniello)								*
* CREATED:	 	July 10, 2014																			*
* UPDATED:   																						*																									*
* TITLE:	 	Base cohort_AMI NSAIDs_NCC IPD MA and WCE__RAMQ9304										*
* OBJECTIVE:	Create base cohort for analysis of RAMQ via a nested case-control sampling				*
*				for various analyses: 1) as single study, 2) for inclusion in an individual patient		*
*				data meta-analysis (IPD MA) and 3)for a recency-weighted cumulative exposure			*
*				(WCE) analysis																		 	*
* 				Using a RAMQ cohort of new NSAID users (no NSAID use in year prior to cohort entry)		*
*				for the time period from 01JAN1993 to 30SEP2004											*
*				Mostly elderly population but age not restricted										*
* PROJECT:		Create RAMQ datasets for re-examining recency, dose, and duration effects of		    *
*				NSAID exposures on the risk of acute myocardial infarction for all PhD thesis work		*
********************************************************************************************************/

libname data 'C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\NSAIDs2\raw data';
libname ami 'C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami';
libname tables 'C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables';
libname wce 'E:\Michele.Bally\wce';

/* Raw data */
proc contents data=data.admis;
proc contents data=data.demo;
proc contents data=data.deces;
proc contents data=data.hosp;
proc contents data=data.medserv;
proc contents data=data.rx_x;
run;
* in data.demo, agedex and sex are char vars

/* Sort and determine minimum and maximum for date variables;
proc sort data=data.admis; by id; run;
proc sql;
select max(entry) as max_date format=date9., min(entry) as min_date format=date9.
from data.admis;
quit;
* variable entry (date of admission in fichiers RAMQ) ranges from 01JAN1980 to 01FEV2005;

proc sort data=data.demo; by id; run;
proc sql;
select max(firstrx) as max_date format=date9., min(firstrx) as min_date format=date9.
from data.demo;
quit;
* variable firstrx (date of first NSAID prescription) ranges from 01JAN1997 to 31MAR2005;

proc sort data=data.deces; by id; run;
proc sql;
select max(datedc) as max_date format=date9., min(datedc) as min_date format=date9.
from data.deces;
quit;
* variable datedc (death) ranges from 30JUL1992 to 31MAR2005;

proc sort data=data.hosp; by id; run;
proc sql;
select max(admit) as max_date format=date9., min(admit) as min_date format=date9.
from data.hosp;
quit;
* variable admit ranges from 01JAN1992 to 31MAR2005;

proc sort data=data.medserv; by id; run;
proc sql;
select max(date) as max_date format=date9., min(date) as min_date format=date9. 
from data.medserv;
quit;
* variable date ranges from 01JAN1992 to 31MAR2005;


proc sort data=data.medserv; by id; run;
proc sql;
select max(date) as max_date format=date9., min(date) as min_date format=date9. 
from data.medserv;
quit;
* variable date ranges from 01JAN1992 to 31MAR2005;

proc sort data=data.rx_x; by id; run;
proc sql;
select max(datserv) as max_date format=date9., min(datserv) as min_date format=date9.
from data.rx_x;
quit;
* variable datserv ranges from 01JAN1992 to 31MAR2005;

/************************
* Creation of Cohort    *
************************/

/* Obtaining all NSAID Rx dispensed */
data wce.zero;
merge data.admis(keep=id sortie) data.deces(keep=id datedc) data.rx_x(keep=id dencom datserv forme dosge durtxt qtmed)
data.demo(keep=id firstrx agedex); 
* 'firstrx', which is in RAMQ demo file was created by L. Lévesque
and is date of first NSAID prescription Rx after 01JAN1997; 
* agedex is age at first NSAID Rx after 01JAN1997;
by id;
run;


/* For NSAID IPD MA and for RAMQ re-analysis start cohort recruitment on 01JAN1993. End of cohort recruitment is 30MAR2004 so as to allow
at least 6 months of follow-up time in cohort (as per Brophy 2007) and for study to end no later than 30SEP2004 (date of rofecoxib
market withdrawal and possible broader awareness of its cardiotoxicity);

/* Did not include ASA as cohort entry is defined by an NSAID prescription */
* Although they are listed by RAMQ and needed to reproduce Brophy 2007, did not include ketorolac (46006,47066) and salsalate (47107,46208);
* Moreover, did not include phenylbutazone (07642) as use denotes a niche indication or atypical practice;

data wce.one;
 set wce.zero;
if '01Jan93'd<=datserv<=min(sortie,datedc,mdy(03,31,2004)) and dencom in (/*naproxen*/19752,46152,46335,46626 /*ibuprofen*/,04745,46654 
/*diclofenac*/,41694,46154,47059,47078 /*celecoxib*/,46546,47327 /*rofecoxib*/,46596,47346 /*diflunisal*/,43150 /*etodolac*/,47122,46256
/*fenoprofen*/,33803 /*flurbiprofen*/,44749,45514 /*ketoprofen*/,38691 /*indomethacin*/,04810 /*mefenamic acid*/,44359 /*meloxicam*/,47385
/*nabumetone*/,47084,46228/*piroxicam*/,42019,46820,46638 /*sulindac*/,40381 /*tenoxicam*/,45592 /*tiaprofenic acid*/,45407
/*tolmetin sodium*/,37664,46629); 
* Keeping the 5 NSAIDs of interest i.e. naproxen, ibuprofen, diclofenac, celecoxib, and rofecoxib plus other NSAIDs
(which will be grouped as "other")
* Composition of "other" NSAIDs group determined based on additional individual NSAIDs included in the other datasets and for which
info is available (etoricoxib and valdecoxib not marketed in CDN)
* In addition to the 5 NSAIDs of interest, other NSAIDs in the Finland dataset (Helin-Salmivaara 2006) are: aceclofenac, etodolac,
indomethacin, ketoprofen, mefenamic acid, meloxicam, nabumetone, nimesulide, piroxicam, tenoxicam, tiaprofenic acid, and tolfenamic acid 
* Other NSAIDs in the Sask dataset (not described in Varas-Lorenzo 2009 but info available in Sask data files) are: 
diflunisal, etodolac, fenoprofen, flurbiprofen, indomethacin, ketoprofen, mefenamic acid, nabumetone, phenylbutazone, piroxicam, 
sulindac, tiaprofenic acid, and tolmetin
* Other NSAIDs in the GPRD dataset (Andersohn 2006)are: etoricoxib, valdecoxib. Note that "other" NSAIDs category is not described
in publication and further information is not available
/*NB: Checked against dencom file 'Dénomination communes au 2006-02-20', making sure to include code for drug name
when 'e' is written instead of 'é'and when 'en' was used instead of 'ène'*/;
if forme in (/*solution ophtalmique*/02204, /*solution ophtalmique et otique*/02233)then delete;
/* length drug $ 10.;
 if dencom in (19752,46152,46335,46626) then drug='nap';
 if dencom in (04745,46654) then drug='ibu';
 if dencom in (41694,46154,47059,47078)then drug='dic';
 if dencom in (46546,47327) then drug='cel';
 if dencom in (46596,47346) then drug='rof';
 if dencom in (43150,47122,46256,33803,44749,45514,38691,04810,44359,47385,47084,46228,
42019,46820,46638,40381,45592,45407,37664,46629) then drug='other';*/
run;

/* Determining subjects' cohort entry (t0) using date of first NSAID Rx dispensed after 1 January 1993
(cohort entry=date of first Rx) */
proc sort data=wce.one; by id datserv; run;

data wce.two;
 set wce.one; by id; /*order dataset by id, needed when making use of order in later programs*/
 if first.id; /* by taking first subject automatically takes first Rx date since ordered by both variables */
 t0yr = year(datserv); /* defining year of cohort entry */
 t0mth = month(datserv); /* defining month of cohort entry */
 dateserv=datserv;
 format dateserv date9.;
 * rename dateserv=t0;  /* cannot use renamed variable (e.g. t0) in this datastep; variable must exist already*/
 t0=dateserv;
 format t0 date9.;
run;

* t0 not to be confused with variable 'firstrx', which is in RAMQ demo file was created by L. Lévesque and is date of first NSAID prescription (gives age at date 
 of that first NSAID Rx after 01JAN1997 since RAMQ demo file starts in 1997 not in 1992; 
* Age at t0 needs to be re-calculated, using variable agedex, which is age at first
NSAID Rx (see data step below); 

 proc sort data=wce.two nodup; by id t0; run; 
* 0 duplicate observations;

/* Check that subjects' cohort entry (t0) using date of first NSAID Rx respect set dates for cohort entry */
proc sql;
select max(datserv) as max_date format=date9., min(datserv) as min_date format=date9. 
from wce.two;
quit;
* Variable 'datserv' is between 1JAN1993 and 31MAR2004;

/**************************************
* Applying Cohort Exclusion Criteria  *
**************************************/

/* Excluding subjects using NSAIDs in the year prior to cohort entry */

* pnsaids exclusion = to get info about NSAID use in the yr prior to cohort entry;
data wce.minusone;
set wce.zero; *note: need the year before 1993;
if '01Jan92'd<=datserv<=min(sortie,datedc,mdy(03,31,2004))and dencom in (/*naproxen*/19752,46152,46335,46626
/*ibuprofen*/,04745,46654 /*diclofenac*/,41694,46154,47059,47078 /*celecoxib*/,46546,47327 /*rofecoxib*/,46596,47346 
/*diflunisal*/,43150 /*etodolac*/,47122,46256 /*fenoprofen*/,33803 /*flurbiprofen*/,44749,45514 
/*ketoprofen*/,38691 /*indomethacin*/,04810 /*mefenamic acid*/,44359 /*meloxicam*/,47385/*nabumetone*/,47084,46228
/*piroxicam*/,42019,46820,46638 /*sulindac*/,40381 /*tenoxicam*/,45592 /*tiaprofenic acid*/,45407
/*tolmetin sodium*/,37664,46629 /*phenylbutazone*/,07642 /*salsalate*/,46208,47107) and forme not in (/*solution ophtalmique*/02204 /*solution ophtalmique et otique*/02233);
* keeping the 5 NSAIDs of interest i.e. naproxen, ibuprofen, diclofenac, celecoxib, and rofecoxib plus the group of 'other' NSAIDs;
 if forme in (/*solution ophtalmique*/02204, /*solution ophtalmique et otique*/02233) then delete;
/* length drug $ 10.;
 if dencom in (19752,46152,46335,46626) then drug='nap';
 if dencom in (04745,46654) then drug='ibu';
 if dencom in (41694,46154,47059,47078)then drug='dic';
 if dencom in (46546,47327) then drug='cel';
 if dencom in (46596,47346) then drug='rof';
 if dencom in (43150,47122,46256,33803,44749,45514,38691,04810,44359,47385,47084,46228,
 42019,46820,46638,40381,45592,45407,37664,46629,07642 /*phenylbutazone,46208,47107 /*salsalate*) then drug='other';*/
run;

/* Check that NSAID Rx may precede study start by one year */
proc sql;
select max(datserv) as max_date format=date9., min(datserv) as min_date format=date9. 
from wce.minusone;
quit;
* Variable 'datserv' is between 1JAN1992 and 31MAR2004;

* Check for missing values on datserv;
proc freq data=wce.minusone; tables datserv; missing; run;
* No missing;

/* Create dataset that will allow to obtain subjects for which there was an NSAID Rx in year prior to cohort entry */
proc sort data=wce.minusone; by id datserv;run;
proc sort data=wce.two; by id t0; run;

data wce.three;
 merge wce.two (in=a) wce.minusone;
 by id; 
 if a and (datserv<t0);
run;

proc sort data=wce.three; by id datserv; run;

proc freq data=wce.three; tables datserv; missing; run;
* No missing values;

/* Check date range for NSAID Rx */
proc sql;
select max(datserv) as max_date format=date9., min(datserv) as min_date format=date9. 
from wce.three;
quit;
* Variable 'datserv' is between 1JAN1992 and 4SEP2001;

data wce.four;
 set wce.three;
 by id;
 if last.id;
 if 0<(t0-datserv)<=365.25 then pnsaid=1; else pnsaid=0;
 if pnsaid=1;
 keep id pnsaid t0 datserv;
 run;

proc sort data=wce.four nodup; by id; run;
* 0 duplicate obs;

proc freq data=wce.four; table pnsaid/ missing; run;
* 40766 subjects with NSAIDs in the year before cohort entry;

/* Subjects who did not use NSAIDs in the year prior to cohort entry */
data wce.five;
 merge wce.two(in=a) wce.four;
 by id; if a;
 if pnsaid ne 1;
 drop pnsaid;
 run;

 * For 01JAN1993 - 31MAR2004 - Previous analysis
433672 subjects with NSAID Rx (t0)
 40766 subjects received NSAIDs in yr prior to t0
392906 subjects after excluding those with NSAIDs in yr prior to t0

 /* Previous analyses with other cohort start years */

 * For 01JAN1997 - 31MAR2004
424808 subjects with NSAID Rx (t0)
   127 subjects received NSAIDs in yr prior to t0
424681 subjects after excluding those with NSAIDs in yr prior to t0

* For 01JAN1996 - 31MAR2004
427854 subjects with NSAID Rx (t0)
 34043 subjects received NSAIDs in yr prior to t0
393811 subjects after excluding those with NSAIDs in yr prior to t0

* For 01JAN1995 - 31MAR2004
430583 subjects with NSAID Rx (t0)
 39174 subjects received NSAIDs in yr prior to t0
391409 subjects after excluding those with NSAIDs in yr prior to t0

* For 01JAN1994 - 31MAR2004
410288 subjects with NSAID Rx (t0)
 38578 subjects received NSAIDs in yr prior to t0
371710 subjects after excluding those with NSAIDs in yr prior to t0

* Therefore we end up having fewer subjects in base cohort if including population treated with NSAIDs
from 01JAN1993 than from 01JAN1997 due to NSAIDs taken in the year before t0; 

* Possibly explained by introduction of Régime d'assurance universel (in mid-1996 for seniors)
and resulting increase in co-payment for the elderly;

 proc sort data=wce.five; by id; run;

/* No age exclusion criterion - Recalculating age at t0*/
data wce.six;
 merge wce.five(in=a) data.demo;
 by id; if a;
run;

* Need for a datastep to recalculate age at t0 since the age
given in the RAMQ demo file is the age at the time of first NSAID Rx in that file, which starts on 01JAN1997;
proc freq data=wce.six; table agedex/ missing; run;
* No missing values for agedex (age at first NSAID Rx after 01JAN1997);

/* Calculating age at cohort entry (first NSAID Rx after 01JAN1993) */
data wce.sixage;
 set wce.six;
 if t0=firstrx then aget0=(agedex);
 else if t0>firstrx then aget0=(agedex+(t0-firstrx)/365.25);
 else if t0<firstrx then aget0=(agedex-(firstrx-t0)/365.25);
 * if aget0>=66; /* For RAMQ IPD dataset created in Jan 2014, lift age restrictions for age at t0 */
 if agedex=. then delete; 
 * if aget0>=85 then aget0=85; 
 /* Original RAMQ study (Brophy 2007)and IPD MA, which is a nested CCS matched for age
 enforce age limit. Only 11 subjects are older than 85 (request for raw data indicated age limit) */
 newaget0 = input(aget0,2.0); * Needed for nested-case control sampling with matching for age;
 drop aget0; 
 rename newaget0=aget0;
 run;


proc sort data=wce.sixage; by id; run;
proc freq data=wce.sixage; tables aget0 sex / missing; run;
* min age is 54, max age is 90
age 85 and over: n=15734
66 yrs: n=45357
65 yrs: n=21199
54-64 yrs n=10717; 

* In '9304 cohort: females: 59.3% males: 40.7%
OK because more women expected to take NSAIDs
In '9704 cohort: females: 60.2% males: 39.8%
In '9902 cohort: females: 61.8% males: 38.2%

/* Verifying duration of prior medical history at NSAID first Rx (t0= cohort entry) */
/* To ensure that those entering do not have less history (ie, new to province) and therefore potentially misclassified as incident */;
data wce.seven (drop=hole);
 merge wce.sixage (in=a) data.admis;
 by id; if a; 
 yrin=year(entry);
 yrout=year(sortie);
run;

proc freq; table yrin yrout/list; run;
proc sort data=wce.seven; by id; run;

/* Excluding subjects with less than 1 yr medical history at date of first NSAID Rx (t0) */
* Also assigning maximum duration of 13 years;
data wce.eight (drop=medhx1); 
 set wce.seven;
 medhx1= (t0-entry)/365.25;
 if medhx1>=1;
 medhx= round(medhx1, .1);
 if medhx>=13 then medhx=13;
run;
* Therefore 27559 subjects with less than 1 year of medical history;

proc freq data=wce.eight; tables medhx; missing; run;
* OK as medical history at least 1 year (max set at 13 years as in Brophy 2007);

/* Identifying the NSAID that determine cohort entry so as to create algorithm for >=2 different NSAIDs on t0 */
proc sort data=wce.one; by id; run;
proc sort data=wce.eight; by id; run;

data wce.nine;
 merge wce.eight(in=a) wce.one;
 by id;
 if a and (datserv=t0); /* keeping only rx dispensed on date of cohort entry */
 /* datserv is duplicate of variable "t0" */
run;

proc sort data=wce.nine; by id; run;

data wce.ten;
 set wce.nine; by id; 
 retain t0_nap t0_ibu t0_dic t0_cel t0_rof t0_other;
 array meds {6} t0_nap--t0_other; 
 if first.id then do i=1 to 6; meds {i}=0; 
 end;
 if forme in (/*solution ophtalmique*/02204, /*solution ophtalmique et otique*/02233) then delete;
 if dencom in (19752,46152,46335,46626) then t0_nap=1;
 if dencom in (04745,46654) then t0_ibu=1;
 if dencom in (41694,46154,47059,47078)then t0_dic=1;
 if dencom in (46546,47327) then t0_cel=1;
 if dencom in (46596,47346) then t0_rof=1;
 if dencom in (43150,47122,46256,33803,44749,45514,38691,04810,44359,47385,47084,46228,42019,46820,46638,40381,45592,45407,37664,46629)
 then t0_other=1;
 if last.id then output;
drop i; 
run; 
* With wce.ten, back to number of subjects in cohort previously defined; 

proc sort data=wce.ten; by id; run; 

proc freq data=wce.ten;
 tables t0_nap*t0_ibu*t0_dic*t0_cel*t0_rof*t0_other/list missing; run;
* Some subjects have multiple NSAIDs on t0;

/* Exclusion based on >=2 different NSAID Rx on t0 */
* Getting the number of double prescriptions that are different;
data wce.doublensaids;
set wce.ten (keep=id t0 t0_nap t0_ibu t0_dic t0_cel t0_rof t0_other);
if t0_nap=1 and t0_ibu=0 and t0_dic=0 and t0_cel=0 and t0_rof=0 and t0_other=0 then n=1;else n=0;
if t0_nap=0 and t0_ibu=1 and t0_dic=0 and t0_cel=0 and t0_rof=0 and t0_other=0 then ib=1;else ib=0;
if t0_nap=0 and t0_ibu=0 and t0_dic=1 and t0_cel=0 and t0_rof=0 and t0_other=0 then d=1;else d=0;
if t0_nap=0 and t0_ibu=0 and t0_dic=0 and t0_cel=1 and t0_rof=0 and t0_other=0  then c=1;else c=0;
if t0_nap=0 and t0_ibu=0 and t0_dic=0 and t0_cel=0 and t0_rof=1 and t0_other=0  then r=1;else r=0;
if t0_nap=0 and t0_ibu=0 and t0_dic=0 and t0_cel=0 and t0_rof=0 and t0_other=1  then o=1;else o=0;
if n=0 and ib=0 and d=0 and c=0 and r=0 and o=0 then dupnsaid=1; else dupnsaid=0;
run;

proc sort data=wce.doublensaids; by id; run;

proc freq data=wce.doublensaids; table dupnsaid/missing; run;
* 364 subjects with more than one NSAID at cohort entry
In '9704 cohort, 511 subjects with more than one NSAID at cohort entry
In '9604 cohort, 445 subjects with more than one NSAID at cohort entry
In '9304 cohort, 364 subjects with more than one NSAID at cohort entry
In '9902 cohort, 1057 subjects with more than one NSAID at cohort entry
In Brophy 2007, 168 subjects with double NSAIDs at cohort entry;
	
/* Identifying the NSAID(s) that determine cohort entry  */
proc sort data=wce.one; by id; run;
proc sort data=wce.ten; by id; run;

data wce.eleven;
 merge wce.one (keep=id dencom datserv durtxt qtmed) wce.ten(in=a);
 by id;
 if a and (datserv=t0); /* keeping only rx dispensed on date of cohort entry */
run;


data wce.twelve;
 set wce.eleven; by id;
 retain t0_nap t0_ibu t0_dic t0_cel t0_rof t0_other;
 array meds {6} t0_nap--t0_other; 
 if first.id then do i=1 to 6; meds {i}=0; 
 end;
 if dencom in (19752,46152,46335,46626) then t0_nap=1;
 if dencom in (04745,46654) then t0_ibu=1;
 if dencom in (41694,46154,47059,47078)then t0_dic=1;
 if dencom in (46546,47327) then t0_cel=1;
 if dencom in (46596,47346) then t0_rof=1;
 if dencom in (43150,47122,46256,33803,44749,45514,38691,04810,44359,47385,47084,46228,42019,46820,46638,40381,45592,45407,37664,46629)
 then t0_other=1;
 if last.id then output;
drop i; 
run; 


proc sort data=wce.twelve; by id; run; 

data wce.nsaidnoexcl;
merge wce.twelve(in=a) wce.doublensaids (keep=id dupnsaid);
by id;
if dupnsaid=0;
drop dupnsaid;
run;


proc freq data=wce.nsaidnoexcl; tables t0_nap*t0_ibu*t0_dic*t0_cel*t0_rof*t0_other/list missing; run;
* OK since NSAIDs at t0 are mutually exclusive;

data wce.nsaidqt;
set wce.nsaidnoexcl; 
if qtmed=0 or dosge=0 then delete;
run;
* N= 135 subjects deleted, 113 with qtmed=0, 22 with dosge=0, and 16 with both qtmed and dosge=0;

* N= 364848 subjects after applying all exclusion criteria and removing subjects without dispensed NSAID quantity or dosage
at first NSAID prescription;


/******************************************************
* Verification and Validation of NSAID Base Cohort	*
******************************************************/

/* Create binary variables for gender and age groups */
data wce.nsaidnoexclage;
set wce.nsaidqt;
if sex ='' then male =.; if sex ='F' then male = 0; if sex ='M' then male = 1;
run;

/* Verifying chronology of date variables */
data wce.nsaidnoexcldat;
set wce.nsaidnoexclage;
 yrin = year(entry);
 yrstart = year(t0);
 yrout = year(sortie);
 if entry > t0 then entryprob1=1; 
 if entry > sortie then entryprob2=1; 
 if sortie > '30Sep2004'd then exitprob=1; * End of study is September 30, 2004; 
  if t0 > sortie then startprob1=1; * sortie is only used for health insurance coverage;
run;

proc freq data=wce.nsaidnoexcldat;
  tables /*sex yob death yrstart*death yob*death yrout*death aget0*death yobprob1 yobprob2
  		yobprob3*/ yrin yrstart yrout entryprob1 entryprob2 exitprob startprob1;
run;
* No subjects have entry after t0, none with entry before sortie, none with t0 after sortie but most subjects
(N=290147) have exit beyond end of study;


/******************************************************
* CREATING PERMANENT DATASET FOR NSAID BASE COHORT	*
******************************************************/
/*Identifying date of censoring for 3 separate sources of cohort exit (death, loss, end of study on 30 September 2004)*/

proc sort data= wce.nsaidnoexcldat out=wce.cohort1; by id; run; 
proc sort data=data.deces out=wce.cohort2; by id; run;

data wce.basecoh9304;
 merge wce.cohort1(in=a drop=entryprob1 entryprob2 exitprob startprob1) wce.cohort2(keep=id datedc);
 by id; if a;
 exit=min(sortie,datedc,mdy(09,30,2004)); 
 length exitype $ 10.;
 if datedc then death=1; else death=0;
 if death=1 and datedc<='30Sep04'd then exitype='death';
 else if exit='30Sep04'd then exitype='study end';
 	  else exitype='loss';
 format exit date9.;
run;

/*Removing and sorting variables of final base cohort */ 
proc contents data=wce.basecoh9304 position; run;

data wce.basecoh9304final (drop= medhx yrin yrstart yrout sex);
retain id datserv firstrx agedex t0 dateserv aget0 male forme dosge
t0_nap t0_ibu t0_dic t0_cel t0_rof t0_other durtxt qtmed  
t0yr t0mth entry sortie datedc death exitype exit;
set wce.basecoh9304;
run;

data ami.ramq_basecoh9304;
set wce.basecoh9304final;
run;

proc contents data=ami.ramq_basecoh9304; run;

/* Examining distribution of base cohort entry year */
ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Base cohort entry year.rtf' style=analysis;
Title1 'RAMQ base cohort dataset';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
Title3 'Base cohort entry years';
proc freq data=ami.ramq_basecoh9304; tables t0yr; missing;
options nodate nonumber;
run;
ods rtf close;
* Increase in proportion entering in 1999 and 2000 thought to be associated with coxib launch in 1999
(Apr for celecoxib and Nov for rofecoxib) i.e. patients with GI risk factors now being prescribed 
the newly launched coxibs;

/* Examining distribution of NSAIDs that determine base cohort entry */
ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Drug at cohort entry.rtf' style=analysis;
Title1 'RAMQ base cohort dataset';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
Title3 'NSAID at base cohort entry';
proc freq data=ami.ramq_basecoh9304; tables t0_nap t0_ibu t0_dic t0_cel t0_rof t0_other/list nocum missing;
options nodate nonumber;
run;
ods rtf close;


/* Examining distribution of NSAIDs at base cohort according to entry year */
ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Drug at cohort entry by year.rtf' style=analysis;
Title1 'RAMQ base cohort dataset';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
Title3 'NSAID at base cohort entry - According to entry year';
proc freq data= ami.ramq_basecoh9304;
tables t0yr*(t0_nap t0_ibu t0_dic t0_cel t0_rof t0_other)/list missing;
options nodate nonumber;
run;
ods rtf close;

