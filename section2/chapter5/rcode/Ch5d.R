## ----echo=FALSE----------------------------------------------------------
dat <- read.csv("full_cohort_data.csv")

## ----echo=TRUE-----------------------------------------------------------
library(survival);

## ----echo=TRUE-----------------------------------------------------------
dat$mort_day_censored[dat$censor_flg==1] <- 731;

## ----echo=TRUE-----------------------------------------------------------
datSurv <- Surv(dat$mort_day_censored,dat$censor_flg==0)
datSurv[101:105]

## ----echo=FALSE,fig.cap="Kaplan-Meier plot of the estimated survivor function stratified by gender",results="hide"----
gender.surv <- survfit(datSurv~gender_num,data=dat)
postscript("FigD1.eps")
plot(gender.surv,col=1:2,conf.int = TRUE,xlab="Days",ylab="Proportion Who Survived")
legend(400,0.4,col=c("black","red"),lty=1,c("Women","Men"))
dev.off()

## ----echo=TRUE,fig.cap="Kaplan-Meier plot of the estimated survivor function stratified by gender"----
plot(gender.surv,col=1:2,conf.int = TRUE,xlab="Days",ylab="Proportion Who Survived")
legend(400,0.4,col=c("black","red"),lty=1,c("Women","Men"))

## ----echo=FALSE,fig.cap="Kaplan-Meier plot of the estimated survivor function stratified by service unit",results="hide"----
unit.surv <- survfit(datSurv~service_unit,data=dat)
postscript("FigD2.eps")
plot(unit.surv,col=1:3,conf.int = FALSE,xlab="Days",ylab="Proportion Who Survived")
legend(400,0.4,col=c("black","red","green"),lty=1,c("FICU","MICU","SICU"))
dev.off()


## ----echo=TRUE,fig.cap="Kaplan-Meier plot of the estimated survivor function stratified by service unit"----
plot(unit.surv,col=1:3,conf.int = FALSE,xlab="Days",ylab="Proportion Who Survived")
legend(400,0.4,col=c("black","red","green"),lty=1,c("FICU","MICU","SICU"))

## ----echo=TRUE-----------------------------------------------------------
gender.coxph <- coxph(datSurv ~ gender_num,data=dat)
summary(gender.coxph)

## ----echo=TRUE-----------------------------------------------------------
genderafib.coxph <- coxph(datSurv~gender_num + afib_flg,data=dat)
summary(genderafib.coxph)$coef

## ----echo=TRUE-----------------------------------------------------------
anova(gender.coxph,genderafib.coxph)

