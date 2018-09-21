# thesis-project

This repository contains R code written for my thesis project.

The thesis project consists of a case-control study with several sensitivity analysis using RAMQ administrative data. For a brief introduction to the project, please read the [Abstract] (https://github.com/nancyzhu24/thesis-project/wiki)

This document explains the order of files that manipulate and analyze the data

**Date Cleaning & Manipulation**
1. Data  import: [read_files.R](https://github.com/nancyzhu24/thesis-project/blob/master/read_files.R). This file reads the raw csv files, namely, the demo, intervention, diagnostic dataset and the code book for ICD and CCI. Study population age range were defined from the demo table.

2. Case selection: [Case_selection.R](https://github.com/nancyzhu24/thesis-project/blob/master/1.Case_selection.R). This file defines the cases for the case-control study in the main analysis. Cases were defined as individuals having been diagnosed AS during hospitalization or having underwent a SAVR procedure. Patients with previous history of AS, mitral stenosis, congenital AS, rheumatic AS were excluded from the study population. After running this script, you will have a file called *case_final.csv* and another one called *complete_set.csv*
These two files are the input to a SAS algorithm developed by Michael for case-control matching.

Once the study cohort was created, covariates predefined in the study protocol were ascertained from in-hospital diagnostic data and prescription data

3. Load and clean prescription data: [2A.clean_pharma.R](https://github.com/nancyzhu24/thesis-project/blob/master/2A.clean_pharma%20.R). The files reads all 10 year prescription data and cdenom code book. also, prescription history were defined by ahf code

4. Ascertain prescription history for study cohort: [2B.covariate_pharma.R](https://github.com/nancyzhu24/thesis-project/blob/master/2B.covariate_pharma.R) This files contains a function written to ascertain whether individuals in the study cohort has been exposed to certain classes of drugs before cohort entry

5. Ascertain disease diagnosis history for study cohort: [2C.covariate_diagnostic.R](https://github.com/nancyzhu24/thesis-project/blob/master/2C.Covariate_diagnostic.R) This file contains a script to define disease history for individuals in the study cohort using in-hospital diagnostic data. 

6. Ascertain covariates: [confounding_ascertainment.R](https://github.com/nancyzhu24/thesis-project/blob/master/3.confounding_ascertainment.R) This script combines information from diagnsotic data and prescription history for each individual in the study cohort to ascertain covariates status for logistic regression model

7. Calcualte charlson index [charlson_index.R](https://github.com/nancyzhu24/thesis-project/blob/master/4.charlson_index.R) This script prepares the data from charlson index calculation for each individuals in the study cohort using Lyne's SAS script. The returned dataset is the cleaned dataset for analysis.

**Data Exploration and Analysis**
1. [EDA_case_control.Rmd](https://github.com/nancyzhu24/thesis-project/blob/master/5.EDA_case_control.Rmd) is a Rmarkdown files which serves as a template for exploratory data analysis and regression model analysis for the main analysis and some sensitivity analysis. The reports generated from this Rmarkdown files includes descriptive analysis of the study cohort and results from conditional logistic regression model. Notice, script for exposure definition were also included in this Rmarkdown file.

**Sensitivity analysis**

For the thesis project, a number of sensitivity analysis were conducted to test the robustness of the study result.

-*Sensitivity analysis 1*: in the analysis, case definition was altered to include information from physician billing code (ie outpatient visit were taken into consideration to define cases)

[load_billing_data.R](https://github.com/nancyzhu24/thesis-project/blob/master/load_billing_data.R) reads all physician billing data into R.

Cases were defined from [AS_bill_selection.R](https://github.com/nancyzhu24/thesis-project/blob/master/AS_bill_selection.R)
All the following data manipulation steps were the same for this analysis

-*Sensitivity analysis 2/3*:in this analysis Death due to AS or Death of any cause was included in the case. The goal of this analysis was to capture cases from death due to AS. Since reason of death is not thoroughly reported, to investigate the extend of missing report, another analysis was conducted to include death of all causes.

Death cases were ascertained from the death registry [deces_as.R](https://github.com/nancyzhu24/thesis-project/blob/master/deces_as.R)
Cases were defined using script [AS&death.R](https://github.com/nancyzhu24/thesis-project/blob/master/AS%26death.R)

For reporting, [Competing_risk_as.Rmd](https://github.com/nancyzhu24/thesis-project/blob/master/Competing_risk_as.Rmd) was used as the template.

-*Sensitivity analysis 4*: aortic stenosis features a long period time during which a patient remains asymptomatic. A patient could have developed AS long before being diagnosed. To study the long term effect of LTRAs on AS development, we re-defined cases when they have longer follow-up time

In supplement to case_selection.R, [define_case_by_fu(sensitivity).R](https://github.com/nancyzhu24/thesis-project/blob/master/define_case_by_fu(sensitivity).R) constructs the study cohort for this analysis.

-*Sensitivity analysis 5*: From exploratory data analysis from the main analysis, we realized an over-sampling issue with our case-control cohort. Since the source population of the study contains a relatively old population, many of our cases had short follow-up time in the study, thus controls who entered close to study end date were over-sampled to match on study follow-up time.

To study the effect, we conducted another sensitivity analysis where case and controls were matched on study entry year and follow-up time. The case-control matching algorithm can be found [here]() All other data manipulation steps were the same as the main analysis.

The reporting template for this analysis can be found in [EDA_case_control-match on calendar time.Rmd](https://github.com/nancyzhu24/thesis-project/blob/master/EDA_case_control%20-%20match%20on%20calendar%20time.Rmd)


