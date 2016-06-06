
  # GBM Analyses
  
  ## outcome variable specification and/or creating additional variables for analysis
  # outcome1 variable: needed 2nd rate control agent or not
  #                   --> entire cohort
  # outcome2 variable: rvr duration (time to control)
  #                   --> for those who got only 1 agent during the entire course
  # outcome3 variable: controlled within 4 hours or not
  #                   --> exclude those who got 2 agent within 4 hours
  # outcome4 variable: need 2nd agent within 4 hours
  #                   --> entire cohort
  # outcome5 variable: increased vassopressor need (dose or type)
  #                   --> entire cohort
  # outcome6 variable: mortality
  #                   --> entire cohort

dataset = read.csv(file="dataset_0906.csv",head=TRUE,sep=",")
dataset$need.2nd.agent = factor(as.numeric(dataset$rate.drugs.num>1),
                                levels=c(0,1))
dataset$need.2nd.agent.within4 = ifelse(dataset$second.agent.kick.in.time <= 240 ,1,0)
dataset$need.2nd.agent.within4 = factor(dataset$need.2nd.agent.within4,
                                        levels=c(0,1))
dataset$controlled.within4 = ifelse(dataset$rvr.duration <=240,1,0)
dataset$controlled.within4 = factor(dataset$controlled.within4,
                                    levels=c(0,1))


## assign proper variable characteristics (and labels factor values as needed)

# make identifiers nominal
dataset$s.id = factor(dataset$s.id)
dataset$h.id = factor(dataset$h.id)
dataset$icu.id = factor(dataset$icu.id)
dataset$controlled.4hrs = factor(dataset$controlled.4hrs)
# assign labels to rate.drugs
dataset$rate.drug.1st = factor(dataset$rate.drug.1st, 
                               levels=c(6,1,3),
                               labels=c('metoprolol','amiodarone','diltiazem'))
dataset$rate.drug.2nd = factor(dataset$rate.drug.2nd, 
                               levels=c(1,2,3,4,5,6,7,8,0),
                               labels=c('amiodarone','digoxin','diltiazem','esmolol',
                                        'ibutilide','metoprolol','procainamide',
                                        'propafenone','none'))
dataset$rate.drug.3rd = factor(dataset$rate.drug.3rd,
                               levels=c(1,2,3,4,5,6,7,8,0),
                               labels=c('amiodarone','digoxin','diltiazem','esmolol',
                                        'ibutilide','metoprolol','procainamide',
                                        'propafenone','none'))
dataset$rate.drug.4th = factor(dataset$rate.drug.4th,
                               levels=c(1,2,3,4,5,6,7,8,0),
                               labels=c('amiodarone','digoxin','diltiazem','esmolol',
                                        'ibutilide','metoprolol','procainamide',
                                        'propafenone','none'))
dataset$rate.drug.5th = factor(dataset$rate.drug.5th,
                               levels=c(1,2,3,4,5,6,7,8,0),
                               labels=c('amiodarone','digoxin','diltiazem','esmolol',
                                        'ibutilide','metoprolol','procainamide',
                                        'propafenone','none'))
dataset$vasopressor.before.rvr = factor(dataset$vasopressor.before.rvr,
                                        levels=c(0,1))
dataset$vasopressor.1st = factor(dataset$vasopressor.1st,
                                 levels=c(42,43,44,47,119,306,307,309,0),
                                 labels=c('dobutamine','dopamine','epinephrine',
                                          'levophed','epinephrine.k','dobutamine.drip',
                                          'dopamine.drip','epinephrine.drip','none'))
dataset$vasopressor.2nd = factor(dataset$vasopressor.2nd,
                                 levels=c(42,43,44,47,119,306,307,309,0),
                                 labels=c('dobutamine','dopamine','epinephrine',
                                          'levophed','epinephrine.k','dobutamine.drip',
                                          'dopamine.drip','epinephrine.drip','none'))
dataset$vasopressor.3rd = factor(dataset$vasopressor.3rd,
                                 levels=c(42,43,44,47,119,306,307,309,0),
                                 labels=c('dobutamine','dopamine','epinephrine',
                                          'levophed','epinephrine.k','dobutamine.drip',
                                          'dopamine.drip','epinephrine.drip','none'))
dataset$gender = factor(dataset$gender,
                        levels=c('F','M'))
dataset$death.within.2yr = factor(dataset$death.within.2yr, 
                                  levels=c(0,1))
dataset$ethnicity.simplified = factor(dataset$ethnicity.simplified,
                                      levels=c('white','black','hispanic','asian',
                                               'other','unknown'))
dataset$liver.dz.elix = factor(dataset$liver.dz.elix,
                               levels=c(0,1))
dataset$malignancy.elix = factor(dataset$malignancy.elix,
                                 levels=c(0,1))
dataset$dm.elix = factor(dataset$dm.elix,
                         levels=c(0,1))
dataset$asthma.icd9 = factor(dataset$asthma.icd9,
                             levels=c(0,1))
dataset$afib.ds.pmh = factor(dataset$afib.ds.pmh,
                             levels=c(0,1))
dataset$ckd.icd9 = factor(dataset$ckd.icd9,
                          levels=c(0,1))
dataset$copd.icd9 = factor(dataset$copd.icd9,
                           levels=c(0,1))
dataset$chf.icd9 = factor(dataset$chf.icd9,
                          levels=c(0,1))
dataset$valvular.dz.icd9 = factor(dataset$valvular.dz.icd9,
                                  levels=c(0,1))
dataset$bb.home = factor(dataset$bb.home,
                         levels=c(0,1))
dataset$increased.vaso = factor(dataset$increased.vaso,
                                levels=c(0,1))
dataset$day.30.mortality = factor(dataset$day.30.mortality, 
                                  levels=c(0,1))

# create a subset of complete cases
dataset.rmna = na.omit(dataset)




## Use GBM to create propensity score to treatment groups
# treatment group variable: rate.drug.1st
# load twang library
library(twang)
# use mnps function 
afib.mnps.ate  = mnps(rate.drug.1st ~ 
                        age + gender + first.icu.unit + ethnicity.simplified +
                        sofa.score + MAP.before.1st.drug + temp.F + spo2 + hb + 
                        wbc + plt + hct + na + k + cl + bun + cre + hco3 + glu + 
                        asthma.icd9 + copd.icd9 + chf.icd9 + ckd.icd9 + liver.dz.elix + 
                        dm.elix + valvular.dz.icd9 + malignancy.elix + afib.ds.pmh,
                      data = dataset,
                      estimand = "ATE",
                      verbose = FALSE,
                      stop.method = c('es.mean','es.max','ks.mean','ks.max'),
                      n.trees = 3500
)




# use mnps function 
afib.mnps.att  = mnps(rate.drug.1st ~ 
                        age + gender + first.icu.unit + ethnicity.simplified +
                        sofa.score + MAP.before.1st.drug + temp.F + spo2 + hb + 
                        wbc + plt + hct + na + k + cl + bun + cre + hco3 + glu + 
                        asthma.icd9 + copd.icd9 + chf.icd9 + ckd.icd9 + liver.dz.elix + 
                        dm.elix + valvular.dz.icd9 + malignancy.elix + afib.ds.pmh,
                      data = dataset,
                      estimand = "ATT",
                      treatATT = 'amiodarone',
                      verbose = FALSE,
                      stop.method = c('es.mean','es.max','ks.mean','ks.max'),
                      n.trees = 6000
)


### diagnostic plots for balances achieved by GBM generated propensity score

# evaluate iteration numbers for stop.method statistics
plot(afib.mnps.ate, plots=1)
# visualize propensity score distribution and overlapping
plot(afib.mnps.ate, plots=2, subset = 'ks.max')
# assessments of balance
plot(afib.mnps.ate, plots=3)
# pairwise assessments of balance
plot(afib.mnps.ate, plots=3, pairwiseMax=FALSE, figureRows=1)
# p-value rank for pretreatment variables
plot(afib.mnps.ate, plots=4, multiPage=True)


# tabular assessments of balance
afib.bal.table = bal.table(afib.mnps.ate, collapse.to = 'covariate', digits =4)
afib.bal.table2 = bal.table(afib.mnps.ate, digits =2)
afib.bal.table3 = bal.table(afib.mnps.ate, collapse.to = 'stop.method', digits =4)
write.csv(afib.bal.table,file='afib_bal_table1.csv')
write.csv(afib.bal.table2,file='afib_bal_table2.csv')
write.csv(afib.bal.table3,file='afib_bal_table3.csv')
summary(afib.mnps.ate)
summary(afib.mnps.ate$psList$amiodarone$gbm.obj)
summary(afib.mnps.ate$psList$diltiazem$gbm.obj)
summary(afib.mnps.ate$psList$metoprolol$gbm.obj)


###################################################
###################################################
###################################################
# Estimating treatment effects (outcomes)
# use survey library to do regression on the weights obtained by GBM

# primary outcome, weighted logistic regression, doubly robust
library(survey)
dataset$w = get.weights(afib.mnps.ate, stop.method = 'ks.max')
design1.mnps.ate = svydesign(ids=~1, weights=~w, data=dataset)
logi.outcome1.wted.dr = svyglm(need.2nd.agent 
                               ~ rate.drug.1st + 
                                 ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                 liver.dz.elix + plt, 
                               family=quasibinomial, 
                               design = design1.mnps.ate)

summary(logi.outcome1.wted.dr)
exp(cbind(OR=coef(logi.outcome1.wted.dr),confint(logi.outcome1.wted.dr)))


# 2nd outcome of RVR duration, weighted linear regression, doubly robust
dataset.sub2 = dataset[t(dataset$rate.drugs.num ==1),]
design.sub2.mnps.ate = svydesign(ids=~1, weights=~w, data=dataset.sub2)
linear.outcome2.wted.dr = svyglm(rvr.duration
                                 ~ rate.drug.1st + 
                                   ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                   liver.dz.elix + plt, 
                                 design = design.sub2.mnps.ate)
summary(linear.outcome2.wted.dr)



# 3rd outcome, weighted logistic regression, doubly robust
dataset.sub3 = dataset[t(dataset$need.2nd.agent.within4 ==0),]
design.sub3.mnps.ate = svydesign(ids=~1, weights=~w, data=dataset.sub3)
logi.outcome3.wted.dr = svyglm(controlled.within4
                               ~ rate.drug.1st+ 
                                 ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                 liver.dz.elix + plt, 
                               family=quasibinomial, 
                               design = design.sub3.mnps.ate)
summary(logi.outcome3.wted.dr)
exp(cbind(OR=coef(logi.outcome3.wted.dr),confint(logi.outcome3.wted.dr)))


# outcome 4: need a second drug within 4 hours
design4.mnps.ate = svydesign(ids=~1, weights=~w, data=dataset)
logi.outcome4.wted.dr = svyglm(need.2nd.agent.within4
                               ~ rate.drug.1st+ 
                                 ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                 liver.dz.elix + plt, 
                               family=quasibinomial, 
                               design = design4.mnps.ate)
summary(logi.outcome4.wted.dr)
exp(cbind(OR=coef(logi.outcome4.wted.dr),confint(logi.outcome4.wted.dr)))

# outcome 5: odds of increasing vasopressor

design5.mnps.ate = svydesign(ids=~1, weights=~w, data=dataset)
logi.outcome5.wted.dr = svyglm(increased.vaso
                               ~ rate.drug.1st+ 
                                 ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                 liver.dz.elix + plt, 
                               family=quasibinomial, 
                               design = design5.mnps.ate)
summary(logi.outcome5.wted.dr)
exp(cbind(OR=coef(logi.outcome5.wted.dr),confint(logi.outcome5.wted.dr)))


# outcome 6: mortality

design6.mnps.ate = svydesign(ids=~1, weights=~w, data=dataset)
logi.outcome6.wted.dr = svyglm(day.30.mortality
                               ~ rate.drug.1st+ 
                                 ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                 liver.dz.elix + plt, 
                               family=quasibinomial, 
                               design = design6.mnps.ate)
summary(logi.outcome6.wted.dr)
exp(cbind(OR=coef(logi.outcome6.wted.dr),confint(logi.outcome6.wted.dr)))




###################################################
###################################################
###################################################
##Use stablized weights to rerun all weighted regression analyses
#output propensity score raw data
dataset$ps_amiodarone = afib.mnps.ate$psList$amiodarone$ps[[1]]
dataset$ps_diltiazem = afib.mnps.ate$psList$diltiazem$ps[[1]]
dataset$ps_metoprolol = afib.mnps.ate$psList$metoprolol$ps[[1]]
#construct stablized weight from individual treatement gouop frequency and PS
p.amio = sum(dataset$rate.drug.1st=='amiodarone')/nrow(dataset)
p.dilt = sum(dataset$rate.drug.1st=='diltiazem')/nrow(dataset)
p.meto = sum(dataset$rate.drug.1st=='metoprolol')/nrow(dataset)
dataset$sw = ifelse(dataset$rate.drug.1st=='amiodarone', p.amio/dataset$ps_amiodarone ,
                    ifelse(dataset$rate.drug.1st=='diltiazem', p.dilt/dataset$ps_diltiazem ,
                           ifelse(dataset$rate.drug.1st=='metoprolol', p.meto/dataset$ps_metoprolol ,
                                  NA)))
library(survey)
design1.mnps.ate.sw = svydesign(ids=~1, weights=~sw, data=dataset)
logi.outcome1.swted.dr = svyglm(need.2nd.agent 
                                ~ rate.drug.1st + 
                                  ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                  liver.dz.elix + plt, 
                                family=quasibinomial, 
                                design = design1.mnps.ate.sw)

summary(logi.outcome1.swted.dr)
exp(cbind(OR=coef(logi.outcome1.swted.dr),confint(logi.outcome1.swted.dr)))


# sw--2nd outcome of RVR duration, weighted linear regression, doubly robust
dataset.sub2 = dataset[t(dataset$rate.drugs.num ==1),]
design.sub2.mnps.ate.sw = svydesign(ids=~1, weights=~sw, data=dataset.sub2)
linear.outcome2.swted.dr = svyglm(rvr.duration
                                  ~ rate.drug.1st + 
                                    ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                    liver.dz.elix + plt, 
                                  design = design.sub2.mnps.ate.sw)
summary(linear.outcome2.swted.dr)


# 3rd outcome, weighted logistic regression, doubly robust
dataset.sub3 = dataset[t(dataset$need.2nd.agent.within4 ==0),]
design.sub3.mnps.ate.sw = svydesign(ids=~1, weights=~sw, data=dataset.sub3)
logi.outcome3.swted.dr = svyglm(controlled.within4
                                ~ rate.drug.1st+ 
                                  ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                  liver.dz.elix + plt, 
                                family=quasibinomial, 
                                design = design.sub3.mnps.ate.sw)
summary(logi.outcome3.swted.dr)
exp(cbind(OR=coef(logi.outcome3.swted.dr),confint(logi.outcome3.swted.dr)))



# outcome 4: need a second drug within 4 hours
design4.mnps.ate.sw = svydesign(ids=~1, weights=~sw, data=dataset)
logi.outcome4.swted.dr = svyglm(need.2nd.agent.within4
                                ~ rate.drug.1st+ 
                                  ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                  liver.dz.elix + plt, 
                                family=quasibinomial, 
                                design = design4.mnps.ate.sw)
summary(logi.outcome4.swted.dr)
exp(cbind(OR=coef(logi.outcome4.swted.dr),confint(logi.outcome4.swted.dr)))



# outcome 5: odds of increasing vasopressor
design5.mnps.ate.sw = svydesign(ids=~1, weights=~sw, data=dataset)
logi.outcome5.swted.dr = svyglm(increased.vaso
                                ~ rate.drug.1st+ 
                                  ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                  liver.dz.elix + plt, 
                                family=quasibinomial, 
                                design = design5.mnps.ate.sw)
summary(logi.outcome5.swted.dr)
exp(cbind(OR=coef(logi.outcome5.swted.dr),confint(logi.outcome5.swted.dr)))



# outcome 6: mortality
design6.mnps.ate.sw = svydesign(ids=~1, weights=~sw, data=dataset)
logi.outcome6.swted.dr = svyglm(day.30.mortality
                                ~ rate.drug.1st+ 
                                  ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                  liver.dz.elix + plt, 
                                family=quasibinomial, 
                                design = design6.mnps.ate.sw)
summary(logi.outcome6.swted.dr)
exp(cbind(OR=coef(logi.outcome6.swted.dr),confint(logi.outcome6.swted.dr)))

###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
# --Sensitivity Analysis--****beta blockers****

# sw--primary outcome, weighted logistic regression, doubly robust
library(survey)

dataset.bb1 = dataset[t(dataset$bb.home ==1 & !is.na(dataset$bb.home)),]
design1.mnps.ate.sw.bb1 = svydesign(ids=~1, weights=~sw, data=dataset.bb1)
logi.outcome1.swted.dr.bb1 = svyglm(need.2nd.agent 
                                    ~ rate.drug.1st + 
                                      ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                      liver.dz.elix + plt, 
                                    family=quasibinomial, 
                                    design = design1.mnps.ate.sw.bb1)

summary(logi.outcome1.swted.dr.bb1)
exp(cbind(OR=coef(logi.outcome1.swted.dr.bb1),confint(logi.outcome1.swted.dr.bb1)))


# sw--2nd outcome of RVR duration, weighted linear regression, doubly robust
dataset.sub2.bb1 = dataset[t(dataset$rate.drugs.num ==1 & dataset$bb.home ==1 & !is.na(dataset$bb.home)),]
design.sub2.mnps.ate.sw.bb1 = svydesign(ids=~1, weights=~sw, data=dataset.sub2.bb1)
linear.outcome2.swted.dr.bb1 = svyglm(rvr.duration
                                      ~ rate.drug.1st + 
                                        ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                        liver.dz.elix + plt, 
                                      design = design.sub2.mnps.ate.sw.bb1)
summary(linear.outcome2.swted.dr.bb1)


# 3rd outcome, weighted logistic regression, doubly robust
dataset.sub3.bb1 = dataset[t(dataset$need.2nd.agent.within4 ==0 & dataset$bb.home ==1 & !is.na(dataset$bb.home)),]
design.sub3.mnps.ate.sw.bb1 = svydesign(ids=~1, weights=~sw, data=dataset.sub3.bb1)
logi.outcome3.swted.dr.bb1 = svyglm(controlled.within4
                                ~ rate.drug.1st+ 
                                  ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                  liver.dz.elix + plt, 
                                family=quasibinomial, 
                                design = design.sub3.mnps.ate.sw.bb1)
summary(logi.outcome3.swted.dr.bb1)
exp(cbind(OR=coef(logi.outcome3.swted.dr.bb1),confint(logi.outcome3.swted.dr.bb1)))



# outcome 4: need a second drug within 4 hours
design4.mnps.ate.sw.bb1 = svydesign(ids=~1, weights=~sw, data=dataset.bb1)
logi.outcome4.swted.dr.bb1 = svyglm(need.2nd.agent.within4
                                ~ rate.drug.1st+ 
                                  ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                  liver.dz.elix + plt, 
                                family=quasibinomial, 
                                design = design4.mnps.ate.sw.bb1)
summary(logi.outcome4.swted.dr.bb1)
exp(cbind(OR=coef(logi.outcome4.swted.dr.bb1),confint(logi.outcome4.swted.dr.bb1)))

# outcome 5: odds of increasing vasopressor
design5.mnps.ate.sw.bb1 = svydesign(ids=~1, weights=~sw, data=dataset.bb1)
logi.outcome5.swted.dr.bb1 = svyglm(increased.vaso
                                    ~ rate.drug.1st+ 
                                      ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                      liver.dz.elix + plt, 
                                    family=quasibinomial, 
                                    design = design5.mnps.ate.sw.bb1)
summary(logi.outcome5.swted.dr.bb1)
exp(cbind(OR=coef(logi.outcome5.swted.dr.bb1),confint(logi.outcome5.swted.dr.bb1)))

# outcome 6: mortality
design6.mnps.ate.sw.bb1 = svydesign(ids=~1, weights=~sw, data=dataset.bb1)
logi.outcome6.swted.dr.bb1 = svyglm(day.30.mortality
                                    ~ rate.drug.1st+ 
                                      ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                      liver.dz.elix + plt, 
                                    family=quasibinomial, 
                                    design = design6.mnps.ate.sw.bb1)
summary(logi.outcome6.swted.dr.bb1)
exp(cbind(OR=coef(logi.outcome6.swted.dr.bb1),confint(logi.outcome6.swted.dr.bb1)))

###################################################
###################################################
###################################################
###################################################
###################################################
###################################################
# --Sensitivity Analysis--****beta blockers****

# sw--primary outcome, weighted logistic regression, doubly robust
library(survey)

dataset.bb0 = dataset[t(dataset$bb.home ==0 & !is.na(dataset$bb.home)),]
design1.mnps.ate.sw.bb0 = svydesign(ids=~1, weights=~sw, data=dataset.bb0)
logi.outcome1.swted.dr.bb0 = svyglm(need.2nd.agent 
                                    ~ rate.drug.1st + 
                                      ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                      liver.dz.elix + plt, 
                                    family=quasibinomial, 
                                    design = design1.mnps.ate.sw.bb0)

summary(logi.outcome1.swted.dr.bb0)
exp(cbind(OR=coef(logi.outcome1.swted.dr.bb0),confint(logi.outcome1.swted.dr.bb0)))


# sw--2nd outcome of RVR duration, weighted linear regression, doubly robust
dataset.sub2.bb0 = dataset[t(dataset$rate.drugs.num ==1 & dataset$bb.home ==0 & !is.na(dataset$bb.home)),]
design.sub2.mnps.ate.sw.bb0 = svydesign(ids=~1, weights=~sw, data=dataset.sub2.bb0)
linear.outcome2.swted.dr.bb0 = svyglm(rvr.duration
                                      ~ rate.drug.1st + 
                                        ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                        liver.dz.elix + plt, 
                                      design = design.sub2.mnps.ate.sw.bb0)
summary(linear.outcome2.swted.dr.bb0)


# 3rd outcome, weighted logistic regression, doubly robust
dataset.sub3.bb0 = dataset[t(dataset$need.2nd.agent.within4 ==0 & dataset$bb.home ==0 & !is.na(dataset$bb.home)),]
design.sub3.mnps.ate.sw.bb0 = svydesign(ids=~1, weights=~sw, data=dataset.sub3.bb0)
logi.outcome3.swted.dr.bb0 = svyglm(controlled.within4
                                    ~ rate.drug.1st+ 
                                      ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                      liver.dz.elix + plt, 
                                    family=quasibinomial, 
                                    design = design.sub3.mnps.ate.sw.bb0)
summary(logi.outcome3.swted.dr.bb0)
exp(cbind(OR=coef(logi.outcome3.swted.dr.bb0),confint(logi.outcome3.swted.dr.bb0)))



# outcome 4: need a second drug within 4 hours
design4.mnps.ate.sw.bb0 = svydesign(ids=~1, weights=~sw, data=dataset.bb0)
logi.outcome4.swted.dr.bb0 = svyglm(need.2nd.agent.within4
                                    ~ rate.drug.1st+ 
                                      ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                      liver.dz.elix + plt, 
                                    family=quasibinomial, 
                                    design = design4.mnps.ate.sw.bb0)
summary(logi.outcome4.swted.dr.bb0)
exp(cbind(OR=coef(logi.outcome4.swted.dr.bb0),confint(logi.outcome4.swted.dr.bb0)))

# outcome 5: odds of increasing vasopressor
design5.mnps.ate.sw.bb0 = svydesign(ids=~1, weights=~sw, data=dataset.bb0)
logi.outcome5.swted.dr.bb0 = svyglm(increased.vaso
                                    ~ rate.drug.1st+ 
                                      ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                      liver.dz.elix + plt, 
                                    family=quasibinomial, 
                                    design = design5.mnps.ate.sw.bb0)
summary(logi.outcome5.swted.dr.bb0)
exp(cbind(OR=coef(logi.outcome5.swted.dr.bb0),confint(logi.outcome5.swted.dr.bb0)))


# outcome 6: mortality
design6.mnps.ate.sw.bb0 = svydesign(ids=~1, weights=~sw, data=dataset.bb0)
logi.outcome6.swted.dr.bb0 = svyglm(day.30.mortality
                                    ~ rate.drug.1st+ 
                                      ethnicity.simplified + first.icu.unit + valvular.dz.icd9 + sofa.score + 
                                      liver.dz.elix + plt, 
                                    family=quasibinomial, 
                                    design = design6.mnps.ate.sw.bb0)
summary(logi.outcome6.swted.dr.bb0)
exp(cbind(OR=coef(logi.outcome6.swted.dr.bb0),confint(logi.outcome6.swted.dr.bb0)))










