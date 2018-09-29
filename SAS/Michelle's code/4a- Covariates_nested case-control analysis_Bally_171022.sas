%put &sysdate9;
%let temps1=%sysfunc(time());


/********************************************************************************************************
* AUTHOR:		Michèle Bally (based on Linda Lévesque and Sophie Dell'Aniello							*
*				for RAMQ - AF and Bisphosphonates)					 									*
*				Lyne Nadeau revised codes for hospitalizations (July 2013) and programmed determination *
*				of covariates per indexdate								         						*
* CREATED:		July 16, 2014																			*
* UPDATED																								*
* TITLE:		Covariates SpSe_AMI NSAIDs_NCC IPD MA_RAMQ9304											*
* OBJECTIVE:	Third of 3 scenario for determining covariates											*
*				in the  nested case-control RAMQ dataset for analyses: 1) as single study and			*
*				2) for inclusion in an individual patient data meta-analysis (IPD MA)					*
*				Covariates are determined via a strategy balancing specificity and sensitivity			*
*				This scenario is also applied to the recency-weighted cumulative exposure (WCE)			*
*				analysis (program is modified to additionally determines date of onset of comorbidity)	*
*				Hospitalization-, and prescription-defined comorbidities that on causal pathway are		* 
* 				assessed only before cohort entry														*
*				Hospitalization-, procedure-, and prescription-defined covariates are determined		* 
*				in the period preceding index date for other comorbidities								*	
*				(exception: prescriptions for comorbidities without good algorithm to overcome			* 
*				low specificity of drug treatment are assessed in the year preceding index date)		*
*				Concomitant drugs are assessed in the 30 days preceding index date						*
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
Comorbidities: coronary heart disease, cerebrovascular disease, hypertension, diabetes, 
previous MI, congestive heart failure, peripheral vascular disease, rheumatoid arthritis, 
osteoarthritis, hyperlipidemia, COPD, GI ulcer disease, GI bleed, renal failure (acute and chronic), 
Concomitant specific drugs: low-dose ASA, anticoagulants, oral corticosteroids, and clopidogrel 

*/ Justification for not including certain covariates in the preliminary IPD MA dataset */ 

* Although they were included in the original RAMQ study (Brophy 2007), will not include the following covariates
for the IPD MA: cancer, thyroid disease, or psychiatric disease
Reason is that these three comorbidities are not part of the DAG for NSAID exposure and AMI outcome

* Will include COPD rather than respiratory illness and cerebrovascular disease instead of stroke 
Reasons are that COPD excludes bronchitis and asthma and is therefore preferred over respiratory illness and that
cerebrovascular disease is less restrictive than stroke

* Will not include arrhythmia because although the causal diagram for 
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
  create table hosp (keep=id caseid t0 indexdate admit dp dS1--dS15 TXT1--TXT9  DATXT1--DATXT9) as
  select * 
  from  ami.ramq_NCC_cc9304,data.hosp
  where ramq_NCC_cc9304.id=hosp.id and admit ne . and '01Jan92'd<= admit < indexdate;
quit;

proc sort data=hosp;by id caseid; run; * by id first and caseid in second;

data hosp1; 
set hosp; by id caseid; * by id first and caseid in second 
since covariates are determined with respect to index date, in a matched CC dataset; 
retain hospdm0-hospdm15 hosplip0-hosplip15 hospht0-hospht15 hosppriormi0-hosppriormi15 hospchd0-hospchd15 
hospchf0-hospchf15 hospcvd0-hospcvd15 hosppvd0-hosppvd15 hospcopd0-hospcopd15 hospgi0-hospgi15
hospgibleed0-hospgibleed15 hosprenal0-hosprenal15 hospra0-hospra15;
* This approach makes it possible to see and count which position determines comorbidity; 

* Modified by Lyne  - Create variables for diagnosis with different length, 3,4,5 digits
Need to specify format because SAS will read 20 or so first line and if it finds variables to be numeric
then will consider them all numeric. Which may bug at some point if var is entered as character; 

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

* Defining 13 comorbidities. Time window for assessment will differ based on clinical rationale (see notes at start of program);
 array dm{16} hospdm0-hospdm15;/*diabetes*/
 array lip{16} hosplip0-hosplip15;/*hyperlipidemia*/
 array ht{16} hospht0-hospht15;/*hypertension*/
 array priormi{16} hosppriormi0-hosppriormi15;/*MI or old M */
 array chd{16} hospchd0-hospchd15;/*coronary heart disease*/
 array chf{16} hospchf0-hospchf15;/*congestive heart failure*/
 array cvd{16} hospcvd0-hospcvd15;/*cerebrovascular disease*/
 array pvd{16} hosppvd0-hosppvd15;/*peripheral vascular disease*/
 array copd{16} hospcopd0-hospcopd15;/*chronic obstructive pulmonary disease*/
 array gi{16} hospgi0-hospgi15;/*peptic ulcer disease and related*/
 array gibleed{16} hospgibleed0-hospgibleed15;/*gastrointestinal bleed except alcohol-related (Sask study-PDS 2009 exclusion)*/
 array renal{16} hosprenal0-hosprenal15;/*acute and chronic renal failure*/
 array ra{16} hospra0-hospra15;/*rheumatoid arthritis*/

if first.caseid then do i=1 to 16; * sorted by id caseid;

dm{i}=0; lip{i}=0; ht{i}=0; priormi{i}=0; chd{i}=0; chf{i}=0;
cvd{i}=0; pvd{i}=0; copd{i}=0; gi{i}=0; gibleed{i}=0; renal{i}=0; ra{i}=0; 
end;

/* For hospitalization-defined comorbidities, default time window is from the year prior to study start up to index date,
since these are all chronic morbidities and as this program optimizes sensitivity. 
For hypertension, CHF and renal disease, which are on the causal pathway, a diffrerent time-window is used (see below)*/

if admit ne . and '01Jan92'd<= admit < indexdate then do i=1 to 16;

/* 250.0 Diabetes mellitus without mention of complication 250.1 Diabetes with ketoacidosis 
250.2 Diabetes with hyperosmolarity 250.3 Diabetes with other coma 250.4 Diabetes with renal manifestations 
250.5 Diabetes with ophthalmic manifestations 250.6 Diabetes with neurological manifestations 
250.7 Diabetes with peripheral circulatory disorders 250.8 Diabetes with other specified manifestations
250.9 Diabetes with unspecified complication */
if dss{i}='250' then dm{i}=dm{i}+1;

/* 272.0 Pure hypercholesterolemia  272.1 Pure hyperglyceridemia  272.2 Mixed hyperlipidemia  
272.3 Hyperchylomicronemia  272.4 Other and unspecified hyperlipidemia 272.5 Lipoprotein deficiencies
272.7 Lipidoses  272.8 Other disorders of lipoid metabolism  272.9 Unspecified disorder of lipoid metabolism */
if '2720'<=dll{i}<='2725' or '2727'<=dll{i}<='2729' then lip{i}=lip{i}+1; /* 272.6 Lipodystrophy not relevant */  

/* 410 Acute myocardial infarction 412 Old myocardial infarction */
if dss{i}='410' or dss{i}='412' then priormi{i}=priormi{i}+1;  /*Myocardial infarction was defined as a 
medical claim for hospitalization with ICD-9 code 410.xx (excluding 410.x2, which is used to designate follow-up 
to the initial episode)and a length of stay (LOS) between 3 and 180 days, or death if LOS is <3 days.
This definition for MI has been used in several validation studies using Medicare claims data, yielding a PPV
of 94% for claims-based diagnosis of MI against structured medical chart review. (Wahl PM, et al. 
Validation of claims-based diagnostic and procedure codes for cardiovascular and gastrointestinal serious adverse
events in a commercially-insured population. PDS 2010;19(6):596-603. from Kiyota Y, et al.
Accuracy of Medicare claims-based diagnosis of acute myocardial infarction: estimating positive predictive value
on the basis of review of hospital records. Am Heart J 2004; 148: 99–104. */

/* 411 Other acute and subacute forms of ischemic heart disease 411.0 Postmyocardial infarction syndrome 
411.1 Intermediate coronary syndrome 411.8 Other acute and subacute forms of ischemic heart disease
411.81 Acute coronary occlusion without myocardial infarction 411.8 .....other  413 Angina pectoris 
414 Other forms of chronic ischemic heart disease */
if '4111'<=dll{i}<='4119' or '413'<=dss{i}<='414' then chd(i)=chd{i}+1; 
/* 411.0 Postmyocardial infarction syndrome excluded, 412 Old myocardial infarction defines prior MI */
/* ICD-9 411 code has high PPV for UA cases. (Varas-Lorenzo C, et al. Positive predictive value of ICD-9 codes
410 and 411 in the identification of cases of acute coronary syndromes 
in the Saskatchewan Hospital automated database. Pharmacoepidemiol Drug Saf. 2008 Aug:17(8):842-52.)*/ 

/* 430 Subarachnoid hemorrhage 431 Intracerebral hemorrhage 432 Other and unspecified intracranial hemorrhage
433 Occlusion and stenosis of precerebral arteries 434 Occlusion of cerebral arteries
435 Transient cerebral ischemia 436 Acute, but ill-defined, cerebrovascular disease 
437 Other and ill-defined cerebrovascular disease 438 Late effects of cerebrovascular disease */
if '430'<=dss{i}<='438' then cvd{i}=cvd{i}+1;  
/* Andrade SE, et al. A systematic review of validated methods for identifying cerebrovascular accident 
or transient ischemic attack using administrative data. PDS. 2012;21:100-28. */

/* 440.0 Atherosclerosis of aorta 440.1 Atherosclerosis of renal artery  440.2 Atherosclerosis of native arteries
of the extremities 440.3 Atherosclerosis of bypass graft of the extremities
440.4 Chronic total occlusion of artery of the extremities 440.8 Atherosclerosis of other specified arteries
440.9 Generalized and unspecified atherosclerosis 443.0 Raynaud's syndrome 443.1 Thromboangiitis obliterans
[Buerger's disease]  443.2 Other arterial dissection 443.8 Other specified peripheral vascular diseases 
443.9 Peripheral vascular disease, unspecified 444.0 Embolism and thrombosis of abdominal aorta 
444.1 Embolism and thrombosis of thoracic aorta 444.2 Embolism and thrombosis of arteries of the extremities
444.8 Embolism and thrombosis of other specified artery 444.9 Embolism and thrombosis of unspecified artery */
if dss{i}='440' or  '4438'<=dll{i}<='4439' or dll{i}='4442' then pvd{i}=pvd{i}+1;
/* Patients with peripheral arterial disease were identified using the International Classification of Diseases 
(ICD-9) codes 440, 440.2, or 443.9. 
The broader three-digit code 443 was allowed if it coincided with documentation of a prescription for 
pentoxifylline  on the assumption that all patients who received this prescription were diagnosed 
with peripheral arterial disease (Caro JJ et al. The morbidity and mortality following a diagnosis of 
peripheral arterial disease: Long-term follow-up of a large database. BMC Cardiovasc Disord. 2005)
Coding for PVD  http://campus.ahima.org/audio/2009/RB082009.pdf  */ 

/* 491 Chronic bronchitis 492 Emphysema 496 Chronic airway obstruction, not elsewhere classified */
if '491'<=dss{i}<='492' or dss{i}='496' then copd{i}=copd{i}+1;
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
if dll{i}='5311' or dll{i}='5313' or dll{i}='5315' or dll{i}='5317' or dll{i}='5319'
or dll{i}='5321' or dll{i}='5323' or dll{i}='5325' or dll{i}='5327' or dll{i}='5329'
or dll{i}='5331' or dll{i}='5333' or dll{i}='5335' or dll{i}='5337' or dll{i}='5339' 
or dll{i}='5341' or dll{i}='5343' or dll{i}='5345' or dll{i}='5347' or dll{i}='5349' 
or dlsl{i}='53500' or dlsl{i}='53510' or dlsl{i}='53550' or dlsl{i}='53560' or dlsl{i}='5368'  then gi{i}=gi{i}+1; /*exclude alcohol-related GI codes since alcohol-related Dx are excluded from Sask. 
Also exclude all codes related to GI hemorrhage (see below) */
/* Investigators have consistently demonstrated the accuracy of site-specific codes for gastric (531.xx) and
duodenal ulcer (532.xx) in the identification of UGIE. 
Abraham NS, et al. Validation of administrative data used for the diagnosis of upper gastrointestinal events
following nonsteroidal anti-inflammatory drug prescription.
Aliment Pharmacol Ther. 2006 Jul 15;24(2):299-306.)  */

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
if dll{i}='5310' or dll{i}='5312' or dll{i}='5314' or dll{i}='5316' or dll{i}='5320' or dll{i}='5322'
or dll{i}='5324' or dll{i}='5326' or dll{i}='5330' or dll{i}='5332' or dll{i}='5334' or dll{i}='5336'
or dll{i}='5340' or dll{i}='5342' or dll{i}='5344' or dll{i}='5346' or dss{i}='578' 
or dlsl(i)='53501' or dlsl(i)='53551' or dlsl(i)='53561'
then gibleed{i}=gibleed{i}+1; /* includes only ‘with hemorrhage’ GI codes*/

/* 714 Rheumatoid arthritis and other inflammatory polyarthropathies */
if dss{i}='714' then ra{i}=ra{i}+1; 

end;


/* For ht, chf, and renal, hospitalizations documented with time window of one year before cohort entry */
* NSAIDs are known to be associated with increases in blood pressure, new onset of congestive heart failure
or its deterioration, and deteriorating renal function. 
To avoid overadjustment i.e. adjusting for a variable on the causal pathway, since the main analysis is not 
done with a marginal structural model, we do not record hospitalizations after start of first NSAID prescription and
we determine these comorbidities in the period in which this population of incident users can be confirmed to be
free of NSAID (since the cohort is not composed of first-time users, we cannot rule out that subjects may have had pre-exisiting
hypertension or CHF or renal problems to which antecedent NSAID use might have contributed);

if admit ne . and admit < t0 then do i=1 to 16;

/* 401 Essential hypertension 402 Hypertensive heart disease 403 Hypertensive chronic kidney disease
404 Hypertensive heart and chronic kidney disease 405 Secondary hypertension */
if '401'<=dss{i}<='405' then ht{i}=ht{i}+1;

/* 428 Heart failure 429 Ill-defined descriptions and complications of heart disease */
if '428'<=dss{i}<'429' then chf{i}=chf{i}+1; /*429.3 Cardiomegaly excluded since not specific enough / 
/* In general, differences in the PPVs for the use of ICD-9 code 428.x alone as compared with its combined use
with other ICD-9 codes were negligible. Studies that included a primary hospital discharge diagnosis of ICD-9 code
428.X had the highest PPV and specificity. This algorithm, however, may compromise sensitivity because many
patients with HF are managed on an outpatient basis. Characteristics of the sample population and details related
to the diagnosis of HF, including whether cases are incident or prevalent, should be considered when choosing
a diagnostic algorithm. (Saczynski JS, Andrade SE, Harrold LR, Tjia J, Cutrona SL, Dodd KS, et al. 
A systematic review of validated methods for identifying heart failure using administrative data. 
Pharmacoepidemiol Drug Saf. 2012:21:129-40.) */

/* 584 Acute kidney failure 585 Chronic kidney disease (ckd) 586 Renal failure, unspecified */
if '584'<=dss{i}<='586' then renal{i}=renal{i}+1; 
/* http://www.inspq.qc.ca/pdf/publications/317-DiabeteCri_Ang.pdf */
end;

if last.caseid then do;
* To create dichotomized covariates based on all diagnostic codes.
  NB: the "h" identified that the covariate comes from the hospitalization dataset;
if sum(of hospdm0-hospdm15)>=1 then hdm=1; else hdm=0;
if sum(of hosplip0-hosplip15)>=1 then hlip=1; else hlip=0;
if sum(of hospht0-hospht15)>=1 then hht=1; else hht=0;
if sum(of hosppriormi0-hosppriormi15)>=1 then hpriormi=1; else hpriormi=0;
if sum(of hospchd0-hospchd15)>=1 then hchd=1; else hchd=0;
if sum(of hospchf0-hospchf15)>=1 then hchf=1; else hchf=0;
if sum(of hospcvd0-hospcvd15)>=1 then hcvd=1; else hcvd=0;
if sum(of hosppvd0-hosppvd15)>=1 then hpvd=1; else hpvd=0;
if sum(of hospcopd0-hospcopd15)>=1 then hcopd=1; else hcopd=0;
if sum(of hospgi0-hospgi15)>=1 then hgi=1; else hgi=0;
if sum(of hospgibleed0-hospgibleed15)>=1 then hgibleed=1; else hgibleed=0;
if sum(of hosprenal0-hosprenal15)>=1 then hrenal=1; else hrenal=0;
if sum(of hospra0-hospra15)>=1 then hra=1; else hra=0;
end;
run;

proc sort  data=ami.ramq_NCC_cc9304; by id caseid; run;
proc sort data=hosp1; by id caseid; run;

/* To finalize hospitalization-based covariates dataset */

data wce.hosp2_SpSe (keep= id caseid hdm hlip hht hpriormi hchd hchf hcvd hpvd hcopd hgi hgibleed hrenal hra);
merge hosp1 ami.ramq_NCC_cc9304(in=q);
by id caseid;
if q;
array dd(13) hdm hlip hht hpriormi hchd hchf hcvd hpvd hcopd hgi hgibleed hrenal hra;
do i=1 to 13;
if dd(i)=. then dd(i)=0;
end;
if (hdm+hlip+hht+hpriormi+hchd+hchf+hcvd+hpvd+hcopd+hgi+hgibleed+hrenal+hra)>=1 then hosp=1; else hosp=0;
if last.caseid then output; 
drop i;
run;

/* To verify distribution of hospitalization-defined comorbidities */

ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - NCC hospitalizations - SpSe.rtf' style=analysis; 
title1 'RAMQ nested case control dataset for individual patient data meta-analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'Hospitalization-defined comorbidities assessed via a strategy balancing specificity and sensitivity';
title4 'All subjects have at least one year of hospitalization history';
title5 'Potentially mediating comorbidities - hypertension, CHF, and renal failure - assessed before cohort entry';
title6 'Other comorbidities determined during period preceding index date'; 
proc freq data=wce.hosp2_SpSe;
tables hdm hlip hht hpriormi hchd hchf hcvd hpvd hcopd hgi hgibleed hrenal hra/list missing;
options nodate nonumber;
run;
ods rtf close;


/*************************************************
* Defining comorbidities using procedures        *
*************************************************/

proc sort data=data.hosp; by id; run;
proc sql;
select max(admit) as max_date format=date9., min(admit) as min_date format=date9.
from data.hosp;
quit;
* variable admit ranges from 01JAN1992 to 31MAR2005;

proc sort data= ami.ramq_NCC_cc9304; by id caseid; run;
proc sort data=data.hosp; by id; run;

/* Coronary heart disease can be defined with PCI or CABG (in addition to hospitalizations and prescription
drugs)*/

* Diabetes could have been defined with skin and eye procedures whereas renal failure could have been additionally
 defined by dialysis. This was not implemented in the RAMQ IPD MA dataset;

* Note that hospitalization data are available from 01JAN1992 and that study starts 01JAN1993.
Therefore at least one year of hospitalization history is available for all subjects, (including those for whom t0 is 01JAN1993);


proc sort data=hosp;by id caseid;run; *by id first and caseid in second; 

data proc1;
set hosp; by id caseid; * need by id first and caseid in second 
since covariates are determined with respect to index date, in a matched CC dataset; 
format txt3c1-txt3c9 $3. ;
if first.caseid then do pci=0; cabg=0;end; * sorted by id caseid;
 
retain pci cabg ;
array tx(9) txt1-txt9;
array txc(9) txt3c1-txt3c9;
 
/* As for hospitalizations, document CHD-related procedures at any time before the index date */ 
if admit ne . and '01Jan92'd<= admit < indexdate then do i=1 to 9;

txc(i)=substr(tx(i),1,3);
if txc(i)='480' then pci=1;
if txc(i)='481' then cabg=1;
end;
run;

proc sort data=proc1; by id caseid; run;
* To finalize procedure-based comordities dataset and remove unnecessary variables;

data wce.proc2_SpSe (keep= id caseid pci cabg);
merge proc1 ami.ramq_NCC_cc9304(in=q);;
by id caseid; if q;
if pci=. then pci=0;
if cabg=. then cabg=0;
if (pci+cabg)>=1 then proc=1; else proc=0;
if last.caseid then output;
run;


/* To verify distribution of procedure-defined comorbidities */
ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - NCC procedures - SpSe.rtf' style=analysis;  
title1 'RAMQ nested case control dataset for individual patient data meta-analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'Procedure-defined comorbidities assessed via a strategy balancing specificity and sensitivity';
title4 'All subjects have at least one year of hospitalization history';
title5 'Determined during period preceding index date'; 
proc freq data=wce.proc2_SpSe;
tables pci cabg /list missing;
options nodate nonumber;
run;
ods rtf close; 


/***********************************************************
* Defining comorbidities using associated drug treatments  *
***********************************************************/

proc sort data=data.rx_x; by id; run;
proc sql;
select max(datserv) as max_date format=date9., min(datserv) as min_date format=date9.
from data.rx_x;
quit;
* variable datserv ranges from 01JAN1992 to 31MAR2005;

* Note that study dates are 01Jan1993 to 30Sept2004;

proc sql;
create table wce.rxSpSe (keep=id caseid t0 indexdate datserv dencom dosge forme) as
  select * 
  from  ami.ramq_NCC_cc9304, data.rx_x
  where ramq_NCC_cc9304.id=rx_x.id and datserv ne . and qtmed not=0 and '01Jan92'd<= datserv < indexdate;
quit;


proc sort data=wce.rxSpSe;by id caseid;run; * by id first and caseid in second; 

/* arrhaf hyal tyl tylcomb cortia coum hep removed as these are for comorbidities no longer defined per preliminary results */

* Note that prescription data are available from 01JAN1992 and that study starts 01JAN1993.
Therefore at least one year of prescription drug history is available for all subjects, (including those for whom t0 is 01JAN1993);

/* First step - Prescription-defined comorbidities determined in the period preceding index date - 
Those comorbidities that are not on the causal pathway (i.e. excluding ht, chf, and renal) and those for which an
algorithm exists to overcome low specificity of drug treatment)(i.e. excluding copd and gi) */

data wce.rx1a; 
set wce.rxSpSe; by id caseid; * need by id first and caseid in second 
since covariates are determined with respect to index date, in a matched CC dataset; 
retain asa1 asa2 asa3 asa4 bb bmr ccb rxclopi clopi dmard1 dmard2 dmard3 gold mtx1 mtx2 ntg plat pred
rxcvd rxdm rxlip rxpvd tim;

if first.caseid then do; * sorted by id caseid;
asa1=0; asa2=0; asa3=0; asa4=0; bb=0; bmr=0; ccb=0; rxclopi=0; clopi=0; dmard1=0; dmard2=0; dmard3=0;epo=0; gold=0; mtx1=0;
mtx2=0; ntg=0; plat=0; pred=0; rxcvd=0; rxdm=0;rxlip=0; rxpvd=0; spir=0; tim=0;;
end;

if datserv ne . and datserv <indexdate then do; * In the period preceding index date;

/*dm*/
if dencom in (00091/*acetohexamide*/, 01937/*chlorpropamide*/, 46056, 47329/*gliclazide*/, 47427, 46799/*glimepiride*/, 04264/*glyburide*/, 
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
/*insuline detemir NOC 2005*/)then rxdm=1;

/*lip*/
if dencom in (01989/*cholestyramine*/, 44905/*colestipol*/, 47092/*bezafibrate*/, 02067/*clofibrate*/, 45574, 47366, 47373, 46575/*fenofibrate*/,
44879/*gemfibrozil*/, 06887, 19089, 47560/*niacin*/, 38392/*probucol*/, 46355, 47232/*atorvastatin*/, 47272, 46425/*cerivastatin*/, 
47083, 46240/*fluvastatin*/, 45500/*lovastatin*/, 45570, 47169/*pravastatin*/, 46860/*rosuvastatin*/, 45564, 46584/*simvastatin*/, 
47456/*ezetimibe approved May 2003*/)then rxlip=1;

/*chd - See also algorithm further down*/
if dencom in (45463/*acebutolol*/, 43670, 46325/*atenolol*/, 47355/*bisoprolol*/, 45243/*labetalol/*, 38275, 46763, 46780/*metoprolol*/, 
40563/*nadolol*/, 42162/*oxprenolol*/, 39016/*pindolol*/, 08229/*propranolol*/)then bb=1;
if dencom=38314 /*timolol*/ and forme=203/*tablets*/ then tim=1;
if dencom in (47006, 47009/*amlodipine*/, 46369, 43228, 47247/*diltiazem*/, 45624/*felodipine*/, 45571/*nicardipine*/, 
42708, 46388, 46469/*nifedipine*/, 40550, 46573/*verapamil*/, 47440/*verapamil/trandolapril*/)then ccb=1;

if dencom in (47104/*isosorbide-5-mononitrate*/, 03029/*isosorbide dinitrate*/, 09438/*pentaerythritol tetranitrate(Peritrate)*/, 
09919, 42864/*trinitrate de glycéryle*/)then ntg=1;
if dencom in (46486, 47307/*clopidogrel*/, 03094/*dipyridamole*/, 46077, 47365/*ASA/dipyridamole*/, 45617/*ticlopidine*/)then plat=1;

if dencom=46353/*ASA comprimé entérique 81mg*/ then asa1=1;
if dencom=00143/*ASA*/ and forme=00203/*comprimé*/ and dosge in (40199, 52216/*80mg or 325mg*/)then asa2=1;
if dencom=00143/*ASA*/ and forme=00406/*comprimé entérique*/ and dosge in (40199, 51244 /*80mg or 300-325mg*/)then asa3=1;
if dencom=00143/*ASA*/ and forme=00464/*comprimé masticable 80mg*/ then asa4=1;

/*priormi*/
* Not defined by Rx;

/*cvd*/
if dencom=45532/*nimodipine*/ then rxcvd=1;

/*pvd*/
if dencom=44346/*pentoxifylline*/then rxpvd=1;

/*gibleed*/
*Not defined by Rx;

/*ra - See also algorithm further down*/
/*Categories and further definition of rxra derived from Russell A, Haraoui B, Keystone E, Klinkhoff A. 
Current and emerging therapies for rheumatoid arthritis, with a focus on infliximab: clinical impact on joint damage and cost of care in Canada.
Clin Ther. 2001 Nov;23(11):1824-38. Adalimumab deleted from drug codes previously defined in RAMQ-AF and Bisphosphonates as 
NOC was received Sept 2004*/
if dencom in (46829/*anakinra NOC May 2002*/, 47438, 46711/*etanercept NOC Dec 2000*/, 47416, 46739/*infliximab NOC May 2001*/)then bmr=1;
/*Methotrexate usual doses for time period 7.5-15 mg/wk PO and 5-15 ad 25 mg/wk IM*/;
if dencom=00338/*amethopterin(methotrexate)*/ and forme=00203/*comprimé*/ then mtx1=1;
if dencom=00351/*amethopterin(methotrexate)*/and forme=02001/*solution injectable*/ 
and dosge in (14396, 14518, 24766, 30988/*2.5 mg/mL, 2.5 mg/mL(2mL), 10 mg/mL(2mL), 25 mg/mL(2mL)*/)then mtx2=1;
if dencom in (45256/*auranofin*/,45549/*aurothioglucose*/, 00715/*sodium aurothiomalate*/)then gold=1;
if dencom in (47362, 46649/*leflunomide*/) then dmard1=1;
if dencom in (04654/*hydroxychloroquine*/, 06994/*penicillamine*/, 45420/*sulfasalazine*/)then dmard2=1;
if dencom in (00754, 37820 /*azathioprine*/, 44060, 46266, 46329, 46375/*cyclosporine*/, 47152, 46483/*tacrolimus*/, 
01716/*chlorambucil*/)then dmard3=1;
if dencom=08021/*prednisone*/ and forme=00203 then pred=1;

end;

/*********************************************************************************/
* To continue defining comorbidities based on prescriptions drugs by creating those 
that are based on prescription drug algorithms - Comorbidities that are not on the causal pathway between NSAID and AMI and
with algorithm that confer sufficient specificity; 

if last.caseid then do;

/* chd */
if ntg and (plat or ccb or bb or tim or (asa1 or asa2 or asa3 or asa4))>=1 then rxchd=1; else rxchd=0;
 
/*ra*/
/* From Tavares R, et al. Early management of newly diagnosed rheumatoid arthritis by Canadian rheumatologists: a national, multicenter, 
retrospective cohort. J Rheumatol. 2011 Nov;38(11):2342-5. To describe early rheumatologic management for newly diagnosed rheumatoid arthritis
(RA) in Canada. A retrospective cohort of 339 randomly selected patients with RA diagnosed from 2001-2003 from 18 rheumatology practices was 
audited between 2005-2007. The most frequent initial disease-modifying antirheumatic drugs (DMARD) included hydroxychloroquine (55.5%) and
methotrexate (40.1%). Initial therapy with multiple DMARD (15.6%) or single DMARD and corticosteroid combinations (30.7%) was infrequent*/
/* Etanercept and infliximab have non-RA use (e.g.: psoriasis, IBD)*/
if (mtx1+mtx2+dmard1+gold)>=1 or ((mtx1 and bmr) or (mtx2 and bmr) or (mtx1 and dmard2) or (mtx2 and dmard2) or (mtx1 and pred) or
(mtx2 and pred) or (dmard2 and pred) or (dmard3 and pred))=1 then rxra=1; else rxra=0;

output; 
end;
run;

/* Second step - Prescription-defined comorbidities determined in the period preceding cohort entry
- For ht, chf, and renal, which are on the causal pathway */

data wce.rx1b; 
set wce.rxSpSe; by id caseid; * need by id first and caseid in second 
since covariates are determined with respect to index date, in a matched CC dataset; 
retain ace alpha arb arbchf bb bbchf ccb cdiur dig diur epo ht1 ht2 ht3 ht4 ht5 ht6 ht7 hydra loop mischt ntg phos spir tim;

if first.caseid then do; * sorted by id caseid;
ace=0; alpha=0; arb=0; arbchf=0; bb=0; bbchf=0; ccb=0; cdiur=0; dig=0; diur=0; epo=0; ht1=0; ht2=0; ht3=0; ht4=0; ht5=0; ht6=0; ht7=0;
hydra=0; loop=0; mischt=0; ntg=0; phos=0; spir=0; tim=0; 
end;

if datserv ne . and datserv <t0 then do; * In the period preceding cohort entry;


/*ht*/
if dencom in (41759/*amiloride*/, 41772/*amiloride/HCTZ*/, 00806/*bendroflumethiazide*/, 01976 /*chlorthalidone*/, 04537/*HCTZ*/,
43397/*indapamide*/, 06110/*methyclothiazide*/, 19440/*metolazone*/, 09763/*triamterene*/, 38158/*spironolactone/HCTZ*/, 
38197, 46772/*triamterene/HCTZ*/)then diur=1;
if dencom in (46157/*nadolol/bendroflumethiazide*/, 46315/*atenolol/chlorthalidone*/, 45408/*pindolol/HCTZ*/, 47320/*cilazapril/HCTZ*/, 
45572/*enalapril/HCTZ*/, 47040/*lisinoril/HCTZ*/, 47449/*perindopril/indapamide*/ 47301/*quinapril/HCTZ*/, 47412, 46760/*candesartan/HCTZ*/,
47534/*eprosartan/HCTZ*/, 47354/*irbesartan/HCTZ*/, 47207/*losartan/HCTZ*/, 47413/*telmisartan/HCTZ*/, 47369/*valsartan/HCTZ*/) then cdiur=1;
if dencom in (45463/*acebutolol*/, 43670, 46325/*atenolol*/, 47355/*bisoprolol*/, 45243/*labetalol/*, 38275, 46763, 46780/*metoprolol*/, 
40563/*nadolol*/, 42162/*oxprenolol*/, 39016/*pindolol*/, 08229/*propranolol*/)then bb=1;
if dencom=38314 /*timolol*/ and forme=203/*tablets*/ then tim=1;
if dencom in (47049/*benazepril*/, 42071/*captopril*/, 47056, 46194/*cilazapril*/, 45476/*enalapril*/, 47002/*fosinopril*/, 
45576/*lisinopril*/, 47117, 46258/*perindopril*/, 45629/*quinapril*/, 47079, 46216/*ramipril*/, 47250, 47440/*trandolapril*/)then ace=1;
if dencom in (47309, 46529/*candesartan*/, 47389/*eprosartan*/, 47282, 46459/*irbesartan*/, 47135, 46284, 46441/*losartan*/, 
47333, 46587/*telmisartan*/, 47259, 46418/*valsartan*/)then arb=1;
if dencom in (47006, 47009/*amlodipine*/, 46369, 43228, 47247/*diltiazem*/, 45624/*felodipine*/, 45571/*nicardipine*/, 
42708, 46388, 46469/*nifedipine*/, 40550, 46573/*verapamil*/, 47440/*verapamil/trandolapril*/)then ccb=1;
if dencom=37742/*prazosin*/ then alpha=1/*doxazosin and terazosin not listed as they are also labelled for BPH*/;
if dencom in (10751/*clonidine*/, 04524/*hydralazine*/06136, 46389/*methyldopa*, 41564/*minoxidil*/)then mischt=1;

/*to exclude chd */
if dencom in (47104/*isosorbide-5-mononitrate*/, 03029/*isosorbide dinitrate*/, 09438/*pentaerythritol tetranitrate(Peritrate)*/, 
09919, 42864/*trinitrate de glycéryle*/)then ntg=1;

/*chf*/
if dencom in (03562/*ethacrynic acid*/, 04173/*furosemide*/, 46379/*torsemide*/)then loop=1;
if dencom in (09100/*spironolactone*/)then spir=1;
if dencom in (47355/*bisoprolol*/, 47199, 46319 /*carvedilol*/, 38275, 46763, 46780/*metoprolol*/)then bbchf=1;
if dencom in (47309, 46529/*candesartan*/, 47259, 46418/*valsartan*/)then arbchf=1;
if dencom in (47049/*benazepril*/, 42071/*captopril*/, 47056, 46194/*cilazapril*/, 45476/*enalapril*/, 47002/*fosinopril*/, 
45576/*lisinopril*/, 47117, 46258/*perindopril*/, 45629/*quinapril*/, 47079, 46216/*ramipril*/, 47250, 47440/*trandolapril*/)then ace=1;
if dencom in (47309, 46529/*candesartan*/, 47389/*eprosartan*/, 47282, 46459/*irbesartan*/, 47135, 46284, 46441/*losartan*/, 
47333, 46587/*telmisartan*/, 47259, 46418/*valsartan*/)then arb=1;
if dencom in (02834/*digitoxin*/, 02847/*digoxin*/)then dig=1;
if dencom=04524/*hydralazine*/then hydra=1;

/*renal*/
if dencom in (46826, 47441/*darbepoetine alfa*/ 47191, 46635/*epoetine alfa*/)then epo=1;
if dencom=46671/*sevelamer*/ then phos=1;

end;

**********************************************************************************************************************
* To continue defining comorbidities based on prescriptions drugs by creating those 
that are based on prescription drug algorithms - Comorbidities that are on the causal pathway between NSAID and AMI: ht, chf, and renal; 

if last.caseid then do;

/*ht*/
if diur=1 and dig=0 then ht1=1; else ht1=0;
if cdiur=1 and dig=0 then ht2=1; else ht2=0;
if ace=1 and (loop+dig)=0 then ht3=1; else ht3=0;
if arb=1 and (loop+dig)=0 then ht4=1; else ht4=0;
if (bb or tim)=1 and (loop+dig)=0 then ht5=1; else ht5=0;
if (bb=1 and ntg=0) or (tim=1 and ntg=0) then ht6=1; else ht6=0;
if ccb=1 and ntg=0 then ht7=1; else ht7=0;

if (ht1+ht2+ht3+ht4+ht5+ht6+ht7+alpha+mischt)>=1 then rxht=1; else rxht=0;


/*chf*/
/*vars for defining rxchf from Liu P, et al. The 2002/3 CCS consensus guideline update for the diagnosis and management of heart failure.
Can J Cardiol. 2003;19(4):347-56. and Arnold, et al. CCS consensus conference recommendations on heart failure 2006: diagnosis and management.
Can J Cardiol. 2006;22(1):23-45. and Lee DS, et al. Trends in heart failure outcomes and pharmacotherapy: 1992 to 2000. Am J Med. 2004:116(9):
581-9. Included both emerging and older treatment*/
if ((bbchf /*bisoprolol,carvedilol,metoprolol*/ and loop) or (loop and dig) or (ace and (loop or dig)) or (arb and (loop or dig)) 
or (loop and bbchf and ace) or (loop and bbchf and arbchf/*candesartan, valsartan*/)
or ((loop and ace) and (spir or diur)) or (loop and dig and ntg and hydra))=1 
then rxchf=1; else rxchf=0; 

/*renal*/
if (epo=1 or phos=1)then rxrenal=1; else rxrenal=0;

output; 
end;
run;

/* Third step - Prescription-defined comorbidities without algorithm to overcome low specificity of drug treatment: copd, gi
are determined in the period of 1 year preceding index date */

data wce.rx1c; 
set wce.rxSpSe; by id caseid; * need by id first and caseid in second 
since covariates are determined with respect to index date, in a matched CC dataset; 
retain antichol bag beclo bude cbag flun fluti triam xant h2 ppi othergi;

if first.caseid then do; * sorted by id caseid;
antichol=0; bag=0; beclo=0; bude=0; cbag=0; flun=0; fluti=0; triam=0; xant=0; h2=0; ppi=0; othergi=0;
end;

if datserv ne . and indexdate-365.25<= datserv <indexdate then do; * in the period of 1 year preceding index date;

/*copd - See also algorithm further down*/
if dencom in (00364, 46428/*aminophylline*/, 34310/*bufylline*/, 03276/*diphylline*/, 09464, 46847, 09490, 09503/*theophylline*/, 
43475/*oxtriphylline*/)then xant=1;
if dencom in (38548/*fenoterol*/, 47231, 47271, 46430/*formoterol*/, 06721/*orciprenaline*/, 47153, 46299/*pirbutérol*/, 45547/*procaterol*/, 
46737, 10530, 33634/*salbutamol*/, 47112, 46247/*salmeterol*/, 34180/*terbutaline*/)then bag=1;
if dencom in (47428, 46800/*formoterol/budesonide*/47335, 46597/*salmeterol/fluticasone*/)then cbag=1;
if dencom=00780/*beclomethasone*/ and forme in (01305/*poudre aérosol*/, 01334/*poudre aérosol avec applicateur*/, 01856/*solution aérosol*/,
05563/*poudre pour inhalation avec applicateur*/, 05564/*poudre pour inhalation*/, 05584/*aérosol oral*/, 05619/*poudre pour inhalation applicateur*/)then beclo=1;
if dencom=45499/*budesonide*/ and forme in (01305/*poudre aérosol*/, 01334/*poudre aérosol avec applicateur*/, 01856/*solution aérosol*/, 
05563/*poudre pour inhalation avec applicateur*/, 05564/*poudre pour inhalation*/, 05584/*aérosol oral*/, 
05619/*poudre pour inhalation applicateur*/)then bude=1;
if dencom in (38730, 47213/*flunisolide*/) and forme in (01305/*poudre aérosol*/, 01334/*poudre aérosol avec applicateur*/, 
01856/*solution aérosol*/, 05563/*poudre pour inhalation avec applicateur*/, 05564/*poudre pour inhalation*/, 05584/*aérosol oral*/,
05619/*poudre pour inhalation applicateur*/)then flun=1;
if dencom in (47050, 46345/*fluticasone*/) and forme in (01305/*poudre aérosol*/, 01334/*poudre aérosol avec applicateur*/, 
01856/*solution aérosol*/, 05563/*poudre pour inhalation avec applicateur*/, 05564/*poudre pour inhalation*/, 05584/*aérosol oral*/, 
05619/*poudre pour inhalation applicateur*/)then fluti=1;
if dencom=09737/*triamcinolone acetonide*/ and forme in (01305/*poudre aérosol*/, 01334/*poudre aérosol avec applicateur*/, 
01856/*solution aérosol*/, 05563/*poudre pour inhalation avec applicateur*/, 05564/*poudre pour inhalation*/, 05584/*aérosol oral*/, 
05619/*poudre pour inhalation applicateur*/)then triam=1;
if dencom in (43124, 46640/*ipratropium*/, 46288/*ipratropium/fenoterol*/, 47186, 46302/*ipratropium/salbutamol*/, 
46856/*tiotropium*/)then antichol=1;

/*gi - See also algorithm further down*/
if dencom in (38366, 38756/*cimetidine*/, 45460, 46336/*famotidine*/, 45491, 46483/*nizatidine*/, 43163/*ranitidine*/, 
47257, 46409/*ranitidine/bismuth*/)then h2=1;
if dencom in (47418, 46761/*esomeprazole*/, 47140/*lansoprazole*/, 47292/*lansoprazole/amoxicilline/clarithromycine*/, 
45519, 47146, 46713/*omeprazole*/, 47234, 46365/*pantoprazole*/, 47432/*rabeprazole*/)then ppi=1;
if dencom in (19427/*carbenoxolone*/,45445/*misoprostol*/, 44320/*pirenzepine*/, 42006, 46623, 46447/*sucralfate*/)then othergi=1;

end;

/*********************************************************************************/
* To continue defining comorbidities based on prescriptions drugs by creating those 
that are based on prescription drug algorithms - Comorbidities without algorithm to overcome low specificity of drug treatment; 

if last.caseid then do;

/*copd*/
if (xant+bag+cbag +beclo+bude+flun+fluti+triam+antichol)>=1 then rxcopd=1; else rxcopd=0;

/*gi*/
if (h2+ppi+othergi)>=1 then rxgi=1; else rxgi=0;

output; 
end;
run;

/* Fourth step - Concomitant drugs are determined in the period of 30 days preceding index date */

data wce.rx1d; 
set wce.rxSpSe; by id caseid; * need by id first and caseid in second 
since covariates are determined with respect to index date, in a matched CC dataset; 
retain asa1 asa2 asa3 asa4 beta1 beta2 beta3 budes cort dexa hcort methyl predn1 predn2 pred rxclopi triamc1 triamc2;

if first.caseid then do; * sorted by id caseid;
asa1=0; asa2=0; asa3=0; asa4=0; beta1=0; beta2=0; beta3=0; budes=0; cort=0; dexa=0; hcort=0; methyl=0; predn1=0; predn2=0;
pred=0; rxclopi=0; triamc1=0; triamc2=0;
end;


if datserv ne . and indexdate-30<= datserv <indexdate then do; * In the 30 days preceding index date;

/*To identify use of low-dose ASA - See also algorithm further down*/
if dencom=46353/*ASA comprimé entérique 81mg*/ then asa1=1;
if dencom=00143/*ASA*/ and forme=00203/*comprimé*/ and dosge in (40199, 52216/*80mg or 325mg*/)then asa2=1;
if dencom=00143/*ASA*/ and forme=00406/*comprimé entérique*/ and dosge in (40199, 51244 /*80mg or 300-325mg*/)then asa3=1;
if dencom=00143/*ASA*/ and forme=00464/*comprimé masticable 80mg*/ then asa4=1;

/*To identify use of oral corticosteroids - See also algorithm further down*/
if dencom=00923/*betamethasone*/ and forme=00203/*comprime*/ then beta1=1;
if dencom=45421/*betamethasone*/ and forme=00377/*comprime effervescent*/then beta2=1;
if dencom=47141/*betamethasone*/ and forme=00377/*comprime effervescent*/then beta3=1;
if dencom=45499/*budesonide*/ and forme=116/*capsule*/ then budes=1;
if dencom=02197/*cortisone acetate*/ and forme=00203/*comprime*/ then cort=1;
if dencom=02587/*dexamethasone*/ and forme in (00203/*comprime*/, 00754/*elixir*/)then dexa=1;
if dencom=04550/*hydrocortisone*/ and forme=00203 then hcort=1;
if dencom=06175/*methylprednisolone*/ and forme=00203 then methyl=1;
if dencom=07956/*prednisolone*/ and forme=00203 then predn1=1;
if dencom=08008/*prednisolone*/ and forme=02262/*solution orale*/ then predn2=1;
if dencom=08021/*prednisone*/ and forme=00203 then pred=1;
if dencom=09724/*triamcinolone*/ and forme=00203/*comprime*/ then triamc1=1;
if dencom=09750/*triamcinolone*/ and forme=01827/*sirop*/ then triamc2=1;

/*To identify use of clopidogrel*/
if dencom in (46486, 47307)/*clopidogrel*/ then rxclopi=1;

end;

/*********************************************************************************/
* To continue defining concomitant drugs by creating those that are based on algorithms; 

if last.caseid then do;

/*Use of low-dose ASA*/
if (asa1+asa2+asa3+asa4)>=1 then rxasa=1; else rxasa =0;

/*Use of oral corticosteroids*/
if (beta1+beta2+beta3+budes+cort+dexa+hcort+methyl+predn1+predn2+pred+triamc1+triamc2) >=1 then rxcorti=1; else rxcorti=0;

output; 
end;
run;


proc sort data=wce.rx1a; by id caseid; run;
proc sort data=wce.rx1b; by id caseid; run;
proc sort data=wce.rx1c; by id caseid; run;
proc sort data=wce.rx1d; by id caseid; run;
proc sort  data=ami.ramq_NCC_cc9304; by id caseid; run;


data wce.rx2_SpSe ; 
merge  wce.rx1a (keep=id caseid rxdm rxlip rxchd rxcvd rxpvd rxra) 
wce.rx1b (keep=id caseid rxht rxchf rxrenal) wce.rx1c (keep=id caseid rxcopd rxgi) wce.rx1d (keep=id caseid rxasa rxcorti rxclopi)
ami.ramq_NCC_cc9304(in=q);
by id caseid; if q;
array dd(14) rxdm rxlip rxht rxchd rxchf rxcvd rxpvd rxcopd rxgi rxrenal rxra rxasa rxcorti rxclopi;
do i=1 to 14;
if dd(i)=. then dd(i)=0;
if (rxdm+rxlip+rxht+rxchd+rxchf+rxcvd+rxpvd+rxcopd+rxgi+rxrenal+rxra+rxasa+rxcorti+rxclopi)>=1 then rx=1; else rx=0;
end;
if last.caseid then output;
drop i;
run;

/* To verify distribution of prescription-defined covariates */
ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - NCC prescriptions - SpSe.rtf' style=analysis;
title1 'RAMQ nested case control dataset for individual patient data meta-analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'Prescription-defined covariates and concomitant drugs determined via a strategy balancing specificity and sensitivity';
title4 'All subjects have at least one year of prescription drug history';
title5 'Concomitant drugs - Cardioprotective aspirin, oral corticosteroids, and clopidogrel - assessed in the 30 days preceding index date';
title6 'Potentially mediating comorbidities - hypertension, CHF, and renal failure - assessed before cohort entry';
title7 'Comorbidities without algorithm to overcome low specificity of drug treatment - COPD and GI ulcer disease - assessed in the year preceding index date'; 
title8 'Other comorbidities determined during period preceding index date'; 
proc freq data=wce.rx2_SpSe;
tables rxdm rxlip rxht rxchd rxchf rxcvd rxpvd rxcopd
rxgi rxrenal rxra rxcorti rxclopi rxasa/list missing;
options nodate nonumber;
run;
ods rtf close;


/********************************************************************************
* DEFINING BASELINE COVARIATES FROM ALL DATA SOURCES							*
* CREATING PERMANENT DATASET OF COVARIATES IN THE YEAR PRECEDING COHORT ENTRY	*
* UP TO INDEX DATE																*
********************************************************************************/

* Checking variable names across datasets to ensure there are no duplicates before merging ;
proc contents data= ami.ramq_NCC_cc9304 position; run;
proc contents data=wce.hosp2_SpSe position; run;
proc contents data=wce.proc2_SpSe position; run;
proc contents data=wce.rx2_SpSe position; run;

proc sort data= ami.ramq_NCC_cc9304; by id caseid; run;
proc sort data=wce.hosp2_SpSe; by id caseid; run;
proc sort data=wce.proc2_SpSe; by id caseid; run;
proc sort data=wce.rx2_SpSe; by id caseid; run;


* Creating permanent dataset of variables in the year preceding cohort entry;
data ramq_covars9304; 
merge ami.ramq_NCC_cc9304 wce.hosp2_SpSe wce.proc2_SpSe wce.rx2_SpSe; by id caseid;
 array var{*} hdm hlip hht hpriormi hchd hchf hcvd hpvd hcopd hgi hgibleed hrenal hra pci cabg rxdm rxlip rxht
 rxchd rxchf rxcvd rxpvd rxcopd rxgi rxrenal rxra rxasa rxcorti rxclopi;
 do i=1 to dim(var);
 	if var{i}=. then var{i}=0; * see notes 1 and 2 below;
 end;
* NOTE 1: if var{i}=. then var{i}=0 - this replace all missing value by 0.
* NOTE 2: Caution!! When using "+" and variables are missing the result is missing.
  (var1+var2=. if var1=. or var2=. and . is the smallest value). Here OK because
  missing have been changed to "0". One way to avoid this is to use sum(var1,var2)
  When using "sum" SAS does sum of non-missing values;

if last.caseid then do; 
/*diabetes*/
if (hdm+rxdm)>=1 then dm=1; else dm=0;
/*hyperlipidemia*/
if (hlip+rxlip)>=1 then lip=1; else lip=0;
/*hypertension*/
if (hht+rxht)>=1 then ht=1; else ht=0;
/* prior MI */
if (hpriormi)=1 then priormi=1; else priormi=0;
/*coronary heart disease*/
if (hchd+rxchd+pci+cabg)>=1 then chd=1; else chd=0; 
/*congestive heart failure*/
if (hchf+rxchf)>=1 then chf=1; else chf=0;
/*cerebrovascular disease*/
if (hcvd+rxcvd)>=1 then cvd=1; else cvd=0;
/*peripheral vascular disease*/
if (hpvd+rxpvd)>=1 then pvd=1; else pvd=0;
/*chronic obstructive pulmonary disease*/
if (hcopd+rxcopd)>=1 then copd=1; else copd=0;
/*peptic ulcer disease and related*/
if (hgi+rxgi)>=1 then gi=1; else gi=0;
/*gastrointestinal bleed*/
if (hgibleed)=1 then gibleed=1; else gibleed=0;
/*acute and chronic renal failure*/
if (hrenal+rxrenal)>=1 then renal=1; else renal=0; 
/*rheumatoid arthritis*/
if (hra+rxra)>=1 then ra=1; else ra=0;

/*Use of low-dose ASA*/
if rxasa=1 then asa=1; else asa=0; 
/*Use of oral corticosteroids*/
if rxcorti=1 then cortirx=1; else cortirx=0; 
/*Use of clopidogrel*/
if rxclopi=1 then clopi=1; else clopi=0; 
output;
end;
run;

proc sort data=ramq_covars9304;by caseid id; run; * sort by caseid id;


/* Cleaning up to keep only comorbidities */
data ramq_covars9304reduced (keep=caseid t0 id indexdate ami male ageindex dm lip ht priormi chd chf cvd
pvd copd gi gibleed renal ra asa cortirx clopi);
set ramq_covars9304;
run;

data ami.ramq_NCC_covars_SpSe9304;
retain caseid id t0 indexdate ami ageindex male dm lip ht priormi chd chf cvd pvd copd gi gibleed renal ra
cortirx clopi asa;
set ramq_covars9304reduced;
run;

ods rtf file='C:\Users\michele.bally\Documents\IPD MA\IPD PhD Project\Datasets\RAMQ\RAMQ_ipd\ami\tables\AMI NSAIDs RAMQ - NCC covariates - SpSe.rtf' style=analysis;
title1 'RAMQ nested case control dataset for individual patient data meta-analysis';
title2 'NSAID cohort years 1993-2004 - Population mostly elderly subjects';
title3 'Covariates determined via a strategy balancing specificity and sensitivity'; 
title4 'All subjects have at least one year of hospitalization and prescription drug history';
title5 'Hospitalization-, procedure-, and prescription-defined comorbidities and use of concomitant drugs';
title6 'Potentially mediating comorbidities - hypertension, CHF, and renal failure - assessed before cohort entry';
title7 'Other comorbidities determined during period preceding index date'; 
title8 'Prescriptions for comorbidities without algorithm to overcome low specificity of drug treatment - COPD and GI ulcer disease - assessed in the year preceding index date'; 
title9 'Concomitant drugs - Cardioprotective aspirin, oral corticosteroids, and clopidogrel - assessed in the 30 days preceding index date';
proc freq data=ami.ramq_NCC_covars_SpSe9304;
tables male dm lip ht priormi chd chf cvd
pvd copd gi gibleed renal ra cortirx clopi asa/list missing; run;
options nodate nonumber;
run;
ods rtf close;


proc sort data= ami.ramq_NCC_covars_SpSe9304; by caseid id; run;
