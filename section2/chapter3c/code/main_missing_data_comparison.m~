%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%
%      Comparison of the various imputation methods using logistic 
%      regressions in a 10-fold crossvalidation fashion
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%      The user needs to select the following variables:
%      
%      1. dataset    - it can be either 'IAC' or 'NON_IAC' 
%      2. perc       - the percenteges of missingness that are going to be 
%                      tested
%      3. type       - it can be univariate ('univar') or multivariate
%      ('multi') missingness
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% USER DEFINED VARIABLES
% Clear everything in the workspace
clearvars
close all

% Variables that need to be introduced by the user
dataset = 'IAC';
type = 'univar';
column2remove = 1; % position of the variable to remove in the case of univariate
% missingness


%% OTHER VARIABLES
% Variables already selected
kfolds=10; % number of folds in the crossvalidation
separate = 1; % separate the data by classes when applying the methods 
method = {'remove','mean','median','linear','knn','randlinear','MI-Cond',...
'MI-MVN'};

%% Loading the data, removing initial missing data and creating artificial
% missingness
load_data
% Percentages of missingness
perc = [0.05,0.10,0.20,0.30,0.40,0.50,0.60,0.70,0.80,0.90];
rng(163)
% creates the datasets with missigness
[DATA_in_M,orig_data_in] = create_missingness_datasets(data_in,perc,column2remove,type);

%% Comparisons
rng(163)
indices = crossvalind('Kfold',data_out,kfolds);
% Compute the kfold crossvalidation with logistic regressions
% for each method with each percentage
[AUC,Sen,Spec,kappa]  = method_comparison(DATA_in_M,orig_data_in,...
    data_out,separate,constraint,perc,method,kfolds,type,indices);

% Computing the logistic regression for the multiple imputation results
% that were computed in R
auxl= length(AUC(1,:,1)); % number of methods already used
[AUC(:,auxl+1:auxl+2,:), Sen(:,auxl+1:auxl+2,:), Spec(:,auxl+1:auxl+2,:), ...
kappa(:,auxl+1:auxl+2,:)] = crossvalidation_R_data(dataset,orig_data_in,...
data_out,perc,kfolds,type,indices);

% Computing the logistic regression with the complete data
rng(163)
[FAUC, FSen, FSpec, Fkappa]...
    =logistic_cross_classic(orig_data_in(:,1:end),orig_data_in(:,1:end),data_out,indices);

% Save important data in a file
name_saved_file = strcat(dataset,'_',type,'.mat');
save(name_saved_file,'dataset','type','perc','AUC','Sen','Spec','kappa',...
    'DATA_in_M','FAUC','FSen','FSpec','Fkappa','method')        
