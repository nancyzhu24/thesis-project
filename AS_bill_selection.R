#sensitivity analysis incorporating cases from physician billing code:

#load cases from physician billing code:
#see load_billing_data for case identification:

########################################################################################################
#Define cases through billing information:
#filter diagnostic code for AS:
AS<-c('4241','I350','I351','I352','I358','I359','I391')
bill_as<-lapply(bill,function(x)x[x$diag %in% AS,])
bill_as<-do.call(rbind,bill_as)

#find AS cases defined by having at least two diagnosis of AS or
#or 1 billing code if the MD was a cardiologist.

#subjects with at least two diagnosis,extract the first-time diagnosis:
bill_as_1<-bill_as%>%group_by(nam)%>%filter(n()>1)%>%
  arrange(dt_serv)%>%
  slice(1)%>%
  ungroup()


#subject with a diagnosis by cardiologist:
bill_as_2<-bill_as%>%filter(sp_prof==6)

#subjects with AS defined by bill info:
as_id<-unique(bill_as_1$nam,bill_as_2$nam)

#subjects not captured by hospitalization and surgery:
as_extra<-setdiff(as_id,case_final$nam)  #need to exclude cases with exclusion criteria
as_extra<-setdiff(as_extra,unique(exclusion1,exclusion2$nam))

#search previous diagnosis:
bill_subset<-lapply(bill,filter,nam %in% as_extra)
bill_subset<-do.call(rbind,bill_subset)
bill_subset$dt_serv<-as.Date(bill_subset$dt_serv,origin="1960-01-01")

#link to cohort entry date: (remove individuals not in demo)
bill_subset<-left_join(bill_subset,demo[,c(1,2,5)])%>%filter(!is.na(dt_index))

#previous diagnosis:
previous_as<-bill_subset%>%
  filter(diag==4241)%>%
  group_by(nam)%>%
  mutate(`1st_diag`=min(dt_serv))%>%
  ungroup()%>%
  filter(dt_index>=`1st_diag`)

#previous other conditions:
previous_ms<-bill_subset%>%
  filter(diag %in% c(exclusion_code$CIM.10.CA,exclusion_code$CIM9.Quebec))%>%
  group_by(nam)%>%
  mutate(`1st_diag`=min(dt_serv))%>%
  ungroup()%>%
  filter(dt_index>=`1st_diag`)

#exclude subjects from bill_subset to get the final extra cases from billing information:
`%ni%`<-Negate('%in%')
bill_subset<-bill_subset%>%
  filter(nam %ni% c(previous_as$nam,previous_ms$nam))

length(unique(bill_subset$nam))
#1885 new cases not captured by hospitalization and surgery database

#add 1454 cases to 'case_final', form new nested_case_control cohort, new analysis:
bill_subset<-bill_subset%>%filter(diag==4241)%>%
  group_by(nam)%>%
  arrange(dt_serv)%>%
  slice(1)%>%
  ungroup()%>%
  rename(entry_date=dt_index,
         exit_date=dt_serv)%>%
  mutate(case=1)%>%
  select(-code_act,-cl_prof,-sp_prof,-diag)

case_final[,c('entry_date','exit_date')]<-lapply(case_final[,c('entry_date','exit_date')],ymd)
case_final<-rbind(case_final,bill_subset)
write.csv(case_final,'C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/case_final_withbill.csv',row.names=F)


#form base cohort:
non_case<-demo%>%filter(nam %ni% unique(c(case_final$nam,exclusion2$nam,exclusion1,previous_as$nam,
                                          previous_ms$nam)))%>%
  dplyr::rename(entry_date=dt_index)

non_case<-left_join(non_case,sejour[,c('no_seq','nam','dtadm','dtsort','typ_deces')])

non_case<-non_case%>%mutate(exit_date_0=if_else(is.na(typ_deces),ymd('2011-03-31'),dtsort))%>%
  group_by(nam)%>%
  mutate(exit_date=min(exit_date_0))%>%
  ungroup()%>%
  select(nam,age,entry_date,exit_date)%>%
  distinct()

non_case$case<-0





















#incorporate residence status result:
#censoring can also be due to relocating outside Quebec

non_case<-left_join(non_case,clsc_move_date[,c('nam','exit_date')],by='nam')
non_case$exit_date<-coalesce(non_case$exit_date.y,non_case$exit_date.x)
non_case%<>%select(-exit_date.x,-exit_date.y)