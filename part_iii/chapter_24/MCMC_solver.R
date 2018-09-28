# Adapted from the MCMC_solver.m code to R by: Sanya Aggarwal

# Labels for the different states in the state space
vbl<-c("I","E","D")

# The transition matrix for the control group
tpm_c<-matrix(c(0.878,0.1,0.022,0.01,0.978,0.012,0,0,1),nrow=3,byrow=T,dimnames=list(vbl,vbl))

# The transition matrix for the intervention group
tpm_int<-matrix(c(0.862,0.12,0.018,0.0088,0.982,0.0092,0,0,1),nrow=3,byrow=T,dimnames=list(vbl,vbl)) 


days <- 29
samps<-1e4  #10000 samples simulated

set.seed(12345)

sampler <- function(tpm,vbl.=vbl) {  
  S <- rep(NA,days)
  p_int <- c(0.5,0.5,0)  ## the initial probability vector.  Starts off with 50/50 intubated/extubated.
  S[1] <- sample(vbl.,size=1,p_int,replace=TRUE)
  for(i in 2:days) {
    S[i] <- sample(vbl.,size=1,tpm[S[i-1],],replace=TRUE)
    
  }
  return(S)
}
rec <- sapply(1:samps, function(x) { return(sampler(tpm_c)) })  ## recording states.
z<-colSums(rec=="E")   ## total ventilator free days (extubated) for each simulated sample.



rec <- sapply(1:samps, function(x) { return(sampler(tpm_int)) })
y<-colSums(rec=="E") 


require(ggplot2)  ## using ggplot to plot ventilator free days for intervention and control group.

dat <- data.frame(group=c(rep("control",samps),rep("intervention",samps)),vfds = c(z,y))
ggplot(dat,aes(as.factor(vfds),fill=group)) + geom_bar(position=position_dodge2()) + xlab("Days") + ylab("Count") + ggtitle("Fig. a: Ventilator-free days for 10,000 samples, \nfor the intervention and control group")

g<-sapply(data,mean)  #mean: both groups.
h<-sapply(data,median) #median : both groups.
matrix(c(g,h),nrow=2,byrow=T,dimnames=list(c("mean","median"),c("   Intervention group","  Control group")))   ## matrix of mean and median of intervention and control group.
