clearvars
close all
load aline
ALL_VARIABLES=alinecohortdatajune15.Properties.VariableNames;

%%%%%%%%%%%%%%%%%%%%%%%
%%% SELECT FEATURES %%%
%%%%%%%%%%%%%%%%%%%%%%%

DATA=alinecohortdatajune15(:,[10, 11, 17, 19, 50, 51, 52, 53, 54, 55, 56, 57, 58, 60, 71, 72, 73, 74, 75, 76, 77, 78, 79, 96, 97, 110]);

SELECTED_VARIABLES=DATA.Properties.VariableNames;

%% DEFINE LABELS USING ALINE_FLG

IAC=DATA(find(alinecohortdatajune15.ALINE_FLG==1),:);
NON_IAC=DATA(find(alinecohortdatajune15.ALINE_FLG==0),:);

IAC_out=alinecohortdatajune15(find(alinecohortdatajune15.ALINE_FLG==1),:);
NON_IAC_out=alinecohortdatajune15(find(alinecohortdatajune15.ALINE_FLG==0),:);

IAC_out=IAC_out.DAY_28_FLG;
NON_IAC_out=NON_IAC_out.DAY_28_FLG;
% Vector of the features that are integers (or binary)
vector_int_ft = [2:14,26];
max_ft = ones(1,26);
max_ft([1,3,15:25])=+inf;
min_ft = zeros(1,26);
min_ft([1,3,15:25])=-inf;
min_ft(3)=1;
constraint.int =vector_int_ft;
constraint.max =max_ft;
constraint.min =min_ft;

%%%%%%%%%%%%%%%%%%%%
%%% MISSING DATA %%%
%%%%%%%%%%%%%%%%%%%%

pathh='/home/hugo/Work/MIT_textbook/MIT textbook/missing_data/latex/figures/';

%% check missing data/create tables
% IAC
nr_missing = missing_data(IAC);

% create table with nr of values discarded and percentages
resultados_MISSING=array2table(nr_missing,'VariableNames',{'nr_points_missing' 'perc_missing'}, 'RowNames', SELECTED_VARIABLES);
writetable(resultados_MISSING,'resultados_MISSING_IAC.xls','WriteRowNames',true);
clear nr_missing

% NON IAC
nr_missing = missing_data(NON_IAC);

% create table with nr of values discarded and percentages
resultados_MISSING=array2table(nr_missing,'VariableNames',{'nr_points_missing' 'perc_missing'}, 'RowNames', SELECTED_VARIABLES);
writetable(resultados_MISSING,'resultados_MISSING_IAC.xls','WriteRowNames',true);
clear nr_missing

%% UNTIL HERE IT WAS EQUAL TO THE CODE OF CATIA
%% Remove Missing Data
% IAC
[IAC, IAC_out ] = remove_missing(IAC,IAC_out );
%NON_IAC
[NON_IAC, NON_IAC_out ] = remove_missing(NON_IAC,NON_IAC_out);

%% Normalize data
% IAC
IAC{:,:} = normalize_matrix(IAC{:,:});
%NON_IAC
NON_IAC{:,:} = normalize_matrix(NON_IAC{:,:});

%% Create 5% 10% 20% 40% Missing Data
perc = [0.05, 0.10, 0.20, 0.40];
% IAC and NON_IAC removal
rng(163)
[IAC_05,IAC_10,IAC_20,IAC_40] = create_missing_special(IAC,perc);
%[NON_IAC_05,NON_IAC_10,NON_IAC_20,NON_IAC_40] = create_missing_special(NON_IAC,perc);
% verify that there is no row with all missing data sum(sum(IAC_40') ==26)
% for the sake of simplicity I will just use the 40% IAC for a while
clear IAC_05 IAC_10 IAC_20 

%% Reference logistic regression


%% Mean
% seprate decides if the impute function will be applied to each class (=1)
% or to all the data
separate = 1; 
inp_case = 'mean';
data_in_new= data_impute(inp_case,IAC_40,IAC_out,separate,constraint);

clear impute_func
%% Median 
separate = 1;
inp_case = 'median';
data_in_new= data_impute(inp_case,IAC_40,IAC_out,separate,constraint);

%% Linear regression
separate = 1;
inp_case = 'linear';
data_in_new= data_impute(inp_case,IAC_05,IAC_out,separate,constraint);

%% Quadratic regression
separate = 1;
inp_case = 'quadratic';
data_in_new= data_impute(inp_case,IAC_40,IAC_out,separate,constraint);

%% Hotdeck
separate = 1;
inp_case = 'hotdeck';
data_in_new= data_impute(inp_case,IAC_40,IAC_out,separate,constraint);

%% Logistic regression

% Reference case
b = glmfit(IAC{:,:},IAC_out,'binomial','link','logit');
yfit = round(glmval(b,IAC{:,:},'logit')); % using 0.5 as threshold!

%% Cross validation

for j = 1:num_shuffles
    indices = crossvalind('Kfold',Labels,num_folds);
    for i = 1:num_folds
        test = (indices == i); train = ~test;
        [b,dev,stats] = glmfit(X(train,:),Labels(train),'binomial','logit'); % Logistic regression
        Fit(j,i) = glmval(b,X(test,:),'logit')';
    end
end



