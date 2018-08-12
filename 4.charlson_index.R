#charlson index calculation

file<-'ramq_cc_as_death2.RData'
#read in case-control file:
#setwd("~/OneDrive - McGill University/Code for thesis/R/thesis-project")
#ramq_cc<-readRDS(file)
#prepare me_diag dataset for SAS macro:
setwd("~/OneDrive - McGill University/Code for thesis")
charlson_filename<-'diag_charlson.csv'
diag_charlson<-ramq_cc%>%select(id,tentry_date)%>%rename(nam=id,dt_entry=tentry_date)%>%distinct()
write.csv(diag_charlson,charlson_filename,row.names = F)

###########################################################################################################
#run SAS algorithm from Lyne for charlson index calculation:
#reload results from SAS program:
comor_entry<-fread('C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/charlson.csv',
                   stringsAsFactors = F)
comor_entry_nch<-comor_entry%>%select(nam,starts_with('ch'))


#calculate index:
comor_entry_nch%<>%mutate(charlson=ch1+ch2+ch3+ch4+ch5+ch6+ch7+ch8+ch9+ch10+2*ch11+
                       2*ch12+2*ch13+2*ch14+3*ch15+6*ch16+6*ch17)
comor_entry_nch%<>%select(nam,charlson)

ramq_cc<-left_join(ramq_cc,comor_entry_nch,by=c('id'='nam'))

#assign 0 to NAs in the charlson index variable (questionable at this point)
ramq_cc$charlson[is.na(ramq_cc$charlson)]<-0

summary(ramq_cc$charlson)

saveRDS(ramq_cc,
    paste0('C:/Users/Nancy Zhu/OneDrive - McGill University/Code for thesis/R/thesis-project/',file))

rm(diag_charlson)