#this file was used to ascertain covariates status from prescription data:
objects <- list()
files<-c('asthma','beta_user','diabete','hypertension','nasaid','statin_user','pvd')
filename<-paste0('../RData files/',files, ".RData")
for (i in seq_along(files)){
  objects[[i]]<-readRDS(filename[i])
}

names(objects)<-c('asthma','beta_blocker','diabete','hypertension','nasaid','statin','pvd')

#select individuals with prescription history before cohort entry:
#remove prescription record with 0 quantite input
objects<-lapply(objects,function(x){x<-x%>%left_join(distinct(ramq_cc,id,tentry_date),by=c('nam'='id'))%>%
  filter(!is.na(tentry_date) & quantite!=0)%>%
  filter(dt_serv<tentry_date)
return(x)})

#further divide up categories into single medications:
#for Table-one:
#load cdenom code definitions from clean_pharma.R file:
theophylline<-objects[[1]]%>%filter(cdenom %in% theophylline)
beta_agonist<-objects[[1]]%>%filter(cdenom %in% beta_agonist)
inhaled_corti<-objects[[1]]%>%filter(din %in% asthma_cortico)
cromoglycate<-objects[[1]]%>%filter(cdenom==39419)


ACE_ARB<-objects[[4]]%>%filter(cdenom %in% c(ARB,ACEI))
Diuretic<-objects[[4]]%>%filter(cdenom %in% diuretic)
alpha_blocker<-objects[[4]]%>%filter(cdenom %in% alpha_blocker)
calcium_channel<-objects[[4]]%>%filter(cdenom %in% calcium_channel)

thiazolidinediones<-objects[[3]]%>%filter(cdenom %in% thiazolidinediones)
sulfonylurees<-objects[[3]]%>%filter(cdenom %in% sulfonylurees)
biguanides<-objects[[3]]%>%filter(cdenom %in% biguanides)
insulin<-objects[[3]]%>%filter(cdenom %in% insulin)

statin<-objects[[6]]
nasaid<-objects[[5]]
beta_blocker<-objects[[2]]


object2<-list(theophylline,beta_agonist,inhaled_corti,cromoglycate,ACE_ARB,Diuretic,alpha_blocker,calcium_channel,thiazolidinediones,
              sulfonylurees,biguanides,insulin,statin,nasaid,beta_blocker)
names(object2)<-c('theophylline','beta_agonist','inhaled_corti','cromoglycate','ACE_ARB','Diuretic','alpha_blocker','calcium_channel','thiazolidinediones',
                 'sulfonylurees','biguanides','insulin','statin','nasaid','beta_blocker')
rm(theophylline,beta_agonist,inhaled_corti,cromoglycate,ACE_ARB,Diuretic,alpha_blocker,calcium_channel,thiazolidinediones,
   sulfonylurees,biguanides,meglitinides,statin,nasaid,beta_blocker,insulin)


#assign categorical columns to ramq_cc:
ramq_cc<-ramq_cc%>%mutate(theophylline=ifelse(id %in% object2[[1]]$nam,1,0),
                          beta_agonist=ifelse(id %in% object2[[2]]$nam,1,0),
                          inhaled_corti=ifelse(id %in% object2[[3]]$nam,1,0),
                          ACE_ARB=ifelse(id %in% object2[[5]]$nam,1,0),
                          diuretic=ifelse(id %in% object2[[6]]$nam,1,0),
                          alpha_blocker=ifelse(id %in% object2[[7]]$nam,1,0),
                          calcium_channel=ifelse(id %in% object2[[8]]$nam,1,0),
                          thiazolidinediones=ifelse(id %in% object2[[9]]$nam,1,0),
                          sulfonylure=ifelse(id %in% object2[[10]]$nam,1,0),
                          biguanide=ifelse(id %in% object2[[11]]$nam,1,0),
                          statin=ifelse(id %in% object2[[13]]$nam,1,0),
                          beta_blocker=ifelse(id %in% object2[[15]]$nam,1,0),
                          nasaid=ifelse(id %in% object2[[14]]$nam,1,0),
                          insulin=ifelse(id %in% object2[[12]]$nam,1,0))

factors<-c('theophylline','beta_agonist','inhaled_corti','ACE_ARB','diuretic','alpha_blocker','calcium_channel','thiazolidinediones',
           'sulfonylure','biguanide','statin','nasaid','beta_blocker','insulin')
ramq_cc[,factors]<-lapply(ramq_cc[,factors],as.factor)

rm(object2)
#create tableone for descriptive analysis:
# variables<-c('tage','tfu','sexe','dyslipidemia','diabete','CKD','hypertension','CAD','peripheral','COPD','theophylline','beta_agonist','inhaled_corti','ACE_ARB','diuretic','alpha_blocker','calcium_channel','thiazolidinediones',
#              'sulfonylure','biguanide','statin','nasaid','beta_blocker','insulin')
# factor_vars<-c('sexe','dyslipidemia','diabete','CKD','hypertension','CAD','peripheral','COPD','theophylline','beta_agonist','inhaled_corti','ACE_ARB','diuretic','alpha_blocker','calcium_channel','thiazolidinediones',
#                'sulfonylure','biguanide','statin','nasaid','beta_blocker','insulin')
# CreateTableOne(variables,'status',ramq_cc,factorVars =factor_vars )


#add hyperlipidemia column to indicate individual taking hyperlipidemia(excluding statin) medication:
hyperlipidemia<-readRDS('C:/Users/nzhu/Desktop/Thesis project/Code for thesis/RData files/hyperlipidemia.RData')
hyperlipidemia<-hyperlipidemia%>%
  left_join(distinct(ramq_cc,id,tentry_date),by=c('nam'='id'))%>%
  filter(dt_serv<tentry_date)


ramq_cc$hyperlipidemia_med<-as.factor(ifelse(ramq_cc$id %in% unique(hyperlipidemia$nam),1,0))


#add HF medication:
HF<-readRDS('C:/Users/nzhu/Desktop/Thesis project/Code for thesis/RData files/HF_med.RData')%>%
  left_join(distinct(ramq_cc,id,tentry_date),by=c('nam'='id'))%>%
  filter(dt_serv<tentry_date)

lanoxin<-HF%>%filter(cdenom==2847)%>%distinct(nam)
ACEI<-HF%>%filter(cdenom %in% ACEI)%>%distinct(nam)

ramq_cc$lanoxin<-ifelse(ramq_cc$id %in% lanoxin$nam,1,0)
ramq_cc$acei<-ifelse(ramq_cc$id %in% ACEI$nam,1,0)

ramq_cc$diuretic<-as.numeric(ramq_cc$diuretic)
ramq_cc$hf_med<-ramq_cc$diuretic+ramq_cc$lanoxin+ramq_cc$acei


#saveRDS(ramq_cc,'ramq_cc.RData')