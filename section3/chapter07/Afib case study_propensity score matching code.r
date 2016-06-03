library(rJava)

cpath <<- "/Users/jeremy/Dropbox/Eclipse Workspace/DoPE Pharmacoepi Toolbox/jar/pharmacoepi.jar"

.jinit(classpath=cpath, parameters=c("-Xmx1gm"), force.init = TRUE);


# create sample patient data
N <- 250000
id <- as.character(1:N)
exposure <- rbinom(N, 1, 0.5)
ps <- runif(N, 0, 1)

cohort <- data.frame(id, exposure, ps)

m <- .jnull("org.drugepi.match.Match");

# Instantiate match object
m <- .jnew("org.drugepi.match.Match");

print(sprintf("Match version %s", m$version))

.jcall(m, "V", "initMatch", "nn", "2");
.jfield(m, "matchRatio") <- as.integer(1);
.jfield(m, "fixedRatio") <- as.integer(1);
.jfield(m, "parallelMatchingMode") <- as.integer(1);

# not all options will be used in all runs, but set them anyway	
.jfield(m, "caliper") <- as.double(0.05)
.jfield(m, "startDigit") <- as.integer(5)
.jfield(m, "endDigit") <- as.integer(1)

# treatment group is group 1
.jcall(m, "V", "addMatchGroup", "1");

# referent group is group 0
.jcall(m, "V", "addMatchGroup", "0");

.jfield(m, "outfilePath") <- "/tmp/out.txt"
	
match_header <- paste(names(cohort), collapse="\t")
match_data <- paste(paste(cohort[,1], cohort[,2], cohort[,3], sep="\t"), 
					collapse="\n")
	
.jcall(m, "V", "addPatientsFromBuffer", paste(match_header, match_data, sep="\n"))

tryCatch( .jcall(m, "V", "run"), 
	NumberFormatException = function(e) {
		e$jobj$printStackTrace() 
	}
);

matches <- read.table("/tmp/out.txt", header=TRUE, sep="\t");
matched_cohort <- merge(matches, cohort, by.x="pat_id", by.y=names(cohort)[1], all=FALSE)

m <- .jnull("Object")


#### 
# EXPERIMENTAL
####

match_results <- .jcall(m, "S", "getMatchOutputData");

# get the lines of data
r <- unlist(strsplit(match_results, "\n"))
# split into a list of field vectors
d <- strsplit(r, split="\t")
# remove the header
d <- d[2:length(d)]

# create a data frame of matches
matches <- data.frame(
			set_num = sapply(d, function(x) {x[1]}),
			pat_id = sapply(d, function(x) {x[2]}),
			stringsAsFactors = FALSE
)

# strip quotes from the patient ID
matches$pat_id <- gsub("\"", "", matches$pat_id)

# merge into a single matched cohort, deleting any patients who didn't match
matched_cohort <- merge(matches, cohort, by.x="pat_id", by.y=names(cohort)[1], all=FALSE)
matched_cohort = matched_cohort[order(matched_cohort$set_num), ]
#matched_cohort
