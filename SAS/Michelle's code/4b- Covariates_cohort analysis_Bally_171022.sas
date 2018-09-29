%put &sysdate9;
%let temps1=%sysfunc(time());


/********************************************************************************************************
* AUTHOR:		Michèle Bally (based on Linda Lévesque and Sophie Dell'Aniello							*
*				for RAMQ - AF and Bisphosphonates)					 									*
*				Lyne Nadeau revised codes for hospitalizations (July 2013) and programmed determination *
*				of covariates per indexdate	(Spring - Summer 2014)							         	*
* CREATED:		August 21, 2014 - Includes variables for better objectivated CHD and prior MI			*
* UPDATED																								*
* TITLE:		Covariates NCC WCE_SpSe date based_AMI NSAIDs_RAMQ9304								    *
* OBJECTIVE:	Scenario for determining covariates	in the recency-weighted cumulative exposure			*
*				(WCE) analysis																			*
*				Covariates are determined via a strategy balancing specificity and sensitivity			*
*				This same stategy is also applied to the RAMQ dataset used for inclusion in the			*
*				individual patient data meta-analysis i.e. same time windows as in the					*
*				'Covariates SpSe_AMI NSAIDs_NCC IPD MA_RAMQ9304' and the								*
*				'Covariates Coh WCE_SpSe date based programs however the following program				* 
*				additionally allows for	determining absence or											*
*				presence of comorbidity on "by date basis" (as would be needed for a cohort analysis)	*
*				Hospitalization-, and prescription-defined comorbidities that on causal pathway are		*
* 				assessed only before cohort entry														*
*				Hospitalization-, procedure-, and prescription-defined covariates are determined		*
*				in the period preceding index date for other comorbidities								*
*				(exception: prescriptions for comorbidities without good algorithm to overcome			*
*				low specificity of drug treatment are assessed in the year preceding index date)		*
*				Concomitant drugs are assessed in the 30 days preceding index date						*
*				Using a RAMQ cohort of new NSAID users (no NSAID use in year prior to cohort entry)		*
*				for the time period from 01JAN1993 to 30SEP2004	with nested-case-control sampling		*
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
proc contents data= ami.ramq_NCC_cc9304; run;
proc contents data= ami.ramq_NCC_exp9304; run;

proc sort data= ami.ramq_basecoh9304; by id; run; * Program Base cohort_AMI NSAIDs_NCC IPD MA and WCE__RAMQ9304;
proc sort data= ami.ramq_coh_ami9304; by id; run; * Program Outcome_AMI NSAIDs_NCC IPD MA and WCE_RAMQ9304;
proc sort data= ami.ramq_NCC_cc9304; by id; run; * Program NCC sampling_AMI NSAIDs_NCC IPD MA and WCE_RAMQ9304;
proc sort data= ami.ramq_NCC_exp9304; by id; run; * Program Exposure_AMI NSAIDs_NCC IPD MA and WCE_RAMQ9304;

proc freq data=ami.ramq_NCC_exp9304; table ami; run;
* 21256 AMI, OK;


/************************************************
* Rationale for documentation of covariates  	*
************************************************/

****************************************
*/ Original RAMQ study - 
(ref: Brophy JM, Levesque LE, Zhang B. 
The coronary risk of cyclo-oxygenase-2 inhibitors in patients with a previous myocardial infarction. Heart. 2007:93(2):189-94.) */

Demographic variables were: age (matched) and gender (unmatched)
In the year before cohort entry (first NSAID prescription after study start) documented comorbid conditions were:
hypertension, coronary artery disease, cerebrovascular disease, peripheral vascular disease, previous MI,
congestive heart failure, diabetes, respiratory illness,gastrointestinal ulcer disease, thyroid disorders,
depression/psychiatric illness, and cancer
In the year before cohort entry (first NSAID prescription after study start) documented use of medications was:
low-dose ASA, anticoagulants, oral corticosteroids, and antilipidemic agents
In the year preceding the index date, healthcare utilisation was documented by: hospitalizations (none, >=1),
all doctor visits (<=12, >12), cardiologist visits (none, >=1)
In the year preceding the index date, comorbidity indices were: Charlson index, number of different drugs, 
and chronic disease score;

*******************************************************************************************************************
*/ RAMQ nested case-control dataset included in preliminary IPD MA */

* The rationale for selection of potentially confounding variables and time of assessment is the causal diagram (DAG)
for exposure to NSAIDs and acute myocardial infarction outcome.

*/ List of defined covariates for IPD MA */

* Decision M. Bally and J. Brophy (2013-07-23):
Demographic variables: age (unmatched) and gender (unmatched)
Comorbidities: coronary heart disease, cerebrovascular disease, hypertension, diabetes, 
previous MI, congestive heart failure, peripheral vascular disease, atrial fibrillation, rheumatoid arthritis, 
osteoarthritis, hyperlipidemia, COPD, GI ulcer disease, GI bleed, renal failure (acute and chronic), 
Concomitant specific drugs: low-dose ASA, anticoagulants, oral corticosteroids, and clopidogrel 

*/ Justification for not including certain covariates in the preliminary IPD MA dataset */ 

* Although they were included in the original RAMQ study (Brophy 2007), will not include the following covariates
for the IPD MA: cancer, thyroid disease, or psychiatric disease
Reason is that these three comorbidities are not part of the DAG for NSAID exposure and AMI outcome

* Will include COPD rather than respiratory illness and cerebrovascular disease instead of stroke 
Reasons are that COPD excludes bronchitis and asthma and is therefore preferred over respiratory illness and that
cerebrovascular disease is less restrictive than stroke

* Will not include arrhythmia (but will include atrial fibrillation)because although the causal diagram for 
NSAID exposure and AMI outcome includes arrhythmia, their under documentation is a concern

* Will not include obesity, valvular heart disease, other rheumatic inflammatory diseases because although
these are part of the DAG, obesity is likely very misclassified while valvular heart disease
and other rheumatic inflammatory diseases are most likely to be dropped from model (very low prevalence in RAMQ)

* Will not include antilipidemic agents but will keep the following concomitant drugs: use of anticoagulants, 
use of low-dose ASA, use of oral corticosteroids.
Additionally will include clopidogrel (available for RAMQ and Finland but not Sask or GPRD)
Justified because of antilipidemic agents is already part of definition of hyperlipidemia (therefore collinearity)
and clopidogrel use is included in the DAG for NSAID exposure and AMI outcome and available in RAMQ and Finland

* Healthcare utilisation and comorbidity indices are not available in other IPD MA datasets 
(Finland, GPRD) and will not be defined for the RAMQ IPD MA dataset;

*/ Definition of comorbidities and assessment timepoints for covariates for preliminary work for IPD MA */

* Comorbidities are defined using hospitalizations with or without prescription drugs (plus procedures for CHD)

* For determination of covariates, 3 programs were written with a different time window for 
prescription-defined comorbidities and concomitant drugs: program 'Base covariates' defined for
prescriptions one year prior to cohort entry (similarly to original RAMQ study), 
program 'Index covariates' defined for prescriptions one year prior to cohort entry up to index date
and program 'Index covariates Rx yr PTID' defined for prescriptions one year prior to index date.
These serve as sensitivity analyses.

* In the 2 'Index covariates' programs, hospitalization-defined comorbidities and procedure-defined comorbidities
are determined for the period of one year before cohort entry up to the index date (and not in the one year prior to cohort entry).
For prior MI, can only document for hospitalization in the period before cohort entry. Because AMI is the
outcome, any MI occurring after cohort entry is an cohort exit defining event.
For coronary artery disease, and cerebrovascular disease, will additionally document 
by hospitalisations in the period before the index date.
For hypertension, congestive heart failure, and renal disease, hospitalizations are documented for the period
of one year before cohort entry up to one year prior to index date (see below for justification);

*/ Rationale for change in time period in which covariates are asssessed */

* Change from 'baseline' in Brophy 2007 (i.e. in the year prior to cohort entry)to 'concurrent' in IPD MA is
justified based on:
1) the attempt to more fully capture the occurrence of comorbidities and
2) to minimize the misclassification of these potential confounders, 
considering the longer duration of the RAMQ study re-designed for the IPD MA 
(11.75 years in IPD MA RAMQ study vs 4 years in orignal study - Brophy 2007)

EXCEPTIONS FOR HOSPITALIZATION-DEFINED COVARIATES: 
1) For coronary heart disease and cerebrovascular disease, will additionally document 
by hospitalisations in the period before the index date. The time window is broader for these comorbidities 
a) because they cannot be determined specifically from drug treatments and 
b) because we consider hospitalization codes for CHD or CVD to have good sensitivity. 
A more restrictive time window is likely to miss the presence of these comorbidities.
2) NSAIDs are known to be associated with increases in blood pressure, new onset of congestive heart failure
or its deterioration, and deteriorating renal function. 
Whenever these covariates are defined by hospitalizations, to avoid overadjustment i.e. adjusting for a
variable on the causal pathway (the main analysis is not done with a marginal structural model),
we do not include hospitalizations in the year before index date for these covariates;

******************************************************************************************************************
/* RAMQ nested case-control dataset for final analyses: 1) as single study and 
2) for inclusion in an individual patient data meta-analysis (IPD MA)	 */

* Data available from RAMQ does not allow for markers of severity 
e.g. no measure of BP, renal function or ejection fraction,
for corresponding comorbidities (i.e. HTA, renal disease, CHF) that are also mediators on the causal pathway
between NSAID use and AMI.
Indeed, once a subject is diagnosed with HTA, CHF or renal disease, this is carried forward to cohort exit.
Consequently, a marginal structural model cannot be used in this database study to adjust for these 
time-varying covariates, which depend on previous NSAID exposure;

* For the recency-weighted cumulative exposure (WCE) analysis, comorbidities must be determined concurrently
with time-varying exposure (determination of date of first occurence of each chronic comorbidity);

/* Rationale for choice of time window */

* Four different programs were written for determining covariates:

- For analysis of RAMQ as a single study
  1) a specificity-maximizing strategy (Sp)
  2) a sensitivity-maximizing strategy (Se)
  
  3) a strategy balancing specificity and sensitivity (SpSe)

  These first 3 scenarios determine the presence or absence of each chronic comorbidity and concomitant drug treatment,
  at index date. The time windows for assessing these covariates vary in these three strategies and also depend on the source
  of raw RAMQ data (i.e. hospitalizations, procedures, prescriptions - see below).
  Using same data presentation as in Brophy et al. Heart. 2007:93(2):189-94, the effect of determining comorbidities
  and concomitant drug treatments with reference to different time windows (e.g. before cohort entry, before 
  index date) on inferences on AMI risk with NSAID will be explored in a sensitivity analysis of the RAMQ dataset (single study)

 - For preparing the RAMQ dataset to be used in the IPD MA, the Sp Se-balancing strategy will be applied

 - For preparing the RAMQ dataset to be used in the recency-weighted cumulative exposure (WCE) analysis 
   4) a strategy balancing Se and Sp with the same time windows as the Sp Se-balancing strategy described above is used for the 
      WCE analysis.
	  However, instead of simply assessing presence or absence of each chronic comorbidity and concomitant drug treatment,
      at index date it also determines the date of first occurence of each chronic comorbidity,
	  therefore adjusting for time-varying values of comorbidities and concomitant drug treatments over the cohort duration


1) In the specificity-maximizing strategy (Sp)

a) Hospitalization-defined covariates

Chronic comorbidities (confounders): dm, lip, priormi, chd, cvd, pvd, gibleed, ra
In the year preceding cohort entry

Chronic comorbidities (confounders – no algorithm to overcome low specificity of drug treatment): copd, gi 
In the year preceding cohort entry

Chronic comorbidities (intermediates, on the causal pathway): ht, chf, renal 
In the year preceding cohort entry

b) Procedure-defined covariate	

Chronic comorbidities (confounders): chd
In the year preceding cohort entry

c) Prescription-defined covariates	

Chronic comorbidities (confounders): dm, lip, chd, cvd, pvd, ra
In the year preceding cohort entry

Chronic comorbidities (confounders – no algorithm to overcome low specificity of drug treatment): copd, gi 
In the year preceding cohort entry

Chronic comorbidities (intermediates, on the causal pathway): ht, chf, renal
In the year preceding cohort entry

Concomitant drugs (confounders): cortirx clopi asa
In the year preceding cohort entry


2) In the sensitivity-maximizing strategy (Se)

a) Hospitalization-defined covariates

Chronic comorbidities (confounders): dm, lip, priormi, chd, cvd, pvd, gibleed, ra
In the period preceding index date 
NB: 01Jan1992 is the minimum date in data.hosp the raw data obtained from RAMQ.
With this time window subjects have at least 1 year of hospitalization data before their t0.

Chronic comorbidities (confounders – no algorithm to overcome low specificity of drug treatment): copd, gi 
In the period preceding index date

Chronic comorbidities (intermediates, on the causal pathway): ht, chf, renal 
In the period preceding index date

b) Procedure-defined covariate	

Chronic comorbidities (confounders): chd
In the period preceding index date

c) Prescription-defined covariates	

Chronic comorbidities (confounders): dm, lip, chd, cvd, pvd, ra
In the period preceding index date

Chronic comorbidities (confounders – no algorithm to overcome low specificity of drug treatment): copd, gi 
In the period preceding index date

Chronic comorbidities (intermediates, on the causal pathway): ht, chf, renal
In the period preceding index date

Concomitant drugs (confounders): cortirx clopi asa
In the period preceding index date


3) In the strategy balancing specificity and sensitivity (SpSe)

a) Hospitalization-defined covariates

Chronic comorbidities (confounders): dm, lip, priormi, chd, cvd, pvd, gibleed, ra
In the period preceding index date 
NB: 01Jan1992 is the minimum date in data.hosp the raw data obtained from RAMQ.
With this time window subjects have at least 1 year of hospitalization data before their t0.

Chronic comorbidities (confounders – no algorithm to overcome low specificity of drug treatment): copd, gi 
In the period preceding index date

Chronic comorbidities (intermediates, on the causal pathway): ht, chf, renal 
In the period preceding cohort entry

b) Procedure-defined covariate	

Chronic comorbidities (confounders): chd
In the period preceding index date

c) Prescription-defined covariates	

Chronic comorbidities (confounders): dm, lip, chd, cvd, pvd, ra
In the period preceding index date

Chronic comorbidities (confounders – no algorithm to overcome low specificity of drug treatment): copd, gi  
In the year preceding index date 

Chronic comorbidities (intermediates, on the causal pathway): ht, chf, renal
In the period preceding cohort entry

Concomitant drugs (confounders): cortirx clopi asa
In the 30 days preceding index date;

* Note that the variable used for adjusting for concomitant aspirin use is asa_cuse, which is obtained from the 'Exposure' program
where concomitant cardioprotective aspirin overlaps with the index date;


/*************************************************
* Defining comorbidities using hospitalizations  *
*************************************************/
proc sort data= ami.ramq_NCC_cc9304; by id caseid; run; * sorting added by Lyne Nadeau, need to sort by id first and caseid in second 
since covariates are determined with respect to index date, in a matched CC dataset; 
proc sort data=data.hosp; by id; run;

proc sort data=data.hosp; by id; run;
proc sql;
select max(admit) as max_date format=date9., min(admit) as min_date format=date9.
from data.hosp;
quit;
* variable admit ranges from 01JAN1992 to 31MAR2005;

* Note that hospitalization data are available from 01JAN1992 and that study starts 01JAN1993.
Therefore at least one year of hospitalization history is available for all subjects, (including those for whom t0 is 01JAN1993);

proc sql;
  create table wce.hospwce (keep=id caseid t0 indexdate admit dp dS1--dS15 TXT1--TXT9  DATXT1--DATXT9) as
  select * 
  from  ami.ramq_NCC_cc9304,data.hosp
  where ramq_NCC_cc9304.id=hosp.id and admit ne . and '01Jan92'd<= admit < indexdate;
quit;
*  Table WCE.HOSPWCE created, with 584920 rows and 39 columns;

proc sort data=wce.hospwce; by id caseid admit; run; * Must sort by admission date;

* Want first (dt_) and last (dtl_) admission date for each comorbidity. Since these are chronic diseases or, in the case
of gi or gibleed, affect future use of NSAID, we consider that, in the hospital dataset,
'once diagnosed, always diagnosed';
 
/* Hospitalization-defined comorbidities are determined in the period preceding index date 
for all comorbidities except for hypertension, CHF, and renal disease, which are on the causal pathway and therefore
are determined in the period preceding index cohort entry */

/* dm*/
data wce.pre_hdm;
set wce.hospwce; 
by id caseid;
retain dt_hdm dtl_hdm;
if first.caseid then do; dt_hdm=.; dtl_hdm=.; end;

format dshort0-dshort15 $3. dsll0-dsll15 $4. dslsl0-dslsl15 $5.;
array ds{16} dp--ds15;
array dss{16} dshort0-dshort15;
array dll{16} dsll0-dsll15;
array dlsl{16} dslsl0-dslsl15;

do i=1 to 16;
dss(i)=substr(ds(i),1,3);
dll(i)=substr(ds(i),1,4);
dlsl(i)=substr(ds(i),1,5);
end;

/* 250.0 Diabetes mellitus without mention of complication 250.1 Diabetes with ketoacidosis 
250.2 Diabetes with hyperosmolarity 250.3 Diabetes with other coma 250.4 Diabetes with renal manifestations 
250.5 Diabetes with ophthalmic manifestations 250.6 Diabetes with neurological manifestations 
250.7 Diabetes with peripheral circulatory disorders 250.8 Diabetes with other specified manifestations
250.9 Diabetes with unspecified complication */

if admit ne . and '01Jan92'd<= admit < indexdate then do i=1 to 16; *In the period preceding index date;

if dss{i}='250' then do;
if admit<dt_hdm or dt_hdm=. then dt_hdm=admit; 
if admit>=dt_hdm then dtl_hdm=admit; 
end;
end;

if dt_hdm ne . then hdm=1; else hdm=0;
format dt_hdm dtl_hdm date9.;
drop i;
keep caseid id t0 indexdate admit dt_hdm dtl_hdm hdm;
if  dtl_hdm ne . then output; * First suppress to check ;
run;


proc sort data= wce.pre_hdm; by id caseid; run;
data wce.hdm;
set wce.pre_hdm;
by id caseid;
drop admit;
if last.caseid then output; 
run;

/*lip*/
data wce.pre_hlip;
set wce.hospwce; 
by id caseid;
retain dt_hlip dtl_hlip;
if first.caseid then do; dt_hlip=.; dtl_hlip=.; end;

format dshort0-dshort15 $3. dsll0-dsll15 $4. dslsl0-dslsl15 $5.;
array ds{16} dp--ds15;
array dss{16} dshort0-dshort15;
array dll{16} dsll0-dsll15;
array dlsl{16} dslsl0-dslsl15;

do i=1 to 16;
dss(i)=substr(ds(i),1,3);
dll(i)=substr(ds(i),1,4);
dlsl(i)=substr(ds(i),1,5);
end;

/* 272.0 Pure hypercholesterolemia  272.1 Pure hyperglyceridemia  272.2 Mixed hyperlipidemia  
272.3 Hyperchylomicronemia  272.4 Other and unspecified hyperlipidemia 272.5 Lipoprotein deficiencies
272.7 Lipidoses  272.8 Other disorders of lipoid metabolism  272.9 Unspecified disorder of lipoid metabolism */

/* 272.6 Lipodystrophy not relevant */ 

if admit ne . and '01Jan92'd<= admit < indexdate then do i=1 to 16; *In the period preceding index date;

if '2720'<=dll{i}<='2725' or '2727'<=dll{i}<='2729' then do; 
if admit<dt_hlip or dt_hlip=. then dt_hlip=admit; 
if admit>=dt_hlip then dtl_hlip=admit; 
end;
end;

if dt_hlip ne . then hlip=1; else hlip=0;
format dt_hlip dtl_hlip date9.;
drop i;
keep caseid id t0 indexdate admit dt_hlip dtl_hlip hlip;
if  dtl_hlip ne . then output; * First suppress to check ;
run;


proc sort data= wce.pre_hlip; by id caseid; run;
data wce.hlip;
set wce.pre_hlip;
by id caseid;
drop admit;
if last.caseid then output; 
run;

/*ht*/
data wce.pre_hht;
set wce.hospwce; 
by id caseid;
retain dt_hht dtl_hht;
if first.caseid then do; dt_hht=.; dtl_hht=.; end;

format dshort0-dshort15 $3. dsll0-dsll15 $4. dslsl0-dslsl15 $5.;
array ds{16} dp--ds15;
array dss{16} dshort0-dshort15;
array dll{16} dsll0-dsll15;
array dlsl{16} dslsl0-dslsl15;

do i=1 to 16;
dss(i)=substr(ds(i),1,3);
dll(i)=substr(ds(i),1,4);
dlsl(i)=substr(ds(i),1,5);
end;

/* 401 Essential hypertension 402 Hypertensive heart disease 403 Hypertensive chronic kidney disease
404 Hypertensive heart and chronic kidney disease 405 Secondary hypertension */

if admit ne . and admit < t0 then do i=1 to 16; *In the period preceding cohort entry;

if '401'<=dss{i}<='405' then do;
if admit<dt_hht or dt_hht=. then dt_hht=admit; 
if admit>=dt_hht then dtl_hht=admit; 
end;
end;

if dt_hht ne . then hht=1; else hht=0;
format dt_hht dtl_hht date9.;
drop i;
keep caseid id t0 indexdate admit dt_hht dtl_hht hht;
if  dtl_hht ne . then output; 
run;


proc sort data= wce.pre_hht; by id caseid; run;
data wce.hht;
set wce.pre_hht;
by id caseid;
drop admit;
if last.caseid then output; 
run;

/*priormi*/
data wce.pre_hpriormi;
set wce.hospwce; 
by id caseid;
retain dt_hpriormi dtl_hpriormi;
if first.caseid then do; dt_hpriormi=.; dtl_hpriormi=.; end;

format dshort0-dshort15 $3. dsll0-dsll15 $4. dslsl0-dslsl15 $5.;
array ds{16} dp--ds15;
array dss{16} dshort0-dshort15;
array dll{16} dsll0-dsll15;
array dlsl{16} dslsl0-dslsl15;

do i=1 to 16;
dss(i)=substr(ds(i),1,3);
dll(i)=substr(ds(i),1,4);
dlsl(i)=substr(ds(i),1,5);
end;

/* 410 Acute myocardial infarction 412 Old myocardial infarction */

/*Myocardial infarction was defined as a 
medical claim for hospitalization with ICD-9 code 410.xx (excluding 410.x2, which is used to designate follow-up 
to the initial episode)and a length of stay (LOS) between 3 and 180 days, or death if LOS is <3 days.
This definition for MI has been used in several validation studies using Medicare claims data, yielding a PPV
of 94% for claims-based diagnosis of MI against structured medical chart review. (Wahl PM, et al. 
Validation of claims-based diagnostic and procedure codes for cardiovascular and gastrointestinal serious adverse
events in a commercially-insured population. PDS 2010;19(6):596-603. from Kiyota Y, et al.
Accuracy of Medicare claims-based diagnosis of acute myocardial infarction: estimating positive predictive value
on the basis of review of hospital records. Am Heart J 2004; 148: 99–104. */

if admit ne . and '01Jan92'd<= admit < indexdate then do i=1 to 16; *In the period preceding index date;

if dss{i}='410' or dss{i}='412' then do;
if admit<dt_hpriormi or dt_hpriormi=. then dt_hpriormi=admit; 
if admit>=dt_hpriormi then dtl_hpriormi=admit; 
end;
end;

if dt_hpriormi ne . then hpriormi=1; else hpriormi=0;
format dt_hpriormi dtl_hpriormi date9.;
drop i;
keep caseid id t0 indexdate admit dt_hpriormi dtl_hpriormi hpriormi;
if  dtl_hpriormi ne . then output; 
run;


proc sort data= wce.pre_hpriormi; by id caseid; run;
data wce.hpriormi;
set wce.pre_hpriormi;
by id caseid;
drop admit;
if last.caseid then output; 
run;


/*chd*/
data wce.pre_hchd;
set wce.hospwce; 
by id caseid;
retain dt_hchd dtl_hchd;
if first.caseid then do; dt_hchd=.; dtl_hchd=.; end;

format dshort0-dshort15 $3. dsll0-dsll15 $4. dslsl0-dslsl15 $5.;
array ds{16} dp--ds15;
array dss{16} dshort0-dshort15;
array dll{16} dsll0-dsll15;
array dlsl{16} dslsl0-dslsl15;

do i=1 to 16;
dss(i)=substr(ds(i),1,3);
dll(i)=substr(ds(i),1,4);
dlsl(i)=substr(ds(i),1,5);
end;


/* 411 Other acute and subacute forms of ischemic heart disease 411.0 Postmyocardial infarction syndrome 
411.1 Intermediate coronary syndrome 411.8 Other acute and subacute forms of ischemic heart disease
411.81 Acute coronary occlusion without myocardial infarction 411.8 .....other  413 Angina pectoris 
414 Other forms of chronic ischemic heart disease */

/* 411.0 Postmyocardial infarction syndrome excluded, 412 Old myocardial infarction defines prior MI */
/* ICD-9 411 code has high PPV for UA cases. (Varas-Lorenzo C, et al. Positive predictive value of ICD-9 codes
410 and 411 in the identification of cases of acute coronary syndromes 
in the Saskatchewan Hospital automated database. Pharmacoepidemiol Drug Saf. 2008 Aug:17(8):842-52.)*/ 

if admit ne . and '01Jan92'd<= admit < indexdate then do i=1 to 16; *In the period preceding index date;

if '4111'<=dll{i}<='4119' or '413'<=dss{i}<='414' then do;
if admit<dt_hchd or dt_hchd=. then dt_hchd=admit; 
if admit>=dt_hchd then dtl_hchd=admit; 
end;
end;

if dt_hchd ne . then hchd=1; else hchd=0;
format dt_hchd dtl_hchd date9.;
drop i;
keep caseid id t0 indexdate admit dt_hchd dtl_hchd hchd;
if  dtl_hchd ne . then output; * First suppress to check ;
run;


proc sort data= wce.pre_hchd; by id caseid; run;
data wce.hchd;
set wce.pre_hchd;
by id caseid;
drop admit;
if last.caseid then output; 
run;


/*chd_o*/
* Coronary heart disease objectivated by Dx in first position;
data wce.pre_hchd_o;
set wce.hospwce; 
by id caseid;
retain dt_hchd_o dtl_hchd_o;
if first.caseid then do; dt_hchd_o=.; dtl_hchd_o=.; end;


/* 411 Other acute and subacute forms of ischemic heart disease 411.0 Postmyocardial infarction syndrome 
411.1 Intermediate coronary syndrome 411.8 Other acute and subacute forms of ischemic heart disease
411.81 Acute coronary occlusion without myocardial infarction 411.8 .....other  413 Angina pectoris 
414 Other forms of chronic ischemic heart disease */

/* 411.0 Postmyocardial infarction syndrome excluded, 412 Old myocardial infarction defines prior MI */
/* ICD-9 411 code has high PPV for UA cases. (Varas-Lorenzo C, et al. Positive predictive value of ICD-9 codes
410 and 411 in the identification of cases of acute coronary syndromes 
in the Saskatchewan Hospital automated database. Pharmacoepidemiol Drug Saf. 2008 Aug:17(8):842-52.)*/ 

if admit ne . and '01Jan92'd<= admit < indexdate then do; *In the period preceding index date;

if dp in ('4110', '4111','41181', '41189', '4118', '4119', '41190', '4130', '4131', '4139','4140', '4141', '4148', '4149') then do;
if admit<dt_hchd_o or dt_hchd_o=. then dt_hchd_o=admit; 
if admit>=dt_hchd_o then dtl_hchd_o=admit; 
end;
end;

if dt_hchd_o ne . then hchd_o=1; else hchd_o=0;
format dt_hchd_o dtl_hchd_o date9.;
keep caseid id t0 indexdate admit dt_hchd_o dtl_hchd_o hchd_o;
if  dtl_hchd_o ne . then output; * First suppress to check ;
run;


proc sort data= wce.pre_hchd_o; by id caseid; run;
data wce.hchd_o;
set wce.pre_hchd_o;
by id caseid;
drop admit;
if last.caseid then output; 
run;


/*chf*/
data wce.pre_hchf;
set wce.hospwce; 
by id caseid;
retain dt_hchf dtl_hchf;
if first.caseid then do; dt_hchf=.; dtl_hchf=.; end;

format dshort0-dshort15 $3. dsll0-dsll15 $4. dslsl0-dslsl15 $5.;
array ds{16} dp--ds15;
array dss{16} dshort0-dshort15;
array dll{16} dsll0-dsll15;
array dlsl{16} dslsl0-dslsl15;

do i=1 to 16;
dss(i)=substr(ds(i),1,3);
dll(i)=substr(ds(i),1,4);
dlsl(i)=substr(ds(i),1,5);
end;

/* 428 Heart failure 429 Ill-defined descriptions and complications of heart disease */

/*429.3 Cardiomegaly excluded since not specific enough / 
/* In general, differences in the PPVs for the use of ICD-9 code 428.x alone as compared with its combined use
with other ICD-9 codes were negligible. Studies that included a primary hospital discharge diagnosis of ICD-9 code
428.X had the highest PPV and specificity. This algorithm, however, may compromise sensitivity because many
patients with HF are managed on an outpatient basis. Characteristics of the sample population and details related
to the diagnosis of HF, including whether cases are incident or prevalent, should be considered when choosing
a diagnostic algorithm. (Saczynski JS, Andrade SE, Harrold LR, Tjia J, Cutrona SL, Dodd KS, et al. 
A systematic review of validated methods for identifying heart failure using administrative data. 
Pharmacoepidemiol Drug Saf. 2012:21:129-40.) */

if admit ne . and admit < t0 then do i=1 to 16; *In the period preceding cohort entry;

if '428'<=dss{i}<'429' then do;
if admit<dt_hchf or dt_hchf=. then dt_hchf=admit; 
if admit>=dt_hchf then dtl_hchf=admit; 
end;
end;

if dt_hchf ne . then hchf=1; else hchf=0;
format dt_hchf dtl_hchf date9.;
drop i;
keep caseid id t0 indexdate admit dt_hchf dtl_hchf hchf;
if  dtl_hchf ne . then output; * First suppress to check ;
run;


proc sort data= wce.pre_hchf; by id caseid; run;
data wce.hchf;
set wce.pre_hchf;
by id caseid;
drop admit;
if last.caseid then output; 
run;

/*cvd*/
data wce.pre_hcvd;
set wce.hospwce; 
by id caseid;
retain dt_hcvd dtl_hcvd;
if first.caseid then do; dt_hcvd=.; dtl_hcvd=.; end;

format dshort0-dshort15 $3. dsll0-dsll15 $4. dslsl0-dslsl15 $5.;
array ds{16} dp--ds15;
array dss{16} dshort0-dshort15;
array dll{16} dsll0-dsll15;
array dlsl{16} dslsl0-dslsl15;

do i=1 to 16;
dss(i)=substr(ds(i),1,3);
dll(i)=substr(ds(i),1,4);
dlsl(i)=substr(ds(i),1,5);
end;

/* 430 Subarachnoid hemorrhage 431 Intracerebral hemorrhage 432 Other and unspecified intracranial hemorrhage
433 Occlusion and stenosis of precerebral arteries 434 Occlusion of cerebral arteries
435 Transient cerebral ischemia 436 Acute, but ill-defined, cerebrovascular disease 
437 Other and ill-defined cerebrovascular disease 438 Late effects of cerebrovascular disease */

/* Andrade SE, et al. A systematic review of validated methods for identifying cerebrovascular accident 
or transient ischemic attack using administrative data. PDS. 2012;21:100-28. */

if admit ne . and '01Jan92'd<= admit < indexdate then do i=1 to 16; *In the period preceding index date;

if '430'<=dss{i}<='438' then do;
if admit<dt_hcvd or dt_hcvd=. then dt_hcvd=admit; 
if admit>=dt_hcvd then dtl_hcvd=admit; 
end;
end;

if dt_hcvd ne . then hcvd=1; else hcvd=0;
format dt_hcvd dtl_hcvd date9.;
drop i;
keep caseid id t0 indexdate admit dt_hcvd dtl_hcvd hcvd;
if  dtl_hcvd ne . then output; * First suppress to check ;
run;


proc sort data= wce.pre_hcvd; by id caseid; run;
data wce.hcvd;
set wce.pre_hcvd;
by id caseid;
drop admit;
if last.caseid then output; 
run;

/*pvd*/
data wce.pre_hpvd;
set wce.hospwce; 
by id caseid;
retain dt_hpvd dtl_hpvd;
if first.caseid then do; dt_hpvd=.; dtl_hpvd=.; end;

format dshort0-dshort15 $3. dsll0-dsll15 $4. dslsl0-dslsl15 $5.;
array ds{16} dp--ds15;
array dss{16} dshort0-dshort15;
array dll{16} dsll0-dsll15;
array dlsl{16} dslsl0-dslsl15;

do i=1 to 16;
dss(i)=substr(ds(i),1,3);
dll(i)=substr(ds(i),1,4);
dlsl(i)=substr(ds(i),1,5);
end;

/* 440.0 Atherosclerosis of aorta 440.1 Atherosclerosis of renal artery  440.2 Atherosclerosis of native arteries
of the extremities 440.3 Atherosclerosis of bypass graft of the extremities
440.4 Chronic total occlusion of artery of the extremities 440.8 Atherosclerosis of other specified arteries
440.9 Generalized and unspecified atherosclerosis 443.0 Raynaud's syndrome 443.1 Thromboangiitis obliterans
[Buerger's disease]  443.2 Other arterial dissection 443.8 Other specified peripheral vascular diseases 
443.9 Peripheral vascular disease, unspecified 444.0 Embolism and thrombosis of abdominal aorta 
444.1 Embolism and thrombosis of thoracic aorta 444.2 Embolism and thrombosis of arteries of the extremities
444.8 Embolism and thrombosis of other specified artery 444.9 Embolism and thrombosis of unspecified artery */

/* Patients with peripheral arterial disease were identified using the International Classification of Diseases 
(ICD-9) codes 440, 440.2, or 443.9. 
The broader three-digit code 443 was allowed if it coincided with documentation of a prescription for 
pentoxifylline  on the assumption that all patients who received this prescription were diagnosed 
with peripheral arterial disease (Caro JJ et al. The morbidity and mortality following a diagnosis of 
peripheral arterial disease: Long-term follow-up of a large database. BMC Cardiovasc Disord. 2005)
Coding for PVD  http://campus.ahima.org/audio/2009/RB082009.pdf  */ 

if admit ne . and '01Jan92'd<= admit < indexdate then do i=1 to 16; *In the period preceding index date;

if dss{i}='440' or  '4438'<=dll{i}<='4439' or dll{i}='4442' then do;
if admit<dt_hpvd or dt_hpvd=. then dt_hpvd=admit; 
if admit>=dt_hpvd then dtl_hpvd=admit; 
end;
end;

if dt_hpvd ne . then hpvd=1; else hpvd=0;
format dt_hpvd dtl_hpvd date9.;
drop i;
keep caseid id t0 indexdate admit dt_hpvd dtl_hpvd hpvd;
if  dtl_hpvd ne . then output; * First suppress to check ;
run;


proc sort data= wce.pre_hpvd; by id caseid; run;
data wce.hpvd;
set wce.pre_hpvd;
by id caseid;
drop admit;
if last.caseid then output; 
run;

/*copd*/
data wce.pre_hcopd;
set wce.hospwce; 
by id caseid;
retain dt_hcopd dtl_hcopd;
if first.caseid then do; dt_hcopd=.; dtl_hcopd=.; end;

format dshort0-dshort15 $3. dsll0-dsll15 $4. dslsl0-dslsl15 $5.;
array ds{16} dp--ds15;
array dss{16} dshort0-dshort15;
array dll{16} dsll0-dsll15;f
array dlsl{16} dslsl0-dslsl15;

do i=1 to 16;
dss(i)=substr(ds(i),1,3);
dll(i)=substr(ds(i),1,4);
dlsl(i)=substr(ds(i),1,5);
end;

/* 491 Chronic bronchitis 492 Emphysema 496 Chronic airway obstruction, not elsewhere classified */

/* COPD, like atherosclerosis, is a disease of systemic inflammation and as such may hasten the progression of
atherosclerotic disease and contribute to the higher rate of cardiovascular-related morbidity and death in COPD.
(Han MK, et al. Pulmonary diseases and the heart. Circulation. 2007;116(25):2992-3005.) A random sample of 
200 patients was taken from all 644 patients with a code for COPD (491.2x, 492.8, 496) at two academic medical 
centers between 2005 and 2006. The overall PPV  for the presence of any of the specified codes was 97%.
The positive predictive value for a code of 496 alone was 60% (95% CI 32-84%). 
A more recent study using claims in Ontario, Canada examined the combination of ICD-9 outpatient codes and 
ICD-10 inpatient codes to identify patients with COPD cared for by community providers [19]. 
The combination of one or more outpatient ICD-9 codes (491.xx, 492.xx, 496.xx) or one or more inpatient 
ICD-10 codes (J41, J43, J44) had a sensitivity of 85% and specificity of 78.4% among 113 patients with COPD
and 329 patients without COPD. In the current study the best performing model included: =6 albuterol MDI, 
=3 ipratropium MDI, =1 outpatient ICD-9 code,=1 inpatient ICD-9 code and age 
(Cooke CR, Joo MJ, Anderson SM, Lee TA, Udris EM, Johnson E, Au DH. The validity of using ICD-9 codes and 
pharmacy records to identify patients with chronic obstructive pulmonary disease.
BMC Health Serv Res. 2011 Feb 16;11:37. */

if admit ne . and '01Jan92'd<= admit < indexdate then do i=1 to 16; *In the period preceding index date;

if '491'<=dss{i}<='492' or dss{i}='496' then do;

if admit<dt_hcopd or dt_hcopd=. then dt_hcopd=admit; 
if admit>=dt_hcopd then dtl_hcopd=admit; 
end;
end;

if dt_hcopd ne . then hcopd=1; else hcopd=0;
format dt_hcopd dtl_hcopd date9.;
drop i;
keep caseid id t0 indexdate admit dt_hcopd dtl_hcopd hcopd;
if  dtl_hcopd ne . then output; * First suppress to check ;
run;


proc sort data= wce.pre_hcopd; by id caseid; run;
data wce.hcopd;
set wce.pre_hcopd;
by id caseid;
drop admit;
if last.caseid then output; 
run;

/*gi*/
data wce.pre_hgi;
set wce.hospwce; 
by id caseid;
retain dt_hgi dtl_hgi;
if first.caseid then do; dt_hgi=.; dtl_hgi=.; end;

format dshort0-dshort15 $3. dsll0-dsll15 $4. dslsl0-dslsl15 $5.;
array ds{16} dp--ds15;
array dss{16} dshort0-dshort15;
array dll{16} dsll0-dsll15;
array dlsl{16} dslsl0-dslsl15;

do i=1 to 16;
dss(i)=substr(ds(i),1,3);
dll(i)=substr(ds(i),1,4);
dlsl(i)=substr(ds(i),1,5);
end;

/* 531 Gastric ulcer 531.1 Acute gastric ulcer with perforation  531.10 ... without mention of obstruction
531.11 ... with obstruction 531.3 Acute gastric ulcer without mention of hemorrhage or perforation  
531.30 ... without mention of obstruction  531.31 ... with obstruction
531.5 Chronic or unspecified gastric ulcer with perforation  531.50 ... without mention of obstruction 
531.51 ... with obstruction 531.7 Chronic gastric ulcer without mention of hemorrhage or perforation 
531.70 ... without mention of obstruction  531.71 ... with obstruction 
531.9 Gastric ulcer unspecified as acute or chronic without mention of hemorrhage or perforation 
531.90 ... without mention of obstruction  531.91 ... with obstruction 
532 Duodenal ulcer 532.1 Acute duodenal ulcer with perforation  532.10 ... without mention of obstruction 
532.11 ... with obstruction 532.3 Acute duodenal ulcer without mention of hemorrhage or perforation
532.30 ... without mention of obstruction  532.31 ... with obstruction 
532.5 Chronic or unspecified duodenal ulcer with perforation 532.50 ... without mention of obstruction
532.51 ... with obstruction 532.7 Chronic duodenal ulcer without mention of hemorrhage or perforation
532.70 ... without mention of obstruction 532.71 ... with obstruction
532.9 Duodenal ulcer unspecified as acute or chronic without mention of hemorrhage or perforation
532.90 ... without mention of obstruction 532.91 ... with obstruction 
533.1 Acute peptic ulcer of unspecified site with perforation  533.10 ... without mention of obstruction
533.11 ... with obstruction 533.3 Acute peptic ulcer of unspecified site without mention of hemorrhage 
and perforation 533.30 ... without mention of obstruction 533.31 ... with obstruction
533.5 Chronic or unspecified peptic ulcer of unspecified site with perforation 
533.50 ... without mention of obstruction 533.51 ...  with obstruction 
533.7 Chronic peptic ulcer of unspecified site without mention of hemorrhage or perforation 
533.70 ... without mention of obstruction 533.71 ... with obstruction 
533.9 Peptic ulcer of unspecified site unspecified as acute or chronic without mention of hemorrhage or
perforation 533.90 ... without mention of obstruction 533.91 ... with obstruction 534 Gastrojejunal ulcer
534.1 Acute gastrojejunal ulcer with perforation  534.10 ... without mention of obstruction  
534.11 ... with obstruction 534.3 Acute gastrojejunal ulcer without mention of hemorrhage or perforation
534.30 ... without mention of obstruction  534.31 ... with obstruction 
534.5 Chronic or unspecified gastrojejunal ulcer with perforation  534.50 ... without mention of obstruction
534.51 ... with obstruction 534.7 Chronic gastrojejunal ulcer without mention of hemorrhage or perforation
534.70 … without mention of obstruction  534.71 ... with obstruction 
534.9 Gastrojejunal ulcer unspecified as acute or chronic without mention of hemorrhage or perforation
534.90 ... without mention of obstruction 534.91 ... with obstruction 535 Gastritis and duodenitis
535.0 Acute gastritis 535.00 ... without mention of hemorrhage 535.5 Unspecified gastritis and gastroduodenitis 
535.50 … without mention of hemorrhage  535.6 Duodenitis 535.60 ... without mention of hemorrhage 
536.8 Dyspepsia and other specified disorders of function of stomach */

/* exclude alcohol-related GI codes since alcohol-related Dx are excluded from Sask. 
Also exclude all codes related to GI hemorrhage (see below) */
/* Investigators have consistently demonstrated the accuracy of site-specific codes for gastric (531.xx) and
duodenal ulcer (532.xx) in the identification of UGIE. 
Abraham NS, et al. Validation of administrative data used for the diagnosis of upper gastrointestinal events
following nonsteroidal anti-inflammatory drug prescription.
Aliment Pharmacol Ther. 2006 Jul 45;24(2):299-306.)  */

if admit ne . and '01Jan92'd<= admit < indexdate then do i=1 to 16; *In the period preceding index date;

if dll{i}='5311' or dll{i}='5313' or dll{i}='5345' or dll{i}='5317' or dll{i}='5319'
or dll{i}='5321' or dll{i}='5323' or dll{i}='5325' or dll{i}='5327' or dll{i}='5329'
or dll{i}='5331' or dll{i}='5333' or dll{i}='5335' or dll{i}='5337' or dll{i}='5339' 
or dll{i}='5341' or dll{i}='5343' or dll{i}='5345' or dll{i}='5347' or dll{i}='5349' 
or dlsl{i}='53500' or dlsl{i}='53510' or dlsl{i}='53550' or dlsl{i}='53560' or dlsl{i}='5368' then do; 
if admit<dt_hgi or dt_hgi=. then dt_hgi=admit; 
if admit>=dt_hgi then dtl_hgi=admit; 
end;
end;

if dt_hgi ne . then hgi=1; else hgi=0;
format dt_hgi dtl_hgi date9.;
drop i;
keep caseid id t0 indexdate admit dt_hgi dtl_hgi hgi;
if  dtl_hgi ne . then output; * First suppress to check ;
run;

proc sort data= wce.pre_hgi; by id caseid; run;
data wce.hgi;
set wce.pre_hgi;
by id caseid;
drop admit;
if last.caseid then output; 
run;

/*gibleed*/
data wce.pre_hgibleed;
set wce.hospwce; 
by id caseid;
retain dt_hgibleed dtl_hgibleed;
if first.caseid then do; dt_hgibleed=.; dtl_hgibleed=.; end;

format dshort0-dshort15 $3. dsll0-dsll15 $4. dslsl0-dslsl15 $5.;
array ds{16} dp--ds15;
array dss{16} dshort0-dshort15;
array dll{16} dsll0-dsll15;
array dlsl{16} dslsl0-dslsl15;

do i=1 to 16;
dss(i)=substr(ds(i),1,3);
dll(i)=substr(ds(i),1,4);
dlsl(i)=substr(ds(i),1,5);
end;

/* 531.0 Acute gastric ulcer with hemorrhage 531.2 Acute gastric ulcer with hemorrhage and perforation
531.4 Chronic or unspecified gastric ulcer with hemorrhage 531.6 Chronic or unspecified gastric ulcer with hemorrhage and perforation 532.0 Acute duodenal ulcer with hemorrhage
532.2 Acute duodenal ulcer with hemorrhage and perforation 532.4 Chronic or unspecified duodenal ulcer with hemorrhage 532.6 Chronic or unspecified duodenal ulcer with hemorrhage and perforation
533.0 Acute peptic ulcer of unspecified site with hemorrhage 533.2 Acute peptic ulcer of unspecified site with hemorrhage and perforation 
533.4 Chronic or unspecified peptic ulcer of unspecified site with hemorrhage 
533.6 Chronic or unspecified peptic ulcer of unspecified site with hemorrhage and perforation
534.0 Acute gastrojejunal ulcer with hemorrhage 534.2 Acute gastrojejunal ulcer with hemorrhage and perforation
534.4 Chronic or unspecified gastrojejunal ulcer with hemorrhage
534.6 Chronic or unspecified gastrojejunal ulcer with hemorrhage and perforation  
535.01 Acute gastritis with hemorrhage 535.51 Unspecified gastritis and gastroduodenitis with hemorrhage
535.61 Duodenitis with hemorrhage 578 Gastrointestinal hemorrhage */

/* includes only ‘with hemorrhage’ gibleed codes*/

if admit ne . and '01Jan92'd<= admit < indexdate then do i=1 to 16; *In the period preceding index date;

if dll{i}='5310' or dll{i}='5312' or dll{i}='5314' or dll{i}='5316' or dll{i}='5320' or dll{i}='5322'
or dll{i}='5324' or dll{i}='5326' or dll{i}='5330' or dll{i}='5332' or dll{i}='5334' or dll{i}='5336'
or dll{i}='5340' or dll{i}='5342' or dll{i}='5344' or dll{i}='5346' or dss{i}='578' 
or dlsl(i)='53501' or dlsl(i)='53551' or dlsl(i)='53561' then do;
if admit<dt_hgibleed or dt_hgibleed=. then dt_hgibleed=admit; 
if admit>=dt_hgibleed then dtl_hgibleed=admit; 
end;
end;

if dt_hgibleed ne . then hgibleed=1; else hgibleed=0;
format dt_hgibleed dtl_hgibleed date9.;
drop i;
keep caseid id t0 indexdate admit dt_hgibleed dtl_hgibleed hgibleed;
if  dtl_hgibleed ne . then output; * First suppress to check ;
run;

proc sort data= wce.pre_hgibleed; by id caseid; run;
data wce.hgibleed;
set wce.pre_hgibleed;
by id caseid;
drop admit;
if last.caseid then output; 
run;

/*renal*/
data wce.pre_hrenal;
set wce.hospwce; 
by id caseid;
retain dt_hrenal dtl_hrenal;
if first.caseid then do; dt_hrenal=.; dtl_hrenal=.; end;

format dshort0-dshort15 $3. dsll0-dsll15 $4. dslsl0-dslsl15 $5.;
array ds{16} dp--ds15;
array dss{16} dshort0-dshort15;
array dll{16} dsll0-dsll15;
array dlsl{16} dslsl0-dslsl15;

do i=1 to 16;
dss(i)=substr(ds(i),1,3);
dll(i)=substr(ds(i),1,4);
dlsl(i)=substr(ds(i),1,5);
end;

/* 584 Acute kidney failure 585 Chronic kidney disease (ckd) 586 ra failure, unspecified */
* http://www.inspq.qc.ca/pdf/publications/317-DiabeteCri_Ang.pdf;

if admit ne . and admit < t0 then do i=1 to 16; *In the period preceding cohort entry;

if '584'<=dss{i}<='586' then do;
if admit<dt_hrenal or dt_hrenal=. then dt_hrenal=admit; 
if admit>=dt_hrenal then dtl_hrenal=admit; 
end;
end;

if dt_hrenal ne . then hrenal=1; else hrenal=0;
format dt_hrenal dtl_hrenal date9.;
drop i;
keep caseid id t0 indexdate admit dt_hrenal dtl_hrenal hrenal;
if  dtl_hrenal ne . then output; * First suppress to check ;
run;


proc sort data= wce.pre_hrenal; by id caseid; run;
data wce.hrenal;
set wce.pre_hrenal;
by id caseid;
drop admit;
if last.caseid then output; 
run;

/*ra*/
data wce.pre_hra;
set wce.hospwce; 
by id caseid;
retain dt_hra dtl_hra;
if first.caseid then do; dt_hra=.; dtl_hra=.; end;

format dshort0-dshort15 $3. dsll0-dsll15 $4. dslsl0-dslsl15 $5.;
array ds{16} dp--ds15;
array dss{16} dshort0-dshort15;
array dll{16} dsll0-dsll15;
array dlsl{16} dslsl0-dslsl15;

do i=1 to 16;
dss(i)=substr(ds(i),1,3);
dll(i)=substr(ds(i),1,4);
dlsl(i)=substr(ds(i),1,5);
end;

/* 714 Rheumatoid arthritis and other inflammatory polyarthropathies */

if admit ne . and '01Jan92'd<= admit < indexdate then do i=1 to 16; *In the period preceding index date;

if dss{i}='714' then do;
if admit<dt_hra or dt_hra=. then dt_hra=admit; 
if admit>=dt_hra then dtl_hra=admit; 
end;
end;

if dt_hra ne . then hra=1; else hra=0;
format dt_hra dtl_hra date9.;
drop i;
keep caseid id t0 indexdate admit dt_hra dtl_hra hra;
if  dtl_hra ne . then output; * First suppress to check ;
run;


proc sort data= wce.pre_hra; by id caseid; run;
data wce.hra;
set wce.pre_hra;
by id caseid;
drop admit;
if last.caseid then output; 
run;


/* To finalize hospitalization-based covariates dataset */

proc sort data=wce.hdm; by id caseid; run;
proc sort data=wce.hlip; by id caseid; run;
proc sort data=wce.hht; by id caseid; run;
proc sort data=wce.hpriormi;  by id caseid; run;
proc sort data=wce.hchd; by id caseid; run;
proc sort data=wce.hchd_o; by id caseid; run;
proc sort data=wce.hchf; by id caseid; run;
proc sort data=wce.hcvd; by id caseid; run;
proc sort data=wce.hpvd; by id caseid; run;
proc sort data=wce.hcopd; by id caseid; run;
proc sort data=wce.hgi; by id caseid; run;
proc sort data=wce.hgibleed; by id caseid; run;
proc sort data=wce.hrenal; by id caseid; run;
proc sort data=wce.hra; by id caseid; run;


data wce.hospwce1;
merge wce.hdm wce.hlip wce.hht wce.hpriormi wce.hchd  wce.hchd_o wce.hchf wce.hcvd wce.hpvd wce.hcopd wce.hgi wce.hgibleed
wce.hrenal wce.hra;
by id caseid;
run;

proc sort data= ami.ramq_NCC_cc9304; by caseid id; run;
proc sort data= wce.hospwce1; by caseid id; run;

data hospwce2_datSpSe;
merge ami.ramq_NCC_cc9304 (in=p) wce.hospwce1;
by caseid id; if p;
array hcomorb(14) hdm hlip hht hpriormi hchd hchd_o hchf hcvd hpvd hcopd hgi hgibleed hrenal hra;
do i=1 to 14;
if hcomorb(i) =. then hcomorb(i) =0;
end;
if (hdm+hlip+hht+hpriormi+hchd+hchd_o+hchf+hcvd+hpvd+hcopd+hgi+hgibleed+hrenal+hra)>=1 then hosp=1; else hosp=0;
drop i;
run;

data wce.hospwce2_datSpSe;
retain caseid id t0 indexdate hdm dt_hdm dtl_hdm hlip dt_hlip dtl_hlip hht dt_hht dtl_hht hpriormi dt_hpriormi dtl_hpriormi
hchd dt_hchd dtl_hchd hchd_o dt_hchd_o dtl_hchd_o hchf dt_hchf dtl_hchf hcvd dt_hcvd dtl_hcvd hpvd dt_hpvd dtl_hpvd hcopd dt_hcopd dtl_hcopd hgi dt_hgi dtl_hgi
hgibleed dt_hgibleed dtl_hgibleed hrenal dt_hrenal dtl_hrenal hra dt_hra dtl_hra ;
set hospwce2_datSpSe;
run;

/*************************************************
* Defining comorbidities using procedures        *
*************************************************/

proc sort data= ami.ramq_NCC_cc9304; by id caseid; run;
proc sort data=data.hosp; by id; run;

/* Coronary heart disease can be defined with PCI or CABG (in addition to hospitalizations and prescription
drugs)*/

* Diabetes could have been defined with skin and eye procedures whereas renal failure could have been additionally
 defined by dialysis. This was not implemented in the RAMQ WCE (or IPD) dataset;

* Want first (dt_) and last (dtl_) admission date for each procedure. Since CHD is a chronic diseases we consider that,
in the procedures dataset, 'once diagnosed, always diagnosed';

* Note that hospitalization data are available from 01JAN1992 and that study starts 01JAN1993.
Therefore at least one year of hospitalization history is available for all subjects, (including those for whom t0 is 01JAN1993);

proc sort data=wce.hospwce; by id caseid admit; run;

/* First check procedures */
data wce.procwce1;
set wce.hospwce; 
format txt3c1-txt3c9 $3. ;
array tx(9) txt1-txt9;
array txc(9) txt3c1-txt3c9;
 
if admit ne . and '01Jan92'd<= admit < indexdate then do i=1 to 9; 

txc(i)=substr(tx(i),1,3);

if txc(i)='480' then do;
pci=1;
dt_pci=admit;
end;

if txc(i)='481' then do;
cabg=1;
dt_cabg=admit;
end;

format dt_pci dt_cabg date9.;
drop i;
end;
run;

/* pci */
data wce.pre_pci;
set wce.hospwce; 
by id caseid;
retain dt_pci dtl_pci;
if first.caseid then do; dt_pci=.; dtl_pci=.; end;

format txt3c1-txt3c9 $3. ;
array tx(9) txt1-txt9;
array txc(9) txt3c1-txt3c9;
 
if admit ne . and '01Jan92'd<= admit < indexdate then do i=1 to 9; *In the period preceding index date;

txc(i)=substr(tx(i),1,3);

if txc(i)='480' then do ;
if admit<dt_pci or dt_pci=. then dt_pci=admit; 
if admit>=dt_pci then dtl_pci=admit; 
end;
end;

if dt_pci ne . then pci=1; else pci=0;
format dt_pci dtl_pci date9.;
drop i;
keep caseid id t0 indexdate admit dt_pci dtl_pci pci; 
if  dtl_pci ne . then output;
run;


proc sort data= wce.pre_pci; by id caseid; run;
data wce.pci;
set wce.pre_pci;
by id caseid;
if last.caseid then output; 
run;

/* cabg */
data wce.pre_cabg;
set wce.hospwce; 
by id caseid;
retain dt_cabg dtl_cabg;
if first.caseid then do; dt_cabg=.; dtl_cabg=.; end;

format txt3c1-txt3c9 $3. ;
array tx(9) txt1-txt9;
array txc(9) txt3c1-txt3c9;
 
if admit ne . and '01Jan92'd<= admit < indexdate then do i=1 to 9; *In the period preceding index date;

txc(i)=substr(tx(i),1,3);

if txc(i)='481' then do ;
if admit<dt_cabg or dt_cabg=. then dt_cabg=admit; 
if admit>=dt_cabg then dtl_cabg=admit; 
end;
end;

if dt_cabg ne . then cabg=1; else cabg=0;
format dt_cabg dtl_cabg date9.;
drop i;
keep caseid id t0 indexdate admit dt_cabg dtl_cabg cabg; 
if  dtl_cabg ne . then output; * First suppressed to check;
run;


proc sort data= wce.pre_cabg; by id caseid; run;
data wce.cabg;
set wce.pre_cabg;
by id caseid;
if last.caseid then output; 
run;

/* To finalize procedure-defined covariates dataset */
proc sort data=wce.pci; by id caseid; run;
proc sort data=wce.cabg; by id caseid; run;

data wce.procwce1;
merge wce.pci wce.cabg;
by id caseid;
run;

proc sort data= ami.ramq_NCC_cc9304; by caseid id; run;

proc sort data= wce.procwce1; by caseid id; run;

data procwce2;
merge ami.ramq_NCC_cc9304 (in=p) wce.procwce1;
by caseid id; if p;
array pcomorb(2) cabg pci;
do i=1 to 2;
if pcomorb(i) =. then pcomorb(i) =0;
end;
if (pci+cabg)>=1 then proc=1; else proc=0;
drop i;
run;

data wce.procwce2;
retain caseid id t0 indexdate pci dt_pci dtl_pci cabg dt_cabg dtl_cabg;
set procwce2;
run;


/***********************************************************
* Defining comorbidities using associated drug treatments  *
***********************************************************/

proc sort data= ami.ramq_NCC_cc9304; by id caseid; run;
proc sort data=data.rx_x; by id; run;

proc sql;
select max(datserv) as max_date format=date9., min(datserv) as min_date format=date9.
from data.rx_x;
quit;
* variable datserv ranges from 01JAN1992 to 31MAR2005;

* Note that study dates are 01Jan1993 to 30Sept2004;

proc sql;
create table wce.rxwce (keep=id caseid t0 indexdate datserv dencom dosge forme) as
  select * 
  from  ami.ramq_NCC_cc9304, data.rx_x
  where ramq_NCC_cc9304.id=rx_x.id and datserv ne . and qtmed not=0 and '01Jan92'd<= datserv < indexdate; 
quit;

proc sort data=wce.rxwce;by id caseid datserv; run;

* Not defined by prescriptions: priormi (not specific refer to chd) and gibleed;  

* Want first (dt_) and last (dtl_) prescription date for each comorbidity defined by drugs. 
Since these are chronic diseases or, in the case of GI ulcer disease, a comorbidity that will affect future use of NSAID,
we consider that, in the prescription dataset, 'once diagnosed, always diagnosed';

* Note that prescription data are available from 01JAN1992 and that study starts 01JAN1993.
Therefore at least one year of prescription drug history is available for all subjects, (including those for whom t0 is 01JAN1993);

/*dm*/
data wce.pre_rxdm; 
* doing set dataset (where=(dencom in ...) saves space and speeds up program;
set wce.rxwce (where=(dencom in (00091/*acetohexamide*/, 01937/*chlorpropamide*/, 46056, 47329/*gliclazide*/, 47427, 46799/*glimepiride*/, 04264/*glyburide*/, 
09672, 15184/*tolbutamide*/, 05824, 47208/*metformine*/, 46862/*metformine/rosiglitazone*/, 47151, 46300/*acarbose*/, 
46810/* nateglinide launched March 1, 2002*/, 47357, 46568/*repaglinide*/, 47392, 46678/*pioglitazone*/, 46642, 47371/*rosiglitazone*/,
18348, 39458/*insulin isophane (boeuf)*/, 18335/*insulin isophane (porc)*/, 39133, 46537/*insulin isophane (bœuf et porc)*/,
39523, 43735/*insuline zinc (boeuf)*/, 18296, 47004/*insuline zinc (porc)*/, 39185, 46536/*insulin zinc (bœuf et porc)*/, 
43033/*insulin zinc/isophane (porc), 18309, 39484/*insuline protamine zinc (boeuf)*/, 18322, 39497/*insuline protamine zinc (porc)*/,
39146/*insulin protamine zinc (bœuf et porc)*/, 04823/*insulin globine zinc*/, 04888/*insulin sulfatée*/, 
39159/*insulin semi-lente (bœuf et porc)*/, 41655/*insulin lente(porc)*/, 39120, 46538/*insulin lente (bœuf et porc)*/, 
39172/*insulin ultralente (bœuf et porc)*/, 46603/*human insulin*/, 46602, 44151, 44164, 46592/*human insulin isophane*/,
44502, 44489/*human insulin zinc*/, 45531, 45534, 45405, 45511, 45535/*human insulin zinc/isophane*/, 45415, 44476/*human insulin lente*/,
44996, 45483/*human insulin ultralente*/, 47424, 46798/*insulin aspart*/, 46322, 47206/*insulin lispro*/, 47426/*insulin lispro/protamine*/, 
46607/*insulin lispro isophane*/, 47536/*insuline glargine*/, 45481/*aiguille jetable pour auto-injecteur d'insuline*/, 
41668/*seringue avec aiguille jetable pour insuline*/, 43995, 47350/*réactif quantitatif du glucose dans le sang*/
/*insuline detemir NOC 2005*/)));

by id caseid;

retain dt_rxdm dtl_rxdm;

if first.caseid then do; dt_rxdm=.; dtl_rxdm=.; end;

if datserv<dt_rxdm or dt_rxdm=. then dt_rxdm=datserv; * Sets first date of diagnosis via first time rx is filled (datserv) and keeps that date onward;
if datserv>=dt_rxdm then dtl_rxdm=datserv; * Each time Rx is filled date of diagnosis is updated. This will be used to determined
persistence with antidiabetics ;

if dt_rxdm ne . then rxdm=1; else rxdm=0;
format dt_rxdm dtl_rxdm date9.;
keep caseid id t0 indexdate datserv dt_rxdm dtl_rxdm rxdm; 
run;

proc sort data= wce.pre_rxdm; by id caseid datserv; run;

data wce.rxdm;
set wce.pre_rxdm;
by id caseid;
if last.caseid  then output; * In the period preceding index date;
run;

/*lip*/
data wce.pre_rxlip; 
set wce.rxwce(where=(dencom in (01989/*cholestyramine*/, 44905/*colestipol*/, 47092/*bezafibrate*/, 02067/*clofibrate*/, 45574, 47366, 47373, 46575/*fenofibrate*/,
44879/*gemfibrozil*/, 06887, 19089, 47560/*niacin*/, 38392/*probucol*/, 46355, 47232/*atorvastatin*/, 47272, 46425/*cerivastatin*/, 
47083, 46240/*fluvastatin*/, 45500/*lovastatin*/, 45570, 47169/*pravastatin*/, 46860/*rosuvastatin*/, 45564, 46584/*simvastatin*/, 
47456/*ezetimibe approved May 2003*/))); 
by id caseid;

retain dt_rxlip dtl_rxlip;

if first.caseid then do; dt_rxlip=.; dtl_rxlip=.; end;

if datserv<dt_rxlip or dt_rxlip=. then dt_rxlip=datserv;
if datserv>=dt_rxlip then dtl_rxlip=datserv;

format dt_rxlip dtl_rxlip date9.;
if dt_rxlip ne . then rxlip=1; else rxlip=0;
keep caseid id t0 indexdate datserv dt_rxlip dtl_rxlip rxlip; 
run;

proc sort data= wce.pre_rxlip; by id caseid datserv; run;

data wce.rxlip;
set wce.pre_rxlip;
by id caseid;
if last.caseid  then output; * In the period preceding index date;
run;

/*ht*/
data wce.pre_rxht; 
set wce.rxwce(where=(dencom in (41759/*amiloride*/, 41772/*amiloride/HCTZ*/, 00806/*bendroflumethiazide*/, 01976 /*chlorthalidone*/, 04537/*HCTZ*/,
43397/*indapamide*/, 06110/*methyclothiazide*/, 19440/*metolazone*/, 09763/*triamterene*/, 38458/*spironolactone/HCTZ*/, 
38197, 46772/*triamterene/HCTZ*/, 46457/*nadolol/bendroflumethiazide*/, 46345/*atenolol/chlorthalidone*/, 45408/*pindolol/HCTZ*/, 
47320/*cilazapril/HCTZ*/, 45572/*enalapril/HCTZ*/, 47040/*lisinoril/HCTZ*/, 47449/*perindopril/indapamide*/ 47301/*quinapril/HCTZ*/,
47412, 46760/*candesartan/HCTZ*/, 47534/*eprosartan/HCTZ*/, 47354/*irbesartan/HCTZ*/, 47207/*losartan/HCTZ*/, 47413/*telmisartan/HCTZ*/,
47369/*valsartan/HCTZ*/, 45463/*acebutolol*/, 43670, 46325/*atenolol*/, 47355/*bisoprolol*/, 
45243/*labetalol/*, 38275, 46763, 46780/*metoprolol*/, 40563/*nadolol*/, 42162/*oxprenolol*/, 39016/*pindolol*/, 08229/*propranolol*/,
47049/*benazepril*/, 42071/*captopril*/, 47056, 46194/*cilazapril*/, 45476/*enalapril*/, 
47002/*fosinopril*/, 45576/*lisinopril*/, 47117, 46258/*perindopril*/, 45629/*quinapril*/, 47079, 46216/*ramipril*/, 
47250, 47440/*trandolapril*/, 47309, 46529/*candesartan*/, 47389/*eprosartan*/, 47282, 46459/*irbesartan*/, 47135, 46284, 46441/*losartan*/, 
47333, 46587/*telmisartan*/, 47259, 46418/*valsartan*/, 47006, 47009/*amlodipine*/, 46369, 43228, 47247/*diltiazem*/, 45624/*felodipine*/, 
45571/*nicardipine*/, 42708, 46388, 46469/*nifedipine*/, 40550, 46573/*verapamil*/, 47440/*verapamil/trandolapril*/, 37742/*prazosin*/,
10751/*clonidine*/, 04524/*hydralazine*/06136, 46389/*methyldopa*, 44564/*minoxidil*/, 02834/*digitoxin*/, 02847/*digoxin*/,
47104/*isosorbide-5-mononitrate*/, 03029/*isosorbide dinitrate*/, 09438/*pentaerythritol tetranitrate(Peritrate)*/, 
09919, 42864/*trinitrate de glycéryle*/,03562/*ethacrynic acid*/, 04173/*furosemide*/, 46379/*torsemide*/) 
or (dencom =38314 /*timolol*/ and forme=203)/*tablets*/)); 

by id caseid;
* Retain first;
retain 
dt_diur dt_cdiur dt_bb dt_tim dt_ccb dt_ace dt_arb dt_alpha dt_mischt dt_dig dt_ntg dt_loop
dtl_diur dtl_cdiur dtl_bb dtl_tim dtl_ccb dtl_ace dtl_arb dtl_alpha dtl_mischt dtl_dig dtl_ntg dtl_loop
du_diur du_cdiur du_bb du_tim du_ccb du_ace du_arb du_alpha du_mischt du_dig du_ntg du_loop;
* Note no retain on ddht;

array htdt(12) dt_diur dt_cdiur dt_bb dt_tim dt_ccb dt_ace dt_arb dt_alpha dt_mischt dt_dig dt_ntg dt_loop;
* dt_dig dt_ntg dt_loop: we include digoxin, nitrates and loop diuretics so as to implement algorithm for exclusion of CHF
later in the program;
array htdtl (12) dtl_diur dtl_cdiur dtl_bb dtl_tim dtl_ccb dtl_ace dtl_arb dtl_alpha dtl_mischt dtl_dig dtl_ntg dtl_loop;
array duht(12) du_diur du_cdiur du_bb du_tim du_ccb du_ace du_arb du_alpha du_mischt du_dig du_ntg du_loop;
array ddht(12) dd_diur dd_cdiur dd_bb dd_tim dd_ccb dd_ace dd_arb dd_alpha dd_mischt dd_dig dd_ntg dd_loop;

if first.caseid then do;
do i=1 to 12;
htdt(i)=.;
htdtl(i)=.;
duht (i)=.; 
ddht (i)=.; 
end;
end;


if dencom in (41759/*amiloride*/, 41772/*amiloride/HCTZ*/, 00806/*bendroflumethiazide*/, 01976 /*chlorthalidone*/, 04537/*HCTZ*/,
43397/*indapamide*/, 06110/*methyclothiazide*/, 19440/*metolazone*/, 09763/*triamterene*/, 38458/*spironolactone/HCTZ*/, 
38197, 46772/*triamterene/HCTZ*/)then do;
if datserv<dt_diur or dt_diur=. then dt_diur=datserv;
if datserv>=dt_diur then dtl_diur=datserv;
du_diur=1;dd_diur=1;
end;

if dencom in (46457/*nadolol/bendroflumethiazide*/, 46345/*atenolol/chlorthalidone*/, 45408/*pindolol/HCTZ*/, 47320/*cilazapril/HCTZ*/, 
45572/*enalapril/HCTZ*/, 47040/*lisinoril/HCTZ*/, 47449/*perindopril/indapamide*/ 47301/*quinapril/HCTZ*/, 47412, 46760/*candesartan/HCTZ*/,
47534/*eprosartan/HCTZ*/, 47354/*irbesartan/HCTZ*/, 47207/*losartan/HCTZ*/, 47413/*telmisartan/HCTZ*/, 47369/*valsartan/HCTZ*/)then do;
if datserv<dt_cdiur or dt_cdiur=. then dt_cdiur=datserv;
if datserv>=dt_cdiur then dtl_cdiur=datserv;
du_cdiur=1;dd_cdiur=1;
end;

if dencom in (45463/*acebutolol*/, 43670, 46325/*atenolol*/, 47355/*bisoprolol*/, 45243/*labetalol/*, 38275, 46763, 46780/*metoprolol*/, 
40563/*nadolol*/, 42162/*oxprenolol*/, 39016/*pindolol*/, 08229/*propranolol*/)then do;
if datserv<dt_bb or dt_bb=. then dt_bb=datserv;
if datserv>=dt_bb then dtl_bb=datserv;
du_bb=1;dd_bb=1;
end;

if dencom=38314 /*timolol*/ and forme=203/*tablets*/ then do;
if datserv<dt_tim or dt_tim=. then dt_tim=datserv;
if datserv>=dt_tim then dtl_tim=datserv;
du_tim=1;dd_tim=1;
end;

if dencom in (47049/*benazepril*/, 42071/*captopril*/, 47056, 46194/*cilazapril*/, 45476/*enalapril*/, 47002/*fosinopril*/, 
45576/*lisinopril*/, 47117, 46258/*perindopril*/, 45629/*quinapril*/, 47079, 46216/*ramipril*/, 47250, 47440/*trandolapril*/)then do;
if datserv<dt_ace or dt_ace=. then dt_ace=datserv;
if datserv>=dt_ace then dtl_ace=datserv;
du_ace=1;dd_ace=1;
end;

if dencom in (47309, 46529/*candesartan*/, 47389/*eprosartan*/, 47282, 46459/*irbesartan*/, 47135, 46284, 46441/*losartan*/, 
47333, 46587/*telmisartan*/, 47259, 46418/*valsartan*/)then do;
if datserv<dt_arb or dt_arb=. then dt_arb=datserv;
if datserv>=dt_arb then dtl_arb=datserv;
du_arb=1;dd_arb=1;
end;

if dencom in (47006, 47009/*amlodipine*/, 46369, 43228, 47247/*diltiazem*/, 45624/*felodipine*/, 45571/*nicardipine*/, 
42708, 46388, 46469/*nifedipine*/, 40550, 46573/*verapamil*/, 47440/*verapamil/trandolapril*/)then do;
if datserv<dt_ccb or dt_ccb=. then dt_ccb=datserv;
if datserv>=dt_ccb then dtl_ccb=datserv;
du_ccb=1;dd_ccb=1;
end;

if dencom=37742/*prazosin*/ then do;
/*doxazosin and terazosin not listed as they are also labelled for BPH*/
if datserv<dt_alpha or dt_alpha=. then dt_alpha=datserv;
if datserv>=dt_alpha then dtl_alpha=datserv;
du_alpha=1;
end;

if dencom in (10751/*clonidine*/, 04524/*hydralazine*/06136, 46389/*methyldopa*, 44564/*minoxidil*/)then do;
if datserv<dt_mischt or dt_mischt=. then dt_mischt=datserv;
if datserv>=dt_mischt then dtl_mischt=datserv;
du_mischt=1;dd_mischt=1;
end;

if dencom in (02834/*digitoxin*/, 02847/*digoxin*/)then do;
if datserv<dt_dig or dt_dig=. then dt_dig=datserv;
if datserv>=dt_dig then dtl_dig=datserv;
du_dig=1;dd_dig=1;
end;

if dencom in (47104/*isosorbide-5-mononitrate*/, 03029/*isosorbide dinitrate*/, 09438/*pentaerythritol tetranitrate(Peritrate)*/, 
09919, 42864/*trinitrate de glycéryle*/)then do;
if datserv<dt_ntg or dt_ntg=. then dt_ntg=datserv;
if datserv>=dt_ntg then dtl_ntg=datserv;
du_ntg=1;dd_ntg=1;
end;

if dencom in (03562/*ethacrynic acid*/, 04173/*furosemide*/, 46379/*torsemide*/)then do;
if datserv<dt_loop or dt_loop=. then dt_loop=datserv;
if datserv>=dt_loop then dtl_loop=datserv;
du_loop=1;dd_loop=1;
end;

run;

/* IPD MA algorithm
(du_diur=1 and du_dig=0) or 
(du_cdiur=1 and du_dig=0) or
(du_bb=1 and du_ntg=0) or 
(du_tim=1 and du_ntg=0) or
(du_ccb=1 and du_ntg=0) or
(du_ace=1 and du_loop=0 and du_dig=0) or
(du_arb=1 and du_loop=0 and du_dig=0) or
(du_bb=1 and du_loop=0 and du_dig=0) or
(du_tim=1 and du_loop =0 and du_dig=0) or
du_alpha=1 or
du_mischt=1
*/

/* Hypertension diagnosis is affected by risk of misclassification since drugs used for HTA are also used for CHD and/or CHF.
To improve specificity, we assign a condition that a prescription for HTA be filled at least 60 days before a prescription is filled
for ntg, dig or loop */ 

data wce.algo_rxht;
set wce.pre_rxht;
by id caseid;

retain dt_rxht dtl_rxht; * First retain;

if first.caseid then do dt_rxht=.; dtl_rxht=.; end;

if dt_rxht =. 
and
(
(dd_diur=1 and (dt_diur+60 < dt_dig or dt_dig=.) 
and (dt_diur+60 < dt_loop or dt_loop=.) and   (dt_diur+60 < dt_ntg or dt_ntg=.))
or
(dd_cdiur=1 and (dt_cdiur+60 < dt_dig or dt_dig=.)  and (dt_cdiur+60 < dt_loop or dt_loop=.) and  
    (dt_cdiur+60 < dt_ntg or dt_ntg=.))
or
(dd_bb=1 and (dt_bb+60 < dt_dig or dt_dig=.)  and (dt_bb+60 < dt_loop or dt_loop=.) and  
      (dt_bb+60 < dt_ntg or dt_ntg=.))
or
(dd_tim=1 and (dt_tim+60 < dt_dig or dt_dig=.)  and (dt_tim+60 < dt_loop or dt_loop=.) and 
     (dt_tim+60 < dt_ntg or dt_ntg=.))
or
(dd_ccb=1 and (dt_ccb+60 < dt_dig or dt_dig=.)  and (dt_ccb+60 < dt_loop or dt_loop=.) and  
     (dt_ccb+60 < dt_ntg or dt_ntg=.))
or 
(dd_ace=1 and (dt_ace+60 < dt_dig or dt_dig=.)  and (dt_ace+60 < dt_loop or dt_loop=.) and  
     (dt_ace+60 < dt_ntg or dt_ntg=.))
or
(dd_arb=1 and (dt_arb+60 < dt_dig or dt_dig=.)  and (dt_arb+60 < dt_loop or dt_loop=.) and  
     (dt_arb+60 < dt_ntg or dt_ntg=.))
or
dd_alpha=1 
or
dd_mischt=1
)
then do;
dt_rxht=datserv;
dtl_rxht=datserv;
end;

/* The requirement of a 60-day gap before a first Rx for ntg, loop, or dig means that hypertension cannot be diagnosed after
CHD or CHF. This may decrease sensitivity but should occur rarely because hypertension occurs before CHD or CHF on the causal pathway of 
CV disease. Practically, this means that dt_rxht (date of first prescription indicative of HTA) is not created
(or if previously created is re-assigned to missing) if there is a prescription for ntg, dig or loop in the 60 days 
after first dt_rxht.
Per Lyne, the lines of code below are needed because SAS looks at one line of data at a time chronologically and cannot anticipates 
what data lines will be in the 60-day period after assigning the date to dt_rxht */

if dt_rxht ne . and (
(.<dt_dig<dt_rxht+60)
 or (.<dt_loop<dt_rxht+60) 
or (.<dt_ntg<dt_rxht+60) 
)
then do
dt_rxht=.;
dtl_rxht=.;
end;


if dt_rxht ne . and 
(dd_diur=1 or dd_cdiur=1 or dd_bb=1 or dd_tim=1 or dd_ccb=1 or dd_ace=1 or dd_arb=1 or dd_alpha=1 or dd_mischt=1)
and datserv>dtl_rxht
then dtl_rxht=datserv;
/* Last prescription for HTA updated by any antihypertensive drug that is part of the HT algorithm. This variable will
be used for determining persistence with HTA drug treatment */

if dt_rxht ne . then rxht=1; else rxht=0;

format dt_diur dt_cdiur dt_bb dt_tim dt_ccb dt_ace dt_arb dt_alpha dt_mischt dt_dig dt_ntg dt_loop
dtl_diur dtl_cdiur dtl_bb dtl_tim dtl_ccb dtl_ace dtl_arb dtl_alpha dtl_mischt dtl_dig dtl_ntg dtl_loop dt_rxht dtl_rxht date9.;
drop i;
run;

proc sort data=wce.algo_rxht; by id caseid datserv;run;

data wce.rxht;
set wce.algo_rxht;
by id caseid;
keep caseid id t0 indexdate datserv dt_rxht dtl_rxht  rxht; 
if last.caseid and dt_rxht <t0 and rxht=1 then output; * First diagnosis before cohort entry (dt_rxht);
run;
* N= 101656 (SpSe scenario used with nested-case-control approach, not date-based);


/*chd*/

data wce.pre_rxchd; 
set wce.rxwce(where=(dencom in (47104/*isosorbide-5-mononitrate*/, 03029/*isosorbide dinitrate*/, 09438/*pentaerythritol tetranitrate(Peritrate)*/, 
09919, 42864/*trinitrate de glycéryle*/, 46486, 47307/*clopidogrel*/, 03094/*dipyridamole*/, 46077, 47365/*ASA/dipyridamole*/, 
45617/*ticlopidine*/, 45463/*acebutolol*/, 43670, 46325/*atenolol*/, 47355/*bisoprolol*/, 
45243/*labetalol/*, 38275, 46763, 46780/*metoprolol*/, 40563/*nadolol*/, 42162/*oxprenolol*/, 39016/*pindolol*/, 08229/*propranolol*/,
47006, 47009/*amlodipine*/, 46369, 43228, 47247/*diltiazem*/, 45624/*felodipine*/, 45571/*nicardipine*/, 
42708, 46388, 46469/*nifedipine*/, 40550, 46573/*verapamil*/, 47440/*verapamil/trandolapril*/, 46353/*ASA comprimé entérique 81mg*/) 
or (dencom =38314 /*timolol*/ and forme=203/*tablets*/)
or dencom=00143/*ASA*/ and forme=00203/*comprimé*/ and dosge in (40199, 52216/*80mg or 325mg*/)
or dencom=00143/*ASA*/ and forme=00406/*comprimé entérique*/ and dosge in (40199, 51244 /*80mg or 300-325mg*/)
or (dencom=00143/*ASA*/ and forme=00464/*comprimé masticable 80mg*/)))
;
by id caseid;
* First retain;
retain 
dt_ntg dt_plat dt_ccb dt_bb dt_tim dt_asa1 dt_asa2 dt_asa3 dt_asa4
dtl_ntg dtl_plat dtl_ccb dtl_bb dtl_tim dtl_asa1 dtl_asa2 dtl_asa3 dtl_asa4
du_ntg du_plat du_ccb du_bb du_tim du_asa1 du_asa2 du_asa3 du_asa4;

array chddt(9) dt_ntg dt_plat dt_ccb dt_bb dt_tim dt_asa1 dt_asa2 dt_asa3 dt_asa4;
array chddtl (9) dtl_ntg dtl_plat dtl_ccb dtl_bb dtl_tim dtl_asa1 dtl_asa2 dtl_asa3 dtl_asa4;
array duchd(9) du_ntg du_plat du_ccb du_bb du_tim du_asa1 du_asa2 du_asa3 du_asa4;
* Note no retain on ddchd;
array ddchd(9) dd_ntg dd_plat dd_ccb dd_bb dd_tim dd_asa1 dd_asa2 dd_asa3 dd_asa4;

if first.caseid then do;
do i=1 to 9;
chddt(i)=.;
chddtl(i)=.;
duchd(i)=.;
ddchd(i)=.;
end;
end;


if dencom in (47104/*isosorbide-5-mononitrate*/, 03029/*isosorbide dinitrate*/, 09438/*pentaerythritol tetranitrate(Peritrate)*/, 
09919, 42864/*trinitrate de glycéryle*/)then do;
if datserv<dt_ntg or dt_ntg=. then dt_ntg=datserv;
if datserv>=dt_ntg then dtl_ntg=datserv;
du_ntg=1;dd_ntg=1;
end;

if dencom in (46486, 47307/*clopidogrel*/, 03094/*dipyridamole*/, 46077, 47365/*ASA/dipyridamole*/, 45617/*ticlopidine*/)then do;
if datserv<dt_plat or dt_plat=. then dt_plat=datserv;
if datserv>=dt_plat then dtl_plat=datserv;
du_plat=1; dd_plat=1;
end;

if dencom in (45463/*acebutolol*/, 43670, 46325/*atenolol*/, 47355/*bisoprolol*/, 45243/*labetalol/*, 38275, 46763, 46780/*metoprolol*/, 
40563/*nadolol*/, 42162/*oxprenolol*/, 39016/*pindolol*/, 08229/*propranolol*/)then do;
if datserv<dt_bb or dt_bb=. then dt_bb=datserv;
if datserv>=dt_bb then dtl_bb=datserv;
du_bb=1;dd_bb=1;
end;

if dencom =38314 /*timolol*/ and forme=203/*tablets*/ then do; 
if datserv<dt_tim or dt_tim=. then dt_tim=datserv;
if datserv>=dt_tim then dtl_tim=datserv;
du_tim=1; dd_tim=1;
end;

if dencom in (47006, 47009/*amlodipine*/, 46369, 43228, 47247/*diltiazem*/, 45624/*felodipine*/, 45571/*nicardipine*/, 
42708, 46388, 46469/*nifedipine*/, 40550, 46573/*verapamil*/, 47440/*verapamil/trandolapril*/)then do;
if datserv<dt_ccb or dt_ccb=. then dt_ccb=datserv;
if datserv>=dt_ccb then dtl_ccb=datserv;
du_ccb=1;dd_ccb=1;
end;

if dencom=46353/*ASA comprimé entérique 81mg*/then do;
if datserv<dt_asa1 or dt_asa1=. then dt_asa1=datserv;
if datserv>=dt_asa1 then dtl_asa1=datserv;
du_asa1=1;dd_asa1=1;
end;

if dencom=00143/*ASA*/ and forme=00203/*comprimé*/ and dosge in (40199, 52216/*80mg or 325mg*/)then do;
if datserv<dt_asa2 or dt_asa2=. then dt_asa2=datserv;
if datserv>=dt_asa2 then dtl_asa2=datserv;
du_asa2=1; dd_asa2=1;
end;

if dencom=00143/*ASA*/ and forme=00406/*comprimé entérique*/ and dosge in (40199, 51244 /*80mg or 300-325mg*/)then do;
if datserv<dt_asa3 or dt_asa3=. then dt_asa3=datserv;
if datserv>=dt_asa3 then dtl_asa3=datserv;
du_asa3=1;dd_asa3=1;
end;

if dencom=00143/*ASA*/ and forme=00464/*comprimé masticable 80mg*/then do;
if datserv<dt_asa4 or dt_asa4=. then dt_asa4=datserv;
if datserv>=dt_asa4 then dtl_asa4=datserv;
du_asa4=1;dd_asa4=1;
end;

run;

proc sort data= wce.pre_rxchd;by id caseid;run;

data wce.algo_rxchd;
set wce.pre_rxchd;
by id caseid;
retain dt_rxchd dtl_rxchd; * First retain;

if first.caseid then do; dt_rxchd=.; dtl_rxchd=.;end;

* In IPD MA algorithm for chd is as follows:
if ntg and (plat or ccb or bb or tim or (asa1 or asa2 or asa3 or asa4))>=1 then do;

* Patients have a first date of CHD diagnosis (dt_chd) as soon as they meet condition of the algorithm below;
if 
(
(
(du_ntg=1 and du_plat=1 and (dd_ntg=1 or dd_plat=1)) 
and (.<dtl_ntg-20 <= dtl_plat <= dtl_ntg+20)
) 
/* Looking for a first instance that prescription of ntg is within 40 days of a prescription for antiplatelet drug*/
or 
(
(du_ntg=1 and du_ccb=1 and (dd_ntg=1 or dd_ccb=1)) 
and (.<dtl_ntg-20 <= dtl_ccb <= dtl_ntg+20)
)
or   
(
(du_ntg=1 and du_bb=1 and (dd_ntg=1 or dd_bb=1))
and (.<dtl_ntg-20 <= dtl_bb <= dtl_ntg+20)
)
or 
(
(du_ntg=1 and du_tim=1 and (dd_ntg=1 or dd_tim=1)) 
and (.<dtl_ntg-20 <= dtl_tim <= dtl_ntg+20)
)
or
(
(du_ntg=1 and du_asa1=1 and (dd_ntg=1 or dd_asa1=1))
and (.<dtl_ntg-20 <= dtl_asa1 <= dtl_ntg+20)
)
or   
(
(du_ntg=1 and du_asa2=1 and (dd_ntg=1 or dd_asa2=1)) 
and (.<dtl_ntg-20 <= dtl_asa2 <= dtl_ntg+20)
)
or   
(
(du_ntg=1 and du_asa3=1 and (dd_ntg=1 or dd_asa3=1))
and (.<dtl_ntg-20 <= dtl_asa3 <= dtl_ntg+20)
)
or   
(
(du_ntg=1 and du_asa4=1 and (dd_ntg=1 or dd_asa4=1)) 
and (.<dtl_ntg-20 <= dtl_asa4 <= dtl_ntg+20)
)
)
and 
dt_rxchd=. 
then do;
dt_rxchd=datserv;dtl_rxchd=datserv;
end;


if dt_rxchd ne . and 
(dd_ntg=1 or dd_plat=1 or dd_ccb=1 or dd_bb=1 or dd_tim=1 or dd_asa1=1 or dd_asa2=1  or dd_asa3=1  or dd_asa4=1)
and datserv>dtl_rxchd then dtl_rxchd=datserv;
/* Last prescription for CHD updated by use of any of the drugs that are part of the algorithm */ 

if dt_rxchd ne . then rxchd=1; else rxchd=0;

format dt_ntg dt_plat dt_ccb dt_bb dt_tim dt_asa1 dt_asa2 dt_asa3 dt_asa4
dtl_ntg dtl_plat dtl_ccb dtl_bb dtl_tim dtl_asa1 dtl_asa2 dtl_asa3 dtl_asa4 dt_rxchd dtl_rxchd date9.;
drop i;
run;


proc sort data= wce.algo_rxchd; by id caseid datserv; run;


data wce.rxchd;
set wce.algo_rxchd;
by id caseid;
keep caseid id t0 indexdate datserv dt_rxchd dtl_rxchd rxchd rxchd; 
if last.caseid and dtl_rxchd <indexdate and  rxchd=1 then output; * In the period preceding index date;
run;
* N= 70887 (SpSe scenario used with nested-case-control approach, not date-based);


/* chf */
data wce.pre_rxchf; 
set wce.rxwce(where=( dencom in (03562/*ethacrynic acid*/, 04173/*furosemide*/, 46379/*torsemide*/, 09100/*spironolactone*/,47355/*bisoprolol*/, 
47199, 46319 /*carvedilol*/, 38275, 46763, 46780/*metoprolol*/,
47309, 46529/*candesartan*/, 47259, 46418/*valsartan*/,
47049/*benazepril*/, 42071/*captopril*/, 47056, 46194/*cilazapril*/, 45476/*enalapril*/, 47002/*fosinopril*/, 
45576/*lisinopril*/, 47117, 46258/*perindopril*/, 45629/*quinapril*/, 47079, 46216/*ramipril*/, 47250, 47440/*trandolapril*/,
47309, 46529/*candesartan*/, 47389/*eprosartan*/, 47282, 46459/*irbesartan*/, 47135, 46284, 46441/*losartan*/, 
47333, 46587/*telmisartan*/, 47259, 46418/*valsartan*/, 02834/*digitoxin*/, 02847/*digoxin*/, 04524/*hydralazine*/))); 

by id caseid datserv;
* First retain;
retain 
dt_bbchf dt_loop dt_dig dt_ace dt_arb dt_arbchf dt_ntg dt_spir dt_hydra dt_diur
dtl_bbchf dtl_loop dtl_dig dtl_ace dtl_arb dtl_arbchf dtl_ntg dtl_spir dtl_hydra dtl_diur
du_bbchf du_loop du_dig du_ace du_arb du_arbchf du_ntg du_spir du_hydra du_diur;
* Note no retain on ddchf;

array chfdt(10) dt_bbchf dt_loop dt_dig dt_ace dt_arb dt_arbchf dt_ntg dt_spir dt_hydra dt_diur;
array chfdtl (10) dtl_bbchf dtl_loop dtl_dig dtl_ace dtl_arb dtl_arbchf dtl_ntg dtl_spir dtl_hydra dtl_diur;
array duchf (10) du_bbchf du_loop du_dig du_ace du_arb du_arbchf du_ntg du_spir du_hydra du_diur;
array ddchf (10) dd_bbchf dd_loop dd_dig dd_ace dd_arb dd_arbchf dd_ntg dd_spir dd_hydra dd_diur;

if first.caseid then do;
do i=1 to 10;
chfdt(i)=.;
chfdtl(i)=.;
duchf(i)=.;
ddchf(i)=.;

end;
end;

if dencom in (47355/*bisoprolol*/, 47199, 46319 /*carvedilol*/, 38275, 46763, 46780/*metoprolol*/)then do;
if datserv<dt_bbchf or dt_bbchf=. then dt_bbchf=datserv;
if datserv>=dt_bbchf then dtl_bbchf=datserv;
du_bbchf=1; dd_bbchf=1;
end;

if dencom in (03562/*ethacrynic acid*/, 04173/*furosemide*/, 46379/*torsemide*/)then do;
if datserv<dt_loop or dt_loop=. then dt_loop=datserv;
if datserv>=dt_loop then dtl_loop=datserv;
du_loop=1; dd_loop=1;
end;

if dencom in (02834/*digitoxin*/, 02847/*digoxin*/)then do;
if datserv<dt_dig or dt_dig=. then dt_dig=datserv;
if datserv>=dt_dig then dtl_dig=datserv;
du_dig=1; dd_dig=1;
end;

if dencom in (47049/*benazepril*/, 42071/*captopril*/, 47056, 46194/*cilazapril*/, 45476/*enalapril*/, 47002/*fosinopril*/, 
45576/*lisinopril*/, 47117, 46258/*perindopril*/, 45629/*quinapril*/, 47079, 46216/*ramipril*/, 47250, 47440/*trandolapril*/)then do;
if datserv<dt_ace or dt_ace=. then dt_ace=datserv;
if datserv>=dt_ace then dtl_ace=datserv;
du_ace=1;dd_ace=1;
end;

if dencom in (47309, 46529/*candesartan*/, 47389/*eprosartan*/, 47282, 46459/*irbesartan*/, 47135, 46284, 46441/*losartan*/, 
47333, 46587/*telmisartan*/, 47259, 46418/*valsartan*/)then do;
if datserv<dt_arb or dt_arb=. then dt_arb=datserv;
if datserv>=dt_arb then dtl_arb=datserv;
du_arb=1;dd_arb=1;
end;

if dencom in (47309, 46529/*candesartan*/, 47259, 46418/*valsartan*/)then do;
if datserv<dt_arbchf or dt_arbchf=. then dt_arbchf=datserv;
if datserv>=dt_arbchf then dtl_arbchf=datserv;
du_arbchf=1;dd_arbchf=1;
end;

if dencom in (09100/*spironolactone*/)then do;
if datserv<dt_spir or dt_spir=. then dt_spir=datserv;
if datserv>=dt_spir then dtl_spir=datserv;
du_spir=1;dd_spir=1;
end;

if dencom in (41759/*amiloride*/, 41772/*amiloride/HCTZ*/, 00806/*bendroflumethiazide*/, 01976 /*chlorthalidone*/, 04537/*HCTZ*/,
43397/*indapamide*/, 06110/*methyclothiazide*/, 19440/*metolazone*/, 09763/*triamterene*/, 38458/*spironolactone/HCTZ*/, 
38197, 46772/*triamterene/HCTZ*/)then do;
if datserv<dt_diur or dt_diur=. then dt_diur=datserv;
if datserv>=dt_diur then dtl_diur=datserv;
du_diur=1;dd_diur=1;
end;

if dencom in (47104/*isosorbide-5-mononitrate*/, 03029/*isosorbide dinitrate*/, 09438/*pentaerythritol tetranitrate(Peritrate)*/, 
09919, 42864/*trinitrate de glycéryle*/)then do;
if datserv<dt_ntg or dt_ntg=. then dt_ntg=datserv;
if datserv>=dt_ntg then dtl_ntg=datserv;
du_ntg=1;dd_ntg=1;
end;

if dencom=04524/*hydralazine*/then do;
if datserv<dt_hydra or dt_hydra=. then dt_hydra=datserv;
if datserv>=dt_hydra then dtl_hydra=datserv;
du_hydra=1;dd_hydra=1;
end;

run;

/*vars for defining rxchf from Liu P, et al. The 2002/3 CCS consensus guideline update for the diagnosis and management of heart failure.
Can J Cardiol. 2003;19(4):347-56. and Arnold, et al. CCS consensus conference recommendations on heart failure 2006: diagnosis and management.
Can J Cardiol. 2006;22(1):23-45. and Lee DS, et al. Trends in heart failure outcomes and pharmacotherapy: 1992 to 2000. Am J Med. 2004:116(9):
581-9. Included both emerging and older treatment*/

/* data a ;set wce.pre_rxchf(obs=10); if datserv>0  then put 'look'; run; */ 

proc sort data=wce.pre_rxchf;by id caseid datserv;run;
data wce.algo_rxchf;
set wce.pre_rxchf;
by id caseid;

retain dt_rxchf dtl_rxchf; * First retain;

if first.caseid then do; dt_rxchf=.; dtl_rxchf=.; end;

* In IPD MA algorithm for chf is as follows:
if ((bbchf /*bisoprolol,carvedilol,metoprolol*/ and loop) or (loop and dig) or (ace and (loop or dig)) or (arb and (loop or dig)) 
or (loop and bbchf and ace) or (loop and bbchf and arbchf/*candesartan, valsartan*/)
or ((loop and ace) and (spir or diur)) or (loop and dig and ntg and hydra))=1;

* Patients have a first date of CHF diagnosis (dt_chf) as soon as they meet condition of the algorithm below
Treatment is likely to be a step up therapy;

if 
(
(
(du_bbchf=1 and du_loop=1 and (dd_bbchf=1 or dd_loop=1)) 
and (.<dtl_bbchf-20 <= dtl_loop <= dtl_bbchf+20)
)
/* Looking for a first instance that prescription of beta-blocker used in CHF is within 40 days of a
prescription for digoxin*/
or
(
(du_loop=1 and du_dig=1 and (dd_loop=1 or dd_dig=1)) 
and (.<dtl_loop-20 <= dtl_dig <= dtl_loop+20)
)
or
(
(du_ace=1 and du_loop=1 and (dd_ace=1 or dd_loop=1)) 
and (.<dtl_ace-20 <= dtl_loop <= dtl_ace+20)
)
or
(
(du_ace=1 and du_dig=1 and (dd_ace=1 or dd_dig=1))
and (.<dtl_ace-20 <= dtl_dig <= dtl_ace+20)
)
or
(
(du_arb=1 and du_loop=1 and (dd_arb=1 or dd_loop=1))
and (.<dtl_arb-20 <= dtl_loop <= dtl_arb+20)
)
or
(
(du_arb=1 and du_dig=1 and (dd_arb=1 or dd_dig=1))
and (.<dtl_arb-20 <= dtl_dig <= dtl_arb+20)
)

or
(
(du_loop=1 and du_bbchf=1 and du_ace=1 and (dd_loop=1 or dd_bbchf=1 or dd_ace=1 ))
and (.<dtl_loop-20 <= dtl_bbchf <= dtl_loop+20) 
and (.<dtl_loop-20 <= dtl_ace <= dtl_loop+20)
and (.<dtl_bbchf-20 <= dtl_ace <= dtl_bbchf+20)
)

or
(
(du_loop=1 and du_bbchf=1 and du_arbchf=1 and (dd_loop=1 or dd_bbchf=1 or dd_arbchf=1 )) 
and (.<dtl_loop-20 <= dtl_bbchf <= dtl_loop+20) and (.<dtl_loop-20 <= dtl_arbchf <= dtl_loop+20)
and (.<dtl_bbchf-20 <= dtl_arbchf <= dtl_bbchf+20)
)
or
(
(du_loop=1 and du_ace=1 and du_spir=1 and (dd_loop=1 or dd_ace=1 or dd_spir=1 )) 
and (.<dtl_loop-20 <= dtl_ace <= dtl_loop+20) 
and (dtl_loop-20 <= dtl_spir <= dtl_loop+20)
and (dtl_ace-20 <= dtl_spir <= dtl_ace+20)
)
or 
(
(du_loop=1 and du_ace=1 and du_diur=1 and (dd_loop=1 or dd_ace=1 or dd_diur=1 )) 
and (.<dtl_loop-20 <= dtl_ace <= dtl_loop+20) and (dtl_loop-20 <= dtl_diur <= dtl_loop+20)
and (dtl_ace-20 <= dtl_diur <= dtl_ace+20)
)
or
(
(du_loop=1 and du_dig=1 and du_ntg=1 and du_hydra=1 and (dd_loop=1 or dd_dig=1 or dd_ntg=1 or dd_hydra=1 )) 
and (.<dtl_loop-20 <= dtl_dig <= dtl_loop+20) and (.<dtl_loop-20 <= dtl_ntg <= dtl_loop+20)
and (.<dtl_loop-20 <= dtl_hydra <= dtl_loop+20) and (.<dtl_dig-20 <=  dtl_ntg <= dtl_dig+20)
and (.<dtl_dig-20 <= dtl_hydra <= dtl_dig+20) and (.<dtl_ntg-20 <= dtl_hydra <= dtl_ntg+20)
)
)
and dt_rxchf=. then do;
dt_rxchf=datserv;
dtl_rxchf=datserv;
end;

if dt_rxchf ne . and 
(dd_bbchf=1 or dd_loop=1 or dd_dig=1 or dd_ace=1 or dd_arb=1 or dd_arbchf=1)  
and datserv>dtl_rxchf then dtl_rxchf=datserv;
/* dt_ntg dt_spir dt_hydra dt_diur not used to update last date of a prescription for CHF drugs */

if dt_rxchf ne . then rxchf=1; else rxchf=0;

format dt_bbchf dt_loop dt_dig dt_ace dt_arb dt_arbchf dt_ntg dt_spir dt_hydra dt_diur
dtl_bbchf dtl_loop dtl_dig dtl_ace dtl_arb dtl_arbchf dtl_ntg dtl_spir dtl_hydra dtl_diur dt_rxchf dtl_rxchf  date9.;
drop i;

run;

proc sort data= wce.algo_rxchf; by id caseid datserv; run;


data wce.rxchf;
set wce.algo_rxchf;
by id caseid;
keep caseid id t0 indexdate dt_rxchf dtl_rxchf  rxchf; 
if last.caseid and dt_rxchf < t0 and rxchf=1 then output; * Diagnosis before cohort entry (dt_rxchf);
run;
* N= 17802 (SpSe scenario, not date-based);

/*cvd*/
* Other Rx are prescribed but are not specific enough;
data wce.pre_rxcvd; 
set wce.rxwce(where=(dencom=45532/*nimodipine*/)); 
by id caseid;

retain dt_rxcvd dtl_rxcvd;

if first.caseid then do; dt_rxcvd=.; dtl_rxcvd=.; end;

if datserv<dt_rxcvd or dt_rxcvd=. then dt_rxcvd=datserv;
if datserv>=dt_rxcvd then dtl_rxcvd=datserv;
if dt_rxcvd ne . then rxcvd=1; else rxcvd=0;

format dt_rxcvd dtl_rxcvd date9.;

keep caseid id t0 indexdate dt_rxcvd dtl_rxcvd rxcvd; 
if  dtl_rxcvd ne . then output;
run;


proc sort data= wce.pre_rxcvd; by id caseid datserv; run;

data wce.rxcvd;
set wce.pre_rxcvd;
by id caseid;
if last.caseid and dtl_rxcvd <indexdate and rxcvd=1 then output; * At any time before index date;
run;


/*pvd*/
data wce.pre_rxpvd; 
set wce.rxwce(where=(dencom=44346/*pentoxifylline*/)); 
by id caseid;

retain dt_rxpvd dtl_rxpvd;

if first.caseid then do; dt_rxpvd=.; dtl_rxpvd=.;  end;

if datserv<dt_rxpvd or dt_rxpvd=. then dt_rxpvd=datserv;
if datserv>=dt_rxpvd then dtl_rxpvd=datserv;

if dt_rxpvd ne . then rxpvd=1; else rxpvd=0;

format dt_rxpvd dtl_rxpvd date9.;
keep caseid id t0 indexdate dt_rxpvd dtl_rxpvd rxpvd datserv; 
run;

proc sort data= wce.pre_rxpvd; by id caseid datserv; run;

data wce.rxpvd;
set wce.pre_rxpvd;
by id caseid;
if last.caseid and dtl_rxpvd <indexdate  and rxpvd=1 then output; * In the period preceding index date;
run;


/*copd*/
data wce.pre_rxcopd; 
set wce.rxwce(where=(dencom in (00364, 46428/*aminophylline*/, 34310/*bufylline*/, 03276/*diphylline*/, 09464, 46847, 09490, 09503/*theophylline*/, 
43475/*oxtriphylline*/)
or 
dencom in (38548/*fenoterol*/, 47231, 47271, 46430/*formoterol*/, 06721/*orciprenaline*/, 47453, 46299/*pirbutérol*/, 45547/*procaterol*/, 
46737, 10530, 33634/*salbutamol*/, 47112, 46247/*salmeterol*/, 34180/*terbutaline*/)
or
dencom in (47428, 46800/*formoterol/budesonide*/47335, 46597/*salmeterol/fluticasone*/)
or
dencom=00780/*beclomethasone*/ and forme in (01305/*poudre aérosol*/, 01334/*poudre aérosol avec applicateur*/, 01856/*solution aérosol*/,
05563/*poudre pour inhalation avec applicateur*/, 05564/*poudre pour inhalation*/, 05584/*aérosol oral*/, 05619/*poudre pour inhalation applicateur*/)
or
dencom=45499/*budesonide*/ and forme in (01305/*poudre aérosol*/, 01334/*poudre aérosol avec applicateur*/, 01856/*solution aérosol*/, 
05563/*poudre pour inhalation avec applicateur*/, 05564/*poudre pour inhalation*/, 05584/*aérosol oral*/, 
05619/*poudre pour inhalation applicateur*/)
or
dencom in (38730, 47213/*flunisolide*/) and forme in (01305/*poudre aérosol*/, 01334/*poudre aérosol avec applicateur*/, 
01856/*solution aérosol*/, 05563/*poudre pour inhalation avec applicateur*/, 05564/*poudre pour inhalation*/, 05584/*aérosol oral*/,
05619/*poudre pour inhalation applicateur*/)
or
dencom in (47050, 46345/*fluticasone*/) and forme in (01305/*poudre aérosol*/, 01334/*poudre aérosol avec applicateur*/, 
01856/*solution aérosol*/, 05563/*poudre pour inhalation avec applicateur*/, 05564/*poudre pour inhalation*/, 05584/*aérosol oral*/, 
05619/*poudre pour inhalation applicateur*/)
or
dencom=09737/*triamcinolone acetonide*/ and forme in (01305/*poudre aérosol*/, 01334/*poudre aérosol avec applicateur*/, 
01856/*solution aérosol*/, 05563/*poudre pour inhalation avec applicateur*/, 05564/*poudre pour inhalation*/, 05584/*aérosol oral*/, 
05619/*poudre pour inhalation applicateur*/)
or
dencom in (43124, 46640/*ipratropium*/, 46288/*ipratropium/fenoterol*/, 47186, 46302/*ipratropium/salbutamol*/, 
46856/*tiotropium*/))); 

by id caseid;
* First retain;
retain 
dt_xant dt_bag dt_cbag dt_beclo dt_bude dt_flun dt_fluti dt_triam dt_antichol
dtl_xant dtl_bag dtl_cbag dtl_beclo dtl_bude dtl_flun dtl_fluti dtl_triam dtl_antichol dt_rxcopd dtl_rxcopd;

array copddt(9) dt_xant dt_bag dt_cbag dt_beclo dt_bude dt_flun dt_fluti dt_triam dt_antichol;

array copddtl (9) dtl_xant dtl_bag dtl_cbag dtl_beclo dtl_bude dtl_flun dtl_fluti dtl_triam dtl_antichol;

array ddcopd (9) dd_xant dd_bag dd_cbag dd_beclo dd_bude dd_flun dd_fluti dd_triam dd_antichol;


if first.caseid then do;
do i=1 to 9;
copddt(i)=.;
copddtl(i)=.;
ddcopd(i)=.;
end;
end;

if dencom in (00364, 46428/*aminophylline*/, 34310/*bufylline*/, 03276/*diphylline*/, 09464, 46847, 09490, 09503/*theophylline*/, 
43475/*oxtriphylline*/)then do;
if datserv<dt_xant or dt_xant=. then dt_xant=datserv;
if datserv>=dt_xant then dtl_xant=datserv;
dd_xant=1;
end;

if dencom in (38548/*fenoterol*/, 47231, 47271, 46430/*formoterol*/, 06721/*orciprenaline*/, 47453, 46299/*pirbutérol*/, 45547/*procaterol*/, 
46737, 10530, 33634/*salbutamol*/, 47112, 46247/*salmeterol*/, 34180/*terbutaline*/)then do;
if datserv<dt_bag or dt_bag=. then dt_bag=datserv;
if datserv>=dt_bag then dtl_bag=datserv;
dd_bag=1;
end;

if dencom in (47428, 46800/*formoterol/budesonide*/47335, 46597/*salmeterol/fluticasone*/)then do;
if datserv<dt_cbag or dt_cbag=. then dt_cbag=datserv;
if datserv>=dt_cbag then dtl_cbag=datserv;
dd_cbag=1;
end;

if dencom=00780/*beclomethasone*/ and forme in (01305/*poudre aérosol*/, 01334/*poudre aérosol avec applicateur*/, 01856/*solution aérosol*/,
05563/*poudre pour inhalation avec applicateur*/, 05564/*poudre pour inhalation*/, 05584/*aérosol oral*/, 05619/*poudre pour inhalation applicateur*/)
then do;
if datserv<dt_beclo or dt_beclo=. then dt_beclo=datserv;
if datserv>=dt_beclo then dtl_beclo=datserv;
dd_beclo=1;
end;

if dencom=45499/*budesonide*/ and forme in (01305/*poudre aérosol*/, 01334/*poudre aérosol avec applicateur*/, 01856/*solution aérosol*/, 
05563/*poudre pour inhalation avec applicateur*/, 05564/*poudre pour inhalation*/, 05584/*aérosol oral*/, 
05619/*poudre pour inhalation applicateur*/)then do;
if datserv<dt_bude or dt_bude=. then dt_bude=datserv;
if datserv>=dt_bude then dtl_bude=datserv;
dd_bude=1;
end;

if dencom in (38730, 47213/*flunisolide*/) and forme in (01305/*poudre aérosol*/, 01334/*poudre aérosol avec applicateur*/, 
01856/*solution aérosol*/, 05563/*poudre pour inhalation avec applicateur*/, 05564/*poudre pour inhalation*/, 05584/*aérosol oral*/,
05619/*poudre pour inhalation applicateur*/)then do;
if datserv<dt_flun or dt_flun=. then dt_flun=datserv;
if datserv>=dt_flun then dtl_flun=datserv;
dd_flun=1;
end;

if dencom in (47050, 46345/*fluticasone*/) and forme in (01305/*poudre aérosol*/, 01334/*poudre aérosol avec applicateur*/, 
01856/*solution aérosol*/, 05563/*poudre pour inhalation avec applicateur*/, 05564/*poudre pour inhalation*/, 05584/*aérosol oral*/, 
05619/*poudre pour inhalation applicateur*/)then do;
if datserv<dt_fluti or dt_fluti=. then dt_fluti=datserv;
if datserv>=dt_fluti then dtl_fluti=datserv;
dd_fluti=1;
end;

if dencom=09737/*triamcinolone acetonide*/ and forme in (01305/*poudre aérosol*/, 01334/*poudre aérosol avec applicateur*/, 
01856/*solution aérosol*/, 05563/*poudre pour inhalation avec applicateur*/, 05564/*poudre pour inhalation*/, 05584/*aérosol oral*/, 
05619/*poudre pour inhalation applicateur*/)then do;
if datserv<dt_triam or dt_triam=. then dt_triam=datserv;
if datserv>=dt_triam then dtl_triam=datserv;
dd_triam=1;
end;

if dencom in (43124, 46640/*ipratropium*/, 46288/*ipratropium/fenoterol*/, 47186, 46302/*ipratropium/salbutamol*/, 
46856/*tiotropium*/)then do;
if datserv<dt_antichol or dt_antichol=. then dt_antichol=datserv;
if datserv>=dt_antichol then dtl_antichol=datserv;
dd_antichol=1;
end;

* In IPD MA algorithm for COPD is as follows:
if (xant+bag+cbag +beclo+bude+flun+fluti+triam+antichol)>=1;
if first.caseid then do; dt_rxcopd=.; dtl_rxcopd=.; end;

if dd_xant=1 or dd_bag=1 or dd_cbag=1 or dd_beclo=1 or dd_bude=1 or dd_flun=1 or dd_fluti=1 or dd_triam=1 or
dd_antichol=1 then do;

if dt_rxcopd =. then dt_rxcopd=datserv;
dtl_rxcopd=datserv;
end;

drop i dencom forme dosge; 

if dt_rxcopd ne . then rxcopd=1; else rxcopd=0;

format dt_xant dt_bag dt_cbag dt_beclo dt_bude dt_flun dt_fluti dt_triam dt_antichol 
dtl_xant dtl_bag dtl_cbag dtl_beclo dtl_bude dtl_flun dtl_fluti dtl_triam dtl_antichol
dt_rxcopd dtl_rxcopd date9.;
if  dtl_rxcopd ne . then output;
run;

proc sort data= wce.pre_rxcopd; by id caseid datserv; run;


data wce.rxcopd;
set wce.pre_rxcopd;
by id caseid;
keep caseid id t0 indexdate datserv dt_rxcopd dtl_rxcopd  rxcopd;
if last.caseid and dtl_rxcopd <indexdate and rxcopd=1 then output; * In the period preceding index date. 
Apply later the condition restricting to one year preceding index date;
run;


/*gi*/
data wce.pre_rxgi; 
set wce.rxwce(where=(dencom in (38366, 38756/*cimetidine*/, 45460, 46336/*famotidine*/, 45491, 46483/*nizatidine*/, 43163/*ranitidine*/, 
47257, 46409/*ranitidine/bismuth*/)
or 
dencom in (47418, 46761/*esomeprazole*/, 47140/*lansoprazole*/, 47292/*lansoprazole/amoxicilline/clarithromycine*/, 
45519, 47146, 46713/*omeprazole*/, 47234, 46365/*pantoprazole*/, 47432/*rabeprazole*/)
or
dencom in (19427/*carbenoxolone*/,45445/*misoprostol*/, 44320/*pirenzepine*/, 42006, 46623, 46447/*sucralfate*/)
)); 
by id caseid;

retain 
dt_h2 dt_ppi dt_othergi dtl_h2 dtl_ppi dtl_othergi dt_rxgi dtl_rxgi;

array gidt(3) dt_h2 dt_ppi dt_othergi;
array gidtl (3) dtl_h2 dtl_ppi dtl_othergi;

if first.caseid then do;
do i=1 to 3;
gidt(i)=.;
gidtl(i)=.;
end;
end;

if dencom in (38366, 38756/*cimetidine*/, 45460, 46336/*famotidine*/, 45491, 46483/*nizatidine*/, 43163/*ranitidine*/, 
47257, 46409/*ranitidine/bismuth*/)then do;
if datserv<dt_h2 or dt_h2=. then dt_h2=datserv;
if datserv>=dt_h2 then dtl_h2=datserv;
dd_h2=1;
end;

if dencom in (47418, 46761/*esomeprazole*/, 47140/*lansoprazole*/, 47292/*lansoprazole/amoxicilline/clarithromycine*/, 
45519, 47146, 46713/*omeprazole*/, 47234, 46365/*pantoprazole*/, 47432/*rabeprazole*/)then do;
if datserv<dt_ppi or dt_ppi=. then dt_ppi=datserv;
if datserv>=dt_ppi then dtl_ppi=datserv;
dd_ppi=1;
end;

if dencom in (19427/*carbenoxolone*/,45445/*misoprostol*/, 44320/*pirenzepine*/, 42006, 46623, 46447/*sucralfate*/)then do;
if datserv<dt_othergi or dt_othergi=. then dt_othergi=datserv;
if datserv>=dt_othergi then dtl_othergi=datserv;
dd_othergi=1;
end;

* In IPD MA algorithm for gi is as follows:
if (h2+ppi+othergi)>=1;
if first.caseid then do; dt_rxgi=.; dtl_rxgi=.; end;

if dd_h2=1 or dd_ppi=1 or dd_othergi=1
then do;

if dt_rxgi =. then dt_rxgi=datserv;
dtl_rxgi=datserv;
end;

drop i;
if dt_rxgi ne . then rxgi=1; else rxgi=0;

format dt_h2 dt_ppi dt_othergi dtl_h2 dtl_ppi dtl_othergi dt_rxgi dtl_rxgi date9.;
drop dencom forme dosge; 
if  dtl_rxgi ne . then output;
run;

proc sort data= wce.pre_rxgi; by id caseid datserv; run;

data wce.rxgi;
set wce.pre_rxgi;
by id caseid;
keep caseid id t0 indexdate datserv dt_rxgi dtl_rxgi rxgi;
if last.caseid and dtl_rxgi <indexdate and rxgi=1 then output; * In the period preceding index date. 
Apply later the condition restricting to one year preceding index date;
run;


/*renal*/
data wce.pre_rxrenal; 
set wce.rxwce(where=(dencom in (46826, 47441/*darbepoetine alfa*/ 47191, 46635/*epoetine alfa*/)
or
dencom=46671
)); 
by id caseid;

retain 
dt_epo dt_phos dtl_epo dtl_phos dt_rxrenal dtl_rxrenal;

array renaldt(2) dt_epo dt_phos;
array renaldtl (2) dtl_epo dtl_phos;

if first.caseid then do;
do i=1 to 2;
renaldt(i)=.;
renaldtl(i)=.;
end;
end;

if dencom in (46826, 47441/*darbepoetine alfa*/ 47191, 46635/*epoetine alfa*/)then do;
if datserv<dt_epo or dt_epo=. then dt_epo=datserv;
if datserv>=dt_epo then dtl_epo=datserv;
dd_epo=1;
end;

if dencom=46671/*sevelamer*/ then do;
if datserv<dt_phos or dt_phos=. then dt_phos=datserv;
if datserv>=dt_phos then dtl_phos=datserv;
dd_phos=1;
end;

* In IPD MA algorithm for renal is as follows:
if (epo=1 or phos=1);
if first.caseid then do; dt_rxrenal=.; dtl_rxrenal=.;  end;

if dd_epo=1 or dd_phos=1
then do;

if dt_rxrenal =. then dt_rxrenal=datserv;
dtl_rxrenal=datserv;

end;

drop i;
if dt_rxrenal ne . then rxrenal=1; else rxrenal=0;

format dt_epo dt_phos dtl_epo dtl_phos dt_rxrenal dtl_rxrenal date9.;
drop dencom forme dosge; 
run;


proc sort data= wce.pre_rxrenal; by id caseid datserv; run;

data wce.rxrenal;
set wce.pre_rxrenal;
by id caseid;
keep caseid id t0 indexdate datserv dt_rxrenal dtl_rxrenal rxrenal; 
if last.caseid and dt_rxrenal <t0 and rxrenal=1 then output; * Diagnosis before cohort entry (dt_renal);
run;


/*ra*/
data wce.pre_rxra; 
set wce.rxwce(where=(dencom in (46829/*anakinra NOC May 2002*/, 47438, 46711/*etanercept NOC Dec 2000*/, 47416, 46739/*infliximab NOC May 2001*/)
or (dencom=00338/*amethopterin(methotrexate)*/ and forme=00203/*comprimé*/)
or (dencom=00351/*amethopterin(methotrexate)*/and forme=02001/*solution injectable*/ )
or dencom in (45256/*auranofin*/,45549/*aurothioglucose*/, 00745/*sodium aurothiomalate*/)
or dencom in (47362, 46649/*leflunomide*/)
or dencom in (04654/*hydroxychloroquine*/, 06994/*penicillamine*/, 45420/*sulfasalazine*/)
or dencom in (00754, 37820 /*azathioprine*/, 44060, 46266, 46329, 46375/*cyclosporine*/, 47452, 46483/*tacrolimus*/, 01716/*chlorambucil*/)
or (dencom=08021/*prednisone*/ and forme=00203 )
));
 
by id caseid;

retain 
dt_bmr dt_mtx1 dt_mtx2 dt_gold dt_dmard1 dt_dmard2 dt_dmard3 dt_pred
dtl_bmr dtl_mtx1 dtl_mtx2 dtl_gold dtl_dmard1 dtl_dmard2 dtl_dmard3 dtl_pred
du_bmr du_mtx1 du_mtx2 du_gold du_dmard1 du_dmard2 du_dmard3 du_pred;
* Note no retain on ddra;

array radt(8) dt_bmr dt_mtx1 dt_mtx2 dt_gold dt_dmard1 dt_dmard2 dt_dmard3 dt_pred;
array radtl (8) dtl_bmr dtl_mtx1 dtl_mtx2 dtl_gold dtl_dmard1 dtl_dmard2 dtl_dmard3 dtl_pred;
array durad (8) du_bmr du_mtx1 du_mtx2 du_gold du_dmard1 du_dmard2 du_dmard3 du_pred;
array ddrad (8) dd_bmr dd_mtx1 dd_mtx2 dd_gold dd_dmard1 dd_dmard2 dd_dmard3 dd_pred;


if first.caseid then do;
do i=1 to 8;
radt(i)=.;
radtl(i)=.;
durad(i)=.;
ddrad(i)=.;

end;
end;

/*Categories and further definition of rxra derived from Russell A, Haraoui B, Keystone E, Klinkhoff A. 
Current and emerging therapies for rheumatoid arthritis, with a focus on infliximab: clinical impact on joint damage and cost of care in Canada.
Clin Ther. 2001 Nov;23(11):1824-38. Adalimumab deleted from drug codes previously defined in RAMQ-AF and Bisphosphonates as 
NOC was received Sept 2004*/

if dencom in (46829/*anakinra NOC May 2002*/, 47438, 46711/*etanercept NOC Dec 2000*/, 47416, 46739/*infliximab NOC May 2001*/)then do;
/*Methotrexate usual doses for time period 7.5-45 mg/wk PO and 5-45 ad 25 mg/wk IM*/;
if datserv<dt_bmr or dt_bmr=. then dt_bmr=datserv;
if datserv>=dt_bmr then dtl_bmr=datserv;
du_bmr=1;dd_bmr=1;
end;

if dencom=00338/*amethopterin(methotrexate)*/ and forme=00203/*comprimé*/ then do;
if datserv<dt_mtx1 or dt_mtx1=. then dt_mtx1=datserv;
if datserv>=dt_mtx1 then dtl_mtx1=datserv;
du_mtx1=1;dd_mtx1=1;
end;

if dencom=00351/*amethopterin(methotrexate)*/and forme=02001/*solution injectable*/ 
and dosge in (14396, 14518, 24766, 30988/*2.5 mg/mL, 2.5 mg/mL(2mL), 10 mg/mL(2mL), 25 mg/mL(2mL)*/)then do;
if datserv<dt_mtx2 or dt_mtx2=. then dt_mtx2=datserv;
if datserv>=dt_mtx2 then dtl_mtx2=datserv;
du_mtx2=1;dd_mtx2=1;
end;

if dencom in (45256/*auranofin*/,45549/*aurothioglucose*/, 00745/*sodium aurothiomalate*/)then do;
if datserv<dt_gold or dt_gold=. then dt_gold=datserv;
if datserv>=dt_gold then dtl_gold=datserv;
du_gold=1;dd_gold=1;
end;

if dencom in (47362, 46649/*leflunomide*/)then do;
if datserv<dt_dmard1 or dt_dmard1=. then dt_dmard1=datserv;
if datserv>=dt_dmard1 then dtl_dmard1=datserv;
du_dmard1=1;dd_dmard1=1;
end;

if dencom in (04654/*hydroxychloroquine*/, 06994/*penicillamine*/, 45420/*sulfasalazine*/)then do;
if datserv<dt_dmard2 or dt_dmard2=. then dt_dmard2=datserv;
if datserv>=dt_dmard2 then dtl_dmard2=datserv;
du_dmard2=1;dd_dmard2=1;
end;

if dencom in (00754, 37820 /*azathioprine*/, 44060, 46266, 46329, 46375/*cyclosporine*/, 47452, 46483/*tacrolimus*/, 
01716/*chlorambucil*/)then do;
if datserv<dt_dmard3 or dt_dmard3=. then dt_dmard3=datserv;
if datserv>=dt_dmard3 then dtl_dmard3=datserv;
du_dmard3=1;dd_dmard3=1;
end;

if  dtl_pred=. and du_pred=1 then put dencom;

if dencom=08021/*prednisone*/ and forme=00203 then do;
if datserv<dt_pred or dt_pred=. then dt_pred=datserv;
if datserv>=dt_pred then dtl_pred=datserv;
du_pred=1;dd_pred=1;
end;

run;

proc sort data=wce.pre_rxra;by id caseid datserv;run;

data wce.algo_rxra;set wce.pre_rxra;
by id caseid;

retain dt_rxra dtl_rxra;
/* From Tavares R, et al. Early management of newly diagnosed rheumatoid arthritis by Canadian rheumatologists: a national, multicenter, 
retrospective cohort. J Rheumatol. 2011 Nov;38(11):2342-5. To describe early rheumatologic management for newly diagnosed rheumatoid arthritis
(RA) in Canada. A retrospective cohort of 339 randomly selected patients with RA diagnosed from 2001-2003 from 18 rheumatology practices was 
audited between 2005-2007. The most frequent initial disease-modifying antirheumatic drugs (DMARD) included hydroxychloroquine (55.5%) and
methotrexate (40.1%). Initial therapy with multiple DMARD (45.6%) or single DMARD and corticosteroid combinations (30.7%) was infrequent*/
/* Etanercept and infliximab have non-RA use (e.g.: psoriasis, IBD)*/

* In IPD MA algorithm for ra is as follows:
if (mtx1+mtx2+dmard1+gold)>=1 or ((mtx1 and bmr) or (mtx2 and bmr) or (mtx1 and dmard2) or (mtx2 and dmard2) or (mtx1 and pred) or
(mtx2 and pred) or (dmard2 and pred) or (dmard3 and pred))=1; 
if first.caseid then do; dt_rxra=.; dtl_rxra=.; end;

*Lyne: pour ces 4 premiers types de prescription j utilise -dd- mais -du- aurait pu fonctionner
 parce que nous regardons la premiere fois que rxra est initialise;
*Lyne note: pour la premiere rx on utilise pas bmr parce que doit prendre qq chose avant
            sera utilise pour les changements de dtl_rxra;

if dd_mtx1=1 or dd_mtx2=1 or dd_dmard1=1 or dd_gold=1 or

(
(du_dmard2=1 and du_pred=1 and (dd_dmard2=1 or dd_pred=1)) 
and (.<dtl_pred-90 <= dtl_dmard2  < dtl_pred+90)
)
/* looking for the first date that a prescription of certain DMARDs is within 180 days of prescription for prednisone */
or
(
(du_dmard3=1 and du_pred=1 and ( dd_dmard3=1 or dd_pred=1))
and (.<dtl_pred-90 <= dtl_dmard3  < dtl_pred+90)
)
and dt_rxra =. 
then do;
dt_rxra=datserv;
dtl_rxra=datserv;
end;

if dt_rxra ne . and 
(dd_bmr=1 or dd_mtx1=1 or dd_mtx2=1 or dd_gold=1 or dd_dmard1=1 or dd_dmard2=1 or dd_dmard3=1 or dd_pred=1 )
and datserv>dtl_rxra then dtl_rxra=datserv;
/* Last prescription for RA updated by any antirheumatoid drug that is part of the RA algorithm */

if dt_rxra ne . then rxra=1; else rxra=0;

format dt_bmr dt_mtx1 dt_mtx2 dt_gold dt_dmard1 dt_dmard2 dt_dmard3 dt_pred
dtl_bmr dtl_mtx1 dtl_mtx2 dtl_gold dtl_dmard1 dtl_dmard2 dtl_dmard3 dtl_pred dt_rxra dtl_rxra date9.;
drop i dencom forme dosge; 
run;

proc sort data= wce.algo_rxra; by id caseid datserv; run;

data wce.rxra;
set wce.algo_rxra;
by id caseid;
keep caseid id t0 indexdate datserv dt_rxra dtl_rxra rxra; 
if last.caseid and rxra=1  then output ;  * In the period preceding index date;
run;
* N= 3323 (SpSe scenario for nested case-control approach, not date-based);


/*Use of oral corticosteroids*/
data wce.pre_rxcorti; 
set wce.rxwce(where=((dencom=00923/*betamethasone*/ and forme=00203/*comprime*/)
or
(dencom=45421/*betamethasone*/ and forme=00377/*comprime effervescent*/)
or
(dencom=47141/*betamethasone*/ and forme=00377/*comprime effervescent*/)
or 
(dencom=45499/*budesonide*/ and forme=116/*capsule*/)
or
(dencom=02197/*cortisone acetate*/ and forme=00203/*comprime*/)
or
(dencom=02587/*dexamethasone*/ and forme in (00203/*comprime*/, 00754/*elixir*/))
or
(dencom=04550/*hydrocortisone*/ and forme=00203)
or
(dencom=06175/*methylprednisolone*/ and forme=00203)
or
(dencom=07956/*prednisolone*/ and forme=00203 )
or
(dencom=08008/*prednisolone*/ and forme=02262/*solution orale*/)
or
(dencom=08021/*prednisone*/ and forme=00203)
or
(dencom=09724/*triamcinolone*/ and forme=00203/*comprime*/)
or
(dencom=09750/*triamcinolone*/ and forme=01827/*sirop*/)
));; 
by id caseid;

retain 
dt_beta1 dt_beta2 dt_beta3 dt_budes dt_cort dt_dexa dt_hcort dt_methyl dt_predn1 dt_predn2 dt_pred dt_triamc1 dt_triamc2
dtl_beta1 dtl_beta2 dtl_beta3 dtl_budes dtl_cort dtl_dexa dtl_hcort dtl_methyl dtl_predn1 dtl_predn2 dtl_pred dtl_triamc1
dtl_triamc2 dt_rxcorti dtl_rxcorti;

array cortidt(13) dt_beta1 dt_beta2 dt_beta3 dt_budes dt_cort dt_dexa dt_hcort dt_methyl dt_predn1 dt_predn2 dt_pred dt_triamc1 dt_triamc2;
array cortidtl (13) dtl_beta1 dtl_beta2 dtl_beta3 dtl_budes dtl_cort dtl_dexa dtl_hcort dtl_methyl dtl_predn1 dtl_predn2 dtl_pred dtl_triamc1 dtl_triamc2;

if first.caseid then do;
do i=1 to 13;
cortidt(i)=.;
cortidtl(i)=.;
end;
end;

if dencom=00923/*betamethasone*/ and forme=00203/*comprime*/ then do;
if datserv<dt_beta1 or dt_beta1=. then dt_beta1=datserv;
if datserv>=dt_beta1 then dtl_beta1=datserv;
du_beta1=1;
end;

if dencom=45421/*betamethasone*/ and forme=00377/*comprime effervescent*/ then do;
if datserv<dt_beta2 or dt_beta2=. then dt_beta2=datserv;
if datserv>=dt_beta2 then dtl_beta2=datserv;
du_beta2=1;
end;

if dencom=47141/*betamethasone*/ and forme=00377/*comprime effervescent*/ then do;
if datserv<dt_beta3 or dt_beta3=. then dt_beta3=datserv;
if datserv>=dt_beta3 then dtl_beta3=datserv;
du_beta3=1;
end;

if dencom=45499/*budesonide*/ and forme=116/*capsule*/ then do;
if datserv<dt_budes or dt_budes=. then dt_budes=datserv;
if datserv>=dt_budes then dtl_budes=datserv;
du_budes=1;
end;

if dencom=02197/*cortisone acetate*/ and forme=00203/*comprime*/ then do;
if datserv<dt_cort or dt_cort=. then dt_cort=datserv;
if datserv>=dt_cort then dtl_cort=datserv;
du_cort=1;
end;

if dencom=02587/*dexamethasone*/ and forme in (00203/*comprime*/, 00754/*elixir*/) then do;
if datserv<dt_dexa or dt_dexa=. then dt_dexa=datserv;
if datserv>=dt_dexa then dtl_dexa=datserv;
du_dexa=1;
end;

if dencom=04550/*hydrocortisone*/ and forme=00203 then do;
if datserv<dt_hcort or dt_hcort=. then dt_hcort=datserv;
if datserv>=dt_hcort then dtl_hcort=datserv;
du_hcort=1;
end;

if dencom=06175/*methylprednisolone*/ and forme=00203 then do;
if datserv<dt_methyl or dt_methyl=. then dt_methyl=datserv;
if datserv>=dt_methyl then dtl_methyl=datserv;
du_methyl=1;
end;

if dencom=07956/*prednisolone*/ and forme=00203 then do;
if datserv<dt_predn1 or dt_predn1=. then dt_predn1=datserv;
if datserv>=dt_predn1 then dtl_predn1=datserv;
du_predn1=1;
end;

if dencom=08008/*prednisolone*/ and forme=02262/*solution orale*/ then do;
if datserv<dt_predn2 or dt_predn2=. then dt_predn2=datserv;
if datserv>=dt_predn2 then dtl_predn2=datserv;
du_predn2=1;
end;

if dencom=08021/*prednisone*/ and forme=00203 then do;
if datserv<dt_pred or dt_pred=. then dt_pred=datserv;
if datserv>=dt_pred then dtl_pred=datserv;
du_pred=1;
end;

if dencom=09724/*triamcinolone*/ and forme=00203/*comprime*/ then do;
if datserv<dt_triamc1 or dt_triamc1=. then dt_triamc1=datserv;
if datserv>=dt_triamc1 then dtl_triamc1=datserv;
du_triamc1=1;
end;

if dencom=09750/*triamcinolone*/ and forme=01827/*sirop*/ then do;
if datserv<dt_triamc2 or dt_triamc2=. then dt_triamc2=datserv;
if datserv>=dt_triamc2 then dtl_triamc2=datserv;
du_triamc2=1;
end;

* In IPD MA algorithm for use of oral corticosteroids is as follows:
if (beta1+beta2+beta3+budes+cort+dexa+hcort+methyl+predn1+predn2+pred+triamc1+triamc2) >=1;
if first.caseid then do; dt_rxcorti=.; dtl_rxcorti=.; end;

if du_beta1=1 or du_beta2=1 or du_beta3=1 or du_budes=1 or du_cort=1 or du_dexa=1 or du_hcort=1 or 
du_methyl=1 or du_predn1=1 or du_predn2=1 or du_pred=1 or du_triamc1=1 or du_triamc2=1 then do;

if dt_rxcorti =. then dt_rxcorti=datserv;
dtl_rxcorti=datserv;

end;

drop i dencom forme dosge; 

if dt_rxcorti ne . then rxcorti=1; else rxcorti=0;

format dt_beta1 dt_beta2 dt_beta3 dt_budes dt_cort dt_dexa dt_hcort dt_methyl dt_predn1 dt_predn2 dt_pred dt_triamc1 dt_triamc2
dtl_beta1 dtl_beta2 dtl_beta3 dtl_budes dtl_cort dtl_dexa dtl_hcort dtl_methyl dtl_predn1 dtl_predn2 dtl_pred dtl_triamc1
dtl_triamc2 dt_rxcorti dtl_rxcorti dt_rxcorti dtl_rxcorti date9.;

run;

proc sort data= wce.pre_rxcorti; by id caseid datserv; run;


data wce.rxcorti_30;
set wce.pre_rxcorti;
by id caseid;
keep caseid id t0 indexdate dt_rxcorti dtl_rxcorti rxcorti; 
if last.caseid  and indexdate-30 <= dtl_rxcorti <indexdate then output;  
run;
* 2.2% of subjects with last prescription for oral corticosteroids in the 30-day period before the indexdate;

data rxcorti1; 
set wce.rxcorti_30; 
cortidist= indexdate-dtl_rxcorti;
run;
proc univariate data=rxcorti1; var cortidist; run;
* IQR of last Rx for oral corticosteroids is Days 6-21;

* Decision to use cut-off of last prescription issued within 30 days before indexdate to identify concomitant use of oral corticosteroids;

/*To identify use of clopidogrel*/
data wce.pre_rxclopi; 
set wce.rxwce(where=(dencom in (46486, 47307)/*clopidogrel*/)); 
by id caseid;

retain 
dt_rxclopi dtl_rxclopi;

if first.caseid then do; dt_rxclopi=.; dtl_rxclopi=.;  end;

if datserv<dt_rxclopi or dt_rxclopi=. then dt_rxclopi=datserv;
if datserv>=dt_rxclopi then dtl_rxclopi=datserv;

if dt_rxclopi ne . then rxclopi=1; else rxclopi=0;

format dt_rxclopi dtl_rxclopi date9.;
keep caseid id t0 indexdate datserv dt_rxclopi dtl_rxclopi rxclopi  ;
run;

proc sort data= wce.pre_rxclopi; by id caseid datserv; run;


data wce.rxclopi_30;
set wce.pre_rxclopi;
by id caseid;
keep caseid id t0 indexdate datserv dt_rxclopi dtl_rxclopi rxclopi; 
if last.caseid  and indexdate-30 <= dtl_rxclopi <indexdate and rxclopi=1 then output; 
run;
* 1.7% of subjects with last prescription for clopidogrel in the 30-day period before the indexdate;

data rxclopi1; 
set wce.rxclopi_30; 
clopidist= indexdate-dtl_rxclopi;
run;
proc univariate data=rxclopi1; var clopidist; run;
* IQR of last Rx for clopidogrel is Days 6-21;

* Decision to use cut-off of last prescription issued within 30 days before indexdate to identify concomitant use of clopidogrel;


/*Use of low-dose ASA*/
data wce.pre_rxasa; 
set wce.rxwce(where=(dencom=46353/*ASA comprimé entérique 81mg*/
or
(dencom=00143/*ASA*/ and forme=00203/*comprimé*/ and dosge in (40199, 52216/*80mg or 325mg*/))
or
(dencom=00143/*ASA*/ and forme=00406/*comprimé entérique*/ and dosge in (40199, 51244 /*80mg or 300-325mg*/))
or
(dencom=00143/*ASA*/ and forme=00464/*comprimé masticable 80mg*/)
)); 
by id caseid;

retain 
dt_asa1 dt_asa2 dt_asa3 dt_asa4 dtl_asa1 dtl_asa2 dtl_asa3 dtl_asa4 dt_rxasa dtl_rxasa;

array asadt(4) dt_asa1 dt_asa2 dt_asa3 dt_asa4;
array asadtl (4) dtl_asa1 dtl_asa2 dtl_asa3 dtl_asa4;

if first.caseid then do;
do i=1 to 4;
asadt(i)=.;
asadtl(i)=.;
end;
dt_rxasa=.; dtl_rxasa=.;
end;

if dencom=46353/*ASA comprimé entérique 81mg*/then do;
if datserv<dt_asa1 or dt_asa1=. then dt_asa1=datserv;
if datserv>=dt_asa1 then dtl_asa1=datserv;
dd_asa1=1;
end;

if dencom=00143/*ASA*/ and forme=00203/*comprimé*/ and dosge in (40199, 52216/*80mg or 325mg*/)then do;
if datserv<dt_asa2 or dt_asa2=. then dt_asa2=datserv;
if datserv>=dt_asa2 then dtl_asa2=datserv;
dd_asa2=1;
end;

if dencom=00143/*ASA*/ and forme=00406/*comprimé entérique*/ and dosge in (40199, 51244 /*80mg or 300-325mg*/)then do;
if datserv<dt_asa3 or dt_asa3=. then dt_asa3=datserv;
if datserv>=dt_asa3 then dtl_asa3=datserv;
dd_asa3=1;
end;

if dencom=00143/*ASA*/ and forme=00464/*comprimé masticable 80mg*/then do;
if datserv<dt_asa4 or dt_asa4=. then dt_asa4=datserv;
if datserv>=dt_asa4 then dtl_asa4=datserv;
dd_asa4=1;
end;

* if (asa1+asa2+asa3+asa4)>=1;
if first.caseid then do; dt_rxasa=.; dtl_rxasa=.; end;

if dd_asa1=1 or dd_asa2=1 or dd_asa3=1 or dd_asa4=1 then do;

if dt_rxasa =. then dt_rxasa=datserv;
dtl_rxasa=datserv;
end;

drop i dencom forme dosge; 

if dt_rxasa ne . then rxasa=1; else rxasa=0;

format dt_asa1 dt_asa2 dt_asa3 dt_asa4 dtl_asa1 dtl_asa2 dtl_asa3 dtl_asa4 dt_rxasa dtl_rxasa date9.;
run;

proc sort data= wce.pre_rxasa; by id caseid datserv; run;

data wce.rxasa_30;
set wce.pre_rxasa;
by id caseid;
keep caseid id t0 indexdate datserv dt_rxasa dtl_rxasa rxasa;
if last.caseid  and indexdate-30 <= dtl_rxasa <indexdate then output; 
run;
* 22.4% of subjects with last prescription for aspirin in the 30-day period before the indexdate;

data rxasa1; 
set wce.rxasa_30; 
asadist= indexdate-dtl_rxasa;
run;
proc univariate data=rxasa1; var asadist; run;
* IQR of last Rx for ASA is Days 7-22;

* Decision to use cut-off of last prescription issued within 30 days before indexdate to identify concomitant use of cardioprotective 
aspirin;


/* To finalize prescription-defined covariates dataset */
proc sort data=wce.rxdm; by id caseid; run;
proc sort data=wce.rxlip; by id caseid; run;
proc sort data=wce.rxht; by id caseid; run;
proc sort data=wce.rxchd; by id caseid; run;
proc sort data=wce.rxchf; by id caseid; run;
proc sort data=wce.rxcvd; by id caseid; run;
proc sort data=wce.rxpvd; by id caseid; run;
proc sort data=wce.rxcopd; by id caseid; run;
proc sort data=wce.rxgi; by id caseid; run;
proc sort data=wce.rxrenal; by id caseid; run;
proc sort data=wce.rxra; by id caseid; run;
proc sort data=wce.rxcorti_30; by id caseid; run;
proc sort data=wce.rxclopi_30; by id caseid; run;
proc sort data=wce.rxasa_30;  by id caseid; run;

* In this dataset, prescriptions (or their algorithm) defining chronic comorbidities are assessed so as
to identify the first date of occurence that precedes the index date, 
except for hypertension, CHF, and renal disease, which are on the causal pathway), and for which prescription algorithms
are defined so as to identify the first date of occurence that precedes cohort entry. 
Concomitant drugs are defined in the 30 days before index date;

data wce.rxwce1_datSpSe; 
merge wce.rxdm wce.rxlip wce.rxht wce.rxchd wce.rxchf wce.rxcvd wce.rxpvd wce.rxcopd wce.rxgi wce.rxrenal wce.rxra
wce.rxcorti_30 wce.rxclopi_30 wce.rxasa_30;
by id caseid;
run;

proc sort data= ami.ramq_NCC_cc9304; by caseid id; run;

proc sort data= wce.rxwce1_datSpSe; by caseid id; run;

data rxwce2_datSpSe;
merge ami.ramq_NCC_cc9304 (in=p) wce.rxwce1_datSpSe;
by caseid id; if p;
array rcomorb(14) rxdm rxlip rxht rxchd rxchf rxcvd rxpvd rxcopd rxgi rxrenal rxra rxcorti rxclopi rxasa;
do i=1 to 14;
if rcomorb(i) =. then rcomorb(i) =0;
end;
if (rxdm+rxlip+rxht+rxchd+rxchf+rxcvd+rxpvd+rxcopd+rxgi+rxrenal+rxra+rxcorti+rxclopi+rxasa)>=1 then rx=1; else rx=0;
drop i;
run;

data wce.rxwce2_datSpSe;
retain caseid id t0 indexdate rxdm dt_rxdm dtl_rxdm rxlip dt_rxlip dtl_rxlip rxht dt_rxht dtl_rxht 
rxchd dt_rxchd dtl_rxchd rxchf dt_rxchf dtl_rxchf rxcvd dt_rxcvd dtl_rxcvd rxpvd dt_rxpvd dtl_rxpvd
rxcopd dt_rxcopd dtl_rxcopd rxgi dt_rxgi dtl_rxgi rxrenal dt_rxrenal dtl_rxrenal rxra dt_rxra dtl_rxra 
rxcorti dt_rxcorti dtl_rxcorti rxclopi dt_rxclopi dtl_rxclopi rxasa dt_rxasa dtl_rxasa;
set rxwce2_datSpSe;
run;


/********************************************************************************
* DEFINING BASELINE COVARIATES FROM ALL DATA SOURCES							*
* CREATING PERMANENT DATASET OF COVARIATES 
********************************************************************************/

/* dm */

data wce.pre_dm;
merge wce.hdm  wce.rxdm ;
by id caseid;
run;

proc sort data=wce.pre_dm; by id caseid; run;

data dm1; set wce.pre_dm (where=(dt_rxdm= .)); run;
* N= 2693 subjects without diabetes meds before index date but with at least one hospitalization with
a code for diabetes;
data dm2; set wce.pre_dm (where=(dt_rxdm= . and dt_hdm=dtl_hdm)); run;
* N= 1928 subjects without diabetes meds before index date and a single hospitalization with
code for diabetes;
data dm3; set wce.pre_dm (where=(dt_rxdm= . and dt_hdm=dtl_hdm and dtl_hdm <= indexdate-365)); run;
* N=1419 subjects without diabetes meds before index date and a single hospitalization with a code
for diabetes more than one year before the index date;
data dm4; set wce.pre_dm (where=(dt_rxdm= . and indexdate-365 <= dtl_hdm <indexdate)); run;
* N=827 subjects without diabetes meds before index date but with at least one hospitalization with
a code for diabetes in the year preceding the index date;
data dm5; set wce.pre_dm (where=(dt_rxdm= . and indexdate-180 <= dtl_hdm <indexdate)); run;
* N=497 subjects without diabetes meds before index date but with at least one hospitalization with
a code for diabetes within 180 days before the index date;
data dm6; set wce.pre_dm (where=(dt_rxdm= . and indexdate-90 <= dtl_hdm <indexdate)); run;
* N=295 subjects without diabetes meds before index date but with at least one hospitalization with
a code for diabetes within 90 days before the index date;

data excldm; set dm1; dist= indexdate-dtl_hdm; run;
proc univariate data=excldm; var dist; run;
* IQR 275-1641 days since last hospitalization with a code for diabetes in subjects without diabetes meds before index date; 

**** Discontinuation= Failure to have a medication dispensing within a defined number of days after exhaustion of the
days’ supply of the previous dispensing (often includes exhaustion of any stockpiled medication accumulated from previous dispensings)
Definition of “defined number of days after exhaustion of the days’ supply of the previous dispensing”: 180 days often used 
Ref: Raebel MA, Schmittdiel J, Karter AJ, Konieczny JL, Steiner JF. Standardizing terminology and definitions
of medication adherence and persistence in research employing electronic databases. Med Care. 2013 Aug:51(8 Suppl 3):S11-21;

* Discontinued diabetes meds. Code below allows for control by diet only;
data dm7; set  wce.pre_dm(where=(dtl_hdm ne . and .< dtl_rxdm < indexdate-210)); run;
* Assuming average prescription duration of 30 days
* N=1901 subjects who had a previous hospitalization with a code for diabetes, 
filled last prescription for diabetes meds more than 180 days before the indexdate;
data dm8; set wce.pre_dm(where=(.< dtl_rxdm < indexdate-210)); run; * Assuming average prescription duration of 30 days;
* N=5863 subjects filled last prescription for diabetes meds more than 180 days before the indexdate;

** DECISION: For defining diabetes as a comorbidity (and its date of first diagnosis), 
set no time limit on outpatient prescriptions for diabetes meds before indexdate; 


data wce.dm;
set wce.pre_dm; 
by id caseid;

* Determines first and last date of diabetes diagnosis, either via a hospitalization or a prescription for antidiabetics;
if .<dt_hdm<=dt_rxdm or dt_rxdm=. then dt_dm=dt_hdm;
if .<dt_rxdm<=dt_hdm or dt_hdm=. then dt_dm=dt_rxdm;
if .<dtl_hdm<=dtl_rxdm or dt_hdm=. then dtl_dm=dtl_rxdm;
if .<dtl_rxdm<=dtl_hdm  or dt_rxdm=. then dtl_dm=dtl_hdm;
dm=1;

* Subjects non-persistent to antidiabetics ;
if .< dtl_rxdm < indexdate-210 then stop_rxdm=1; else stop_rxdm=0;

format dt_dm dtl_dm date9.;
* run;
drop datserv; 
run;

data a; set wce.dm (where=(rxdm=1)); run; * Ok 38119;

proc freq data=wce.dm (where=(rxdm=1)); tables stop_rxdm /list missing; run;
* 15.4% of subjects started on medication had discontinued their antidiabetic meds;

proc sort data=wce.dm; by caseid id; run; * Final sort by caseid id;

/*lip*/

data wce.pre_lip;
merge wce.hlip wce.rxlip;
by id caseid;
run;

proc sort data=wce.pre_lip; by id caseid; run;

data lip1; set wce.pre_lip (where=(dt_rxlip= .)); run;
* N= 3657 subjects without outpatient lipid-lowering meds but at least one hospitalization with a code for hyperlipidemia;
data lip2; set wce.pre_lip (where=(dt_rxlip= . and dt_hlip=dtl_hlip)); run;
* N= 2754 subjects without outpatient lipid-lowering meds and a single hospitalization with code for hyperlipidemia;
data lip3; set wce.pre_lip (where=(dt_rxlip= . and dt_hlip=dtl_hlip and dtl_hlip <= indexdate-365)); run;
* N= 2239 subjects without outpatient lipid-lowering meds and a single hospitalization with a code
for hyperlipidemia more than one year before the index date;
data lip4; set wce.pre_lip (where=(dt_rxlip= . and indexdate-365 <= dtl_hlip <indexdate)); run;
* N= 817 subjects without outpatient lipid-lowering meds but with at least one hospitalization with a code for hyperlipidemia 
in the year precedingthe index date;
data lip5; set wce.pre_lip (where=(dt_rxlip= . and indexdate-180 <= dtl_hlip <indexdate)); run;
* N= 473 subjects without outpatient lipid-lowering meds but with at least one hospitalization with a code for hyperlipidemia within
180 days before the index date;
data lip6; set wce.pre_lip (where=(dt_rxlip= . and indexdate-90 <= dtl_hlip <indexdate)); run;
* N= 302 subjects without outpatient lipid-lowering meds but with at least one hospitalization with a code for hyperlipidemia within
90 days before the index date;

* Discontinued lipid-lowering meds. Code below allows for control by diet only;
data lip7; set  wce.pre_lip(where=(dtl_hlip ne . and .< dtl_rxlip < indexdate-210)); run;
* Assuming average prescription duration of 30 days
* N= 2783 subjects who had a previous hospitalization with a code for hyperlipidemia, 
filled last prescription forlipid-lowering meds more than 180 days before the indexdate;
data lip8; set wce.pre_lip(where=(.< dtl_rxlip < indexdate-210)); run; * Assuming average prescription duration of 30 days;
* N= 15600 subjects filled last prescription for lipid-lowering meds more than 180 days before the indexdate;


** DECISION: For defining hyperlipidemia as a comorbidity (and its date of first diagnosis), 
set no time limit on outpatient prescriptions for lipid-lowering meds before indexdate; 

data wce.lip;
set wce.pre_lip; 
by id caseid;

if .<dt_hlip<=dt_rxlip or dt_rxlip=. then dt_lip=dt_hlip;
if .<dt_rxlip<=dt_hlip or dt_hlip=. then dt_lip=dt_rxlip;
if .<dtl_hlip<=dtl_rxlip or dt_hlip=. then dtl_lip=dtl_rxlip;
if .<dtl_rxlip<=dtl_hlip  or dt_rxlip=. then dtl_lip=dtl_hlip;

lip=1;

* Subjects non-persistent to lipid-lowering drugs;
if .< dtl_rxlip < indexdate-210 then stop_rxlip=1; else stop_rxlip=0;

format dt_lip dtl_lip date9.;
* run;
drop datserv; 
run;

data a; set wce.lip(where=(rxlip=1)); run; * Ok 68351;

proc freq data=wce.lip(where=(rxlip=1)); tables stop_rxlip/list missing; run;
* 22.8% of subjects started on medication had discontinued their lipid-lowering drugs;

proc sort data=wce.lip; by caseid id; run;


/*ht*/

data wce.pre_ht;
merge wce.hht wce.rxht; 
by id caseid;
run;

proc sort data=wce.pre_ht; by id caseid; run;

data ht1; set wce.pre_ht (where=(dt_hht= .)); run;
* N=  68644 subjects without hospitalization with a code for hypertension;
data ht2; set wce.pre_ht (where=(dt_rxht= .)); run;
* N= 10152 subjects without outpatient antihypertensives (but with a hospitalization code for hypertension);


* Discontinued antihypertensives;
data ht3; set  wce.pre_ht(where=(dtl_hht ne . and .< dtl_rxht < indexdate-210)); run;
* Assuming average prescription duration of 30 days
* N= 1907 subjects who had a previous hospitalization with a code for hypertension 
filled last prescription more than 180 days before the indexdate;
data ht4; set wce.pre_ht(where=(.< dtl_rxht < indexdate-210)); run; * Assuming average prescription duration of 30 days;
* N= 12023 filled last prescription for antihypertensives more than 180 days before the indexdate;


** DECISION: For defining hypertension as a comorbidity (and its date of first diagnosis), 
set no time limit on outpatient prescriptions for antihypertensives before indexdate;

data wce.ht;
set wce.pre_ht; 
by id caseid;

if .<dt_hht<=dt_rxht or dt_rxht=. then dt_ht=dt_hht;
if .<dt_rxht<=dt_hht or dt_hht=. then dt_ht=dt_rxht;
if .<dtl_hht<=dtl_rxht or dt_hht=. then dtl_ht=dtl_rxht;
if .<dtl_rxht<=dtl_hht  or dt_rxht=. then dtl_ht=dtl_hht;

ht=1;

* Subjects non-persistent to antihypertensives;
if .< dtl_rxht < indexdate-210 then stop_rxht=1; else stop_rxht=0;

format dt_ht dtl_ht date9.;
* run;
drop datserv; 
run;

data a; set wce.ht(where=(rxht=1)); run; * Ok 89754;

proc freq data=wce.ht(where=(rxht=1)); tables stop_rxht/list missing; run;
* 13.4%% of subjects started on medication had discontinued their antihypertensives;

proc sort data=wce.ht; by caseid id; run;


/*priormi*/

data wce.priormi;
set wce.hpriormi;
by id caseid;
rename hpriormi=priormi dt_hpriormi=dt_priormi dtl_hpriormi=dtl_priormi;
run;

proc sort data=wce.priormi; by caseid id; run;
data checkwce; set wce.priormi (where=(dtl_priormi>=indexdate)); run;
* 0 observations, OK;


/*chd */

data wce.pre_chd;
merge wce.hchd wce.pci wce.cabg wce.rxchd;
by id caseid;
run;

proc sort data=wce.pre_chd; by id caseid; run;

data chd1; set wce.pre_chd (where=(dt_hchd=. and dt_pci=. and dt_cabg=.)); run;
* N= 27405 subjects without hospitalization for CHD or PCI or CABG but with meds at any time prior to index date;  
data chd2; set wce.pre_chd (where=(dt_hchd=. and dt_pci=. and dt_cabg=. and .< dtl_rxchd < indexdate-365)); run;
* N=2756 subjects without hospitalization for CHD or PCI or CABG but with meds in the year prior to index date;  
data chd3; set wce.pre_chd (where=(dt_hchd ne . or dt_pci ne . or dt_cabg ne .)); run;
* N= 46782 subjects with hospitalization for CHD with or without PCI or CABG; 
data chd4; set wce.pre_chd (where=(dt_rxchd= . and (dt_hchd ne . or dt_pci ne . or dt_cabg ne .))); run;
* N= 10476 subjects with hospitalization for CHD with or without PCI or CABG but without meds for CHD; 
data chd4; set wce.pre_chd (where=(dt_rxchd= . )); run;
* N= 10476 subjects with a Dx for CHD but without any meds;

* Discontinued CHD meds or were undertreated after an hospit (.<= dtl_rxchd);
data chd5; set  wce.pre_chd(where=((dt_hchd ne . or dt_pci ne . or dt_cabg ne .) and .<= dtl_rxchd < indexdate-210)); run; * Assuming average prescription duration of 30 days;
* N= 13625 subjects who had a previous hospitalization with a code for CHD or had a procedure
either did not receive outpatient CHD meds or filled last prescription more than 180 days before the indexdate;

* Discontinued CHD meds;
data chd6; set wce.pre_chd(where=(.< dtl_rxchd < indexdate-210)); run;
* N= 6547 subjects filled last prescription more than 180 days before the indexdate;

** DECISION: For defining coronary heart disease as a comorbidity (and its date of first diagnosis), 
set no time limit on outpatient prescriptions for CHD meds before indexdate;

data wce.chd;
set wce.pre_chd;
dt_chd= min(of dt_rxchd dt_hchd dt_pci dt_cabg);
dtl_chd= max(of dtl_rxchd dtl_hchd dtl_pci dtl_cabg);
chd=1;

* Discontinued CHD meds;
if (.< dtl_rxchd < indexdate-210) then stop_rxchd=1; else stop_rxchd=0;

format dt_chd dtl_chd date9.;
* run;
drop admit datserv; 
run;

data a; set wce.chd(where=(rxchd=1)); run; * Ok 63711;

proc freq data=wce.chd(where=(rxchd =1)); tables stop_rxchd/list missing; run;
* 10.3% of subjects started on medication had discontinued their CHD meds;

proc sort data=wce.chd; by caseid id; run;



/*chd_o */
* wce.hchd_o= hospitalisation with CHD ICD9 codes in first position or PCI or CABG or Rx for CHD in the 30 days prior to index date;
data wce.pre_chd_o;
merge wce.hchd_o wce.pci wce.cabg wce.rxchd;
by id caseid;
run;

proc sort data=wce.pre_chd_o; by id caseid; run;

data chd_o1; set wce.pre_chd_o (where=(dt_hchd_o=. and dt_pci=. and dt_cabg=.)); run;
* N= 44594 subjects without hospitalization with CHD in first position and no PCI and no CABG but with meds at any time prior to index date;  
data chd_o2; set wce.pre_chd_o (where=(dt_hchd_o=. and dt_pci=. and dt_cabg=. and .< dtl_rxchd < indexdate-365)); run;
* N=4128 subjects without hospitalization with CHD in first position and no PCI and no CABG 
but with meds in the year prior to index date;  
data chd_o3; set wce.pre_chd_o (where=(dt_hchd_o ne . or dt_pci ne . or dt_cabg ne .)); run;
* N= 21404 subjects with hospitalization with CHD in first position or PCI or CABG; 
data chd_o4; set wce.pre_chd_o (where=(dt_rxchd= . and (dt_hchd_o ne . or dt_pci ne . or dt_cabg ne .))); run;
* N= 2287 subjects with hospitalization with CHD in first position with or without PCI or CABG but without meds for chd_o; 
data chd_o4; set wce.pre_chd_o (where=(dt_rxchd= . )); run;
* N= 2287 subjects with a Dx for chd_o but without any meds;

* Discontinued chd meds or were undertreated after an hospit (.<= dtl_rxchd);
data chd_o5; set  wce.pre_chd_o(where=((dt_hchd_o ne . or dt_pci ne . or dt_cabg ne .) and .<= dtl_rxchd < indexdate-210)); run; * Assuming average prescription duration of 30 days;
* N= 3669 subjects who had a previous hospitalization with a code for chd_o or had a procedure
either did not receive outpatient chd_o meds or filled last prescription more than 180 days before the indexdate;

* Discontinued chd meds;
data chd_o6; set wce.pre_chd_o(where=((dt_hchd_o ne . or dt_pci ne . or dt_cabg ne .) and .< dtl_rxchd < indexdate-210)); run;
* N= 1382 subjects filled last prescription more than 180 days before the indexdate;

** DECISION: For defining coronary heart disease as a comorbidity (and its date of first diagnosis), 
set no time limit on outpatient prescriptions for chd_o meds before indexdate;

data wce.chd_o;
set wce.pre_chd_o (where=((dt_hchd_o ne . or dt_pci ne . or dt_cabg ne .) or .< dtl_rxchd < indexdate-30));
dt_chd_o= min(of dt_rxchd dt_hchd_o dt_pci dt_cabg);
dtl_chd_o= max(of dtl_rxchd dtl_hchd_o dtl_pci dtl_cabg);
chd_o=1;

format dt_chd_o dtl_chd_o date9.;
* run;
drop admit datserv; 
run;

proc sort data=wce.chd_o; by caseid id; run;


/*chf*/

data wce.pre_chf;
merge wce.hchf wce.rxchf;
by id caseid;
run;

proc sort data=wce.pre_chf; by id caseid; run;

data chf1; set wce.pre_chf (where=(dt_rxchf= .));run;
* N= 2020 subjects without CHF meds but with at least one hospitalization with a code for CHF;
** Decision to include these subjects for the purpose of defining CHF;

* Discontinued CHF meds or were undertreated after an hospit (.<= dtl_rxchf);
data chf2; set  wce.pre_chf(where=(dt_hchf ne . and (.<= dtl_rxchf < indexdate-210))); run; * Assuming average prescription duration of 30 days;
* N= 2380 subjects who had a previous hospitalization with a code for CHF either did not receive 
outpatient CHF meds or filled last prescription more than 180 days before the indexdate;

* Discontinued CHF meds;
data chf3; set wce.pre_chf(where=(.< dtl_rxchf < indexdate-210)); run;
* N= 1747 subjcts filled last prescription more than 180 days before the indexdate;


data wce.chf;
set wce.pre_chf;
by id caseid;

if .<dt_hchf<=dt_rxchf or dt_rxchf=. then dt_chf=dt_hchf;
if .<dt_rxchf<=dt_hchf or dt_hchf=. then dt_chf=dt_rxchf;
if .<dtl_hchf<=dtl_rxchf or dt_hchf=. then dtl_chf=dtl_rxchf;
if .<dtl_rxchf<=dtl_hchf  or dt_rxchf=. then dtl_chf=dtl_hchf;

chf=1;

* Discontinued CHF meds;
if (.< dtl_rxchf < indexdate-210) then stop_rxchf=1; else stop_rxchf=0;

format dt_chf dtl_chf date9.;
* run; 
run;

data a; set wce.chf(where=(rxchf=1)); run; * Ok 15638;

proc freq data=wce.chf(where=(rxchf =1)); tables stop_rxchf/list missing; run;
* 11.2% of subjects started on medication had discontinued their CHF meds;

proc sort data=wce.chf; by caseid id; run;


/*cvd*/

data wce.pre_cvd;
merge wce.hcvd wce.rxcvd;
by id caseid;
run;

proc sort data=wce.pre_cvd; by id caseid; run;

data wce.cvd;
set wce.pre_cvd; 
by id caseid;

if .<dt_hcvd<=dt_rxcvd or dt_rxcvd=. then dt_cvd=dt_hcvd;
if .<dtl_hcvd<=dtl_rxcvd or dt_hcvd=. then dtl_cvdif .<dt_rxcvd<=dt_hcvd or dt_hcvd=. then dt_cvd=dt_rxcvd;
=dtl_rxcvd;
if .<dtl_rxcvd<=dtl_hcvd  or dt_rxcvd=. then dtl_cvd=dtl_hcvd;

cvd=1;
format dt_cvd dtl_cvd date9.;
* run;
run;

proc sort data=wce.cvd; by caseid id; run;


/*pvd*/

data wce.pre_pvd;
merge wce.hpvd wce.rxpvd;
by id caseid;
run;

data pvd1; set wce.pre_pvd (where=(.< dtl_rxpvd < indexdate-365));run;
data pvd2; set wce.pre_pvd (where=(hpvd=. and rxpvd ne .)); run;
* N=242 subjects without hospitalization code for PVD but prescribed meds (pentoxifylline);

proc sort data=wce.pre_pvd; by id caseid; run;

data wce.pvd;
set wce.pre_pvd; 
by id caseid;

if .<dt_hpvd<=dt_rxpvd or dt_rxpvd=. then dt_pvd=dt_hpvd;
if .<dt_rxpvd<=dt_hpvd or dt_hpvd=. then dt_pvd=dt_rxpvd;
if .<dtl_hpvd<=dtl_rxpvd or dt_hpvd=. then dtl_pvd=dtl_rxpvd;
if .<dtl_rxpvd<=dtl_hpvd  or dt_rxpvd=. then dtl_pvd=dtl_hpvd;

pvd=1;
format dt_pvd dtl_pvd date9.;
* run;
run;

proc sort data=wce.pvd; by caseid id; run;


/*copd*/

data wce.pre_copd;
merge wce.hcopd wce.rxcopd;
by id caseid;
run;
* COPD mostly defined by prescriptions, all of which have acceptable specificity
However it is conceivable that these meds are inappropriately prescribed when they are not used chronically in a patient
since COPD is a chronic condition. As use can be sporadic or intermittent it seems better to rely on distance from indexdate
for defining COPD with meds in patients who have had no hospitalization with a code for COPD;

data copd1; set wce.pre_copd (where=(hcopd= . and (.< dtl_rxcopd < indexdate-365)));run;
* N= 36322 subjects without hospitalization code for COPD and filling no meds for COPD in the 
year prior to index date. Could have been prescribed COPD meds for other reasons during time in cohort;

** DECISION: For defining chronic obstructive pulmonary disease as a comorbidity (and its date of first diagnosis), 
if subjects have no hospitalization code for CODP then set requirement for use of COPD meds in the one year prior to index date;

proc sort data=wce.pre_copd; by id caseid; run;


data wce.copd;
set wce.pre_copd; 
by id caseid;
if hcopd= . and (.< dtl_rxcopd < indexdate-365) then delete;

if .<dt_hcopd<=dt_rxcopd or dt_rxcopd=. then dt_copd=dt_hcopd;
if .<dt_rxcopd<=dt_hcopd or dt_hcopd=. then dt_copd=dt_rxcopd;
if .<dtl_hcopd<=dtl_rxcopd or dt_hcopd=. then dtl_copd=dtl_rxcopd;
if .<dtl_rxcopd<=dtl_hcopd  or dt_rxcopd=. then dtl_copd=dtl_hcopd;

copd=1;
format dt_copd dtl_copd date9.;
* run;
drop datserv; 
run;

proc sort data=wce.copd; by caseid id; run;

/*gi*/

data wce.pre_gi;
merge wce.hgi wce.rxgi;
by id caseid;
run;
* GI disease mostly defined by prescriptions, all of which have acceptable specificity
However it is conceivable that these meds are inappropriately prescribed and use can be sporadic or intermittent.
For identifying subjects with chronic GI condition, it seems better to rely on distance from indexdate
for defining GI with meds in patients who have had no hospitalization with a code for GI disease;

data gi1; set wce.pre_gi (where=(hgi= . and (.< dtl_rxgi < indexdate-365)));run;
* N= 55017 subjects without hospitalization code for GI disease and filling no meds for GI disease in the 
year prior to index date. Could have been prescribed GI meds for other reasons during time in cohort;


** DECISION: For defining GI disease as a comorbidity (and its date of first diagnosis), 
if subjects have no hospitalization code for GI disease then set requirement for use of GI meds in the one year prior to index date;

proc sort data=wce.pre_gi; by id caseid; run;

data wce.gi;
set wce.pre_gi; 
by id caseid;
if hgi= . and (.< dtl_rxgi < indexdate-365) then delete;

if .<dt_hgi<=dt_rxgi or dt_rxgi=. then dt_gi=dt_hgi;
if .<dt_rxgi<=dt_hgi or dt_hgi=. then dt_gi=dt_rxgi;
if .<dtl_hgi<=dtl_rxgi or dt_hgi=. then dtl_gi=dtl_rxgi;
if .<dtl_rxgi<=dtl_hgi  or dt_rxgi=. then dtl_gi=dtl_hgi;

gi=1;
format dt_gi dtl_gi date9.;
* run;
drop datserv; 
run;

proc sort data=wce.gi; by caseid id; run;

/*gibleed*/

data wce.gibleed;
set wce.hgibleed;
by id caseid;
rename hgibleed=gibleed dt_hgibleed=dt_gibleed dtl_hgibleed=dtl_gibleed;
run;

proc sort data=wce.gibleed; by caseid id; run;

/*renal*/

data wce.pre_renal;
merge wce.hrenal wce.rxrenal;
by id caseid;
run;

proc sort data=wce.pre_renal; by id caseid; run;

data wce.renal;
set wce.pre_renal; 
by id caseid;

if .<dt_hrenal<=dt_rxrenal or dt_rxrenal=. then dt_renal=dt_hrenal;
if .<dt_rxrenal<=dt_hrenal or dt_hrenal=. then dt_renal=dt_rxrenal;
if .<dtl_hrenal<=dtl_rxrenal or dt_hrenal=. then dtl_renal=dtl_rxrenal;
if .<dtl_rxrenal<=dtl_hrenal  or dt_rxrenal=. then dtl_renal=dtl_hrenal;

renal=1;
format dt_renal dtl_renal date9.;
* run;
drop datserv; 
run;

proc sort data=wce.renal; by caseid id; run;


/*ra*/

data wce.pre_ra;
merge wce.hra wce.rxra;
by id caseid;
run;
* Note that it is possible that subjects have a hospitalization code for RA but are not yet treated with DMARDs or biologics
(i.e. may receive NSAIDs only);

** DECISION: For defining RA as a comorbidity (and its date of first diagnosis), 
set no time requirement for use of RA meds prior to index date;

proc sort data=wce.pre_ra; by id caseid;run;

data wce.ra;
set wce.pre_ra; 
by id caseid;

if .<dt_hra<=dt_rxra or dt_rxra=. then dt_ra=dt_hra;
if .<dt_rxra<=dt_hra or dt_hra=. then dt_ra=dt_rxra;
if .<dtl_hra<=dtl_rxra or dt_hra=. then dtl_ra=dtl_rxra;
if .<dtl_rxra<=dtl_hra  or dt_rxra=. then dtl_ra=dtl_hra;

ra=1;
format dt_ra dtl_ra date9.;
* run;
drop datserv; * First suppressed;
run;

proc sort data=wce.ra; by caseid id; run;


/* Use of oral corticosteroids*/

data wce.rxcorti;
set wce.rxcorti_30;
by id caseid;
* run;
cortirx=rxcorti;
drop rxcorti;
run;

proc sort data=wce.rxcorti; by caseid id; run;


/* Use of clopidogrel*/

data wce.rxclopi;
set wce.rxclopi_30;
by id caseid;
* run;
clopi=rxclopi;
drop rxclopi datserv;
run;

proc sort data=wce.rxclopi; by caseid id; run;


/* Use of cardioprotective aspirin*/

data wce.rxasa;
set wce.rxasa_30;
by id caseid;
asa=rxasa;
drop rxasa datserv;
run;

proc sort data=wce.rxasa; by caseid id; run;


/* Finalizing comorbidity dataset */

* All datasets already sorted by caseid id;
* The following comorbidities are defined in the period preceding index date  index date: dm, lip, priormi, chd, cvd, pvd, gibleed, ra;
* The following comorbidities are defined in the period preceding index date for hospitalisations
and in the year preceding the index date for prescriptions: copd, gi
The following comorbidities are defined in the period preceding cohort entry: ht, chf, renal;
* Concomitant drugs are defined as prescribed in the 30 days preceding index date: oral corticosteroids, clopidogrel, 
cardioprotective aspirin;


data covars9304;
merge wce.dm wce.lip wce.ht wce.priormi wce.chd wce.chd_o wce.chf wce.cvd wce.pvd wce.copd wce.gi wce.gibleed wce.renal
wce.ra wce.rxcorti wce.rxclopi wce.rxasa;
by caseid id;
run;

proc sort data=covars9304; by caseid id; run;
proc sort data= ami.ramq_NCC_cc9304; by caseid id; run;


data ami.ramq_NCC_dat_covars_SpSe9304;
merge ami.ramq_NCC_cc9304 (in=p) covars9304; by caseid id; if p;
array comorb(17) dm lip ht priormi chd chd_o chf cvd pvd copd gi gibleed renal ra cortirx clopi asa;
do i=1 to 17;
if comorb(i) =. then comorb(i) =0;
end;

* Non-persistence to CV meds;
if stop_rxdm=1 or stop_rxlip=1 or stop_rxht=1 or stop_rxchd=1 or stop_rxchf=1 then nonpersist=1; else nonpersist=0;

* Underuse of cardioprotective aspirin in subjects with CHD or with prior MI;
if priormi=1 and asa=0 then noasa_mi=1; else noasa_mi=0;
if chd=1 and asa=0 then noasa_chd=1; else noasa_chd=0;

keep caseid id t0 indexdate ami ageindex male dt_dm dtl_dm dm dt_lip dtl_lip lip dt_ht dtl_ht ht dt_priormi dtl_priormi priormi 
dt_chd dtl_chd chd dt_chd_o dtl_chd_o chd_o dt_chf dtl_chf chf dt_cvd dtl_cvd cvd dt_pvd dtl_pvd pvd dt_copd dtl_copd copd 
dt_gi dtl_gi gi dt_gibleed dtl_gibleed gibleed dt_renal dtl_renal renal dt_ra dtl_ra ra dt_rxcorti dtl_rxcorti cortirx
dt_rxclopi dtl_rxclopi clopi dt_rxasa dtl_rxasa asa nonpersist stop_rxdm stop_rxlip stop_rxht stop_rxchd stop_rxchf
noasa_mi noasa_chd;
run;

proc sort data=ami.ramq_NCC_dat_covars_SpSe9304; by caseid id; run;


/***********************************************************************************
* Explore non-persistence to CV meds and undertreatment by cardioprotective aspirin
************************************************************************************/

/* Non-persistence to CV meds */

data nonpersist1; 
set ami.ramq_NCC_dat_covars_SpSe9304(where=(nonpersist=1)); 
keep caseid id ami nonpersist stop_rxdm stop_rxlip stop_rxht stop_rxchd stop_rxchf;
run; 
* 15.4% (36092/233816 subjects)overall were non persistent to one of more of antidiabetics, lipid-lowering meds,
antihypertensives, CHD, or CHF meds; 

proc freq data=ami.ramq_NCC_dat_covars_SpSe9304 (where=(ami=1)); tables nonpersist/list missing; run;
* 17.2% with AMI=1 were non-persistent to CV meds;

proc means data= ami.ramq_NCC_dat_covars_SpSe9304 (where=(nonpersist=1));
var nonpersist stop_rxdm stop_rxlip stop_rxht stop_rxchd stop_rxchf ; run; 


proc freq data= ami.ramq_NCC_dat_covars_SpSe9304
(where=(nonpersist=1 and (stop_rxdm=1 or stop_rxlip=1 or stop_rxht=1 or stop_rxchd=1 or stop_rxchf=1)));
tables nonpersist*stop_rxdm*stop_rxlip*stop_rxht*stop_rxchd*stop_rxchf / list missing; run; 


/* Prior MI - N=17025 subjects*/
/* Prior MI and non-persistent to CV meds */

data nonpersist2; 
set ami.ramq_NCC_dat_covars_SpSe9304(where=(priormi=1));
if nonpersist=1 then output; 
keep caseid id ami priormi nonpersist stop_rxdm stop_rxlip stop_rxht stop_rxchd stop_rxchf;
run; 
* 20.8% (3536/17025 subjects) with prior MI were non persistent to one of more of antidiabetics, lipid-lowering meds,
antihypertensives, CHD, or CHF meds (CV meds); 
proc freq data=nonpersist2; tables ami /list missing; run;
* 18% of those had AMI;


/* Prior MI and no cardioprotective ASA in 30 days prior to ami */

data nonpersist3; 
set ami.ramq_NCC_dat_covars_SpSe9304(where=(priormi=1));
if noasa_mi=1 then output; 
keep caseid id ami priormi noasa_mi nonpersist stop_rxdm stop_rxlip stop_rxht stop_rxchd stop_rxchf;
run; 
* 52.0% (8861/17025 subjects) with prior MI had no cardioprotective ASA in 30 days prior to index date;
proc freq data=nonpersist3; tables ami /list missing; run;
* 18% of those had AMI;


/* Prior MI and no cardioprotective ASA in 30 days prior to ami OR non-persistence to CV meds */

data nonpersist4; 
set ami.ramq_NCC_dat_covars_SpSe9304(where=(priormi=1));
if noasa_mi=1 or nonpersist=1 then output; ; 
keep caseid id ami priormi noasa_mi nonpersist stop_rxdm stop_rxlip stop_rxht stop_rxchd stop_rxchf;
run; 
* 58.4% (9941/17025 subjects) with prior MI had no cardioprotective ASA in 30 days prior to index date or were
non-persistence to CV meds;
proc freq data=nonpersist4; tables ami /list missing; run;
* 19% of those had AMI;


/* Prior MI and no cardioprotective ASA in 30 days prior to ami AND non-persistence to CV meds */

data nonpersist5; 
set ami.ramq_NCC_dat_covars_SpSe9304(where=(priormi=1));
if noasa_mi=1 and nonpersist=1 then output; 
keep caseid id ami priormi noasa_mi nonpersist stop_rxdm stop_rxlip stop_rxht stop_rxchd stop_rxchf;
run; 
* 14.4% (2456/17025 subjects) with prior MI had  no cardioprotective ASA in 30 days prior to index date and 
were non persistent to CV meds; 
proc freq data=nonpersist5; tables ami /list missing; run;
* 16% of those had AMI;


/* CHD N=74187 subjects*/
/* CHD and non-persistent to CV meds */

data nonpersist6; 
set ami.ramq_NCC_dat_covars_SpSe9304(where=(chd=1));
if nonpersist=1 then output; 
keep caseid id ami chd nonpersist stop_rxdm stop_rxlip stop_rxht stop_rxchd stop_rxchf;
run; 
* 21.4% (15852/74187 subjects) with CHD were non persistent to one of more of antidiabetics, lipid-lowering meds,
antihypertensives, CHD, or CHF meds (CV meds); 
proc freq data=nonpersist6; tables ami /list missing; run;
* 14% of those had AMI;


/* CHD and no cardioprotective ASA in 30 days prior to ami */

data nonpersist7; 
set ami.ramq_NCC_dat_covars_SpSe9304(where=(chd=1));
if noasa_chd=1 then output;  
keep caseid id ami chd noasa_chd nonpersist stop_rxdm stop_rxlip stop_rxht stop_rxchd stop_rxchf;
run; 
* 56.8% (42117/74187 subjects) with CHD had no cardioprotective ASA in 30 days prior to index date;
proc freq data=nonpersist7; tables ami /list missing; run;
* 14% of those had AMI;


/* CHD and no cardioprotective ASA in 30 days prior to ami OR non-persistence to CV meds */

data nonpersist8; 
set ami.ramq_NCC_dat_covars_SpSe9304(where=(chd=1));
if noasa_chd=1 or nonpersist=1 then output; 
keep caseid id ami chd noasa_chd nonpersist stop_rxdm stop_rxlip stop_rxht stop_rxchd stop_rxchf;
run; 
* 62.0% (46058/74187 subjects) with CHD had no cardioprotective ASA in 30 days prior to index date or were
non-persistence to CV meds;
proc freq data=nonpersist8; tables ami /list missing; run;
* 15% of those had AMI;

/* CHD and no cardioprotective ASA in 30 days prior to ami AND non-persistence to CV meds */

data nonpersist9; 
set ami.ramq_NCC_dat_covars_SpSe9304(where=(chd=1));
if noasa_chd=1 and nonpersist=1 then output; 
keep caseid id ami chd noasa_chd nonpersist stop_rxdm stop_rxlip stop_rxht stop_rxchd stop_rxchf;
run; 
* 16.0% (11911/74187 subjects) with CHD had  no cardioprotective ASA in 30 days prior to index date and 
were non persistent to CV meds; 
proc freq data=nonpersist9; tables ami /list missing; run;
* 12% of those had AMI;

/***********************
* Descriptive analysis
************************/


proc sort data=wce.hospwce2_datSpSe; by caseid id; run;
proc sort data=wce.procwce2; by caseid id; run;
proc sort data=wce.rxwce2_datSpSe; by caseid id; run;


/* To verify distribution of hospitalization-defined covariates */

ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - NCC for WCE hospitalizations - datSpSe.rtf' style=analysis; 
title1 'RAMQ nested case-control dataset for recency-weighted cumulative exposure (WCE) analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'Covariates determined via a strategy balancing sensitivity and specificity - Assessed concurrently with time-varying NSAID exposures';
title4 'All subjects have at least one year of hospitalization history'; 
title5 'Hospitalizations for potentially mediating comorbidities - hypertension, CHF, and renal failure - assessed before cohort entry';
title6 'Hospitalizations for other comorbidities determined before index date';
proc freq data=wce.hospwce2_datSpSe;
tables hdm hlip hht hpriormi hchd hchd_o hchf hcvd hpvd hcopd hgi hgibleed hrenal hra/list missing;
options nodate nonumber;
run;
ods rtf close;

/* To verify distribution of procedure-defined covariates */

ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - NCC for WCE procedures - datSpSe.rtf' style=analysis; 
title1 'RAMQ nested case-control dataset for recency-weighted cumulative exposure (WCE) analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'Covariates determined via a strategy balancing sensitivity and specificity - Assessed concurrently with time-varying NSAID exposures'; 
title4 'All subjects have at least one year of hospitalization history';
title5 'Procedures for coronary heart disease determined before index date';
proc freq data=wce.procwce2;
tables pci cabg /list missing;
options nodate nonumber;
run;
ods rtf close; 

/* To verify distribution of prescription-defined covariates */

ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - NCC for WCE prescriptions - datSpSe.rtf' style=analysis; 
title1 'RAMQ nested case-control dataset for recency-weighted cumulative exposure (WCE) analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'Covariates determined via a strategy balancing sensitivity and specificity - Assessed concurrently with time-varying NSAID exposures';
title4 'All subjects have at least one year of prescription drug history'; 
title5 'Prescriptions for potentially mediating comorbidities - hypertension, CHF, and renal failure - assessed before cohort entry';
title7 'Prescriptions for other comorbidities determined during period preceding index date'; 
title8 'Prescriptions for comorbidities without algorithm to overcome low specificity of drug treatment - COPD and GI ulcer disease - assessed in the year preceding index date'; 
title7 'Concomitant drugs determined during period of 30 days before index date';
proc freq data=wce.rxwce2_datSpSe;
tables rxdm rxlip rxht rxchd rxchf rxcvd rxpvd rxcopd rxgi rxrenal rxra rxcorti rxclopi rxasa/list missing;
options nodate nonumber;
run;
ods rtf close;

proc sort data=ami.ramq_NCC_dat_covars_SpSe9304; by caseid id; run;

ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - NCC for WCE covariates - datSpSe.rtf' style=analysis;  
title1 'RAMQ nested case-control dataset for recency-weighted cumulative exposure (WCE) analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'Covariates determined via a strategy balancing specificity and sensitivity - Assessed concurrently with time-varying NSAID exposures'; 
title4 'All subjects have at least one year of hospitalization and prescription drug history';
title5 'Hospitalization-, procedure-, and prescription-defined comorbidities and use of concomitant drugs';
title6 'Potentially mediating comorbidities - hypertension, CHF, and renal failure - assessed before cohort entry';
title7 'Other comorbidities determined during period preceding index date'; 
title8 'Prescriptions for comorbidities without algorithm to overcome low specificity of drug treatment - COPD and GI ulcer disease - assessed in the year preceding index date'; 
title9 'Concomitant drugs - oral corticosteroids, clopidogrel, and cardioprotective aspirin - determined in the 30 days preceding index date';
proc freq data=ami.ramq_NCC_dat_covars_SpSe9304;
tables male dm lip ht priormi chd chd_o chf cvd pvd copd gi gibleed renal ra cortirx clopi asa /list missing;
options nodate nonumber;
run;
ods rtf close; 
