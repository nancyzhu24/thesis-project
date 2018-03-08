package<-c('dplyr','ggplot2','tidyr','stringr','magrittr','data.table','tidyverse','lubridate')
lapply(package,require,character.only=T)

##########################################################################################################
#Due to limited memory on desktop, the following code was run on Amazon EC2:

#load all out-patient pharma data into a list:
#extract file names:
file<-list.files(path='~/RAMQ_drug/pharma')
file<-file[grepl('pharma_',file)]
filepath<-paste0('~/RAMQ_drug/pharma/',file)
filename<-na.omit(str_extract(file,'pharma_\\d{4}'))

pharma<-list()
for (i in 1:12){
  pharma[[i]]<-fread(filepath[i],stringsAsFactors = F)%>%
                select(nam,din,ahf,dt_serv,quantite,duree,cdenom)
                
}

names(pharma)<-filename[1:12]

pharma<-do.call(rbind,pharma)

pharma$dt_serv<-as.Date(pharma$dt_serv,origin='1960-01-01')
row.names(pharma)<-NULL

#save combined pharma data:
saveRDS(pharma,'complete_pharma.RData')

#ahf code is not accurately coded RAMQ:
cdenom<-read.csv('../NMED_Denom_Comne.csv',header=T,encoding='latin1',stringsAsFactors=F)
#add leading zeros:
# cdenom$Code.denom.comne<-as.character(cdenom$Code.denom.comne)
# cdenom<-cdenom%>%mutate(code=case_when(nchar(Code.denom.comne)==2 ~ paste0('000',Code.denom.comne),
#                                        nchar(Code.denom.comne)==3 ~ paste0('00',Code.denom.comne),
#                                        nchar(Code.denom.comne)==4 ~ paste0('0',Code.denom.comne),
#                                        nchar(Code.denom.comne)==5 ~ Code.denom.comne
#                                        ))

cdenom%<>%rename(code=Code.denom.comne)

#Exposure:leukotriene receptor antagonist ahf code:481024
ltra<-cdenom%>%filter(grepl('kast',Description))%>%distinct(code)%>%pull()

#first need to figure out the prevalence of exposure!!
exposure<-pharma%>%filter(cdenom %in% ltra)
saveRDS(exposure,'LTRA.RData')



#Confounders: statin use
statin<-cdenom%>%filter(grepl('statine',Description))%>%filter(!grepl('nystatine|cilastatine|somatostatine',Description))%>%
          distinct(code)%>%pull()


statin_user<-pharma%>%filter(cdenom %in% statin)
#hyperlipidemia: 240692
hyperlipid<-cdenom%>%filter(grepl('fibrate|fibrozil',Description))%>%distinct(code)%>%pull()
hyperlipidemia<-pharma%>%filter(ahf==240692|cdenom %in% hyperlipid)
#Diabetes drug use: ahf code:682004; 682002;682005;682006;682008;682016;682020;682028;682092
#major class of diabetes drugs:
thiazolidinediones<-cdenom%>%filter(grepl('litazone',Description))%>%distinct(code)%>%pull()
sulfonylurees<-cdenom%>%filter(grepl('gliclazide|glimepiride|
                                     glimépiride|glyburide|tolbutamide',Description))%>%distinct(code)%>%pull()
biguanides<-c(5824,47208,47807)
insulin<-cdenom%>%filter(grepl('insuline',Description))%>%distinct(code)%>%pull()
meglitinides<-cdenom%>%filter(grepl('linide',Description))%>%distinct(code)%>%pull()


diabete<-pharma%>%filter(cdenom %in% c(thiazolidinediones,sulfonylurees,biguanides,insulin,meglitinides))

#Hypertension drug use: ahf code: 240816;
ACEI<-cdenom%>%filter(grepl('trandolapril|ramipril|quinapril|perindopril|périndopril|
                            lisinopril|fosinopril|énalapril|cilazapril|captopril|bénazépril',Description))%>%
  distinct(code)%>%pull()
ARB<-cdenom%>%filter(grepl('sartan|aliskirène',Description))%>%distinct(code)%>%pull()
diuretic<-cdenom%>%filter(grepl('chlorthalidone|indapamide|metolazone|^hydrochlorothiazide|spironolactone|amiloride',Description))%>%distinct(code)%>%pull()
alpha_blocker<-cdenom%>%filter(grepl('prazosin|doxazosine|térazosine',Description))%>%distinct(code)%>%pull()
calcium_channel<-cdenom%>%filter(grepl('amlodipine|félodipine|nifédipine|nimodipine|verapamil|diltiazem',Description))%>%distinct(code)%>%pull()

hypertension<-pharma%>%filter(cdenom %in% c(ACEI,ARB,diuretic,alpha_blocker,calcium_channel))

#cardiovascular drugs:
beta_blocker<-cdenom%>%filter(grepl('acébutolol|aténolol|bisoprolol|carvédilol|esmolol|
                                    labetalol|métoprolol|nadolol|pindolol|propranolol|sotalol|^timolol',Description))%>%distinct(code)%>%pull()
beta_user<-pharma%>%filter(cdenom %in% beta_blocker)

#for asthma treatment, need to look at both ahf and din code
theophylline<-cdenom%>%filter(grepl('aminophylline|oxtriphylline|théophylline',Description))%>%distinct(code)%>%pull()

beta_agonist<-cdenom%>%filter(grepl('formoterol|indacatérol|formoterol|formotérol|
                                    salmétérol|terbutaline|salbutamol',Description))%>%distinct(code)%>%pull()


#din code for corticosteroides for asthma treatment:
asthma_cortico<-as.integer(c(852074,851752,851760,2229099,1978918,1978926,2285606,2285614))
cromoglycate<-c(39419)

'%ni%' <- Negate('%in%')

asthma<-pharma%>%filter(cdenom %in% c(theophylline,beta_agonist,cromoglycate) |din %in% asthma_cortico)
                 
#use of NSAIDs:
NASAID<-cdenom%>%filter(grepl('acétylsalicylique|célécoxib|celecoxib|diclofénac|étodolac|^ibuprofène|
                              flurbiprofène|indométhacine|kétoprofène|méfénamique|méloxicam|nabumétone|
                              nabumetone|naproxène|naproxene|piroxicam|sulindac|tenoxicam|tiaprofénique',Description))%>%
                 distinct(code)%>%pull()

nasaid<-pharma%>%filter(cdenom %in% NASAID)

#medication for pvd:
pvd<-pharma%>%filter(cdenom==44346)


#medication for heart failure:
lanoxin<-c(2242319)

HF<-pharma%>%filter(din==lanoxin|cdenom %in% c(ACEI,diuretic))

# HF<-HF%>%
#   left_join(demo[c('nam','dt_index')])%>%
#   group_by(nam)%>%
#   mutate(earliest_serv=min(dt_serv))%>%
#   ungroup()%>%
#   filter(dt_index>=earliest_serv)


#export files to work on desktop:
objects <- list(asthma,beta_user,diabete,hypertension,nasaid,statin_user,HF,hyperlipidemia)
names(objects)<-c('asthma','beta_user','diabete','hypertension','nasaid','statin_user','HF_med','hyperlipidemia')
for (i in 1:length(objects)){
  filename = paste0('~/RAMQ_drug/',names(objects)[i], ".RData")
  saveRDS(objects[[i]], filename)
}




#prescription before entry date used as another way to ascertain covariate status:(see clean_pharma2.R file)

