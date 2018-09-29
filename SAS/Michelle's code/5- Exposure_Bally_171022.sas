%put &sysdate9;
%let temps1=%sysfunc(time());

/********************************************************************************************************
* AUTHOR:	 	Michèle Bally (mostly from Lyne Nadeau '2013-02-14 episoe of drug use')					*
*			 	Initially based on Linda Levesque and Sophie Dell'Aniello 								*
* CREATED:	 	July 27, 2014													        				*
* UPDATED:																								*
* TITLE:	 	Exposure_AMI NSAIDs_NCC IPD MA_RAMQ9304													*
* OBJECTIVE:	To define NSAID and aspirin exposure in the  nested case-control RAMQ dataset			*
*				for analyses: 1) as single study and 2) for inclusion in an individual					*
*				patient data meta-analysis (IPD MA)														* 
*				Same exposure program as for recency-weighted cumulative exposure (WCE) analysis -		* 
*				up to dose-duration categorization														*
*				Using a RAMQ cohort of new NSAID users (no NSAID use in year prior to cohort entry)		*
*				for the time period from 01JAN1993 to 30SEP2004	with nested-case control sampling		*
*				Controls are matched to AMI cases (10:1) on year and month of cohort entry,				*
*				on age and on gender and are assigned cases' index date (same duration of follow-up)	*
*				Mostly elderly population but age not restricted										*
* PROJECT:		Create RAMQ datasets for re-examining recency, dose, and duration effects of	    	*
*				NSAID exposures on the risk of acute myocardial infarction for all PhD thesis work		*
********************************************************************************************************/

libname data 'C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\NSAIDs2\raw data';
libname ami 'C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami';
libname tables 'C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables';
libname wce 'E:\Michele.Bally\wce';


/*lyne*/ 
libname ami 'D:\database\jay brophy\michele_ramq\ami';
libname data 'D:\database\jay brophy\michele_ramq\raw data';

/* Raw data */
proc contents data=data.admis;run;
proc contents data=data.deces;run;
proc contents data=data.demo;run;
proc contents data=data.hosp;run;
proc contents data=data.rx_x;run;
proc contents data=data.medserv;run;

/* Datasets created for the project */
proc contents data= ami.ramq_basecoh9304; run;
proc contents data= ami.ramq_coh_ami9304; run;
proc contents data= ami.ramq_NCC_cc9304;run;

proc sort data= ami.ramq_basecoh9304; by id; run; * Program Base cohort_AMI NSAIDs_NCC IPD MA and WCE__RAMQ9304;
proc sort data= ami.ramq_coh_ami9304; by id; run; * Program Outcome_AMI NSAIDs_NCC IPD MA and WCE_RAMQ9304;
proc sort data= ami.ramq_NCC_cc9304; by id; run; * Program NCC sampling_AMI NSAIDs_NCC IPD MA and WCE_RAMQ9304;

proc freq data=ami.ramq_NCC_cc9304; table ami; run;
* 21256 AMI, OK;

/*********************************************************************************************************
* Obtaining NSAIDs Dispensed Between Cohort Entry (t0, date of first NSAID prescription) and Index Date  *
*********************************************************************************************************/

* Keeping the 5 NSAIDs of interest i.e. naproxen, ibuprofen, diclofenac, celecoxib, and rofecoxib plus other NSAIDs (grouped as "other")
* Composition of "other" NSAIDs group determined based on additional individual NSAIDs included in datasets included in the NSAIDs IPD MA
and for which info is available (etoricoxib and valdecoxib not marketed in CDN)
* In addition to the 5 NSAIDs of interest, other NSAIDs in the Finland dataset (Helin-Salmivaara 2006) are: aceclofenac, etodolac,
indomethacin, ketoprofen, mefenamic acid, meloxicam, nabumetone, nimesulide, piroxicam, tenoxicam, tiaprofenic acid, and tolfenamic acid 
* Other NSAIDs in the Sask dataset (not described in Varas-Lorenzo 2009 but info available in Sask data files) are: 
diflunisal, etodolac, fenoprofen, flurbiprofen, indomethacin, ketoprofen,mefenamic acid, nabumetone, phenylbutazone, piroxicam, 
sulindac, tiaprofenic acid, and tolmetin
* Other NSAIDs in the GPRD dataset (Andersohn 2006) are: etoricoxib, valdecoxib. Note that "other" NSAIDs category is not described
in publication and that further information is not available
* Although they are listed by RAMQ, and needed to reproduce Brophy 2007, eventually leave out ketorolac (46006,47066)
and salsalate (47107,46208)as they are not listed in "other" NSAID groups in either of Finland, Sask or GPRD datasets.
* Kept phenylbutazone (7642)for the purpose of reproducing Brophy 2007 but do not include for IPD MA as use denotes
a niche indication or unusual practice.
/*NB: Checked against dencom file 'Dénomination communes au 2006-02-20', making sure to include code for drug name
when 'e' is written instead of 'é'and when 'en' was used instead of 'ène'*/;


proc sql;
 create table rx as
 select cc.caseid, cc.id, cc.indexdate, cc.ami, /*caseid defines the risk set*/
 rx.datserv, rx.dencom, rx.forme, rx.durtxt, rx.dosge, rx.qtmed, rx.ctrib, /*contribution du bénéficiaire*/ rx.frserv/*frais de service*/
 from ami.ramq_NCC_cc9304 as cc, data.rx_x as rx
 where cc.id=rx.id and (dencom in (19752,46152,46335,46626 /*naproxen*/,04745,46654 /*ibuprofen*/,41694,46154,47059,47078 /*diclofenac*/,
46546,47327 /*celecoxib*/,46596,47346 /*rofecoxib*/,43150 /*diflunisal*/,47122,46256 /*etodolac*/,33803 /*fenoprofen*/,
44749,45514 /*flurbiprofen*/,38691 /*ketoprofen*/,04810 /*indomethacin*/,44359 /*mefenamic acid*/,47385/*meloxicam*/,47084,46228/*nabumetone*/,
42019,46820,46638 /*piroxicam*/,40381 /*sulindac*/,45592 /*tenoxicam*/,45407 /*tiaprofenic acid*/,37664,46629 /*tolmetin sodium*/)
and forme not in (02204 /*solution ophtalmique*/,02233 /*solution ophtalmique et otique*/)or dencom in(46353/*ASA comprimé entérique 81mg*/,00143/*ASA*/)
and forme in(00203/*comprimé*/,00406/*comprimé entérique*/,00464/*comprimé masticable 80mg*/)
and dosge in (40199, 52216/*80mg or 325mg*/,40199, 51244 /*80mg or 300-325mg*/))
 and t0<=datserv<indexdate 
 order by cc.caseid, cc.id, rx.datserv, rx.dencom; 
quit; 

proc sort data=rx; by caseid id datserv; run;

proc freq data=rx; table ami; run;
* 466011 AMIs - will re-merge later with ami.ramq_NCC_cc9304;

data rxtest;
set rx;
 if forme in (/*solution ophtalmique*/02204, /*solution ophtalmique et otique*/02233)then delete;
run;
* 0 observation deleted;

/* Creating variables for each NSAID and aspirin */

data wce.rx0;
set rx; 
by caseid id datserv;

 if first.datserv then do;
 asa=0; nap=0; ibu=0; dic=0; cel=0; rof=0; other=0; 
  end;

if dencom in(46353/*ASA comprimé entérique 81mg*/,00143/*ASA*/)and forme in(00203/*comprimé*/,00406/*comprimé entérique*/,
00464/*comprimé masticable 80mg*/)and dosge in (40199, 52216/*80mg or 325mg*/,40199, 51244 /*80mg or 300-325mg*/)then asa=1;
if dencom in (19752,46152,46335,46626)then nap=1; 
if dencom in (04745,46654)then ibu=1;
if dencom in (41694,46154,47059,47078) then dic=1; 
if dencom in (46546,47327)then cel=1;
if dencom in (46596,47346) then rof=1;
if dencom in (43150,47122,46256,33803,44749,45514,38691,04810,44359,47385,47084,46228,42019,46820,46638,40381,45592,45407,37664,46629,
07642,46208,47107) then other=1; 
run;

proc sort data=wce.rx0; by id datserv; run;


/* Identifying observations for which the dispensed quantity is equal to 0 */

* Note from February 18, 2013 discussion with Jean-François Guévin, hospital pharmacist with extensive experience as retail pharmacist in Québec:
qtmed (dispensed quantity) is a reliable variable in RAMQ while durtxt (duration of treatment) is not. 
Duration of treatment is calculed automatically from prescribed dosage (an info not available to us as a variable in RAMQ database). 
For example, if prescription is for 1 tablet die 5 days out of 7 and the pharmacist serves 22 tablets, duration of treatment will be calculated
as being 22 days because the mention '5 days out of 7' will not be taken into account. In order for duration of treatment to be reliable, 
the duration of treatment must have been manually adjusted, which one cannot assume is done systematically;

data qt0flag;
set wce.rx0; 
by id datserv; 
if qtmed=0 then output;
run;
* 901 observations with amount of medication served equal to 0;

* Set binary value to 0 for aspirin and NSAIDs for those observations for which quantity dispensed is equal to zero (qtmed=0);
data wce.rx0qt;
set wce.rx0; 
 asa=0; nap=0; ibu=0; dic=0; cel=0; rof=0; other=0; 
if dencom in(46353/*ASA comprimé entérique 81mg*/,00143/*ASA*/)and forme in(00203/*comprimé*/,00406/*comprimé entérique*/,
00464/*comprimé masticable 80mg*/)and dosge in (40199, 52216/*80mg or 325mg*/,40199, 51244 /*80mg or 300-325mg*/)then asa=1;
if dencom in (19752,46152,46335,46626)and qtmed ne 0 then nap=1; 
if dencom in (04745,46654)and qtmed ne 0 then ibu=1; 
if dencom in (41694,46154,47059,47078)and qtmed ne 0 then dic=1;
if dencom in (46546,47327)and qtmed ne 0 then cel=1; 
if dencom in (46596,47346)and qtmed ne 0 then rof=1; 
if dencom in (43150,47122,46256,33803,44749,45514,38691,04810,44359,47385,47084,46228,42019,46820,46638,40381,45592,45407,37664,46629,
07642,46208,47107)and qtmed ne 0 then other=1;
run;

proc sort data=wce.rx0qt; by id datserv; run;


/***************************************************
* Creating Dose Variable Based on Code for Dosage  *
***************************************************/

data check1;
set wce.rx0qt (where=(dosge=0 and dencom ne 143 /*aspirin*/ and forme ne 0)); 
run;
* 0 observations;

data rx1 (drop=ddose);
set wce.rx0qt;
if dosge='00263' then dose=50; /*diclofenac 50 mg-misoprostol 200 mcg*/
else if dosge='00518' then dose=75; /*diclofenac 75 mg-misoprostol 200 mcg*/
else if dosge='23180' then dose=7.5;
else if dosge='24400' then dose=10;
else if dosge='26413' then dose=2.5; /*12,5 mg/5 mL (150 mL)*/
else if dosge='26474' then dose=12.5;
else if dosge='26962' then dose=15;
else if dosge='28426' then dose=20;
else if dosge='30622' then dose=25;
else if dosge='30744' then dose=25; /*suspension orale 25mg/mL (474 mL)*/
else if dosge='36234' then dose=50;
else if dosge='39528' then dose=75;
else if dosge='41602' then dose=100;
else if dosge='44408' then dose=125;
else if dosge='45872' then dose=150;
else if dosge='47702' then dose=200;
else if dosge='49776' then dose=250;
else if dosge='51240' then dose=300;
else if dosge='52948' then dose=375;
else if dosge='53192' then dose=400;
else if dosge='54412' then dose=500;
else if dosge='55876' then dose=600;
else if dosge='56364' then dose=750;
* For identify ASA used at cardioprotective doses later in the program;
else if dencom='143' and dosge='40199' then dose=80;
else if dencom='143' and dosge='51244' then dose=325;
else if dencom='143' and dosge='52216' then dose=325;

qtmed=input(qtmed, 12.);

if qtmed>0 then do;
ddose=(dose*qtmed)/(durtxt*1000); 
daydose=round(ddose, .1);/*daily dose of NSAID or ASA*/
end;
run;

data qtmednot0;
set rx1;
if qtmed=0 then delete;
run;
* N=901 observations deleted. No medication served;

data check2;
set qtmednot0(where=(dosge=0));
run;
* 110 observations. All value durtxt=1 and qtmed=1000. Various NSAIDs, no ASA, all durations of treatment are 1 day;

data dosgenot0;
set qtmednot0;
if dosge=0 then delete;
run;
* N=110 observations deleted. No dosage and quantity served for 1 day. Cannot contribute to definition of recency-duration-dose exposure;

data check3;
set dosgenot0(where=(dosge=0 or qtmed=0 or durtxt=0));
run;
* N=99 observations. All have have dosage and amount served. Daily dose and duration of treatment information can be approximated;

data wce.exp1;
set dosgenot0;
run;

* Check that no cases or controls were lost;
proc sort data= wce.exp1; by caseid id ami; run;

data check4;
set wce.exp1; 
by caseid id ami; 
if last.id and ami=1 then output;
run;
* N=21256 observations, no case lost;

data check5;
set wce.exp1; 
by caseid id ami; 
if last.id and ami=0 then output;
run;
* N=212560 observations, no control lost;


/********************************
* Examining NSAIDs Daily Doses  *
********************************/

/* Descriptive analysis of daily doses of each NSAID - Dataset Rx1 containing observations for which daily dose is calculated based on
duration of treament, which is not always reliable*/
proc univariate data=wce.exp1(where=(nap=1));var daydose;run;
proc univariate data=wce.exp1(where=(ibu=1));var daydose;run;
proc univariate data=wce.exp1(where=(dic=1));var daydose;run;
proc univariate data=wce.exp1(where=(cel=1));var daydose;run;
proc univariate data=wce.exp1(where=(rof=1));var daydose;run;
* 1% of highest and lowest observations are highly suspicious. For these, there is an apparent lack of
correspondance between duration of treatment (durtxt) and quantity served (qtmed).
Note that daily dose is calculated based on durtxt and qtmed;

proc sort data=wce.exp1; by id datserv daydose; run;

/* Get an first idea of the extent of problematic durations of treatment for each drug */
* This is observed by a daily dose that is out of usual daily range and probably results from
'prn' (as needed) prescriptions where the computer registers a duration of treatment that is not directly related
to the quantity of medication dispensed;

data napprob;
set wce.exp1(where=(daydose>2250 or daydose<125));
if nap=1;
run;
* 357 observations;

data ibuprob;
set wce.exp1(where=(daydose>2400 or daydose<200));
if ibu=1;
run;
* 3482 observations;

data dicprob;
set wce.exp1(where=(daydose>200 or daydose<25));
if dic=1;
run;
* 2289 observations;

data celprob;
set wce.exp1(where=(daydose>800 or daydose<100));
if cel=1;
run;
* 602 observations;

data rofprob;
set wce.exp1(where=(daydose>75 or daydose<12.5));
if rof=1;
run;
* 1160 observations;


/*******************************************************************************
* Correcting Datasets Where NSAIDs Daily Doses Are Outside the Clinical Range  *
*******************************************************************************/

/* Daily dose - Correct duration of treatment */

* We assume that out of range daily doses result erroneous durations of treament when the NSAID is prescribed on 
an 'as needed basis'
We will re-create the most probable duration of treatment for problematic observations for each problematic
dataset (the 'NSAIDprob' datasets and merge them with the main Rx dataset;


/* Daily dose - Check missing values and incompatibility of calculated daily dose with available oral dosage forms */
* Again here we assume that daily doses that do not correspond to available oral dosage forms results from duration of
treatment not corresponding to dispensed quantity on account of "as needed use"

We assign the most likely daily dose so as to translate findings into clinical practice
This is important for the single analysis of RAMQ and for the IPD MA and is essential to do 
for the WCE analysis because the latter models the risk associated with each day dose;


/* Naproxen */
data napdose;
set wce.exp1;
where nap=1;
run;

proc freq data=napdose; tables daydose;run;
* 7 missing daydose values;

data napok;
set napdose;
if daydose in (125,250,375,500,625,750,875,1000,1125,1250,1500,1750,2000,2125,2250);
day_dose=daydose;
dur=durtxt;
run;

proc freq data=napok; tables daydose;run;

data nap_not_ok;
set napdose;
if daydose not in (125,250,375,500,625,750,875,1000,1125,1250,1500,1750,2000,2125,2250);
day_dose=daydose;
dur=durtxt;
run;
* This is 4.9% of naproxen prescriptions and most likely explanation is 'as needed' use;

proc freq data=nap_not_ok; tables daydose;run;
* 7 missing daydose values;

data naporal (drop=ddose); 
set nap_not_ok (where=(dosge=30744)); * 77 observation has dosge='30744' = suspension orale 25mg/mL (474 mL);
ddose=(dose*qtmed)/(durtxt*1000); 
day_dose=round(ddose, .1);
* Round daily dose to nearest available dosage form, using mid-point of categories;
if day_dose < 187.5 then daydose= 125; 
if 187.5 <= day_dose < 312.5 then daydose= 250;
if 312.5 <= day_dose < 437.5 then daydose= 375;
if 437.5 <= day_dose < 562.5 then daydose= 500;
if 562.5 <= day_dose < 687.5 then daydose= 625;
if 687.5 <= day_dose < 812.5 then daydose= 750;
if 812.5 <= day_dose < 937.5 then daydose= 875;
if 937.5 <= day_dose < 1062.5 then daydose= 1000;
if 1062.5 <= day_dose < 1187.5 then daydose= 1125;
if 1187.5 <= day_dose < 1312.5 then daydose= 1250;
if 1312.5 <= day_dose < 1625 then daydose= 1500;
if 1625 <= day_dose < 1875 then daydose= 1750;
if 1875 <= day_dose < 2062.5 then daydose= 2000;
if 2062.5 <= day_dose < 2187.5 then daydose= 2125;
if 2187.5 <= day_dose <=2250  then daydose= 2250;
run;
* WORK.NAPORAL has 77 observations and 23 variables;

* Recall that variable 'quantité de médicament' corresponds to actual dispensing by pharmacist and therefore
is assumed to be reliable in RAMQ raw data; 
* strength are 125 to 750mg therefore it is reasonable to assume once a day prn dosing;
data napfix1;
set nap_not_ok (where=(0<= durtxt<7 and dosge ne 30744)); * ok for durtxt=0;
durtxt=qtmed/1000;
daydose=dose;
run;
* WORK.NAPFIX1 has 720 observations and 23 variables;

data napfix2 (drop=duree);
set nap_not_ok (where=(durtxt>=7 and durtxt<=qtmed/6000 and dosge ne 30744));
daydose=4*dose;
duree=qtmed/4000; 
durtxt=round(duree, 1);
run;
* WORK.NAPFIX2 has 63 observations and 23 variables;

data napfix3 (drop=duree);
set nap_not_ok (where=(durtxt>=7 and qtmed/6000< durtxt<=qtmed/3000 and dosge ne 30744));
daydose=3*dose;
duree=qtmed/3000; 
durtxt=round(duree, 1);
run;
* WORK.NAPFIX3 has 1396 observations and 23 variables;

* Round daily dose to nearest available dosage form, using mid-point of categories;
data napfix4;
set nap_not_ok (where=(durtxt>=7 and qtmed/3000< durtxt<=qtmed/2000 and dosge ne 30744));
if day_dose < 187.5 then daydose= 125; 
if 187.5 <= day_dose < 312.5 then daydose= 250;
if 312.5 <= day_dose < 437.5 then daydose= 375;
if 437.5 <= day_dose < 562.5 then daydose= 500;
if 562.5 <= day_dose < 687.5 then daydose= 625;
if 687.5 <= day_dose < 812.5 then daydose= 750;
if 812.5 <= day_dose < 937.5 then daydose= 875;
if 937.5 <= day_dose < 1062.5 then daydose= 1000;
if 1062.5 <= day_dose < 1187.5 then daydose= 1125;
if 1187.5 <= day_dose < 1312.5 then daydose= 1250;
if 1312.5 <= day_dose < 1625 then daydose= 1500;
if 1625 <= day_dose < 1875 then daydose= 1750;
if 1875 <= day_dose < 2062.5 then daydose= 2000;
if 2062.5 <= day_dose < 2187.5 then daydose= 2125;
if 2187.5 <= day_dose <=2250  then daydose= 2250; 
if 2251 <= day_dose <=2500  then daydose= 2500; 
if day_dose> 2500 then daydose=3000;
run;
*  WORK.NAPFIX4 has 4740 observations and 23 variables;

data napfix5 (drop=duree);
set nap_not_ok (where=(durtxt>=7 and qtmed/2000< durtxt and dosge ne 30744));
if day_dose<= dose then do;
 daydose=dose;
 duree=qtmed/1000; 
 durtxt=round(duree, 1);
 end;

if day_dose > dose then do;
if day_dose < 187.5 then daydose= 125; 
if 187.5 <= day_dose < 312.5 then daydose= 250;
if 312.5 <= day_dose < 437.5 then daydose= 375;
if 437.5 <= day_dose < 562.5 then daydose= 500;
if 562.5 <= day_dose < 687.5 then daydose= 625;
if 687.5 <= day_dose < 812.5 then daydose= 750;
if 812.5 <= day_dose < 937.5 then daydose= 875;
if 937.5 <= day_dose < 1062.5 then daydose= 1000;
if 1062.5 <= day_dose < 1187.5 then daydose= 1125;
if 1187.5 <= day_dose < 1312.5 then daydose= 1250;
if 1312.5 <= day_dose < 1625 then daydose= 1500;
if 1625 <= day_dose < 1875 then daydose= 1750;
if 1875 <= day_dose < 2062.5 then daydose= 2000;
if 2062.5 <= day_dose < 2187.5 then daydose= 2125;
if 2187.5 <= day_dose <=2250  then daydose= 2250; 
if 2251 <= day_dose <=2500  then daydose= 2500; 
if day_dose> 2500 then daydose=3000; 
end;

run;
* WORK.NAPFIX5 has 2946 observations and 23 variables;

data a; set napfix5 (where=(day_dose<=dose)); run; * ok;
data b; set napfix5 (where=(day_dose>dose)); run; * ok;

*  194503+77+720+63+1396+4740+2946= 204445 obs, OK;

proc freq  data=napok; tables daydose;run;
proc freq  data=naporal; tables daydose;run;
proc freq  data=napfix1; tables daydose;run;
proc freq  data=napfix2; tables daydose;run;
proc freq  data=napfix3; tables daydose;run;
proc freq  data=napfix4; tables daydose;run;
proc freq  data=napfix5; tables daydose;run;
* Ok range 125-2250 mg;

proc freq  data=napok; tables durtxt;run;
proc freq  data=naporal; tables durtxt;run;
proc freq  data=napfix1; tables durtxt;run;
proc freq  data=napfix2; tables durtxt;run;
proc freq  data=napfix3; tables durtxt;run;
proc freq  data=napfix4; tables durtxt;run;
proc freq  data=napfix5; tables durtxt;run;
* Ok range 1-360 days;


/* Ibuprofen*/
data ibudose;
set wce.exp1;
where ibu=1;
run;

proc freq data=ibudose; tables daydose;run;

data ibuok;
set ibudose;
if daydose in (200,300,400,600,800,900,1200,1600,1800,2000,2400);
day_dose=daydose;
dur=durtxt;
run;

data ibu_not_ok;
set ibudose;
if daydose not in (200,300,400,600,800,900,1200,1600,1800,2000,2400);
day_dose=daydose;
dur=durtxt;
run;
* This is 21.3% of ibuprofen prescriptions and most likely explanation is 'as needed' use;

proc freq data=ibu_not_ok; tables daydose;run;

data ibufix1;
set ibu_not_ok (where=(0<= durtxt<7)); * ok for durtxt=0;
durtxt=qtmed/1000;
daydose=dose;
run;
* WORK.IBUFIX1 has 4770 observations and 23 variables;

data ibufix2(drop=duree);
set ibu_not_ok (where=(durtxt>=7 and durtxt<=qtmed/6000));
daydose=4*dose;
duree=qtmed/4000; 
durtxt=round(duree, 1);
run;
* WORK.IBUFIX2 has 496 observations and 23 variables;

data ibufix3(drop=duree);
set ibu_not_ok (where=(durtxt>=7 and qtmed/6000< durtxt<=qtmed/3000));
daydose=3*dose;
duree=qtmed/3000; 
durtxt=round(duree, 1);
run;
*  WORK.IBUFIX3 has 5680 observations and 23 variables;

* Round daily dose to nearest available dosage form, using mid-point of categories;
data ibufix4;
set ibu_not_ok (where=(durtxt>=7 and qtmed/3000< durtxt<=qtmed/2000));
if  day_dose < 200 then daydose= 200; 
if  200 <= day_dose < 250 then daydose= 200;  
if  250 <= day_dose < 350 then daydose= 300;
if  350 <= day_dose < 450 then daydose= 400;
if  450 <= day_dose < 700 then daydose= 600;
if  700 <= day_dose < 850 then daydose= 800;
if  850 <= day_dose < 1050 then daydose= 900;
if  1050 <= day_dose < 1400 then daydose= 1200;
if  1400 <= day_dose < 1700 then daydose= 1600;
if  1700 <= day_dose < 1900 then daydose= 1800;
if  1900 <= day_dose < 2100 then daydose= 2000;
if  2100 <= day_dose <= 2400 then daydose= 2400; 
if day_dose> 2400 then daydose=2400; 
run;
* WORK.IBUFIX4 has 3070 observations and 23 variables;

data ibufix5 (drop=duree);
set ibu_not_ok (where=(durtxt>=7 and qtmed/2000< durtxt));
if day_dose<= dose then do;
 daydose=dose;
 duree=qtmed/1000; 
 durtxt=round(duree, 1);
 end;

if day_dose > dose then do;
if  day_dose < 200 then daydose= 200; 
if  200 <= day_dose < 250 then daydose= 200;  
if  250 <= day_dose < 350 then daydose= 300;
if  350 <= day_dose < 450 then daydose= 400;
if  450 <= day_dose < 700 then daydose= 600;
if  700 <= day_dose < 850 then daydose= 800;
if  850 <= day_dose < 1050 then daydose= 900;
if  1050 <= day_dose < 1400 then daydose= 1200;
if  1400 <= day_dose < 1700 then daydose= 1600;
if  1700 <= day_dose < 1900 then daydose= 1800;
if  1900 <= day_dose < 2100 then daydose= 2000;
if  2100 <= day_dose <= 2400 then daydose= 2400; 
if day_dose> 2400 then daydose=2400;
end;
 
run;
*  WORK.IBUFIX5 has 391 observations and 23 variables;

data c; set ibufix5 (where=(day_dose<=dose)); run; * ok;
data d; set ibufix5 (where=(day_dose>dose)); run; * ok;

* 53286+4770+496+5680+3070+391= 67693 obs, OK;

proc freq  data=ibuok; tables daydose;run;
proc freq  data=ibufix1; tables daydose;run;
proc freq  data=ibufix2; tables daydose;run;
proc freq  data=ibufix3; tables daydose;run;
proc freq  data=ibufix4; tables daydose;run;
proc freq  data=ibufix5; tables daydose;run;
* Ok range 200-2400 mg;

proc freq  data=ibuok; tables durtxt;run;
proc freq  data=ibufix1; tables durtxt;run;
proc freq  data=ibufix2; tables durtxt;run;
proc freq  data=ibufix3; tables durtxt;run;
proc freq  data=ibufix4; tables durtxt;run;
proc freq  data=ibufix5; tables durtxt;run;
* Ok range 1-200 days;

/* Diclofenac*/
data dicdose;
set wce.exp1;
where dic=1;
run;

proc freq data=dicdose; tables daydose;run;

data dicok;
set dicdose;
if daydose in (25,50,75,100,150,200);
day_dose=daydose;
dur=durtxt;
run;

data dic_not_ok;
set dicdose;
if daydose not in (25,50,75,100,150,200);
day_dose=daydose;
dur=durtxt;
run;
* This is 6.3% of diclofenac prescriptions and most likely explanation is 'as needed' use;

proc freq data=dic_not_ok; tables daydose;run;


data dicfix1;
set dic_not_ok (where=(durtxt=0));
daydose=dose;
durtxt=round(qtmed/1000, 1);
run;
* WORK.DICFIX1 has 46 observations and 23 variables;

data dicfix2 (drop=duree);
set dic_not_ok (where=(0<durtxt<=qtmed/6000)); 
if dose=100 then do;
 daydose=300;
 durtxt=round(qtmed/3000, 1);
end;

if dose ne 100 then do;
 daydose=4*dose;
 duree=qtmed/4000; 
 durtxt=round(duree, 1);
end;

run;
*  WORK.DICFIX2 has 517 observations and 23 variables;

data dicfix3 (drop=duree);
set dic_not_ok (where=(qtmed/6000< durtxt<=qtmed/3000));
daydose=3*dose;
duree=qtmed/3000; 
durtxt=round(duree, 1);
run;
* WORK.DICFIX3 has 5839 observations and 24 variables;

* Round daily dose to nearest available dosage form, using mid-point of categories;
data dicfix4;
set dic_not_ok (where=(qtmed/3000< durtxt<=qtmed/2000));
if day_dose < 25 then daydose= 25; 
if  25 <= day_dose < 37.5 then daydose= 25; 
if  37.5 <= day_dose < 62.5 then daydose= 50;
if  62.5 <= day_dose < 87.5 then daydose= 75;
if  87.5 <= day_dose < 125 then daydose= 100;
if  125 <= day_dose < 175 then daydose= 150;
if  175 <= day_dose < 200 then daydose= 200; 
if day_dose> 200 then daydose=200;
run;
* WORK.DICFIX4 has 7731 observations and 23 variables;

data dicfix5 (drop=duree);
set dic_not_ok (where=(qtmed/2000< durtxt));
if day_dose<= dose then do;
 daydose=dose;
 duree=qtmed/1000; 
 durtxt=round(duree, 1);
 end;

if day_dose > dose then do;
if day_dose < 25 then daydose= 25; 
if  25 <= day_dose < 37.5 then daydose= 25; 
if  37.5 <= day_dose < 62.5 then daydose= 50;
if  62.5 <= day_dose < 87.5 then daydose= 75;
if  87.5 <= day_dose < 125 then daydose= 100;
if  125 <= day_dose < 175 then daydose= 150;
if  175 <= day_dose < 200 then daydose= 200; 
if day_dose> 200 then daydose=200;
end;

run;
*  WORK.DICFIX4 has 3802 observations and 23 variables;

* 265852+46+517+5839+7731+3802= 283787 obs, OK;

proc freq  data=dicok; tables daydose;run;
proc freq  data=dicfix1; tables daydose;run;
proc freq  data=dicfix2; tables daydose;run;
proc freq  data=dicfix3; tables daydose;run;
proc freq  data=dicfix4; tables daydose;run;
proc freq  data=dicfix5; tables daydose;run;
* Ok range 25-300 mg;

proc freq  data=dicok; tables durtxt;run;
proc freq  data=dicfix1; tables durtxt;run;
proc freq  data=dicfix2; tables durtxt;run;
proc freq  data=dicfix3; tables durtxt;run;
proc freq  data=dicfix4; tables durtxt;run;
proc freq  data=dicfix5; tables durtxt;run;
* Ok range 1-270 days;


/* Celecoxib*/
data celdose;
set wce.exp1;
where cel=1;
run;

proc freq data=celdose; tables daydose;run;

data celok;
set celdose;
if daydose in (100,200,300,400,600,800);
day_dose=daydose;
dur=durtxt;
run;

data cel_not_ok;
set celdose;
if daydose not in (100,200,300,400,600,800);
day_dose=daydose;
dur=durtxt;
run;
* This is 2.3% of celecoxib prescriptions and most likely explanation is 'as needed' use;

proc freq data=cel_not_ok; tables daydose;run;


data celfix1;
set cel_not_ok (where=(0<= durtxt<7));
durtxt=qtmed/1000;
daydose=dose;
run;
* WORK.CELFIX1 has 393 observations and 23 variables;


data celfix2 (drop=duree);
set cel_not_ok (where=(durtxt>=7 and durtxt<=qtmed/6000));
daydose=4*dose;
duree=qtmed/4000; 
durtxt=round(duree, 1);
run;
* WORK.CELFIX2 has 15 observations and 23 variables;

data celfix3 (drop=duree);
set cel_not_ok (where=(durtxt>=7 and qtmed/6000< durtxt<=qtmed/3000));
daydose=3*dose;
duree=qtmed/3000; 
durtxt=round(duree, 1);
run;
*  WORK.CELFIX3 has 556 observations and 23 variables;

* Round daily dose to nearest available dosage form, using mid-point of categories;
data celfix4;
set cel_not_ok (where=(durtxt>=7 and qtmed/3000< durtxt<=qtmed/2000));
if day_dose < 100 then daydose= 100; 
if  100 <= day_dose < 150 then daydose= 100;
if  150 <= day_dose < 250 then daydose= 200;
if  250 <= day_dose < 350 then daydose= 300;
if  350 <= day_dose < 500 then daydose= 400;
if  500 <= day_dose < 700 then daydose= 600;
if  700 <= day_dose <= 800 then daydose= 800;
if day_dose> 800 then daydose=800;
run;
* WORK.CELFIX4 has 2618 observations and 23 variables;

data celfix5 (drop=duree);
set cel_not_ok (where=(durtxt>=7 and qtmed/2000< durtxt));
if day_dose<= dose then do;
 daydose=dose;
 duree=qtmed/1000; 
 durtxt=round(duree, 1);
 end;

if day_dose > dose then do;
if day_dose < 100 then daydose= 100; 
if  100 <= day_dose < 150 then daydose= 100;
if  150 <= day_dose < 250 then daydose= 200;
if  250 <= day_dose < 350 then daydose= 300;
if  350 <= day_dose < 500 then daydose= 400;
if  500 <= day_dose < 700 then daydose= 600;
if  700 <= day_dose <= 800 then daydose= 800;
if day_dose> 800 then daydose=800;
end;

run;
* WORK.CELFIX5 has 4563 observations and 24 variables;

* 350596+393+15+556+2618+4563 =358741 observations, ok;

proc freq  data=celok; tables daydose;run;
proc freq  data=celfix1; tables daydose;run;
proc freq  data=celfix2; tables daydose;run;
proc freq  data=celfix3; tables daydose;run;
proc freq  data=celfix4; tables daydose;run;
proc freq  data=celfix5; tables daydose;run;
* Ok range 100-800 mg;

proc freq  data=celok; tables durtxt;run;
proc freq  data=celfix1; tables durtxt;run;
proc freq  data=celfix2; tables durtxt;run;
proc freq  data=celfix3; tables durtxt;run;
proc freq  data=celfix4; tables durtxt;run;
proc freq  data=celfix5; tables durtxt;run;
* Ok range 1-360 days;


/* Rofecoxib */
data rofdose;
set wce.exp1;
where rof=1;
run;

proc freq data=rofdose; tables daydose;run;

data rofok;
set rofdose;
if daydose in (12.5,25,37.5,50,75);
day_dose=daydose;
dur=durtxt;
run;

data rof_not_ok;
set rofdose;
if daydose not in (12.5,25,37.5,50,75);
day_dose=daydose;
dur=durtxt;
run;
* This is 3.6% of rofecoxib prescriptions and most likely explanation is 'as needed' use;

proc freq data=rof_not_ok; tables daydose;run;


data roforal (drop=ddose); 
set rof_not_ok (where=(dosge=26413)); 
* 161 observation has dosge='26413' = 12,5 mg/5 mL (150 mL);
ddose=(dose*qtmed)/(durtxt*1000); 
day_dose=round(ddose, .1);
* Round daily dose to nearest available dosage form, using mid-point of categories;
if day_dose <= 2.5 then daydose= 2.5; 
if  12.5 <= day_dose < 18.75 then daydose= 12.5; 
if  18.75 <= day_dose  < 31.25 then daydose= 25;
if  31.25 <= day_dose  < 43.75 then daydose= 37.5;
if  43.75 <= day_dose  < 62.5 then daydose= 50;
if  62.5 <= day_dose  <= 75 then daydose= 75; 
if day_dose> 75 then daydose=75;
run;
* WORK.ROFORAL has 161 observations and 23 variables;

data roffix1;
set rof_not_ok (where=(0<= durtxt<7 and dosge ne 26413));
durtxt=qtmed/1000;
daydose=dose;
run;
* WORK.ROFFIX1 has 379 observations and 23 variables;

/*
data roffix2 (drop=duree);
set rof_not_ok(where=(durtxt>=7 and durtxt<=qtmed/6000 and dosge ne 26413));
daydose=4*dose;
duree=qtmed/4000; 
durtxt=round(duree, 1);
run;
* WORK.ROFFIX2 has 0 observations and 23 variables;
*/

data roffix2 (drop=duree);
set rof_not_ok (where=(durtxt>=7 and qtmed/6000< durtxt<=qtmed/3000 and dosge ne 26413));
daydose=3*dose;
duree=qtmed/3000; 
durtxt=round(duree, 1);
run;
* WORK.ROFFIX2 has 144 observations and 23 variables;

* Round daily dose to nearest available dosage form, using mid-point of categories;
data roffix3;
set rof_not_ok (where=(durtxt>=7 and qtmed/3000< durtxt<=qtmed/2000 and dosge ne 26413)); 
if day_dose < 12.5 then daydose= 25; 
if  12.5 <= day_dose < 18.75 then daydose= 12.5; 
if  18.75 <= day_dose  < 31.25 then daydose= 25;
if  31.25 <= day_dose  < 43.75 then daydose= 37.5;
if  43.75 <= day_dose  < 62.5 then daydose= 50;
if  62.5 <= day_dose  <= 75 then daydose= 75; 
if day_dose> 75 then daydose=75;
run;
*  WORK.ROFFIX3 has 1015 observations and 23 variables;

data roffix4 (drop=duree);
set rof_not_ok (where=(durtxt>=7 and qtmed/2000< durtxt and dosge ne 26413));
if day_dose<= dose then do;
 daydose=dose;
 duree=qtmed/1000; 
 durtxt=round(duree, 1);
 end;

if day_dose > dose then do;
if day_dose < 12.5 then daydose= 25; 
if  12.5 <= day_dose < 18.75 then daydose= 12.5; 
if  18.75 <= day_dose  < 31.25 then daydose= 25;
if  31.25 <= day_dose  < 43.75 then daydose= 37.5;
if  43.75 <= day_dose  < 62.5 then daydose= 50;
if  62.5 <= day_dose  <= 75 then daydose= 75; 
if day_dose> 75 then daydose=75;
end;

run;
* WORK.ROFFIX4 has 6461 observations and 23 variables;

* 221449+161+379+144+1015+6461 =229609 observations, ok;

proc freq  data=rofok; tables daydose;run;
proc freq  data=roforal; tables daydose;run;
proc freq  data=roffix1; tables daydose;run;
proc freq  data=roffix2; tables daydose;run;
proc freq  data=roffix3; tables daydose;run;
proc freq  data=roffix4; tables daydose;run;
* Ok range 2.5-75mg;

proc freq  data=rofok; tables durtxt;run;
proc freq  data=roforal; tables durtxt;run;
proc freq  data=roffix1; tables durtxt;run;
proc freq  data=roffix2; tables durtxt;run;
proc freq  data=roffix3; tables durtxt;run;
proc freq  data=roffix4; tables durtxt;run;
* Ok range 1-365 days;


/* Getting 'other NSAIDs' prescriptions */
* Must also look at other NSAIDs because although dose cannot be analyzed, duration of treatment is accounted
for in determining duration of continuous NSAID exposure and therefore duration of treatment vs quantity of medication
dispensed must be examined;
* NB: In WCE analysis dose and duration of 'other NSAIDs' are not studied and these NSAIDs are 
simply dichotomized for model adjustment;

data other;
set wce.exp1;
where other=1;
run;

data otherok;
set other; 
if qtmed/6000 <= durtxt <= qtmed/200 then ok=1; else ok=0; * Allows for other NSAIds to be
dosed from as often as 6 times a day to prn average of once every 5 days; 
run;

data other_notok;;
set otherok;
if ok=0 then output;
run;
* WORK.OTHER_NOTOK has 632 observations and 22 variables;

data otherok1;
set other; 
if qtmed/6000 <= durtxt <= qtmed/200;
run;

data otherok2;
set otherok (where=(ok=0));
durtxt=qtmed/1000; * Average dose of other NSAIDs to once a day;
if qtmed<1000 then durtxt=1;  * Correct for outliers;
run;
*  WORK.OTHEROK2 has 632 observations and 22 variables;

/*Getting ASA prescriptions*/
data asadose;
set wce.exp1;
where asa=1;
run;

proc freq data=asadose; tables daydose;run;

data asacardio;
set asadose;
if 35<=daydose<=650 or forme=464; * will consider dosage range of 80 mg every other day to 650mg daily as being ASA used for cardioprotection;
if durtxt=0 then durtxt=qtmed/1000;
run;

data asa_not_cardio;
set asadose;
if forme not=464 and (daydose<35 or daydose>650);
if durtxt=0 then durtxt=qtmed/1000;
run;
* WORK.ASA_NOT_CARDIO has 28455 observations and 22 variables;

proc freq data=asa_not_cardio; tables daydose;run;

/* Create new variable for aspirin used prn for reasons other than cardioprotection. Reseat value of asa to 0 */
data asafix1;
set asa_not_cardio;
asa=0; * variable is for aspirin used at cardioprotective dose;
asaother=1; 
run;
* WORK.ASAFIX1 has 28455 observations and 23 variables;


/************************************************************************************ 
Reconstructing Dataset Comprising all NSAIDs and Cardioprotective ASA Prescriptions)*
************************************************************************************/

/* Merging all individual NSAID datasets and the asa dataset */

proc sort data=napok; by caseid id datserv dencom; run;
proc sort data=naporal; by caseid id datserv dencom; run;
proc sort data=napfix1; by caseid id datserv dencom; run;
proc sort data=napfix2; by caseid id datserv dencom; run;
proc sort data=napfix3; by caseid id datserv dencom; run;
proc sort data=napfix4; by caseid id datserv dencom; run;
proc sort data=napfix5; by caseid id datserv dencom; run;
proc sort data=ibuok; by caseid id datserv dencom; run;
proc sort data=ibufix1; by caseid id datserv dencom; run;
proc sort data=ibufix2; by caseid id datserv dencom; run;
proc sort data=ibufix3; by caseid id datserv dencom; run;
proc sort data=ibufix4; by caseid id datserv dencom; run;
proc sort data=ibufix5; by caseid id datserv dencom; run;
proc sort data=dicok; by caseid id datserv dencom; run;
proc sort data=dicfix1; by caseid id datserv dencom; run;
proc sort data=dicfix2; by caseid id datserv dencom; run;
proc sort data=dicfix3; by caseid id datserv dencom; run;
proc sort data=dicfix4; by caseid id datserv dencom; run;
proc sort data=dicfix5; by caseid id datserv dencom; run;
proc sort data=celok; by caseid id datserv dencom; run;
proc sort data=celfix1; by caseid id datserv dencom; run;
proc sort data=celfix2; by caseid id datserv dencom; run;
proc sort data=celfix3; by caseid id datserv dencom; run;
proc sort data=celfix4; by caseid id datserv dencom; run;
proc sort data=celfix5; by caseid id datserv dencom; run;
proc sort data=rofok; by caseid id datserv dencom; run;
proc sort data=roforal; by caseid id datserv dencom; run;
proc sort data=roffix1; by caseid id datserv dencom; run;
proc sort data=roffix2; by caseid id datserv dencom; run;
proc sort data=roffix3; by caseid id datserv dencom; run;
proc sort data=roffix4; by caseid id datserv dencom; run;
proc sort data=otherok1; by caseid id datserv dencom; run;
proc sort data=otherok2; by caseid id datserv dencom; run;
proc sort data=asacardio; by caseid id datserv dencom; run;
proc sort data=wce.exp1; by caseid id datserv dencom; run;
*  WCE.EXP1 has 3777070 observations and 21 variables;


data wce.exp2;
set napok naporal napfix1 napfix2 napfix3 napfix4 napfix5
ibuok ibufix1 ibufix2 ibufix3 ibufix4 ibufix5
dicok dicfix1 dicfix2 dicfix3 dicfix4 dicfix5
celok celfix1 celfix2 celfix3 celfix4 celfix5
rofok roforal roffix1 roffix2 roffix3 roffix4
otherok1 otherok2 asacardio;
by caseid id datserv dencom;
run;

/* Need to identify sources of discrepancy between number of observations in wce.exp1 and wce.exp2 */

*  wce.exp1: N=3777070 - wce.exp2: N=3748615 = N= 28455 observations in wce.exp1 that are not in wce.exp2,
which corresponds to aspirin used prn for reasons other than cardioprotection;

/* Check for duplicate observations;
data napdouble;
merge napok(in=q) napfix1(in=p) napnomiss (in=r);
by caseid id datserv dencom;
if q and p and r;
run;

data ibudouble;
merge ibuok(in=q) ibufix1(in=p)ibunomiss (in=r);
by caseid id datserv dencom;
if q and p and r;
run;

data dicdouble;
merge dicok(in=q) dicfix1(in=p)dicnomiss (in=r);
by caseid id datserv dencom;
if q and p and r;
run;

data celdouble;
merge celok(in=q) celfix1(in=p)celnomiss (in=r);
by caseid id datserv dencom;
if q and p and r;
run;

data rofdouble;
merge rofok(in=q) roffix1(in=p)rofnomiss (in=r);
by caseid id datserv dencom;
if q and p and r;
run;

data otherdouble;
merge otherok1(in=q) otherok2(in=p);
by caseid id datserv dencom;
if q and p;
run;
*/

* Check for zero values;
proc sort data=wce.exp1; by caseid id; run;
proc sort data=wce.exp2; by caseid id; run;

data check1;
set wce.exp2(where=(nap=0 and ibu=0 and dic=0 and cel=0 and rof=0 and other=0 and asa=0));
run;
* 0 observation;

data check2;
set check1;
if qtmed ne 0 then output;
run;
* 0 observation; 

data check3;
set wce.exp2(where=(durtxt=0));
run;
* 0 observation; 

data check4;
merge wce.exp1(in=p) wce.exp2(in=q);
by caseid id;
if p and not q then output;
run;
* 0 observation;

* Check that no cases or controls were lost;
proc sort data= wce.exp2; by caseid id ami; run;

data check5;
set wce.exp2; 
by caseid id ami; 
if last.id and ami=1 then output;
run;
* 21256 observations, no case lost;

data check7;
set wce.exp2; 
by caseid id ami; 
if last.id and ami=0 then output;
run;
* 212560 observations, no controls lost;


/*****************************************************************************************************
* Creating Variables for Dose and Duration (Continuous and Indicator Variables for NSAIDs and Aspirin  *
******************************************************************************************************/

* We start these data steps with the cc cohort i.e by virtue of definition of t0 
(first NSAID Rx after study start)all subjects received an NSAID to be included.
We then determine exposure status in the year before index date;
 
data rx_asa rx_nap rx_ibu rx_dic rx_cel rx_rof rx_other;
   set wce.exp2;
   if asa=1 then output rx_asa;
   else if nap=1 then output rx_nap;
   else if ibu=1 then output rx_ibu;
   else if dic=1 then output rx_dic;
   else if cel=1 then output rx_cel;
   else if rof=1 then output rx_rof;
   else if other=1 then output rx_other;
run;

/* Program for dose and duration created by Lyne Nadeau - Amended by M. Bally (27May2014) to reflect evolving thoughts about
aspirin resistance (e.g. Floyd CN, Ferro A. Mechanisms of aspirin resistance. Pharmacol Ther. 2014 Jan;141(1):69-78.)
*/

/* For defining continuous use grace period is empirically set at 14 days for NSAIDs
(7 days in the recency-weighted cumulative exposure analysis) and 7 days for cardioprotective aspirin */

/********************************************************************************************************************************************
* Method 1 for NSAIDs - Calculate Episode of Drug Use by Using Full Duration of Previous Prescription (Resulting in Extended Drug Episode	*
********************************************************************************************************************************************/

* Create a file of episode, 1 observation per subject episode;
* For this macro: if there are overlaps in duration because a new prescription was filled before the end of duration
  of the previous one, we add the extra number of days at the end of the cumulative episode;
* Note for final dose, if the episode of drug use overlaps the index date we retain the final dose
  It happens that the episode overlaps the index date before we add the last prescription to the episode
  (recall that the last prescription starts at least one day before the index date) 
  in that case we take the last prescription (not the episode) that overlaps the index date to get the last dose
  of NSAID;
* We count as being part of the same episode the prescriptions that have a lag of less than 14 days 
  (changed from lag of 20 days on 27May2014) i.e. if the
  next prescription is dispensed within 14 days of end of duration of the previous prescription (grace period);

%macro med(va);

data step0;
 set rx_&va;
 sd_startt=datserv;  * sd_startt is start date of this prescription (datserv is dispensing date);
 format sd_startt date9.;
 sd_endt=datserv+durtxt-1; * sd_endt is end date of this prescription (durtxt is duration of the Rx);
 * Start of drug use: because we count the day on which the NSAID is dispensed as a day of drug use, we subtract
   one day to determine on what date supply ended;
 format sd_endt date9.;
run;

proc sort data=step0; by caseid id sd_startt sd_endt; run;

data step1 ;
 set step0 ;
 by caseid id;

 if first.id then do;
    epii=1; * (extended) episode number (extended because an episode can have a single prescription or 
              multiple consecutive prescriptions whose durations sum to create an extended episode);
     sd_starte=sd_startt;
     sd_ende=sd_endt;
     epiinrecs=0; * number of records in the (extended) episode;
	 event_dose=.;
	 levent_dose=.;
     end;

   if sd_starte<indexdate<=sd_ende then event_dose=daydose; * daily dose at time of the event;
   if sd_startt<indexdate<=sd_endt then levent_dose=daydose; 

   epiinrecs+1;

   label epiinrecs='# Records in the (extended) episode';
   label sd_starte='Start of extended episode';
   label sd_ende='End of extended episode';
   label epii='Extended episode #';
   label event_dose="Daily dose at time of the event";

   retain epii epiinrecs sd_starte sd_ende  event_dose;

 if not first.id then do;

  if sd_startt>(sd_ende+14) then do; * For NSAIDs, the allowed time lag for 2 consecutive prescriptions to be part of
  same drug episode is 14 days. We count the day on which the NSAID is dispensed as a day of drug use; 
  
    epii+1; * start of a new episode;
    epiinrecs=1;
    sd_starte=sd_startt;
    sd_ende=sd_endt;
    end;

   * extend the current episode: Add the prescription at the end of the previous one;
   * we just add the duration because the new prescription will start the day after the previous one ends;
   if .<sd_startt<=(sd_ende+1) and epiinrecs>1 then sd_ende=sd_ende+durtxt;

   * extend the current episode: If the next prescription is filled within 14 days of the previous one it counts as the same episode
     so we change the end date of the episode for the end date of this new prescription;
   else if (sd_ende+1)<sd_startt<=(sd_ende+14) and epiinrecs>1 then sd_ende=sd_endt; 
 
   if sd_starte<indexdate<=sd_ende then event_dose=daydose;
   * Daily dose: for all subjects the event_dose is the dose of the last prescription:
     1) if the date of the prescription+duration crosses the index date, or
     2) if the date of the episode (starting date end date) crosses the index date
        this can happen if the accumulation duration one after the other brings the
        episode up to the index date even if the last prescription by itself do not cross the index date; 
   end;
run;

data drx_&va (keep=caseid id indexdate epii epiinrecs sd_starte sd_ende daydose event_dose levent_dose sd_startt sd_endt);
 set step1;
 by caseid id epii;
 if last.epii;
 run;

proc sort data=drx_&va; by caseid id epii; run;

data drx_&va (keep=caseid id &va._indexdt  &va.1_use &va._dose &va._ldose &va._dur &va._sd_starte &va._sd_ende);
 set drx_&va;
 by caseid id;
 if last.id;

 if indexdate-365<=sd_ende<indexdate-30 then &va.1_use=1; * use of this NSAID ended 31-365 days before the index date;
 else if indexdate-30<=sd_ende<indexdate then &va.1_use=2; * use of this NSAID ended 1-30 days prior to the index date;
 else if sd_starte<indexdate<=sd_ende then &va.1_use=3; * use of this NSAID overlapped with the index date;

 &va._dose=event_dose;
 &va._ldose=levent_dose;

 if sd_ende>=indexdate then &va._dur=indexdate-sd_starte+1; * duration of the last episode if overlaps the indexdate (current user);
 else if sd_ende<indexdate then &va._dur=sd_ende-sd_starte+1;

 &va._sd_starte=sd_starte;
 &va._sd_ende=sd_ende;
 &va._indexdt=indexdate;
 format &va._sd_starte date9.;
 format &va._sd_ende date9.;
 format &va._indexdt date9.;

run;

proc sort data=drx_&va; by caseid id; run;
run;

%mend;
%med(nap) 
%med(ibu) 
%med(dic) 
%med(cel) 
%med(rof) 
%med(other)


* Note on dose variable:
  xx_dose is the last dose of the built episode (i.e. last dose obtained by building episode with each Rx starting 
  after taking into account duration of previous one)
  xx_ldose is the last dose of the last prescription overlapping index date (without having to create treatment
  episodes);


/********************************************************************************************************************************************
* Method 1 for Aspirin - Calculate Episode of Drug Use by Using Full Duration of Previous Prescription (Resulting in Extended Drug Episode	*
********************************************************************************************************************************************/

* Per Brophy 2007: 'To study the effects of aspirin on the association between NSAIDs and myocardial
infarction, we classified the subjects as current users of aspirin if the duration of the last prescription 
dispensed overlapped with the index date or ended within 30 days of this date. The 30-day grace period was used
to account for aspirin’s irreversible inhibition of platelet aggregation, as well as possible alternate-day 
prescriptions. Consequently the definitions of 'recent' and of 'past' use were amended (see program below);

* Create a file of episode, 1 observation per subject episode;
* For this macro: if there are overlaps in duration because a new prescription was filled before the end of
  duration of the previous one, we add the extra number of days at the end of the cumulative episode;

* In light of evolving thoughts about aspirin resistance, much stricter grace periods are set in this programme.
  We count as being part of the same episode the prescriptions that have a lag of less than 7 days i.e. if the
  next prescription is dispensed within 7 days of end of duration of the previous prescription (grace period)
  Moreover, use is no longer considered as being current on the day after end of prescription duration
  (this is now aligned with definitions of current and recent use of NSAIDs);

%macro asa(va);

data step0;
 set rx_&va;
 sd_startt=datserv;  * sd_startt is start date of this prescription (datserv is dispensing date);
 format sd_startt date9.;
 sd_endt=datserv+durtxt-1; * sd_endt is end date of this prescription (durtxt is duration of the Rx);
 * Start of aspirin use: because we count the day on which the NSAID is dispensed as a day of drug use, we subtract
   one day to determine on what date supply ended;
 format sd_endt date9.;
run;

proc sort data=step0; by caseid id sd_startt sd_endt; run;

data step1 ;
 set step0 ;
 by caseid id;

 if first.id then do;
    epii=1; * (extended) episode number (extended because an episode can have a single prescription or 
              multiple consecutive prescriptions whose durations sum to create an extended episode);
     sd_starte=sd_startt;
     sd_ende=sd_endt;
     epiinrecs=0; * number of records in the (extended) episode;
	 event_dose=.;
	 levent_dose=.;
     end;

   * Aspirin dose: macro same as for NSAIDs however note that the dose of cardioprotective aspirin is not a variable of interest;
   if sd_starte<indexdate<=sd_ende then event_dose=daydose; 
   if sd_startt<indexdate<=sd_endt then levent_dose=daydose; 

   epiinrecs+1;

   label epiinrecs='# Records in the (extended) episode';
   label sd_starte='Start of extended episode';
   label sd_ende='End of extended episode';
   label epii='Extended episode #';
   label event_dose="Daily dose at time of the event";

   retain epii epiinrecs sd_starte sd_ende  event_dose;

 if not first.id then do;

  if sd_startt>(sd_ende+7) then do; * For cardioprotective aspirin, the allowed time lag for 2 consecutive prescriptions 
  to be part of same drug episode is 7 days. We count the day on which the NSAID is dispensed as a day of drug use; 
  
    epii+1; * start of a new episode;
    epiinrecs=1;
    sd_starte=sd_startt;
    sd_ende=sd_endt;
    end;

   * extend the current episode: Add the prescription at the end of the previous one;
   * we just add the duration because the new prescription will start the day after the previous one ends;
   if .<sd_startt<=(sd_ende+1) and epiinrecs>1 then sd_ende=sd_ende+durtxt;

   * extend the current episode: If the next prescription is filled within 7 days of the previous one it counts as the same episode
     so we change the end date of the episode for the end date of this new prescription;
   else if (sd_ende+1)<sd_startt<=(sd_ende+7) and epiinrecs>1 then sd_ende=sd_endt; 
 
   if sd_starte<indexdate<=sd_ende then event_dose=daydose;
   * Daily dose: for all subjects the event_dose is the dose of the last prescription:
     1) if the date of the prescription+duration crosses the index date, or
     2) if the date of the episode (starting date end date) crosses the index date
        this can happen if the accumulation duration one after the other brings the
        episode up to the index date even if the last prescription by itself do not cross the index date; 
   end;
run;


data drx_&va (keep=caseid id indexdate epii epiinrecs sd_starte sd_ende daydose event_dose levent_dose sd_startt sd_endt);
  set step1;
  by caseid id epii;
  if last.epii;
run;

proc sort data=drx_&va; by caseid id epii; run;

data drx_&va (keep=caseid id &va._indexdt &va.1_use &va._dose &va._ldose &va._dur &va._sd_starte &va._sd_ende);
  set drx_&va;
  by caseid id ;
  if last.id;

  /*
  Program formerly was:
  if indexdate-365=<sd_ende<=indexdate-61 then &va.1_use=1;
   * For aspirin category past use is defined as use ending more than 60 days before index date;
  else  if indexdate-60<=sd_ende<=indexdate-31 then &va.1_use=2;
   * For aspirin category recent use is defined as use ending between 31 and 60 days before index date;
  else  if (sd_starte<indexdate and indexdate-31<sd_ende) then &va.1_use=3; 
   * This allows for a 30-day grace period for use to be considered current;
*/

* Modified by M. Bally 27May2014;

if indexdate-365<=sd_ende<indexdate-30 then &va.1_use=1; * use of aspirin ended 31-365 days before the index date;
else if indexdate-30<=sd_ende<indexdate then &va.1_use=2; * use of aspirin ended 1-30 days prior to the index date;
else if sd_starte<indexdate<=sd_ende then &va.1_use=3; * use of aspirin overlapped with the index date;


&va._dose=event_dose;
&va._ldose=levent_dose;

if sd_ende>=indexdate then &va._dur=indexdate-sd_starte+1; * duration of the last episode if overlaps the indexdate (current user);
else if sd_ende<indexdate then &va._dur=sd_ende-sd_starte+1;

&va._sd_starte=sd_starte;
&va._sd_ende=sd_ende;
&va._indexdt=indexdate;

format &va._sd_starte date9.;
format &va._sd_ende date9.;
format &va._indexdt date9.;
run;

proc sort data=drx_&va; by caseid id; run;
run;

%mend;
%asa(asa)

/******************************************************************************************************************************
* Method 2 for NSAIDs  - Calculate Episode of Drug Use by Using Newly Issued Prescription (Not Considering Duration of Previous Prescription	*
************************************************************************************************************************************/


* Create a file of episode, 1 observation per subject episode;
* For this macro: if there are overlaps, we do not add them at the end of the cumulative episode but rather we do as if the subject
  changes prescription and we use the newly issued one ;
* Note for final dose, we use the prescription that overlaps the indexdate based on the date of service for the prescription and the date  
  of end of duration (date prescription + duration of treatment);
* We count as being part of the same episode the prescriptions that have a lag of less than 7 days i.e. if the next prescription is dispensed 
  within 7 days of end of duration of the previous prescription (grace period);

**** NOTE: Decision after meeting with JB 2013-03-26
Allow the full amount supplied for a given prescription to contribute to duration of an episode of continuous
use therefore calculate the duration of an episode of continuous use of an NSAID therefore use Method 1
Using Method 2 is slightly more conservative (fewer observations in last 2 categories of the combined
recency-duration-dose indicator variable) however Method 1, which assumes elderly NSAID users will refill
prescriptions in advance but keep dispensed medication for future use, is considered more realistic;

**** For macro programming of Method 2 see any of the Exposure_NSAIDs9304 RAMQ_ programs used in work preliminary
to RAMQ IPD;


/************************************ 
* Creating Master Exposure Dataset *
************************************/

proc sort data=ami.ramq_NCC_cc9304; by caseid id; run;

data wce.exp3;
merge ami.ramq_NCC_cc9304(in=q) drx_asa drx_nap drx_ibu drx_dic drx_cel drx_rof drx_other;
by caseid id; if q;
run;

/* Verifying that there are no observations for start and end of treatment episodes are missing */

* Observations with missing start and end dates for treatment episodes create errors
in the recency-weighted cumulative exposure analysis program and same nested case-control dataset is used for all analysis of RAMQ;

data check8;
set wce.exp3 
(where=(asa_sd_starte=. and asa_sd_ende=. and nap_sd_starte=. and nap_sd_ende=. and ibu_sd_starte=. and ibu_sd_ende=.
and dic_sd_starte=. and dic_sd_ende=. and cel_sd_starte=. and cel_sd_ende=. and rof_sd_starte=. and rof_sd_ende=.
and other_sd_starte=. and other_sd_ende=.)); 
run;
* WORK.CHECK8 has 0 observations and 57 variables.
0 observation with missing start and end of treatment episodes;


/* Creating variables for past, recent, and current use of NSAIDs and aspirin */

data wce.exp4;
set wce.exp3;
by caseid id;

* var1_use takes value 1=past, 2=recent, 3=current, definition differs for NSAIDs and aspirin (see macros);
array ns(7) asa1_use nap1_use ibu1_use dic1_use cel1_use rof1_use other1_use; 
* var2_use is a binary variable indicating whether a subject has ever used or never used (1/0) NSAIDs in the past year;
array ns2(7) asa2_use nap2_use ibu2_use dic2_use cel2_use rof2_use other2_use;
* Past use (use i.e. duration of drug supply ended 31-365 days before the index date);
array nsp(7) asa_puse nap_puse ibu_puse dic_puse cel_puse rof_puse other_puse;
* Recent use (use i.e. duration of drug supply ended 1-30 days before the index date);
array nsr(7) asa_ruse nap_ruse ibu_ruse dic_ruse cel_ruse rof_ruse other_ruse;
* Current use (use i.e. duration of drug supply overlaps with the index date);
array nsc(7) asa_cuse nap_cuse ibu_cuse dic_cuse cel_cuse rof_cuse other_cuse;

tot_nsaid=0;

/* Identifying past, recent, and current users */
do a=1 to 7;
if ns(a)=. then ns(a)=0;
if  ns(a)>0 then ns2(a)=1;else ns2(a)=0; * ever users;
if  ns(a)=1 then nsp(a)=1;else nsp(a)=0; * past users;
if  ns(a)=2 then nsr(a)=1;else nsr(a)=0; * recent users;
if  ns(a)=3 then nsc(a)=1;else nsc(a)=0; * Current users;


if a>1 then do; * NSAIDs are naproxen, ibuprofen, diclofenac, celecoxib, rofecoxib and others
therefore have to put >1;
tot_nsaid=tot_nsaid+ns2(a);/*total number of NSAIDs used in the last year (current+recent+past)*/
end;
 end;

/* Creating duration variables for current users */

* Variable _dur has a value irrespective of whether the subject is a current, recent or past user;
array cdur(7) asa_cdur nap_cdur ibu_cdur dic_cdur cel_cdur rof_cdur other_cdur;
array dura(7) asa_dur nap_dur ibu_dur dic_dur cel_dur rof_dur other_dur;
do b=1 to 7;
if nsc(b)=. then nsc(b)=0;
if nsc(b)=1 then cdur(b)=dura(b);
end;

 /* Creating binary duration variables for current users of NSAIDs */

array wk(6) nap_week ibu_week dic_week cel_week rof_week other_week;
array short(6) nap_short ibu_short dic_short cel_short rof_short other_long;
array long(6) nap_long ibu_long dic_long cel_long rof_long other_long;
array curdur(6) nap_cdur ibu_cdur dic_cdur cel_cdur rof_cdur other_cdur;
do c=1 to 6;

if   1<=curdur(c)<=7 then wk(c)=1; else wk(c)=0;  * Current continuous duration of use 1-7 days;
if   8<=curdur(c)<=30 then short(c)=1;else short(c)=0; * Current continuous duration of use 8-30 days;
if   30<curdur(c)then long(c)=1;else long(c)=0;  * Current continuous duration of use >30 days;
end;

/* Creating binary variables to define low and high daily doses of current use of NSAIDs */

array lo(5) naplow ibulow diclow cellow roflow;
array hi(5) naphi ibuhi dichi celhi rofhi;
do d=1 to 5;
 lo(d)=0; 
 hi(d)=0; 
end;
  if nap_dose ne . then do;
	if nap_dose <=750 then naplow=1;  /*if current dose of naproxen <=750 mg then daily dose is low*/
	if nap_dose >750 then naphi=1; 
 end;
 if ibu_dose ne . then do;
	if ibu_dose <=1200 then ibulow=1; 
	if ibu_dose >1200 then ibuhi=1; 
 end;
 if dic_dose ne . then do;
	if dic_dose <=100 then diclow=1;  
	if dic_dose >100 then dichi=1; 
 end;
 if cel_dose ne . then do;
	if cel_dose <=200 then cellow=1;
	if cel_dose >200 then celhi=1;
 end;
 if rof_dose ne . then do;
	if rof_dose <=25 then roflow=1;
	if rof_dose >25 then rofhi=1;
 end;
* Note that for 'asa' and 'other' we have no interest in dose or related variables;


/* Creating indicator variables to define NSAIDs exposure*/

* 1= No use (no use of this NSAID in year prior to index date [PTID]) 
2= Past use (use of this NSAID ended 31-365 days PTID)
3= Recent use (use of this NSAID ended 1-30 days PTID)
4= Current use of this NSAID – Continuous duration 1-7 days (low or high dose)
5= Current use of this NSAID – Continuous duration  8-30 days and low dose 
6= Current use of this NSAID – Continuous duration  8-30 days and high dose
7= Current use of this NSAID  – Continuous duration  >30 days and low dose
8= Current use of this NSAID  – Continuous duration  >30 days and high dose; 

* For naproxen, ibuprofen, diclofenac, celecoxib, and rofecoxib;
array nns(5) nap1_use ibu1_use dic1_use cel1_use rof1_use;
array nsf(5)  nap_fuse ibu_fuse dic_fuse cel_fuse rof_fuse;
array nsd(5)  nap_dur ibu_dur dic_dur cel_dur rof_dur;

array nslo(5) naplow ibulow diclow cellow roflow;
array nshi(5) naphi ibuhi dichi celhi rofhi;

do e=1 to 5;
 if nns(e)=0 then nsf(e)=1; * No use (no use of this NSAID in year prior to index date [PTID]);
 if nns(e)=1 then nsf(e)=2; * Past use (use of this NSAID ended 31-365 days PTID); 
 if nns(e)=2 then nsf(e)=3; * Recent use (use of this NSAID ended 1-30 days PTID);

 if nns(e)=3 then do;
  if   1<=nsd(e)<=7 then nsf(e)=4; *Current use of this NSAID – Continuous duration 1-7 days (low or high dose); 
  if   8<=nsd(e)<=30 and nslo(e)=1 then nsf(e)=5; *Current use of this NSAID – Continuous duration  8-30 days and low dose; 
  if   8<=nsd(e)<=30 and nshi(e)=1 then nsf(e)=6; *Current use of this NSAID – Continuous duration  8-30 days and high dose; 
  if   30<nsd(e)     and nslo(e)=1 then nsf(e)=7; *Current use of this NSAID – Continuous duration  >30 days and low dose; 
  if   30<nsd(e)     and nshi(e)=1 then nsf(e)=8; *Current use of this NSAID - Continuous duration  >30 days and high dose; 
 end;
end;
* Grouped NSAIDs 'other' needs separate coding because dose is not included in the indicator variable;
 if other1_use=0 then other_fuse=1; * No use (no use of 'other' NSAIDs in year prior to index date [PTID]);
 if other1_use=1 then other_fuse=2; * Past use (use of 'other' NSAIDs  ended 31-365 days PTID); 
 if other1_use=2 then other_fuse=3; * Recent use (use of 'other' NSAIDs ended 1-30 days PTID);
 if other1_use=3 then do;
  if   1<=other_dur<=7 then other_fuse=4;
  if   8<=other_dur<=30 then other_fuse=5; *Current use of 'other' NSAIDs - Continuous duration 8-30 days;
  if   30<other_dur    then other_fuse=7; *Current use of 'other' NSAIDs - Continuous duration >30 days;
 end;


/* Identifying unexposed */

if tot_nsaid=0 then unexp=1; else unexp=0; * unexposed i.e no use in the year prior to index date;

drop a b c d e asa_dose asa_ldose other_dose other_ldose; 
run;

/* Changing missing values for 0s in final dataset */

* NOTE: For the adjusted analysis of the RAMQ dataset as a single study, will adjust for past and recent use based on variables for
individual NSAIDs (i.e. nsaid_ruse and nsaid_puse variables);

data wce.exp5;
set wce.exp4;

array dura(7) asa_dur nap_dur ibu_dur dic_dur cel_dur rof_dur other_dur;
do a=1 to 7;
if dura(a)=. then dura(a)=0;
end; 

array cdura(7) asa_cdur nap_cdur ibu_cdur dic_cdur cel_cdur rof_cdur other_cdur;
do b=1 to 7;
if cdura(b)=. then cdura(b)=0;
end; 

* Note that variable _dose corresponds to dose in current users;
array dos(6) asa_dose nap_dose ibu_dose dic_dose cel_dose rof_dose;
do c=1 to 6;
if dos(c)=. then dos(c)=0;
end;

drop a b c; 
keep caseid id ami t0 indexdate unexp
cel_fuse cel_puse cel_ruse cel_cuse cel_cdur cel_dur cel_dose cellow  celhi 
dic_fuse dic_puse dic_ruse dic_cuse dic_cdur dic_dur dic_dose diclow dichi
ibu_fuse ibu_puse ibu_ruse ibu_cuse ibu_cdur ibu_dur ibu_dose ibulow ibuhi
nap_fuse nap_puse nap_ruse nap_cuse nap_cdur nap_dur nap_dose naplow naphi 
rof_fuse rof_puse rof_ruse rof_cuse rof_cdur rof_dur rof_dose  roflow rofhi 
other_puse other_ruse other_cuse other_cdur other_dur other_fuse
asa_puse asa_ruse asa_cuse asa_cdur asa_dur;
run;

/* Creating binary variables for categorical recency-dose-duration NSAID variables */
* For naproxen, ibuprofen, diclofenac, celecoxib, and rofecoxib;

data wce.exp6;
set wce.exp5;
array no(5) napno ibuno dicno celno rofno;
array past(5) nappast ibupast dicpast celpast rofpast;
array rec(5) naprec iburec dicrec celrec rofrec;
array onewk(5) napwk ibuwk dicwk celwk rofwk;
array shtlo(5) napshtlo ibushtlo dicshtlo celshtlo rofshtlo;
array shthi(5) napshthi ibushthi dicshthi celshthi rofshthi;
array lglo(5) naplglo ibulglo diclglo cellglo roflglo;
array lghi(5) naplghi ibulghi diclghi cellghi roflghi;
array fuse(5)nap_fuse ibu_fuse dic_fuse cel_fuse rof_fuse; 

do i=1 to 5;
 if no(i)=. then no(i)=0; 
 if past(i)=. then past(i)=0; 
 if rec(i)=. then rec(i)=0; 
 if onewk(i)=. then onewk(i)=0; 
 if shtlo(i)=. then shtlo(i)=0; 
 if shthi(i)=. then shthi(i)=0; 
 if lglo(i)=. then lglo(i)=0; 
 if lghi(i)=. then lghi(i)=0; 

 if fuse(i)=1 then no(i)=1; * No use (no use of this NSAID in year prior to index date [PTID]);
 if fuse(i)=2 then past(i)=1; * Past use (use of this NSAID ended 31-365 days PTID); 
 if fuse(i)=3 then rec(i)=1; * Recent use (use of this NSAID ended 1-30 days PTID);
 if fuse(i)=4 then onewk(i)=1;  *Current use of this NSAID – Continuous duration 1-7 days (low or high dose); 
 if fuse(i)=5 then shtlo(i)=1; *Current use of this NSAID – Continuous duration  8-30 days and low dose; 
 if fuse(i)=6 then shthi(i)=1;  *Current use of this NSAID – Continuous duration  8-30 days and high dose; 
 if fuse(i)=7 then lglo(i)=1;  *Current use of this NSAID – Continuous duration  >30 days and low dose; 
 if fuse(i)=8 then lghi(i)=1;  *Current use of this NSAID - Continuous duration  >30 days and high dose; 
 end;

* Grouped NSAIDs 'other' needs separate coding because dose is not included in the indicator variable;
 otherno=0; otherpast=0; otherrec=0; otherwk=0; othersht=0; otherlg=0;
 if other_fuse=1 then otherno=1; * No use (no use of 'other' NSAIDs in year prior to index date [PTID]);
 if other_fuse=2 then otherpast=1; * Past use (use of 'other' NSAIDs  ended 31-365 days PTID); 
 if other_fuse=3 then otherrec=1; * Recent use (use of 'other' NSAIDs ended 1-30 days PTID);
 if other_fuse=4 then otherwk=1; * Current use of 'other' NSAIDs - Continuous duration 1-7 days;
 if other_fuse=5 then othersht=1; * Current use of 'other' NSAIDs - Continuous duration 8-30 days;
 if other_fuse=7 then otherlg=1; * Current use of 'other' NSAIDs - Continuous duration >30 days;

drop i;
run;

/********************************
* Exposure Data Verifications	*
********************************/

data check9;
set wce.exp4(where=(cel_dose ne cel_ldose));
run;
* 387 observations not equal to 0. This occurs because cel_ldose is a missing value. 
Recall that variables xx_ldose are created with prescription dates and not based on episode dates, 
which may be later than actual prescription date;

proc freq data=wce.exp6; table ami; run;
* 21256 AMI cases, OK;

proc freq data=wce.exp6; 
tables unexp*nap_puse*ibu_puse*dic_puse*cel_puse*rof_puse*other_puse
nap_ruse*ibu_ruse*dic_ruse*cel_ruse*rof_ruse*other_ruse
nap_cuse*ibu_cuse*dic_cuse*cel_cuse*rof_cuse*other_cuse/list missing; run; 

proc freq data=wce.exp6; tables unexp*napno*ibuno*dicno*celno*rofno*otherno/list missing; run; *ok;

proc freq data=wce.exp6; tables cel_fuse*celno*celpast*celrec*celwk*celshtlo*celshthi*cellglo*cellghi /list missing; run; 
proc freq data=wce.exp6; tables dic_fuse*dicno*dicpast*dicrec*dicwk*dicshtlo*dicshthi*diclglo*diclghi /list missing; run; 
proc freq data=wce.exp6; tables ibu_fuse*ibuno*ibupast*iburec*ibuwk*ibushtlo*ibushthi*ibulglo*ibulghi /list missing; run; 
proc freq data=wce.exp6; tables nap_fuse*napno*nappast*naprec*napwk*napshtlo*napshthi*naplglo*naplghi /list missing; run; 
proc freq data=wce.exp6; tables rof_fuse*rofno*rofpast*rofrec*rofwk*rofshtlo*rofshthi*roflglo*roflghi /list missing; run; 
proc freq data=wce.exp6; tables other_fuse*otherno*otherpast*otherrec*otherwk*othersht*otherlg/list missing; run; 
* OK;


/******************************************
* Creating Permanent Dataset for Exposure 
******************************************/

proc sort data=wce.exp6; by caseid id; run;


data ami.ramq_NCC_exp9304;
retain caseid id ami t0 indexdate unexp 
cel_puse cel_ruse cel_cuse cel_cdur cel_dose cel_fuse celno celpast celrec celwk celshtlo celshthi cellglo cellghi cellow  celhi cel_dur  
dic_puse dic_ruse dic_cuse dic_cdur dic_dose dic_fuse dicno dicpast dicrec dicwk dicshtlo dicshthi diclglo diclghi diclow dichi dic_dur 
ibu_puse ibu_ruse ibu_cuse ibu_cdur ibu_dose ibu_fuse ibuno ibupast iburec ibuwk  ibushtlo ibushthi ibulglo ibulghi ibulow ibuhi ibu_dur  
nap_puse nap_ruse nap_cuse nap_cdur nap_dose nap_fuse napno nappast naprec napwk napshtlo napshthi naplglo naplghi naplow naphi nap_dur 
rof_puse rof_ruse rof_cuse rof_cdur rof_dose rof_fuse rofno rofpast rofrec rofwk rofshtlo rofshthi roflglo roflghi roflow rofhi rof_dur 
other_puse other_ruse other_cuse other_cdur other_dur other_fuse otherno otherpast otherrec otherwk othersht otherlg
asa_puse asa_ruse asa_cuse asa_cdur asa_dur ; 
set wce.exp6;
run;

proc sort data=ami.ramq_NCC_exp9304; by caseid id; run;


/*********************************
* Descriptive Analysis of Exposure
**********************************/

/* Proportion of current NSAID use by drug, past use, and non-use, by case and control status */
ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Current exposure - By case and control status.rtf' style=analysis; 
title1 'RAMQ nested case control dataset for analysis as a single study';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'NSAID use defined as current exposure - Proportion of subjects in each category'; 
title4 'Overall case-control dataset';
proc freq data=ami.ramq_NCC_exp9304;
tables ami*(unexp cel_cuse dic_cuse ibu_cuse nap_cuse rof_cuse other_cuse);
options nodate nonumber;
run;
ods rtf close;


/* NSAID use - Proportions of subjects in each recency-dose-duration category - Overall dataset */
ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Recency-duration-dose exposure - Overall.rtf' style=analysis;  
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'NSAID use defined a multidimensional exposure variable - Proportion of subjects in each recency-dose-duration category'; 
title4 'Overall case-control dataset';
proc freq data=ami.ramq_NCC_exp9304;
tables unexp cel_fuse celno celpast celrec celwk celshtlo celshthi cellglo cellghi 
dic_fuse dicno dicpast dicrec dicwk dicshtlo dicshthi diclglo diclghi
ibu_fuse ibuno ibupast iburec ibuwk  ibushtlo ibushthi ibulglo ibulghi 
nap_fuse napno nappast naprec napwk napshtlo napshthi naplglo naplghi
rof_fuse rofno rofpast rofrec rofwk rofshtlo rofshthi roflglo roflghi
other_fuse otherno otherpast otherrec otherwk othersht otherlg
/list missing;
options nodate nonumber;
run;
ods rtf close;

/* NSAID use - Proportions of subjects in each recency-dose-duration category - By case and control */ 
ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Recency-duration-dose exposure - By cases and controls.rtf' style=analysis;  
title1 'RAMQ nested case control dataset for individual patient data meta-analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'NSAID exposure defined as a multidimensional recency-duration-dose variable - Proportion of subjects in each category'; 
title4 'By cases and controls';
proc freq data=ami.ramq_NCC_exp9304;
tables ami*(cel_fuse celno celpast celrec celwk celshtlo celshthi cellglo cellghi 
dic_fuse dicno dicpast dicrec dicwk dicshtlo dicshthi diclglo diclghi
ibu_fuse ibuno ibupast iburec ibuwk  ibushtlo ibushthi ibulglo ibulghi 
nap_fuse napno nappast naprec napwk napshtlo napshthi naplglo naplghi
rof_fuse rofno rofpast rofrec rofwk rofshtlo rofshthi roflglo roflghi
other_fuse otherno otherpast otherrec otherwk othersht otherlg);
options nodate nonumber;
run;
ods rtf close;

/* Aspirin and NSAID use - Proportions of past, recent, and current use - Overall dataset */
ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Exposure by recency of use - Overall.rtf' style=analysis; 
title1 'RAMQ nested case control dataset for individual patient data meta-analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'NSAID and cardioprotective aspirin exposure defined based on recency of use - Proportion of subjects in each category'; 
title4 'Overall case-control dataset';
proc freq data=ami.ramq_NCC_exp9304;
tables unexp
cel_puse cel_ruse cel_cuse celhi cellow
dic_puse dic_ruse dic_cuse dichi diclow 
ibu_puse ibu_ruse ibu_cuse ibuhi ibulow 
nap_puse nap_ruse nap_cuse naphi naplow  
rof_puse rof_ruse rof_cuse rofhi roflow 
other_puse other_ruse other_cuse
asa_puse asa_ruse asa_cuse 
/list missing;
options nodate nonumber;
run;
ods rtf close;

/* Aspirin and NSAID use - Proportions of past, recent, and current use - By case and control */
ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Exposure by recency of use - Overall.rtf' style=analysis;
title1 'RAMQ nested case control dataset for individual patient data meta-analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'NSAID and cardioprotective aspirin exposure defined based on recency of use - Proportion of subjects in each category'; 
title4 'By cases and controls';
proc freq data=ami.ramq_NCC_exp9304;
tables ami*(unexp
cel_puse cel_ruse cel_cuse celhi cellow
dic_puse dic_ruse dic_cuse dichi diclow 
ibu_puse ibu_ruse ibu_cuse ibuhi ibulow 
nap_puse nap_ruse nap_cuse naphi naplow  
rof_puse rof_ruse rof_cuse rofhi roflow 
other_puse other_ruse other_cuse
asa_puse asa_ruse asa_cuse) 
/list missing;
options nodate nonumber;
run;
ods rtf close;

/* NSAID use - Proportions of high and medium-low daily doses - Overall dataset */
ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Exposure by high- and medium-low daily dose - Overall.rtf' style=analysis; 
title1 'RAMQ nested case control dataset for individual patient data meta-analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'NSAID exposure defined based on daily dose dichomized as high or medium-low - Proportion of subjects in each category'; 
title4 'High dose (mg/day) - celecoxib >200, diclofenac >100, ibuprofen >1200, naproxen >750 rofecoxib >25';
title5 'Overall case-control dataset';
proc freq data=ami.ramq_NCC_exp9304;
tables celhi cellow dichi diclow ibuhi ibulow naphi naplow rofhi roflow/list missing; 
options nodate nonumber;
run;
ods rtf close;


/* NSAID use - Proportions of high and medium-low daily doses - By case and control */
ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Exposure by high- and medium-low daily dose - Overall.rtf' style=analysis;  
title1 'RAMQ nested case control dataset for individual patient data meta-analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'NSAID exposure defined based on daily dose dichomized as high or medium-low - Proportion of subjects in each category'; 
title4 'High dose (mg/day) - celecoxib >200, diclofenac >100, ibuprofen >1200, naproxen >750 rofecoxib >25';
title5 'By cases and controls';
proc freq data=ami.ramq_NCC_exp9304;
tables ami*(celhi cellow dichi diclow ibuhi ibulow naphi naplow rofhi roflow)/list missing; 
options nodate nonumber;
run;
ods rtf close;


/* Aspirin and NSAID use - Mean doses and durations in current users - By cases and controls */
ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Celecoxib doses and durations in current users - By cases and controls.rtf' style=analysis; 
title1 'RAMQ nested case control dataset for individual patient data meta-analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'Celecoxib doses and durations in current user cases and controls';
proc means data= ami.ramq_NCC_exp9304(where=(cel_cuse=1));
var cel_dose cel_cdur; class ami; 
options nodate nonumber;
run;
ods rtf close;

ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Diclofenac daily dose and duration in current users - By cases and controls.rtf' style=analysis; 
title1 'RAMQ nested case control dataset for individual patient data meta-analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'Diclofenac doses and durations in current user cases and controls';
proc means data= ami.ramq_NCC_exp9304(where=(dic_cuse=1));
var dic_dose dic_cdur; class ami; 
options nodate nonumber;
run;
ods rtf close;

ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Ibuprofen daily dose and duration in current users - By cases and controls.rtf' style=analysis; 
title1 'RAMQ nested case control dataset for individual patient data meta-analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'Ibuprofen doses and durations in current user cases and controls';
proc means data= ami.ramq_NCC_exp9304(where=(ibu_cuse=1));
var ibu_dose ibu_cdur; class ami; 
options nodate nonumber;
run;
ods rtf close;

ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Naproxen daily dose and duration in current users - By cases and controls.rtf' style=analysis; 
title1 'RAMQ nested case control dataset for individual patient data meta-analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'Naproxen doses and durations in current user cases and controls';
proc means data= ami.ramq_NCC_exp9304(where=(nap_cuse=1));
var nap_dose nap_cdur; class ami; 
options nodate nonumber;
run;
ods rtf close;

ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Rofecoxib daily dose and duration in current users - By cases and controls.rtf' style=analysis;
title1 'RAMQ nested case control dataset for individual patient data meta-analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'Rofecoxib doses and durations in current user cases and controls';
proc means data= ami.ramq_NCC_exp9304(where=(rof_cuse=1));
var rof_dose rof_cdur; class ami; 
options nodate nonumber;
run;
ods rtf close;

ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Other NSAIDs duration in current users - By cases and controls.rtf' style=analysis; 
title1 'RAMQ nested case control dataset for individual patient data meta-analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'Other NSAIDs durations in current user cases and controls';
proc means data= ami.ramq_NCC_exp9304(where=(other_cuse=1));
var other_cdur; class ami; 
options nodate nonumber;
run;
ods rtf close;

ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - Aspirin duration in current users - By cases and controls.rtf' style=analysis;  
title1 'RAMQ nested case control dataset for individual patient data meta-analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'Aspirin duration of use in current user cases and controls';
proc means data= ami.ramq_NCC_exp9304(where=(asa_cuse=1));
var asa_cdur; class ami; 
options nodate nonumber;
run;
ods rtf close;
