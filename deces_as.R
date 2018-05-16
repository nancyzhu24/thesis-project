#update death cause with AS
deces<-fread('E:/export_R/deces.csv',stringsAsFactors = F)

deces<-deces%>%select(nam,Dt_dec,starts_with('cause'))%>%
               gather(key='cause_cat',value='cause',starts_with('cause'),na.rm=T)%>%
               filter(cause!='')

#All subjects with death due to AS (any category of cause):
deces_as<-deces%>%filter(cause %in% c('4241','I350','I351','I352','I358','I359','I391'))%>%
                  distinct(nam,Dt_dec)%>%
                  mutate(Dt_dec=ymd(as.character(Dt_dec)))%>%
                  rename(exit_date=Dt_dec)

saveRDS(deces_as,'deces_as.RData')

