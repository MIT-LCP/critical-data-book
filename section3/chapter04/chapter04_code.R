Require(SuperLearner)

SL.library &lt;-

c(&quot;SL.glmnet&quot;,&quot;SL.glm&quot;,&quot;SL.stepAIC&quot;,&quot;SL.nnet&quot;,&quot;SL.polymars&quot;,&quot;SL.randomForest&quot;,&quot;SL.gam&quot;,&quot;

SL.ipredbagg&quot;,&quot;SL.gbm&quot;,&quot;SL.rpartPrune&quot;)

# RUN Super Learner only with predictors included in the SAPS = X

Y=outcome

X=set of predictors

fitSL&lt;-CV.SuperLearner(Y=Y, X=X, V=10, family = binomial(), SL.library=SL.library, method

= &quot;method.NNLS&quot;, id = NULL, verbose = FALSE,

cvControl=list(stratifyCV=TRUE,shuffle=TRUE,V=10))

predictSL&lt;- fitSL$SL.predict

predictions &lt;- cbind(fitSL$SL.predict,fitSL$library.predict)

labels &lt;- fitSL$Y

folds &lt;- fitSL$folds

pdf(file=&quot;FIT.pdf&quot;)

plot(fitSL,package=&quot;ggplot2&quot;,constant=qnorm(0.975),sort=TRUE) # CV risk estimation for

each candidate and SL

dev.off()

result_AUC&lt;-as.data.frame(matrix(data=NA,ncol=3,nrow=(length(SL.library)+1)))

for (i in 1:(length(SL.library)+1))

{

result_AUC[i,]&lt;-c(AUC_IC(i)$cvAUC,AUC_IC(i)$ci[1],AUC_IC(i)$ci[2])

}

colnames(result_AUC)&lt;-c(&quot;AUC&quot;,&quot;L-95%CI&quot;,&quot;U-95%CI&quot;)

rownames(result_AUC)&lt;-c(&quot;Super Learner&quot;,SL.library)

save(result_AUC,file=&#39;resutlAUC.RData&#39;)
