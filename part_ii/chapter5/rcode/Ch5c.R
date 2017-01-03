## ----echo=FALSE----------------------------------------------------------
dat <- read.csv("full_cohort_data.csv")

## ----echo=TRUE-----------------------------------------------------------
dat$age.cat <- as.factor(ifelse(dat$age<=55, "<=55",">55"))
table(dat$age.cat)

## ----echo=TRUE-----------------------------------------------------------
table(dat$age.cat,dat$day_28_flg)

## ----echo=TRUE-----------------------------------------------------------
deathbyservice <- table(dat$service_unit,dat$day_28_flg)
deathbyservice

## ----echo=TRUE-----------------------------------------------------------
dbys.proptable <- prop.table(deathbyservice,1)
dbys.proptable

## ----echo=TRUE-----------------------------------------------------------
dbys.proptable[,"1"]/dbys.proptable[,"0"]

## ----echo=TRUE-----------------------------------------------------------
age.glm <- glm(day_28_flg ~ age.cat,data=dat,family="binomial")
summary(age.glm)

## ----echo=TRUE-----------------------------------------------------------
ageunit.glm <- glm(day_28_flg ~ age.cat + service_unit,data=dat,family="binomial")
summary(ageunit.glm)$coef

## ----echo=TRUE-----------------------------------------------------------
agects.glm <- glm(day_28_flg ~ age,data=dat,family="binomial")
summary(agects.glm)$coef

## ----echo=FALSE,message=FALSE,warning=FALSE,fig.cap="Plot of log-odds of mortality for each of the five age and temperature groups.  Error bars represent 95% confidence intervals for the log odds",results="hide"----
library(Hmisc); library(grid); library(gridExtra)
postscript("FigC1.eps")
#tmp <- prop.table(table(cut2(dat$age,g=5), dat$day_28_flg),1)
tmp.glm <- glm(day_28_flg ~ cut2(age,g=5),data=dat,family="binomial")
tmp <- tmp.glm$coef
tmp <- tmp[1] + c(0,tmp[2:5])
names(tmp) <- levels(cut2(dat$age,g=5))
library(ggplot2)
se <- sqrt(diag(summary(tmp.glm)$cov.unscaled) + c(0,diag(summary(tmp.glm)$cov.unscaled)[-1]) + 2*c(0,summary(tmp.glm)$cov.unscaled[1,2:5]))
limits <- aes(ymax = tmp + se, ymin=tmp - se)

plotage <- qplot(names(tmp),tmp) + xlab("Age Group") + ylab("Log Odds of 28 Day Mortality") + geom_errorbar(limits, width=0.12) + theme(axis.text.x = element_text(colour="grey20",size=6,angle=0,hjust=.5,vjust=.5,face="plain"))
tmp2.glm <- glm(day_28_flg ~ cut2(temp_1st,g=5),data=dat,family="binomial")
tmp2 <- tmp2.glm$coef
tmp2 <- tmp2[1] + c(0,tmp2[2:5])
names(tmp2) <- levels(cut2(dat$temp_1st,g=5))
library(ggplot2)
se <- sqrt(diag(summary(tmp2.glm)$cov.unscaled) + c(0,diag(summary(tmp2.glm)$cov.unscaled)[-1]) + 2*c(0,summary(tmp2.glm)$cov.unscaled[1,2:5]))
limits <- aes(ymax = tmp2 + se, ymin=tmp2 - se)
plottemp <- qplot(names(tmp2),tmp2) + xlab("Temperature Group") + ylab("Log Odds of 28 Day Mortality") + geom_errorbar(limits, width=0.12) + theme(axis.text.x = element_text(colour="grey20",size=6,angle=0,hjust=.5,vjust=.5,face="plain"))
grid.arrange(plotage, plottemp, nrow=1, ncol=2)
dev.off()


## ----echo=FALSE,message=FALSE,warning=FALSE,fig.cap="Plot of log-odds of mortality for each of the five age and temperature groups.  Error bars represent 95% confidence intervals for the log odds"----
tmp.glm <- glm(day_28_flg ~ cut2(age,g=5),data=dat,family="binomial")
tmp <- tmp.glm$coef
tmp <- tmp[1] + c(0,tmp[2:5])
names(tmp) <- levels(cut2(dat$age,g=5))
library(ggplot2)
se <- sqrt(diag(summary(tmp.glm)$cov.unscaled) + c(0,diag(summary(tmp.glm)$cov.unscaled)[-1]) + 2*c(0,summary(tmp.glm)$cov.unscaled[1,2:5]))
limits <- aes(ymax = tmp + se, ymin=tmp - se)

plotage <- qplot(names(tmp),tmp) + xlab("Age Group") + ylab("Log Odds of 28 Day Mortality") + geom_errorbar(limits, width=0.12) + theme(axis.text.x = element_text(colour="grey20",size=6,angle=0,hjust=.5,vjust=.5,face="plain"))
tmp2.glm <- glm(day_28_flg ~ cut2(temp_1st,g=5),data=dat,family="binomial")
tmp2 <- tmp2.glm$coef
tmp2 <- tmp2[1] + c(0,tmp2[2:5])
names(tmp2) <- levels(cut2(dat$temp_1st,g=5))
library(ggplot2)
se <- sqrt(diag(summary(tmp2.glm)$cov.unscaled) + c(0,diag(summary(tmp2.glm)$cov.unscaled)[-1]) + 2*c(0,summary(tmp2.glm)$cov.unscaled[1,2:5]))
limits <- aes(ymax = tmp2 + se, ymin=tmp2 - se)
plottemp <- qplot(names(tmp2),tmp2) + xlab("Temperature Group") + ylab("Log Odds of 28 Day Mortality") + geom_errorbar(limits, width=0.12) + theme(axis.text.x = element_text(colour="grey20",size=6,angle=0,hjust=.5,vjust=.5,face="plain"))
grid.arrange(plotage, plottemp, nrow=1, ncol=2)

## ----echo=TRUE-----------------------------------------------------------
anova(age.glm,ageunit.glm,test="Chisq")

## ----echo=TRUE,message=FALSE---------------------------------------------
ageunit.glm$coef
confint(ageunit.glm)

## ----echo=TRUE,message=FALSE---------------------------------------------
exp(ageunit.glm$coef[-1])
exp(confint(ageunit.glm)[-1,])

## ----echo=TRUE-----------------------------------------------------------
newdat <- expand.grid(age.cat=c("<=55",">55"),service_unit=c("FICU","MICU","SICU"))
newdat$pred <- predict(ageunit.glm,newdata=newdat,type="response")
newdat

