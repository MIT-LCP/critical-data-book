Require(SuperLearner)

SL.library <-c("SL.glmnet","SL.glm","SL.stepAIC","SL.nnet","SL.polymars","SL.randomForest","SL.gam","SL.ipredbagg","SL.gbm","SL.rpartPrune")

# RUN Super Learner only with predictors included in the SAPS = X

Y=outcome

X=set of predictors

fitSL<-CV.SuperLearner(Y=Y, X=X, V=10, family = binomial(), SL.library=SL.library, method = "method.NNLS", id = NULL, verbose = FALSE, cvControl=list(stratifyCV=TRUE,shuffle=TRUE,V=10))

predictSL<- fitSL$SL.predict

predictions <- cbind(fitSL$SL.predict,fitSL$library.predict)
labels <- fitSL$Y
folds <- fitSL$folds

pdf(file="FIT.pdf")
plot(fitSL,package="ggplot2",constant=qnorm(0.975),sort=TRUE) # CV risk estimation for each candidate and SL
dev.off()

result_AUC<-as.data.frame(matrix(data=NA,ncol=3,nrow=(length(SL.library)+1)))
for (i in 1:(length(SL.library)+1))
{
  result_AUC[i,]<-c(AUC_IC(i)$cvAUC,AUC_IC(i)$ci[1],AUC_IC(i)$ci[2])   
}

colnames(result_AUC)<-c("AUC","L-95%CI","U-95%CI")
rownames(result_AUC)<-c("Super Learner",SL.library)

save(result_AUC,file='resutlAUC.RData')
