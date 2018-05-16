case_final<-read.csv('C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/case_final_withbill.csv',
                     stringsAsFactors = F)

base_cohort<-read.csv('C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/complete_set.csv',
                      stringsAsFactors = F)


#redefine case, select cases with follow-up time > 60 days, anyone with cfu<60 days defined as previous cases and removed 
# from base cohort and cases
date_Var<-c('entry_date','exit_date')
case_final[,date_Var]<-lapply(case_final[,date_Var],ymd)
case_final$cfu<-as.numeric(case_final$exit_date-case_final$entry_date)

exclude_nam<-case_final$nam[case_final$cfu<60]
#12700 cases excluded, 62% of original cases

#second definition: using 1 year as cut off 
exclude_nam<-case_final$nam[case_final$cfu<365]
#15359 cases excluded

`%ni%`<-Negate('%in%')
case_final%<>%filter(nam %ni% exclude_nam)

base_cohort%<>%filter(nam %ni% exclude_nam)

write.csv(case_final,'C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/case_final_365.csv',row.names = F)
write.csv(base_cohort,'C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/complete_set_365.csv',row.names = F)

ramq_cc<-fread('C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/ramq_cc_short365.csv',stringsAsFactors = F)