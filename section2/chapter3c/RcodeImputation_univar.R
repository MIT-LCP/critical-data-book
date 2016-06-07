########################################################################################################
#
#
#
#                               UNIVARIATE
#
#
#
#
#########################################################################################################3
####################################################################################################
#
#
#  MICE package ( Multiple imputation based in iterative linear/logistic regressions)
#
#
####################################################################################################

# Code for multiple imputation with MICE package 
setwd("/home/hugo/Work/Textbook/Missing data chapter code/CSV")
install.packages("mice")
install.packages("Amelia")

###################################################################
library('mice')
method <- 'MICE_'
type <-'_univar'
folds = 1:10
perc = 1:10
p_nam=c('5','10','20','30','40','50','60','70','80','90')
f_nam=c('1','2','3','4','5','6','7','8','9','10')
M <-10
dset='IAC' 
print(paste0("Dataset: ", dset))
print("Missingness: univar")
for (i in perc){
  print(paste0("Percentage: ", p_nam[i]))
  print("Full dataset")
  filename1 <- paste0(dset,type,'_perc',p_nam[i],'_original','.csv')
  dataMiss <-read.csv(filename1);
  dataMI <- mice::mice(dataMiss, m = M, printFlag = F)
  tryCatch(
    {dataMI <- mice::mice(dataMiss, m = M, printFlag = F)
    dataPool <- mice::complete(dataMI, "long")  
    write.csv(dataPool, paste0(method,filename1))  
    }, error=function(e){print("ERROR : Could not perform imputation for this percentage of missingness, it will continue running \n")})
  for (j in folds){
    print(paste0("Fold: ", f_nam[j]))
    filename1 <- paste0(dset,type,'_perc',p_nam[i],'_Fold',f_nam[j],'.csv')
    dataMiss <-read.csv(filename1);
    tryCatch(
      {dataMI <- mice::mice(dataMiss, m = M, printFlag = F)
      dataPool <- mice::complete(dataMI, "long")  
      write.csv(dataPool, paste0(method,filename1))
      }, error=function(e){print("ERROR : Could not perform imputation for this percentage of missingness, it will continue running \n")})
  }
}

dset='NON_IAC'
print(paste0("Dataset: ", dset))
print("Missingness: univar")
for (i in perc){
  print(paste0("Percentage: ", p_nam[i]))
  print("Full dataset")
  filename1 <- paste0(dset,type,'_perc',p_nam[i],'_original','.csv')
  dataMiss <-read.csv(filename1);
  dataMI <- mice::mice(dataMiss, m = M, printFlag = F)
  tryCatch(
    {dataMI <- mice::mice(dataMiss, m = M, printFlag = F)
    dataPool <- mice::complete(dataMI, "long")  
    write.csv(dataPool, paste0(method,filename1))  
    }, error=function(e){print("ERROR : Could not perform imputation for this percentage of missingness, it will continue running \n")})
  for (j in folds){
    print(paste0("Fold: ", f_nam[j]))
    filename1 <- paste0(dset,type,'_perc',p_nam[i],'_Fold',f_nam[j],'.csv')
    dataMiss <-read.csv(filename1);
    tryCatch(
      {dataMI <- mice::mice(dataMiss, m = M, printFlag = F)
      dataPool <- mice::complete(dataMI, "long")  
      write.csv(dataPool, paste0(method,filename1))
      }, error=function(e){print("ERROR : Could not perform imputation for this percentage of missingness, it will continue running \n")})
  }
}

####################################################################################################
#
#
#               Amelia package (Multiple Imputation using Multivariate Normal Regression)
#
#
####################################################################################################


# Imutation with Amelia
library('Amelia')
method <- 'Amelia_'
type <-'_univar'
M <-10
folds = 1:10
perc = 1:10
p_nam=c('5','10','20','30','40','50','60','70','80','90')
f_nam=c('1','2','3','4','5','6','7','8','9','10')
dset='IAC'
print(paste0("Dataset: ", dset))
print("Missingness: univar")
for (i in perc){
  print(paste0("Percentage: ", p_nam[i]))
  print("Full dataset")
  filename1 <- paste0(dset,type,'_perc',p_nam[i],'_original','.csv')
  dataMiss <-read.csv(filename1);
  tryCatch(
    {  dataMI <- Amelia::amelia(dataMiss, m = M, p2s = 0)
    write.amelia(dataMI, separate = FALSE, paste0(method,filename1),extension = NULL, format = "csv",impvar = "imp", orig.data = FALSE)
    }, error=function(e){print("ERROR : Could not perform imputation for this percentage of missingness, it will continue running \n")})
  for (j in folds){
    print(paste0("Fold: ", f_nam[j]))
    filename1 <- paste0(dset,type,'_perc',p_nam[i],'_Fold',f_nam[j],'.csv')
    dataMiss <-read.csv(filename1);
    tryCatch(
      {dataMI <- Amelia::amelia(dataMiss, m = M, p2s = 0)
      write.amelia(dataMI, separate = FALSE, paste0(method,filename1),extension = NULL, format = "csv",impvar = "imp", orig.data = FALSE)
      }, error=function(e){print("ERROR : Could not perform imputation for this percentage of missingness, it will continue running \n")})
  }
}
library('Amelia')
method <- 'Amelia_'
M <-10
dset='NON_IAC'
print(paste0("Dataset: ", dset))
print("Missingness: univar")
for (i in perc){
  print(paste0("Percentage: ", p_nam[i]))
  print("Full dataset")
  filename1 <- paste0(dset,type,'_perc',p_nam[i],'_original','.csv')
  dataMiss <-read.csv(filename1);
  tryCatch(
    {  dataMI <- Amelia::amelia(dataMiss, m = M, p2s = 0)
    write.amelia(dataMI, separate = FALSE, paste0(method,filename1),extension = NULL, format = "csv",impvar = "imp", orig.data = FALSE)
    }, error=function(e){print("ERROR : Could not perform imputation for this percentage of missingness, it will continue running \n")})
  for (j in folds){
    print(paste0("Fold: ", f_nam[j]))
    filename1 <- paste0(dset,type,'_perc',p_nam[i],'_Fold',f_nam[j],'.csv')
    dataMiss <-read.csv(filename1);
    tryCatch(
      {dataMI <- Amelia::amelia(dataMiss, m = M, p2s = 0)
      write.amelia(dataMI, separate = FALSE, paste0(method,filename1),extension = NULL, format = "csv",impvar = "imp", orig.data = FALSE)
      }, error=function(e){print("ERROR : Could not perform imputation for this percentage of missingness, it will continue running \n")})
  }
}
