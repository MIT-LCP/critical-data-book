## ----echo=FALSE----------------------------------------------------------
dat <- read.csv("full_cohort_data.csv")

## ----echo=TRUE, eval=FALSE-----------------------------------------------
## install.package("devtools")
## library(devtools)

## ----echo=TRUE, eval=FALSE-----------------------------------------------
## install_github("jraffa/MIMICbook")
## library(MIMICbook);

## ----echo=FALSE,eval=TRUE------------------------------------------------
rm(dat);
dat <- read.csv("full_cohort_data.csv")

## ----echo=TRUE,tidy=TRUE, eval=FALSE-------------------------------------
## rm(dat);
## dat <- read.csv(url)

## ----echo=TRUE,tidy=TRUE-------------------------------------------------
# Identify which columns are binary coded
bincols <- colMeans((dat==1 | dat==0),na.rm=T)==1
for(i in 1:length(bincols)){  #Turn the binary columns into a factor
  if(bincols[i]) {
    dat[[i]] <- as.factor(dat[[i]]);
  }
}

## ----echo=FALSE,tidy=TRUE------------------------------------------------
produce.table1 <- function(x,labels=NULL) {  # May throw this in an R package on github so I can omit from the book.
  out <- matrix(NA,nr=length(x[1,]))
  rrn <- NULL;
  for(i in 1:length(x[1,])) {
    if(is.factor(x[,i])) {
          if(is.null(labels[i])) {
            tmp<- table(x[,i])
            most.prev.name <- names(which.max(tmp))
          } else  {
            if(is.na(labels[i])) {
              tmp<- table(x[,i])
              most.prev.name <- names(which.max(tmp))
            } else {
              most.prev.name <- labels[i];
            }
          }
          if(sum(is.na(x[,i]))==0) {
          out[i,] <- paste0(sum(x[,i]==most.prev.name,na.rm=T), " (", round(100*mean(x[,i]==most.prev.name,na.rm=T),1), "%)")
          } else {
            out[i,] <- paste0(sum(x[,i]==most.prev.name,na.rm=T), " (", round(100*mean(x[,i]==most.prev.name,na.rm=T),1), "%)", "  [Missing: ", sum(is.na(x[,i])), "]")

          }
          rrn[i] <- paste0(names(x)[i], "==", most.prev.name);
          labels[i] <- most.prev.name;

    } else {
      if(sum(is.na(x[,i]))==0) {
        out[i,] <- paste0(round(mean(x[,i],na.rm=T),1),  " (" , round(sd(x[,i],na.rm=T),1), ")")
      } else {
          out[i,] <- paste0(round(mean(x[,i],na.rm=T),1),  " (" , round(sd(x[,i],na.rm=T),1), ")", "  [Missing: ", sum(is.na(x[,i])), "]")
      }
      rrn[i] <- paste0(names(x)[i]);
    }

  }
  rownames(out) <- rrn;
  colnames(out) <- "Average (SD), or N (%)";
  attr(out,"labels") <- labels;
  return(out)
}

## ----echo=TRUE,eval=FALSE------------------------------------------------
## tab1 <- produce.table1(dat);
## library(knitr);
## kable(tab1,caption = "Overall patient characteristics")
## 

## ----echo=FALSE,eval=TRUE------------------------------------------------
tab1 <- produce.table1(dat);
library(knitr);
kable(tab1,caption = "Overall patient characteristics",format="latex")


## ----echo=TRUE,tidy=TRUE,eval=FALSE--------------------------------------
## datby.aline <- split(dat,dat$aline_flg)
## reftable <- produce.table1(datby.aline[[1]]);
## tab2 <- cbind(produce.table1(datby.aline[[1]],labels=attr(reftable,"labels")),
##               produce.table1(datby.aline[[2]],labels=attr(reftable,"labels")))
## colnames(tab2) <- paste0("Average (SD), or N (%)",c(", No-IAC", ", IAC"))
## kable(tab2, caption="Patient characteristics stratified by IAC administration")

## ----echo=FALSE,eval=TRUE------------------------------------------------
datby.aline <- split(dat,dat$aline_flg)
reftable <- produce.table1(datby.aline[[1]]);
tab2 <- cbind(produce.table1(datby.aline[[1]],labels=attr(reftable,"labels")),
              produce.table1(datby.aline[[2]],labels=attr(reftable,"labels")))
colnames(tab2) <- paste0("Average (SD), or N (%)",c(", No-IAC", ", IAC"))
kable(tab2, caption="Patient characteristics stratified by IAC administration",format="latex")

## ----echo=TRUE,tidy=TRUE,eval=FALSE--------------------------------------
## datby.28daymort <- split(dat,dat$day_28_flg)
## reftablemort <- produce.table1(datby.28daymort[[1]]);
## tab3 <- cbind(produce.table1(datby.28daymort[[1]],labels=attr(reftablemort,"labels")),
##               produce.table1(datby.28daymort[[2]],labels=attr(reftablemort,"labels")))
## colnames(tab3) <- paste0("Average (SD), or N (%)",c(",Alive", ",Dead"))
## kable(tab3,caption="Patient characteristics stratified by 28 day mortality")

## ----echo=FALSE,eval=TRUE------------------------------------------------
datby.28daymort <- split(dat,dat$day_28_flg)
reftablemort <- produce.table1(datby.28daymort[[1]]);
tab3 <- cbind(produce.table1(datby.28daymort[[1]],labels=attr(reftablemort,"labels")),
              produce.table1(datby.28daymort[[2]],labels=attr(reftablemort,"labels")))
colnames(tab3) <- paste0("Average (SD), or N (%)",c(", Alive", ", Dead"))
kable(tab3,caption="Patient characteristics stratified by 28 day mortality",format="latex")

## ----echo=TRUE,message=FALSE---------------------------------------------
uvr.glm <- glm(day_28_flg ~ aline_flg,data=dat,family="binomial")
exp(uvr.glm$coef[-1])
exp(confint(uvr.glm)[-1,]);

## ----echo=FALSE----------------------------------------------------------
summary(uvr.glm)$coef

## ----echo=FALSE,message=FALSE,warning=FALSE,fig.cap="Plot of log-odds of mortality for each of the SOFA groups.  Error bars represent 95% confidence intervals for the log odds",results="hide"----
library(Hmisc)
postscript("FigE1.eps")
#tmp <- prop.table(table(cut2(dat$age,g=5), dat$day_28_flg),1)
tmp.glm <- glm(day_28_flg ~ cut2(sofa_first,c(1:14)),data=dat,family="binomial")
tmp <- tmp.glm$coef
tmp <- tmp[1] + c(0,tmp[2:15])
names(tmp) <- levels(cut2(dat$sofa_first,c(1:14)));
names(tmp)[15] <- "14-17"
#names(tmp)[2:3] <-  c("[5]", "[6]")
library(ggplot2)
se <- sqrt(diag(summary(tmp.glm)$cov.unscaled) + c(0,diag(summary(tmp.glm)$cov.unscaled)[-1]) + 2*c(0,summary(tmp.glm)$cov.unscaled[1,2:15]))
limits <- aes(ymax = tmp + se, ymin=tmp - se)
qplot((names(tmp)),tmp) + xlab("SOFA Group") + ylab("Log Odds of 28 Day Mortality") + geom_errorbar(limits, width=0.12) + scale_x_discrete(limits=names(tmp))
dev.off()

## ----echo=FALSE,message=FALSE,warning=FALSE,fig.cap="Plot of log-odds of mortality for each of the SOFA groups.  Error bars represent 95% confidence intervals for the log odds"----
#tmp <- prop.table(table(cut2(dat$age,g=5), dat$day_28_flg),1)
tmp.glm <- glm(day_28_flg ~ cut2(sofa_first,c(1:14)),data=dat,family="binomial")
tmp <- tmp.glm$coef
tmp <- tmp[1] + c(0,tmp[2:15])
names(tmp) <- levels(cut2(dat$sofa_first,c(1:14)));
names(tmp)[15] <- "14-17"
#names(tmp)[2:3] <-  c("[5]", "[6]")
library(ggplot2)
se <- sqrt(diag(summary(tmp.glm)$cov.unscaled) + c(0,diag(summary(tmp.glm)$cov.unscaled)[-1]) + 2*c(0,summary(tmp.glm)$cov.unscaled[1,2:15]))
limits <- aes(ymax = tmp + se, ymin=tmp - se)
qplot((names(tmp)),tmp) + xlab("SOFA Group") + ylab("Log Odds of 28 Day Mortality") + geom_errorbar(limits, width=0.12) + scale_x_discrete(limits=names(tmp))

## ----echo=TRUE-----------------------------------------------------------
library(Hmisc)
table(cut2(dat$sofa_first,g=5))

## ----echo=TRUE,tidy=TRUE-------------------------------------------------
mva.full.glm <- glm(day_28_flg ~ aline_flg + age + gender_num + cut2(sapsi_first,g=5) + cut2(sofa_first,g=5) + service_unit + chf_flg + afib_flg + renal_flg + liver_flg + copd_flg + cad_flg + stroke_flg + mal_flg + resp_flg,data=dat,family="binomial")
summary(mva.full.glm)

## ----echo=TRUE-----------------------------------------------------------
drop1(mva.full.glm,test="Chisq")

## ----echo=TRUE-----------------------------------------------------------
mva.tmp.glm <- update(mva.full.glm, .~. - cad_flg)

## ----echo=TRUE-----------------------------------------------------------
drop1(mva.tmp.glm,test="Chisq")

## ----echo=TRUE-----------------------------------------------------------
mva.tmp.glm2 <- update(mva.tmp.glm, .~. - chf_flg)
drop1(mva.tmp.glm2,test="Chisq")

## ----echo=FALSE,results="hide"-------------------------------------------
mva.tmp.glm3 <- update(mva.tmp.glm2, .~. - gender_num)
drop1(mva.tmp.glm3,test="Chisq")
mva.tmp.glm4 <- update(mva.tmp.glm3, .~. - copd_flg)
drop1(mva.tmp.glm4,test="Chisq")
mva.tmp.glm5 <- update(mva.tmp.glm4, .~. - liver_flg)
drop1(mva.tmp.glm5,test="Chisq")
mva.tmp.glm6 <- update(mva.tmp.glm5, .~. - cut2(sofa_first, g = 5))
drop1(mva.tmp.glm6,test="Chisq")
mva.tmp.glm7 <- update(mva.tmp.glm6, .~. - renal_flg)
drop1(mva.tmp.glm7,test="Chisq")
mva.tmp.glm8 <- update(mva.tmp.glm7, .~. - service_unit)
drop1(mva.tmp.glm8,test="Chisq")

## ----echo=TRUE-----------------------------------------------------------
drop1(mva.tmp.glm8,test="Chisq")

## ----echo=TRUE,message=FALSE,warning=FALSE-------------------------------
mva.final.glm <- mva.tmp.glm8;
summary(mva.final.glm)

## ----echo=FALSE,message=FALSE,warning=FALSE,eval=TRUE--------------------
library(sjPlot);
out <- sjt.glm(mva.final.glm,no.output=TRUE,emph.p=FALSE)
final.table <- out$data[-1,-6];
colnames(final.table) <- c("Covariate", "AOR", "Lower 95% CI", "Upper 95% CI", "p-value")
final.table[,1] <- c("IAC", "Age (per year increase)", "SAPSI [12-14)* (relative to SAPSI<12)", "SAPSI [14-16)*", "SAPSI [16-19)*", "SAPSI [19-32]*", "Atrial Fibrillation", "Stroke", "Malignancy", "Non-COPD Respiratory disease ")
final.table[,5] <- gsub("&lt;", "<",final.table[,5])
kable(final.table,caption="Multivariable logistic regression analysis for mortality at 28 days outcome (Final Model)",format="latex");

