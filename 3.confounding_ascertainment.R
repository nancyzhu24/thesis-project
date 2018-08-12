#ascertain confounding:combine prescription history and diagnostic information:
ramq_cc$diabete_combined<-ifelse(ramq_cc$diabete==1|ramq_cc$id %in% unique(objects_subset[[3]]$nam),1,0)
ramq_cc$ckd_combined<-ifelse(ramq_cc$CKD==1,1,0)
ramq_cc$hypertension_combined<-ifelse(ramq_cc$hypertension==1 | ramq_cc$id %in% unique(objects_subset[[4]]$nam),1,0)
ramq_cc$pvd_combined<-ifelse(ramq_cc$peripheral==1|ramq_cc$id %in% unique(objects_subset[[7]]$nam),1,0)
ramq_cc$cad_combined<-ifelse(ramq_cc$CAD==1 | ramq_cc$id %in% unique(objects_subset[[2]]$nam),1,0)
ramq_cc$copd_combined<-ifelse(ramq_cc$COPD==1 | ramq_cc$id %in% unique(objects_subset[[1]]$nam),1,0)
ramq_cc$hyperlipidemia_combined<-ifelse(ramq_cc$dyslipidemia==1 | ramq_cc$hyperlipidemia_med==1|
                            ramq_cc$id %in% unique(objects_subset[[6]]$nam),1,0)
ramq_cc$hf_combined<-ifelse(ramq_cc$HF==1|ramq_cc$hf_med>=2,1,0)


rm(HF,hyperlipidemia,ACEI,lanoxin)

#define statin use as confounder:(see stain_use.R) for multi-level definition
#confirm confounding by looking at odds ratio of association between the covariate and exposure to LTRAs in controls:
v_factor<-c('diabete_combined','ckd_combined','hypertension_combined',
            'pvd_combined','cad_combined','copd_combined','hyperlipidemia_combined','hf_combined')
ramq_cc[,v_factor]<-lapply(ramq_cc[,v_factor],as.factor)

variables<-c('tageind','tfu','sexe','dyslipidemia','diabete','CKD','hypertension','COPD','CAD','peripheral','HF',
             'theophylline','beta_agonist','inhaled_corti','ACE_ARB','diuretic','alpha_blocker','calcium_channel','thiazolidinediones','sulfonylure',
             'biguanide','insulin','statin','nasaid','beta_blocker','diabete_combined','ckd_combined','hypertension_combined',
             'pvd_combined','cad_combined','copd_combined','hyperlipidemia_combined','hf_combined')
factor_vars<-c('sexe','dyslipidemia','diabete','CKD','hypertension','COPD','CAD','peripheral','HF','theophylline',
               'beta_agonist','inhaled_corti','ACE_ARB','diuretic','alpha_blocker','calcium_channel',
               'thiazolidinediones','sulfonylure','biguanide','insulin','statin','nasaid','beta_blocker',
               'diabete_combined','ckd_combined','hypertension_combined',
               'pvd_combined','cad_combined','copd_combined','hyperlipidemia_combined','hf_combined')

CreateTableOne(variables,'status',ramq_cc,factorVars=factor_vars)