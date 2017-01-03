## ----echo=FALSE,eval=TRUE------------------------------------------------
dat <- read.csv("full_cohort_data.csv")

## ----echo=TRUE,cache=TRUE,tidy=FALSE,eval=FALSE--------------------------
## url <- "http://physionet.org/physiobank/database/mimic2-iaccd/full_cohort_data.csv";
## dat <- read.csv(url)
## # Or download the csv file from:
## # http://physionet.org/physiobank/database/mimic2-iaccd/full_cohort_data.csv
## # Type: dat <- read.csv(file.choose())
## # And navigate to the file you downloaded (likely in your download directory)

## ----echo=TRUE-----------------------------------------------------------
names(dat)

