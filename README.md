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
For the thesis project, a total of 8 sensitivity analysis were conducted to test the robustness of the study result.

Sensitivity analysis 1: in the analysis, case definition was altered to include information from physician billing code (ie outpatient visit were taken into consideration to define cases)

[load_billing_data.R](https://github.com/nancyzhu24/thesis-project/blob/master/load_billing_data.R) reads all physician billing data into R.

Cases were defined from [AS_bill_selection.R](https://github.com/nancyzhu24/thesis-project/blob/master/AS_bill_selection.R)
