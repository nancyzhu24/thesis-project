library(tableone)


#'table 1' description: match back to demo information for gender, other confounder description data:
ramq_cc%<>%left_join(demo[,c(1,3)],by=c('id'='nam'))
ramq_cc$sexe<-as.factor(ramq_cc$sexe)
date_factor<-c('texit_date','tentry_date')
ramq_cc[,date_factor]<-lapply(ramq_cc[,date_factor],ymd)


prop.table(table(ramq_cc$sexe,ramq_cc$status),2)


ramq_cc<-diagnostic(ramq_cc,ICD,me_diag)

#function to ascertain covariate with diagnostic code (in-patient)

diagnostic<-function(ramq_cc,ICD,me_diag){

#'From inpatient-diagnostic and intervention table find the ICD10 code for the following:
dyslipidemia<-c('^272\\d{,2}')
diabete<-c('^250\\d{,2}')
chronic_kidney<-c('\\b585\\b')
hypertension<-c('^401\\d{,2}')

cad<-c('^410\\d{,2}','^411\\d{,2}','^412\\d{,2}','^413\\d{,2}','^414\\d{,2}')

#code for peripheral:
peripheral_10<-c('^I70\\d{,2}','^I71\\d{,2}')
peripheral_10<-c(ICD$CIM.10.CA[grepl(paste(peripheral_10,collapse ='|'),ICD$CIM.10.CA)],'I731',
                 'I738','I739','I771','I790','K551','K558','K559','Z958','Z959')
peripheral_9<-c(ICD$CIM9.Quebec[grepl('^441.*',ICD$CIM9.Stand)],'4439','V434','7854')
peripheral<-c(peripheral_9,peripheral_10)
  
#code for asthma and copd:
COPD<-c('^491\\d{,2}','^490\\d{,2}','^492\\d{,2}','^493\\d{,2}','^494\\d{,2}','^495\\d{,2}','^496\\d{,2}',
        '^500\\d{,2}','^501\\d{,2}','^502\\d{,2}','^503\\d{,2}','^504\\d{,2}','^505\\d{,2}')
#heart failure:
hf<-c('^428\\d{,2}')
#find icd10 code from ICD table:
icd9_codes<-c(dyslipidemia,diabete,chronic_kidney,hypertension,cad,COPD,hf)
icd10<-ICD$CIM.10.CA[grepl(paste(icd9_codes,collapse ='|'),ICD$CIM9.Stand)]
icd9_qc<-ICD$CIM9.Quebec[grepl(paste(icd9_codes,collapse ='|'),ICD$CIM9.Stand)]
icd_final<-unique(c(icd9_qc,icd10,peripheral))

#find subjects with any of the diagnostic code from me_diag:, filter with nam in ramq_cc
diag_subset<-me_diag%>%filter(diag_diag %in% icd_final)%>%
                       filter(nam %in% ramq_cc$id)%>%
                       select(1,2,3,6)%>%
                       left_join(sejour[,c(1,2,5,6,13)])

#bind to cohort entry date, define whether subjects were diagnosed (use dtsort for comparison) at or before 
#cohort entry date for covariates:
diag_subset<-left_join(diag_subset,distinct(ramq_cc[,c('id','tentry_date')]),by=c('nam'='id'))

#filter dtsort < tentry_date for baseline status:
diag_subset%<>%filter(dtsort<tentry_date)

#assign binary variables to each disease state:
icd9_list<-list(dyslipidemia,diabete,chronic_kidney,hypertension,cad,COPD,hf)
code<-list()
for (i in seq_along(icd9_list)){
  
  code[[i]]<-unique(c(ICD$CIM.10.CA[grepl(paste(icd9_list[[i]],collapse='|'),ICD$CIM9.Stand)],
                      ICD$CIM9.Quebec[grepl(paste(icd9_list[[i]],collapse="|"),ICD$CIM9.Stand)]))
}
names(code)<-c('dyslipidemia','diabete','chronic_kidney','hypertension','cad','COPD','hf')



diag_subset<-diag_subset%>%mutate(dyslipidemia=ifelse(diag_diag %in% code[[1]],1,0),
                                  diabete=ifelse(diag_diag %in% code[[2]],1,0),
                                  CKD=ifelse(diag_diag %in% code[[3]],1,0),
                                  hypertension=ifelse(diag_diag %in% code[[4]],1,0),
                                  COPD=ifelse(diag_diag %in% code[[6]],1,0),
                                  CAD=ifelse(diag_diag %in% code[[5]],1,0),
                                  peripheral=ifelse(diag_diag %in% peripheral,1,0),
                                  HF=ifelse(diag_diag %in% code[[7]],1,0))


#remove duplicated rows, some subject have multiple rows due to repeated admission with the same disease:
diag_status<-diag_subset%>%select(nam,dyslipidemia,diabete,CKD,hypertension,COPD,CAD,peripheral,HF)%>%distinct()

#consolidate each individual status:
diag_status<-diag_status%>%group_by(nam)%>%mutate_all(sum)%>%ungroup()%>%distinct()
length(unique(diag_status$nam))
#one row correspond to one individual with all status of cormodity



#bind results back to ramq_cc table:
ramq_cc%<>%left_join(diag_status,by=c('id'='nam'))

#assign 0 to all NAs in disease status column as those subjects did not show up in the filtering in the first step:
select_col<-c('dyslipidemia','diabete','CKD','hypertension','COPD','CAD','peripheral','HF')
ramq_cc[,select_col]<-lapply(ramq_cc[,select_col],function(x){x<-ifelse(is.na(x),0,x)})
ramq_cc[,select_col]<-lapply(ramq_cc[,select_col],as.factor)

#rm(diag_status,diag_subset,icd9_list,code)
return(ramq_cc)
}



#create tableone for descriptive analysis:
variables<-c('tageind','tfu','sexe','dyslipidemia','diabete','CKD','hypertension','COPD','CAD','peripheral','HF')
factor_vars<-c('sexe','dyslipidemia','diabete','CKD','hypertension','COPD','CAD','peripheral','HF')
CreateTableOne(variables,'status',ramq_cc,factorVars =factor_vars )


#save new version of ramq_cc
#saveRDS(ramq_cc,'ramq_cc.RData')
