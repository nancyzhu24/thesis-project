library(survival)

#conditional logistic regression:

#clean data into right format:
ramq_cc$pair<-rleid(ramq_cc$caseid)
ramq_cc$status<-as.numeric(ramq_cc$status)

library(survival)
model<-clogit(data=ramq_cc,status~exposure+sexe+diabete_combined+ckd_combined+hypertension_combined+
                     pvd_combined+copd_combined+hyperlipidemia_combined+statin+strata(pair))

summary(model)
#full model:
#exposure_var<-grep('exposure.*',colnames(ramq_cc),value=T)
exposure_var<-c('exposure','exposure_30','exposure_60','exposure_90','exposure_120')

lapply(exposure_var,
function(var) {
   formula <-as.formula(paste("outcome ~",var,"+sexe+diabete+ckd+hypertension+
                     pvd+cad+copd+hf+hyperlipidemia+statin+index+strata(pair)"))
   clog<-clogit(formula,data=ramq_cc)

   summary(clog)
})




#model selection:
model.null<-clogit(data=ramq_cc_conf,outcome~exposure+strata(pair))
model.full<-clogit(data=ramq_cc_conf,outcome~exposure+sexe+diabete+ckd+hypertension+pvd+cad+copd+hf+
                     hyperlipidemia+statin+strata(pair))

library(MASS)
#backward selection AIC:
stepAIC(cond_model,direction='backward',trace=1)

#forward selection AIC
forward<-step(model.null,scope=list(lower=model.null,upper=model.full),
               direction='forward',trace=0)

summary(forward)


#model selection with BIC:
forward_BIC<-step(model.null,scope=list(lower=model.null,upper=model.full),
              direction='forward',trace=0,k=log(nrow(ramq_cc_conf)))

summary(forward_BIC)

#assumption check:
