source('C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/R/read_files.R')

#filter in-patient data with diagnostic codes:(both icd 9 and icd 10 code)
AS<-c('4241','I350','I351','I352','I358','I359','I391')

#procedure code for surgical surgery and TVA
interv_cci<-CCI[grepl('1HV',CCI$CCI),]
#convert CCI code to 7 digit format:
interv_cci$CCI<-substr(interv_cci$CCI,1,7)
AS_p<-unique(c(interv_cci$CCI,interv_cci$CCA.stand))


#link individuals to hospital admission date, select for first time diagnosis
case1<-me_diag%>%filter(diag_diag %in% AS)%>%select(nam,diag_diag,no_seq,type_diag)%>%distinct()

case1<-left_join(case1,distinct(sejour[,c('no_seq','nam','dtsort')]))%>%
  select(nam,dtsort)%>%
  left_join(demo[,c(1,5)])%>%
  group_by(nam)%>%
  filter(dtsort==min(dtsort))%>%
  ungroup()%>%
  mutate(diag='AS_diag')%>%
  distinct()
#for ~100 individuals, multiple adm and sort date for the same nam, diag code and no_seq

#first time intervention
interv<-me_interv%>%filter(code_interv %in% AS_p)%>%
                       select(nam,dt_interv)%>%
                       left_join(demo[,c(1,5)])%>%
                       group_by(nam)%>%
                       filter(dt_interv==min(dt_interv))%>%
                       ungroup()%>%
                       mutate(code_interv='AS_p')%>%
                       distinct()

#Before exclusion:
paste('The number of unique cases before exclusion:',length(unique(c(case1$nam,interv$nam))))

#compare first time AS case number by plotting
p1<-ggplot(data=case1,aes(x=year(dtsort)))+geom_bar(fill='#6633CC')+
  ggtitle('Number of first-time cases by \n diagnostic code over time ')
p2<-ggplot(data=interv,aes(x=year(dt_interv)))+geom_bar(fill='#6633CC')+
  ggtitle('Number of first-time cases by \n intervention code over time ')
grid.arrange(p1,p2, nrow=1, ncol=2)

#what about billing information?
bill2<-bill2%>%group_by(nam)%>%
               filter(dt_serv==min(dt_serv))%>%
               ungroup()%>%
               select(nam,dt_serv,dt_index,age,sexe)%>%
               distinct()

#merged_tb includes patients with previous history of AS

#exclude cases:
#step 1, find the earliest date of hospital discharge for each nam individuals
#Remove individuals with index_date after diagnose or procedure date of aortic stenosis:

#merge diagnostic and intervention data for subjects:
merged_tb<-full_join(case1,interv)%>%distinct()

#cases to exclude due to previous exposure:
exclusion1<-unique(c(case1$nam[case1$dtsort<=case1$dt_index],interv$nam[interv$dt_interv<=interv$dt_index]))

`%ni%`<-Negate('%in%')
merged_tb%<>%filter(nam %ni% exclusion1)

paste('The number of unique cases after excluding subjects with previous diagnosis of aortic stenosis:',
        length(unique(merged_tb$nam)))

#step2: exclude subjects with previous diagnosis of Rheumatic aortic stenosis and etc(for complete list,see protocol)
#extract ICD10 &ICD9 code from ICD table:
icd9<-c('3950','3951','3952','3959','396','3961','3962','3963','3968','7463','7464','7465','7466','3910','7140','4240')
exclusion_code<-ICD%>%filter(CIM9.Stand %in% icd9)%>%select(CIM.10.CA,CIM9.Quebec)


#check if all subjects having a surgical intervention had a diagnostics
#subjects need to be further excluded: (mitral abnormality...)
exclusion2<-me_diag%>%
            #filter(nam %in% unique(c(case1$nam,me_interv$nam)))%>%
            filter(diag_diag %in% c(exclusion_code$CIM.10.CA,exclusion_code$CIM9.Quebec))%>%
            left_join(sejour)%>%
            left_join(demo[,c(1,5)])%>%
            group_by(nam)%>%
            mutate(dtsort=min(dtsort))%>%
            ungroup()%>%
            filter(dtsort<=dt_index)
paste('Number of cases with previous other conditions:',length(unique(exclusion2$nam))) 

#exclude the nam from merged_tb
case_final<-anti_join(merged_tb,exclusion2[,'nam'])

##########################################################################
#investigate individuals with only intervention code but no diagnostic code:
test<-case_final%>%filter(is.na(dtsort))

#816 cases only has intervention code but not diagnosis of AS.
#check whether those individuals had a CABG procedure as well at around the same time:
test_interv<-me_interv%>%filter(nam %in% test$nam)%>%count(code_interv)%>%arrange(desc(n))

#separate individuals with a CABG 1IJ76 procedure:
as_cabg_code<-c('1IJ76LA','1HV90LA','1HV80LA','1HV90WJ','1HV90ST','1HV80GP','1HV80ST','1HV90GP')
as_cabg<-me_interv%>%filter(nam %in% test$nam,code_interv %in% as_cabg_code )
#select individuals without CABG procedure for further investigation:
as_cabg_subset<-as_cabg%>%mutate(CABG=ifelse(code_interv=='1IJ76LA',1,0))%>%
                          group_by(nam)%>%
                          filter(sum(CABG)<1)%>%
                          ungroup()

#228 individuals without CABG intervention
#check how many of those has no billing code:
as_cabg_subset%<>%left_join(bill2)
sum(is.na(as_cabg_subset$bill_code))
#in 228 individual: 23 miss billing code as well:
me_interv%>%filter(nam%in%unique(as_cabg_subset$nam))%>%count(code_interv)%>%arrange(desc(n))

#### Record the nams, in case we want to remove them from case
##########################################################################################################

#find the time of entry and time of exit (first case definition) from follow-up:
#clean case_final table for SAS matching algorithm:
case_final<-case_final%>%
            select(nam,dtsort,dt_interv,dt_index)%>%
            distinct()%>%
            mutate(case=1)%>%
            rename(entry_date=dt_index)
case_final$exit_date<-pmin(case_final$dtsort,case_final$dt_interv,na.rm=T)


#Create full set for control selection:
#Match to Age at index date
case_final<-left_join(case_final,demo[,c(1,2)])%>%select(-dt_interv,-dtsort)

#quick summary of cases, check exit_date range and age range
summary(case_final)

#extract nam from demo for non_case=total-cases-excluded individuals
non_case<-demo%>%filter(nam %ni% unique(c(case_final$nam,exclusion2$nam,exclusion1)))%>%
          dplyr::rename(entry_date=dt_index)

#link to sejour data to figure out the exit date: Death or Mar 31 2011:

##################################################################################################
#check consistency between me_diag type_diag vs me_sejour typ_deces for death 
# death<-me_diag%>%filter(type_diag=='D')
# death2<-sejour%>%filter(!is.na(typ_deces))
# setdiff(death$nam,death2$nam)
#got the same number, so either of them can be used for death affirmation



non_case<-left_join(non_case,sejour[,c('no_seq','nam','dtadm','dtsort','typ_deces')])
#2792 individuals without any hospitalization record for admission between cohort entry and 2011-03-31
#some of them might be late entryee and only had record after 2011-03-31(sejour cut off at 2011-03-31)

no_sejour<-non_case%>%filter(is.na(dtsort))
#many of them do have bill history, maybe missing data in diagnostic problem?
#might have prescription data as well, keep those in the cohort.

#should you remove 2792 individuals?
#non_case%<>%filter(!is.na(dtsort))

#reassign the exit_date to 2011-03-31 or death date if smaller than 2011-03-31:
#first assign date if death
#then assign any date after 2011-06-30 to 2011-06-30
non_case<-non_case%>%mutate(exit_date_0=if_else(is.na(typ_deces),ymd('2011-03-31'),dtsort))%>%
                     group_by(nam)%>%
                     mutate(exit_date=min(exit_date_0))%>%
                     ungroup()%>%
                     select(nam,age,entry_date,exit_date)%>%
                     distinct()
non_case$case<-0
#check if any mistake where last dtsort < entry date:
mistake<-non_case%>%filter(exit_date<entry_date)
#remove those 2 individuals, died right after entry
non_case%<>%filter(nam %ni% mistake$nam)

#check percentage of death: (consider competing risk factor)
#non_case$death<-as.factor(ifelse(non_case$exit_date!='2011-03-31',1,0))




complete_set<-bind_rows(non_case,case_final)



write.csv(case_final,'C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/case_final.csv',row.names=F)
write.csv(complete_set,'C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/complete_set2.csv',row.names=F)

# summary(complete_set[complete_set$case==0,]$length)
# summary(complete_set[complete_set$case==1,]$length)
# 
# ggplot(complete_set,aes(length))+geom_histogram(binwidth=100)+
#   ggtitle('Histogram of Follow-up time')+facet_grid(.~case)

#using Michele's SAS code created ramq_cc case control dataset:
ramq_cc<-fread('C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/ramq_cc.csv',stringsAsFactors = F)%>%distinct()

#find groups that has less than 10 matches:
case_to_exclude<-ramq_cc%>%group_by(caseid)%>%filter(n()<11)

paste('number of cases with less than 10 controls:',length(unique(case_to_exclude$caseid)))
#11 cases excluded

#quick check age and follow-up time in each group:
ramq_cc<-ramq_cc%>%filter(caseid %ni% case_to_exclude$caseid)
ramq_cc%>%group_by(status)%>%summarise(mean_age=mean(tageind),mean_fup=mean(tfu),size=n())

rm(merged_tb,non_case,complete_set,case1,case_final,exclusion1,exclusion2,interv_cci,case_to_exclude)
  