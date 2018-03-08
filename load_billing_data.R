package<-c('dplyr','ggplot2','tidyr','stringr',
           'xlsx','magrittr','data.table','tidyverse','xlsx','lubridate')
lapply(package,require,character.only=T)


#look through billing code for surgical intervention:
file<-list.files(path='E:/')
filename<-list.files(path='E:/',pattern='^bill_\\d{4}')
filepath<-paste0('E:/',filename)

bill<-list()
for (i in 1:12){
  bill[[i]]<-fread(filepath[i],stringsAsFactors = F)%>%
    select(nam,diag,dt_serv,code_act)
}

names(bill)<-filename[1:12]

#filter code_act for AS surgical interventions to look at case numbers:
AS_bill_code<-c(4547,4548,4542,4543,4546,4544)
bill<-lapply(bill,function(x)x[x$code_act %in% AS_bill_code,])

bill<-do.call(rbind,bill)
length(unique(bill$nam))
#12792 unique individuals

lapply(bill,function(x)sum(is.na(x))) #no missing values

#link bill to index_age in demo (filtered by age) dataset by nam:
bill2<-left_join(bill,demo[,c('nam','dt_index','age','sexe')])%>%
      filter(!is.na(dt_index))%>%
      mutate(dt_serv=as.Date(dt_serv,origin='1960-01-01'))%>%
      distinct() #remove duplicated rows

length(unique(bill$nam))

#link icd code in bill2 to ICD table:
bill_icd<-unique(c(ICD$Description.CIM10.CA..Français[ICD$CIM9.Stand %in% unique(bill2$diag)],
                ICD$Description.CIM10.CA..Français[ICD$CIM.10.CA %in% unique(bill2$diag)]))
                

#plot surgical intervention cases by year:
#ggplot(data=bill%>%group_by(year(dt_index))%>%summarise(count=n_distinct(nam)),aes(x=`year(dt_index)`,y=count))+
#   geom_bar(stat='identity')

