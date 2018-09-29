
/********************************************************************************************************
* AUTHOR:	 	Michele Bally (based on Linda Levesque and Sophie Dell'Aniello) 							*
* CREATED:	 	July 10, 2014																			*
* UPDATED:   																							*																								*
* TITLE:	 	Outcome_AMI NSAIDs_NCC IPD MA and WCE_RAMQ9304											*
* OBJECTIVE:	Determine AMI outcome in base cohort for analysis of RAMQ via a nested case-control 	*
*				sampling for various analyses: 1) as single study, 2) for inclusion in an individual	*
*				patient data meta-analysis (IPD MA) and 3) for a recency-weighted cumulative exposure   *
* 				(WCE) analysis																			*
*				Using a RAMQ cohort of new NSAID users (no NSAID use in year prior to cohort entry)		*
*				for the time period from 01JAN1993 to 30SEP2004											*
*				Mostly elderly population but age not restricted										*
* PROJECT:		Create RAMQ datasets for re-examining recency, dose, and duration effects of	    	*
*				NSAID exposures on the risk of acute myocardial infarction for all PhD thesis work		*
********************************************************************************************************/


libname data 'C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\NSAIDs2\raw data';
libname ami 'C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami';
libname tables 'C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables';


/* Raw data */
proc sort data=data.admis;by id;run;
proc sort data=data.deces;by id;run;
proc sort data=data.rx_x;by id;run;
proc sort data=data.demo;by id;run;
proc sort data=data.medserv;by id;run;

/* Dataset created for the project */
proc sort data=ami.ramq_basecoh9304;by id;run; * Program Base cohort_AMI NSAIDs_NCC IPD MA and WCE__RAMQ9304;


/***************************************************************
* Dataset created to determine the cut-off date for study exit
****************************************************************/
data basecoh_ami; 
set ami.ramq_basecoh9304(keep=id t0 exit sortie datedc) ;
run;
proc sort data=basecoh_ami;by id; run;


/***************************************************
* AMI on of after t0 - Identified by any ds position
***************************************************/
* This program code is mainly from program anyami cohort sourced from t2dm_Linda_SK programs;

* According to the literature, myocardial infarction defined as a medical claim for hospitalization with ICD-9 code 410.xx (excluding 410.x2,
which is used to designate follow-up to the initial episode) and a length of stay (LOS) between 3 and 180 days, or death if LOS is <3 days. 
This definition for AMI has been used in several validation studies using Medicare claims data, yielding a PPV of 94% for claims-based diagnosis
of AMI against structured medical chart review. (Wahl PM, et al. Validation of claims-based diagnostic and procedure codes for cardiovascular and
gastrointestinal serious adverse events in a commercially-insured population. PDS 2010 19(6) 596-603 based on Kiyota Y, et al. Accuracy of 
Medicare claims-based diagnosis of acute myocardial infarction: estimating positive predictive value on the basis of review of hospital records.
Am Heart J 2004 148, 99–104.);
* Per Lévesque 2005, the case-defining event was a first hospitalization with a diagnosis of acute MI (ICD9, code 410), nonfatal or fatal, 
occurring any time after cohort entry. The date of admission was used as the index date. For the MI to be considered a valid study end point,
the hospital length of stay had to be at least 3 days, unless the patient had been transferred to or from another institution or had undergone
percutaneous coronary angioplasty.
* Per Brophy 2007, MI was considered fatal if the person died within 30 days of admission. In order for non-fatal MI to be considered a valid 
outcome of the study, the length of stay at a hospital had to be at least 3 days, unless the person had been transferred to or from another 
institution or had undergone percutaneous coronary angioplasty;
* Per discussion with J. Brophy April 2, 2013, for the cohort years of interest (1993 to 2004), acceptable to include 
length of stay of at least 3 days in the definition of AMI although in more recent years of cohort enrolment
this may have been unduly restrictive (i.e. hospital stay after AMI tended to become shorter) 

/* Initially take all AMI admissions because if you restrict to first.id (or first MI) right away, you will miss transfers for
same admission unless if you re-merge again with hosp data*/
/* Initially includes AMI after cohort "exit" date but we remove these later when we take min(exit, amia) */;

/* Identifying AMI on or after t0 */
data one;
 merge basecoh_ami(in=a) data.hosp(keep=id dp--ds15 admit datequit);
 by id; if a; /* keeps hospitalizations for cohort members only */
 if t0<=admit<=min(sortie,datedc,mdy(09,30,2004)); 
run;

data two (keep=id t0 exit datedc amia amid ami);
 set one;
 by id;
 retain ami;
 if first.id then do; ami=0; end;
 array dx(16) $dp--ds15;
  if t0<=admit then do i=1 to 16; /* only keeps AMI admissions >=t0, will remove AMI admission exactly on t0 in later step */
  if substr(dx(i),1,3) in ('410') then ami=1;
 end;
 rename admit=amia datequit=amid;/* amia is admisssion for AMI and amid is discharge or transfer due to AMI. Renamed variables to distinguish 
 from admit & disch for the next datastep */
run;

proc sort data=two (where=(ami=1)) out=three nodup; by id amia amid ; run;
* Some individuals in WORK.THREE have multiple admissions for AMI including transfers, procedures and re-admissions;

proc sort data=three; by id; run;

proc sql;
select max(amia) as max_date format=date9., min(amia) as min_date format=date9.
from three;
quit;
* OK, variable amia, which is admit date for AMI, is between 1FEB1993 (corresponding t0 on sorted data is 14JAN1993)
and 30SEP2004;

proc sql;
select max(t0) as max_date format=date9., min(t0) as min_date format=date9.
from three;
quit;
* OK, variable t0, which is date of first NSAID prescription, is between 03JAN1993 and 20MAR2004;

/* Identifying transfers */
/* To apply algorithm for valid study endpoint (incl. correctly account for length of stay) */
proc sql;
 create table four as
 select three.*,hosp.admit,hosp.datequit,hosp.dp, hosp.ds1, hosp.ds2, hosp.ds3, hosp.ds4, hosp.ds5, hosp.ds6, hosp.ds7, hosp.ds8, hosp.ds9, 
hosp.ds10, hosp.ds11, hosp.ds12, hosp.ds13, hosp.ds14, hosp.ds15, hosp.txt1, hosp.txt2, hosp.txt3, hosp.txt4, hosp.txt5, hosp.txt6, hosp.txt7,
hosp.txt8, hosp.txt9  /* need procedures to identify angioplasty */
 from three, data.hosp
 where three.id=hosp.id and three.amia<=hosp.admit /* any admission after AMI - see NOTE 1 */ 
 order by three.id, three.amia, three.amid, hosp.admit, hosp.datequit;
quit;
/* NOTE 1: Could have used data three, which contains all AMI admissions, to identify transfers. However, there is a small risk that transfers
may not be coded as AMI (particularly if we restrict the identification of AMIs to dp only. Because of this,
we obtained all admissions (not just AMI) as those clinically unrelated to AMI are unlikely to overlapp or be back-to-back. */ 

data five; 
set four; by id amia amid; /* ordered by date of AMI admissions */
 previousa=lag(admit); previousd=lag(datequit);
 format previousa previousd date9.;
 retain bloc; /* this variable identifies a "block" of admissions (i.e., accounts for transfers) */
 if first.amid then do; previousa=.; previousd=.; bloc=0; end; 
 if not (previousa<=admit<=previousd+2) then bloc=bloc+1;
run;

proc freq data=five; table bloc; run;
* Among cohort members who had at least 1 admission, 30.5% had only 1 admission during follow-up (bloc=1), 19.8 % had two, 13.8% had 3, 
95.7% have <= 11 admissions, number of admissions ranges from 1 to 52 (would include admissions for repeated procedures such as dialysis);

/* Identifying PCI*/
* t2dm program used procedure codes: '480' and '5159' only
* 5159 is ‘Other repair of blood vessel NEC’ (includes arterioplasty, construction of venous valves etc.): to exclude
/*From Lambert L, Blais C, Hamel D, Brown K, Rinfret S, Cartier R, Giguère M, Carroll C, Beauchamp C, Bogaty P. Evaluation of care and
surveillance of cardiovascular disease: can we trust medico-administrative hospital data? Can J Cardiol. 2012 Mar-Apr 28(2):162-8. */
* “During the period of observation, diagnoses were classified according to ICD-9, while procedures were classified according to the 
Canadian Classification of Diagnostic, Therapeutic and Surgical Procedures. For this study, all hospitalizations within the database 
from April 1, 2002, to March 31, 2006, were identified in which at least 1 of the following conditions was met:    1. Patients had a 
principal diagnosis of acute myocardial infarction (AMI) (ICD-9 Diagnosis Code 410) in the selected primary, secondary, and tertiary 
hospitals 2. Patients underwent percutaneous coronary intervention (PCI) (also commonly known as coronary angioplasty) in 1 of the 4 
secondary hospitals 3. Patients underwent coronary artery bypass graft (CABG) surgery in 1 of the 5 tertiary hospitals. Canadian Classification
of Diagnostic, Therapeutic and Surgical Procedures codes for PCI and CABG and their definitions are provided in Supplemental Table S1.”
* Lambert et al. 2012 cites Canadian classification of diagnostic, therapeutic, and surgical procedures. Ottawa:Statistics Canada;
* Version available in Ross is 1986. Cat no 82-562E;
* List below is from Lambert et al. 2012 On-line supplement. 

/*Percutaneous coronary intervention (PCI)*/
* 4801 Removal coronary artery obstruction Unqualified
48021 Percutaneous Transluminal Coronary Angioplasty (PTCA) without mention of Thrombolytic Agent, without stent 
48022 PTCA without mention of Thrombolytic Agent, with stent
48031 PTCA with mention of Thrombolytic Agent, without stent
48032 PTCA with mention of Thrombolytic Agent, with stent 
48041 Open chest coronary artery angioplasty, without stent
48042 Open chest coronary artery angioplasty, with stent
4805 Intracoronary artery thrombolytic infusion 
4809 Other Removal of Coronary Artery Obstruction; 
* Although not listed by Lambert 2012, also include 480 Removal of coronary artery obstruction;

/*Coronary artery bypass graft surgery (CABG)*/
* 4811 Aortocoronary Bypass for Heart Revascularization, Unqualified
4812 Aortocoronary Bypass of One Coronary Artery
4813 Aortocoronary Bypass of Two Coronary Arteries 
4814 Aortocoronary Bypass of Three Coronary Arteries
4815 Aortocoronary Bypass of Four or more Coronary Arteries
4816 Single (Internal) Mammary-Coronary Artery Bypass 
4817 Double (Internal) Mammary-Coronary Artery Bypass
4819 Other Bypass Anastomosis for Heart Revascularization
4829 Heart revascularization by arterial implant
4839 Other heart revascularization;

* For the purpose of reproducing Brophy 2007, we did not consider codes for CABG and we will not include CABG
for the IPD MA (we keep the same criteria for defining AMI as in the original study);

/* PCI identifed from procedure codes */
* Do not use billing codes (variable 'codact' in medical services raw dataset) to identify PCI
as they are not reliable (L. Nadeau);
data six_txt (drop=bloc keep=id t0 datedc exit amid amia angio datequit txt1--txt9);
 set five (where=(bloc=1)); by id amia amid; /* keeping only distinct MI admissions incl. transfers; 
also keep t0 (date of first NSAID Rx) because need to determine if AMIs occur on t0*/ 
 if first.amid then do angio=0; end;
 retain angio; * initializing variable for angioplasty;
 array tx(9) txt1-txt9;
 array txc(9) txt3c1-txt3c9;
 if amia ne . and amia>t0 then do i=1 to 9; 
 txc(i)=substr(tx(i),1,3);
 if txc(i)='480' then angio=1; 
 end;
 run;

proc sort data=six_txt(where=(angio=1)) out=six_txtcheck; by id amia amid; run;
* OK, subjects with '480' entries for txt1--txt9 have angio=1;

data six (drop=bloc keep=id t0 datedc exit amia amid amidatequit angio time txt1--txt9);
 set five (where=(bloc=1)); by id amia amid; /* keeping only distinct MI admissions incl. transfers; 
also keep t0 (date of first NSAID Rx) because need to determine if AMIs occur on t0*/ 
 format amidatequit date9.;
 if first.amid then do angio=0; end;
 retain angio; * initializing variable for angioplasty;
 array tx(9) txt1-txt9;
 array txc(9) txt3c1-txt3c9;
 if amia ne . and amia>t0 then do i=1 to 9; 
 txc(i)=substr(tx(i),1,3);
 if txc(i)='480' then angio=1; 
 end;
 if last.amid then do;
 amidatequit=max(datequit,amid); /* true AMI discharge date is that from last transfer for AMI */
 time=amidatequit-amia; /* calculating lenght of stay */ 
 output;
 end;
run;

proc freq data= six; table angio; run;
* 7102/70231 (10.1%) where angio=1;

/* Identifying subjects with AMI exactly on t0 */
data six_not0 (keep=id t0 datedc exit amia amidatequit angio time);
set six;
if amia ne t0;
run;

/* Obtaining data to define AMI according to first admission for AMI and length of stay >=3 days unless
PCI was done */
proc sort data=six_not0; by id; run;

data seven; merge ami.ramq_basecoh9304(keep=id t0 exit datedc) six_not0(in=a);
 by id; if a;
 retain amino; /* number of AMI admissions during follow up - not necessarily valid study endpoints (see below) */
 if first.id then amino=0;
 amino=amino+1;
 if time>=3 or angio=1 or amia<=datedc<=amidatequit+1 then ok=1; /* datedc is death and exit is death or loss or study end*/
 else ok=0;
run;

* Check obs where LOS<3 days and ok=1 for death from AMI verifying that amia<=datedc<=amidatequit+1;
proc freq data=seven; table ok; run;
* 83.3% (58497 of 70223) of all AMIs identified met these validity criteria

* Take first AMI admission;
proc sort data=seven(where=(ok=1)) out=eight; by id amia amidatequit; run;

data nine; 
set eight; by id; if first.id; /* Taking first valid AMI admission */
 if time>=3 then plus3days=1;
 else plus3days=0;
 if amia<=datedc<=amidatequit+1 then deces=1;
 else deces=0;
run;

proc freq data=nine; table amino;  run;
* 98.9% (21308 of 21543) had only 1 AMI admission during follow-up. 
197 subjects had 2 AMI admissions and 27 had 3 AMI admissions and 
10 subjects had 4 AMI admissions and 1 subject had 5 AMI admissions during follow-up;

* Case-defining event is a first hospitalization with a diagnosis of acute MI. 
Need to remove those 235 subjects with more than 1 AMI admission;
data ten; 
set nine;
 if amino=1 then output;
run;

proc sort data=ten; by id; run;
proc freq data=ten; table amino plus3days*deces*angio/list;  run;
* 93.7% of admissions had length of stay >= 3days,
5.3% with LOS < 3 days were included because they had died within 3 days of admission
0.86% were included on the basis of PCI only;
* 4270/21308 (20.0%)of subjects with first AMI died;
* Deces is based on var amidatequit, which is max of hospital discharge (datequit) and ami discharge date (amid);

/* Verifying number of first AMI which do not meet validity criteria (i.e., incl ok=0 & ok=1) */
proc sort data=seven out= nine_check; by id amia amidatequit; run;

data eleven; 
set nine_check; by id;
 if time>=3 then plus3days=1;
 else plus3days=0;
 if amia<=datedc<=amidatequit+1 then deces=1;
 else deces=0;
 if amino=1 then firsthosp=1;
 else if amino>1 then firsthosp=0;
run;

proc freq data=eleven; table firsthosp plus3days*deces*angio/list;  run;
* 69.12% (n=48538) were not first hosp for AMI, 16.7% (n=11726) has LOS<3 days and no PCI or death;

/* Final steps to create AMI dataset */ 
proc contents data=ami.ramq_basecoh9304 position; run; /* study cohort */
proc contents data=ten position; run; /* AMI cases and event date */

* Based on SK t2dm, principal ami program;
data ami1;
merge ami.ramq_basecoh9304 ten; /* variable "exit" in both nsaids.nsaidcoh9304 and data ten */
 by id;
 if amia ne . then outcome=1; /* creating variable to identify "event cases" of first AMI */
 else outcome=0;
 tout=min(exit,amia); /* tout=time out is earliest of event date "amia" (AMI admission date) or cohort "exit" (censor) date) */
 format tout date9.;
 if amia<=exit<=amia+30 and deces=1 then do; /* fatal MI = death within 30 days of admission for MI, based on deces=1 if amia<=datedc<=amidatequit+1 */
	fami=1;
	if amia<=exit<=amidatequit+1 and deces=1 then famih=1; /* fatal MI in hospital*/
 end;
 else do; fami=0; famih=0; end;
 if angio=. then angio=0;
 eventyr=year(amia);
 t0mth=month(t0);
 eventmth=month(amia);
 if outcome=1 then exitype='event';
 rename amia=amidate; /* represents date of admission for first MI */
 run;

proc contents data=ami1; run;


* Calculation of age at exit and duration of follow-up;
data ami2;
set ami1;
FU=(tout-t0)/365.25; /*where tout is earliest of AMI admission date or cohort exit*/
followyrs= round(FU, .1); /*duration of cohort follow-up in years based on the exit date for cohort members*/
age_tout= aget0 +((tout-t0)/365.25); /*where aget0 is age at t0 (date of first NSAID prescription) and tout is earliest of AMI admission date or cohort exit*/
agetout= round(age_tout, .1); 
format aget0 4.0;
run;

proc univariate data=ami2; var followyrs; run;
* Follow-up based on exit date min=0, max=11.7, mean 5.5 sd 3.3 median 5.0 mode 4.9;

proc contents data= ami2; run;
proc sort data= ami2; by id; run;

* Check that no subjects had FU<0;
data ami3;
set ami2 (where=(FU < 0));
run;
* 0 observations

* Determine how many subjects has FU=0;
data ami3;
set ami2 (where=((tout-t0) < 1)); * tout is earliest of AMI admission date or cohort exit;
* Reasons for cohort exit are death, end of insurance coverage (loss, cohort includes elderly and social welfare recipients),
or end of study (30Sept2004);
run;

data ami3_check1;
set ami3;
diff=(tout-t0);
run;
proc freq data=ami3_check1; tables diff; run;
* Manually examined data. All 8 subjects died. None had an AMI;

* Additional verifications on duration of stay in cohort;
data ami2_check1;
set ami2 (where=(1 <(tout-t0) <= 2));
run;
* 67 observations;

data ami2_check2;
set ami2 (where=(2 <(tout-t0) <= 3));
run;
* 64 observations;

data ami2_check3;
set ami2 (where=(3 <(tout-t0) <= 4));
run;
* 65 observations;

* Additional verification on variables qtmed;
data ami2_check4;
set ami2 (where=(qtmed=0));
run;
* 0 observation. OK.


/* Remove subjects without follow-up time in cohort of at least 1 day */
* 8 subjects have a follow-up time (cohort tout date - cohort entry date/ 365.25) of less than 1 day,
which indicates AMI or cohort exit occurred exactly of date of t0 (first NSAID prescription after 01Jan1993).
To reduce possibility that the censoring event might have occurred before the first
NSAID dosing these subjects are removed from the cohort for survival analysis;
data ami4;
set ami2;
if (tout-t0) < 1 then delete;
run;
* OK, 8 subjects removed;


/***************************************************************************
CREATING PERMANENT DATASET FOR COHORT WITH AMI AFTER t0 – ALL DX POSITIONS 
***************************************************************************/

data ami.ramq_coh_ami9304; * Includes all variables from ami.ramq_basecoh9304;
retain id outcome datserv firstrx agedex t0 dateserv aget0 male forme dosge
t0_nap t0_ibu t0_dic t0_cel t0_rof t0_other durtxt qtmed  
t0yr t0mth entry sortie datedc death  
deces datedc exitype tout agetout age_tout amidate exit followyrs FU amidatequit
fami famih time angio eventyr eventmth amino plus3days ok;
set ami4;
run;

/* To complete study flow diagram */
proc freq; table exitype / list; run; /* see study population flow diagram for results */

proc freq ; table (fami famih)*outcome fami*famih; run;
* No missing data and looks OK;

/* Flow diagram		Brophy 2007 	ami.amicoh02		ami.amicoh9304 (April 2013)  ami.amicoh9304 (Sept 2013)  ami.ramq_coh_ami9304 (July 2014)
Study population   122079			 276629					364983						356543						364840
First AMI			 3423 (2.80%)	   8125 (2.94%)			 21290 (5.83%)				 20851 (5.85%)				 21308 (5.84%)
Non-fatal MI	     2717 (2.2%)	   6693 (2.3%)			 17510 (4.80%)											 17528 (4.80%)
Fatal MI		 	  706 (0.6%)	   1729 (0.6%)			  3780 (1.04%)				  3729 (1.05%)				  3780 (1.04%)				 
Death (non-AMI)		11763 (9.6%)	  25416 (9.2%)			 58472 (16.0%)				 57509 (16.1%)				 58439 (16.0%)
Alive exit		   106893 (87.6%)	 241379 (87.3%)		    278410 (76.3%)
Loss				Not available	   1709 (0.6%)			  6811 (1.9%)				  4579 (1.3%)				  6808 (1.87%) */

* Difference in numbers between the two ami.amicoh9304 (April and Sept 2013) is due to correction to
the calculation of age at cohort entry in program Base cohort _NSAIDs9304_RAMQ_ipd_130903, 
which resulted in additional subjects being excluded due to not being at least 66 yo at cohort entry;
* In cohort dated Mar 2014, no age restriction was applied;

/* Additional data verifications */
data checkami;
set ami.ramq_coh_ami9304;
diff=(tout-amidate);
run;
proc freq data=checkami; tables diff outcome; run;
* Time difference between ami date and study exit date is 0 for all outcome=1 (i.e. for all AMI);

* Brophy 2007, “We followed the remaining individuals until the earlier of one of the following dates: first hospitalization for an acute MI, 
end of coverage (due to death or emigration from the province), death, or end of the study (31 December 2002)”;
proc sort data= ami.ramq_coh_ami9304 out=amiyr(where=(outcome=1)); by amidate;run;

proc sort data= ami.ramq_coh_ami9304 out=amiyr(where=(outcome=1)); by exitype;run;

data amiyr;
set ami.ramq_coh_ami9304;
amiyr= year(amidate);
run;

ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - AMIs per year.rtf' style=analysis;
Title1 'RAMQ base cohort dataset';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
Title2 'Distribution of acute myocardial infarction cases by year';
proc freq data=amiyr(where=(outcome=1)); tables amiyr;
options nodate nonumber;
run;
ods rtf close;
* 21308 AMIs;








