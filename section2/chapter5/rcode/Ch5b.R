## ----echo=FALSE----------------------------------------------------------
dat <- read.csv("full_cohort_data.csv")

## ----echo=FALSE,warning=FALSE,fig.cap="Scatterplot of PCO2 (x-axis) and TCO2 (y-axis) along with linear regression estimates from the quadratic model (co2.quad.lm) and linear only model (co2.lm).",fig.pos="",message=FALSE,results="hide"----
postscript("FigB1.eps")
plot(dat$pco2_first,dat$tco2_first,xlab="PCO2",ylab="TCO2",pch=19,xlim=c(0,175))
co2.lm <- lm(tco2_first ~ pco2_first,data=dat)
abline(co2.lm,col='red',lwd=2)
co2.quad.lm <- lm(tco2_first ~ pco2_first + I(pco2_first^2),data=dat)
abline(co2.quad.lm,col='blue',lwd=2)
dev.off()

## ----echo=FALSE,warning=FALSE,fig.cap="Scatterplot of PCO2 (x-axis) and TCO2 (y-axis) along with linear regression estimates from the quadratic model (co2.quad.lm) and linear only model (co2.lm).",fig.pos="",message=FALSE----
plot(dat$pco2_first,dat$tco2_first,xlab="PCO2",ylab="TCO2",pch=19,xlim=c(0,175))
co2.lm <- lm(tco2_first ~ pco2_first,data=dat)
abline(co2.lm,col='red',lwd=2)
co2.quad.lm <- lm(tco2_first ~ pco2_first + I(pco2_first^2),data=dat)
abline(co2.quad.lm,col='blue',lwd=2)
#grid.pred <- data.frame(pco2_first=seq.int(from=min(dat$pco2_first,na.rm=T),to=max(dat$pco2_first,na.rm=T)));
#preds <- predict(co2.lm,newdata=grid.pred,interval = "prediction")
#lines(grid.pred$pco2_first,preds[,2],lty=3)
#lines(grid.pred$pco2_first,preds[,3],lty=3)

## ----echo=TRUE,fig.show="hide",eval=TRUE---------------------------------
plot(dat$pco2_first,dat$tco2_first,xlab="PCO2",ylab="TCO2",pch=19,xlim=c(0,175))

## ----echo=TRUE,fig.show="hide",eval=TRUE---------------------------------
co2.lm <- lm(tco2_first ~ pco2_first,data=dat)

## ----echo=TRUE,fig.show="hide",eval=TRUE---------------------------------
summary(co2.lm)

## ----echo=TRUE,warning=FALSE---------------------------------------------
co2.quad.lm <- lm(tco2_first ~ pco2_first + I(pco2_first^2),data=dat)
summary(co2.quad.lm)$coef

## ----echo=TRUE,warning=FALSE,eval=FALSE----------------------------------
## abline(co2.lm,col='red')
## abline(co2.quad.lm,col='blue')

## ----echo=TRUE-----------------------------------------------------------
class(dat$gender_num)

## ----echo=TRUE-----------------------------------------------------------
dat$gender_num <- as.factor(dat$gender_num)

## ----echo=TRUE-----------------------------------------------------------
class(dat$gender_num)

## ----echo=TRUE-----------------------------------------------------------
co2.gender.lm <- lm(tco2_first ~ pco2_first + gender_num,data=dat)
summary(co2.gender.lm)$coef

## ----echo=TRUE,eval=FALSE,tidy=TRUE--------------------------------------
## plot(dat$pco2_first,dat$tco2_first, col=dat$gender_num, xlab="PCO2",ylab="TCO2", xlim=c(0,40), type="n", ylim=c(15,25))
## abline(a=c(coef(co2.gender.lm)[1]),b=coef(co2.gender.lm)[2])
## abline(a=coef(co2.gender.lm)[1]+coef(co2.gender.lm)[3],b=coef(co2.gender.lm)[2],col='red')

## ----echo=FALSE,fig.cap="Regression fits of PCO2 on TCO2 with gender (female: black; male: red; solid: no interaction; dotted: with interaction).  Note: both axes are cropped for illustration purposes.",message=FALSE,results="hide"----
postscript("FigB2.eps")
plot(dat$pco2_first,dat$tco2_first,col=dat$gender_num,xlab="PCO2",ylab="TCO2",xlim=c(0,40),type="n",ylim=c(15,25))
abline(a=c(coef(co2.gender.lm)[1]),b=coef(co2.gender.lm)[2])
abline(a=coef(co2.gender.lm)[1]+coef(co2.gender.lm)[3],b=coef(co2.gender.lm)[2],col='red')
co2.gender.interaction.lm <- lm(tco2_first ~ pco2_first*gender_num,data=dat)
abline(a=coef(co2.gender.interaction.lm)[1], b=coef(co2.gender.interaction.lm)[2],lty=3,lwd=2)
abline(a=coef(co2.gender.interaction.lm)[1] + coef(co2.gender.interaction.lm)[3], b=coef(co2.gender.interaction.lm)[2] + coef(co2.gender.interaction.lm)[4],col='red',lty=3,lwd=2)
legend(24,20,lty=c(1,1,3,3),lwd=c(1,1,2,2),col=c("black","red","black","red"),c("Female","Male","Female (Interaction Model)","Male (Interaction Model)"),cex=0.75)
dev.off()

## ----echo=FALSE,fig.cap="Regression fits of PCO2 on TCO2 with gender (female: black; male: red; solid: no interaction; dotted: with interaction).  Note: both axes are cropped for illustration purposes.",message=FALSE----
plot(dat$pco2_first,dat$tco2_first,col=dat$gender_num,xlab="PCO2",ylab="TCO2",xlim=c(0,40),type="n",ylim=c(15,25))
abline(a=c(coef(co2.gender.lm)[1]),b=coef(co2.gender.lm)[2])
abline(a=coef(co2.gender.lm)[1]+coef(co2.gender.lm)[3],b=coef(co2.gender.lm)[2],col='red')
co2.gender.interaction.lm <- lm(tco2_first ~ pco2_first*gender_num,data=dat)
abline(a=coef(co2.gender.interaction.lm)[1], b=coef(co2.gender.interaction.lm)[2],lty=3,lwd=2)
abline(a=coef(co2.gender.interaction.lm)[1] + coef(co2.gender.interaction.lm)[3], b=coef(co2.gender.interaction.lm)[2] + coef(co2.gender.interaction.lm)[4],col='red',lty=3,lwd=2)
legend(24,20,lty=c(1,1,3,3),lwd=c(1,1,2,2),col=c("black","red","black","red"),c("Female","Male","Female (Interaction Model)","Male (Interaction Model)"),cex=0.75)

## ----echo=TRUE-----------------------------------------------------------
co2.gender.interaction.lm <- lm(tco2_first ~ pco2_first*gender_num,data=dat)
summary(co2.gender.interaction.lm)$coef

## ----echo=TRUE, eval=FALSE,tidy=TRUE-------------------------------------
## abline(a=coef(co2.gender.interaction.lm)[1], b=coef(co2.gender.interaction.lm)[2],lty=3,lwd=2)
## abline(a=coef(co2.gender.interaction.lm)[1] + coef(co2.gender.interaction.lm)[3], b=coef(co2.gender.interaction.lm)[2] + coef(co2.gender.interaction.lm)[4],col='red',lty=3,lwd=2)
## legend(24,20, lty=c(1,1,3,3), lwd=c(1,1,2,2), col=c("black","red","black","red"), c("Female","Male","Female (Interaction Model)","Male (Interaction Model)") )

## ----echo=TRUE-----------------------------------------------------------
anova(co2.lm,co2.gender.interaction.lm)


## ----echo=TRUE,fig.show="hide",eval=TRUE---------------------------------
confint(co2.lm)

## ----echo=TRUE,eval=TRUE-------------------------------------------------
grid.pred <- data.frame(pco2_first=seq.int(from=min(dat$pco2_first,na.rm=T),
                                           to=max(dat$pco2_first,na.rm=T)));


## ----echo=TRUE-----------------------------------------------------------
preds <- predict(co2.lm,newdata=grid.pred,interval = "prediction")
preds[1:2,]

## ----echo=FALSE,eval=TRUE, fig.cap="Scatterplot of PCO2 (x-axis) and TCO2 (y-axis) along with linear regression estimates from the linear only model (co2.lm).  The dotted line represents 95% prediction intervals for the model.",message=FALSE,results="hide"----
postscript("FigB3.eps")
plot(dat$pco2_first,dat$tco2_first,xlab="PCO2",ylab="TCO2",pch=19,xlim=c(0,175))
co2.lm <- lm(tco2_first ~ pco2_first,data=dat)
abline(co2.lm,col='red',lwd=2)
lines(grid.pred$pco2_first,preds[,2],lty=3)
lines(grid.pred$pco2_first,preds[,3],lty=3)
dev.off()

## ----echo=TRUE,eval=TRUE, fig.cap="Scatterplot of PCO2 (x-axis) and TCO2 (y-axis) along with linear regression estimates from the linear only model (co2.lm).  The dotted line represents 95% prediction intervals for the model.",message=FALSE----
plot(dat$pco2_first,dat$tco2_first,xlab="PCO2",ylab="TCO2",pch=19,xlim=c(0,175))
co2.lm <- lm(tco2_first ~ pco2_first,data=dat)
abline(co2.lm,col='red',lwd=2)
lines(grid.pred$pco2_first,preds[,2],lty=3)
lines(grid.pred$pco2_first,preds[,3],lty=3)

