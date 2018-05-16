`%ni%`<-Negate('%in%')

#load data:
case_final<-fread('C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/Case_control_files/case_final.csv',stringsAsFactors = F)
complete_set<-fread('C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/Case_control_files/complete_set.csv',stringsAsFactors = F)

case_final[,c('entry_date','exit_date')]<-lapply(case_final[,c('entry_date','exit_date')],ymd)
complete_set[,c('entry_date','exit_date')]<-lapply(complete_set[,c('entry_date','exit_date')],ymd)

#####################################################################################################
#first analysis: outcome defined as AS and death due to AS
#load death due to AS data:
# See deces_as.R for details of definition
deces_as<-readRDS('deces_as.RData')

#in case_final, how many people eventually died of AS?
case_death<-case_final[case_final$nam %in% deces_as$nam,]
#2753 cases eventually died of AS

#subset to those availabe in complete set:
#Additionally, 670 individuals died of AS eventually, those never had a in-patient diagnosis or surgery
#part of it could be from out-patient diagnosis

#check by loading case_final_bill:
case_final_bill<-read.csv('C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/Case_control_files/case_final_withbill.csv',stringsAsFactors = F)
sum(death_as$nam %in% case_final_bill$nam) #56 cases from out-patient diagnosis was not captured before

death_as<-complete_set[(complete_set$nam %in% deces_as$nam)&(complete_set$nam %ni% case_final$nam),]
death_as%<>%left_join(deces_as,by='nam')
#check if any death date is after '2011-03-31'
#100 subject died of AS after study end period, thus not included as case
summary(death_as$exit_date)
death_as<-death_as%>%filter(exit_date.y<=exit_date.x)%>%
                     select(-exit_date.y)%>%
                     rename(exit_date=exit_date.x)
death_as$case<-1
case_final<-rbind(case_final,death_as)

complete_set$case<-ifelse(complete_set$nam %in% case_final$nam,1,0)

write.csv(case_final,'C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/Case_control_files/as_death.csv',row.names = F)
write.csv(complete_set,'C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/Case_control_files/complete_as_death.csv',row.names = F)

#############################################################################################################
#second analysis: outcome defined as AS and death of all cause (sensitivity analysis due to uncertainty in the
#accuracy of death cause ascertainment)
#include death (before study exit) as outcome as well:
death<-complete_set[(complete_set$nam %in% deces$nam)& complete_set$case==0,]

#identify death during hospitalization as well: death registry not 100% reliable:

#select individuals who died before study ended:
death<-death%>%left_join(deces)%>%
               filter(Dt_dec<='2011-03-31')%>%
               mutate(case=1)%>%
               select(-Dt_dec)
case_final<-rbind(case_final,death)
complete_set$case<-ifelse(complete_set$nam %in% case_final$nam,1,0)

#complete case set stays the same:
write.csv(case_final,'C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/Case_control_files/as_death2.csv',row.names = F)
write.csv(complete_set,'C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/Case_control_files/complete_as_death2.csv',row.names = F)

######################################################################################################
#run SAS program to match controls:

ramq_cc<-fread('C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/ramq_cc_all_death.csv',stringsAsFactors = F)
#find groups that has less than 10 matches:
case_to_exclude<-ramq_cc%>%group_by(caseid)%>%filter(n()<11)

paste('number of cases with less than 10 controls:',length(unique(case_to_exclude$caseid)))
