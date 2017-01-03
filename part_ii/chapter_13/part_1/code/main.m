clearvars
close all
load aline

% change this
pathh='C:\Users\Catia\Desktop\textbook\outliers\latex\figures\';

ALL_VARIABLES=alinecohortdatajune15.Properties.VariableNames;

%%%%%%%%%%%%%%%%%%%%%%%
%%% SELECT FEATURES %%%
%%%%%%%%%%%%%%%%%%%%%%%

% 10 AGE                 age
% 11 GENDER_NUM          gender
% 17 SOFA                sofa score
% 19 SERVICE_NUM         service unit

% 50 CHF_FLG             congestive heart failure 
% 51 AFIB_FLG            arterial fibrillation 
% 52 RENAL_FLG           chronic kidney disease
% 53 LIVER_FLG           chronic liver disease
% 54 COPD_FLG            chronic obstructive pulmonary disease
% 55 CAD_FLG             coronary artery disease
% 56 STROKE_FLG          stroke
% 57 MAL_FLG             malignancy
% 58 RESP_FLG            respiratory disease
% 60 PNEUMONIA_FLG       pneumonia

% 71 WBC_FIRST           white blood cells
% 72 HGB_FIRST           hemoglobin
% 73 PLATELET_FIRST      platelets
% 74 SODIUM_FIRST        sodium
% 75 POTASSIUM_FIRST     potassium
% 76 TCO2_FIRST          bicarbonate or total CO2 
% 77 CHLORIDE_FIRST      chloride
% 78 BUN_FIRST           blood urea nitrogen
% 79 CREATININE_FIRST    creatinine
% 96 PO2_FIRST           partial pressure of oxygen 
% 97 PCO2_FIRST          partial pressure of carbon dioxide

% 110 DNR_ADM_FLG        DNR at admission
% 113 DNR_CMO_SWITCH_FLG  change in code status during ICU admission


DATA=alinecohortdatajune15(:,[10, 11, 17, 19, 50, 51, 52, 53, 54, 55, 56, 57, 58, 60, 71, 72, 73, 74, 75, 76, 77, 78, 79, 96, 97, 110]);

SELECTED_VARIABLES=DATA.Properties.VariableNames;


%% DEFINE LABELS USING ALINE_FLG

IAC=DATA(find(alinecohortdatajune15.ALINE_FLG==1),:);
NON_IAC=DATA(find(alinecohortdatajune15.ALINE_FLG==0),:);

IAC_out=alinecohortdatajune15(find(alinecohortdatajune15.ALINE_FLG==1),:);
NON_IAC_out=alinecohortdatajune15(find(alinecohortdatajune15.ALINE_FLG==0),:);

IAC_out=IAC_out.DAY_28_FLG;
NON_IAC_out=NON_IAC_out.DAY_28_FLG;

%%%%%%%%%%%%%%%%%%%%%
%%% DATA ANALYSIS %%%
%%%%%%%%%%%%%%%%%%%%%

%% plot 2*2 multivariate (dont use many variables)

lab_matrix=DATA{:,15:25};
VarNames=DATA(:,15:25).Properties.VariableNames';
VarNames = strtok(VarNames, '_');
font_size=8;

plot_multivariate(lab_matrix,alinecohortdatajune15.DAY_28_FLG,VarNames,font_size);

name='lab_results_plot';
print_name=strcat(pathh, name, '.eps');
print('-depsc', print_name)

%% plot univariate logistic regression 

var='SOFA_FIRST';
plot_univariate_lr(var, IAC, NON_IAC, IAC_out, NON_IAC_out)

name='sofa_univariate_lr';
print_name=strcat(pathh, name, '.eps');
print('-depsc', print_name)

%% plot outliers using statistical methods

var='SOFA_FIRST';
plot_outliers(IAC, var, pathh);

%% plot some categorical variables (check whats missing)
font_size=18;
plot_histograms_categorical(alinecohortdatajune15, pathh, font_size)

%% plot some other variables (check whats missing)
plot_histograms(IAC, NON_IAC, pathh, font_size)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% OUTLIERS STATISTICAL ANALYSIS %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% IQ

% IAC
[resultados_IQ, variables]=interquartile(IAC);

% create table with nr of values discarded and percentages
resultados_IQ=array2table(resultados_IQ,'VariableNames',{'nr_points_removed' 'perc_removed'}, 'RowNames', variables);
writetable(resultados_IQ,'resultados_IQ_IAC.xls','WriteRowNames',true);
clear resultados_IQ

% NON IAC
[resultados_IQ, ~]=interquartile(NON_IAC);

% create table with nr of values discarded and percentages
resultados_IQ=array2table(resultados_IQ,'VariableNames',{'nr_points_removed' 'perc_removed'}, 'RowNames', variables);
writetable(resultados_IQ,'resultados_IQ_NON_IAC.xls','WriteRowNames',true);
clear resultados_IQ 


%% IQ with log transformation

% IAC
resultados_IQ = interquartile_log(IAC);

% create table with nr of values discarded and percentages
resultados_IQ=array2table(resultados_IQ,'VariableNames',{'nr_points_removed' 'perc_removed'}, 'RowNames', variables);
writetable(resultados_IQ,'resultados_LOG_IQ_IAC.xls','WriteRowNames',true);
IAC_out=IAC(:,variables);
clear resultados_IQ

% NON IAC
resultados_IQ = interquartile_log(NON_IAC);

% create table with nr of values discarded and percentages
resultados_IQ=array2table(resultados_IQ,'VariableNames',{'nr_points_removed' 'perc_removed'}, 'RowNames', variables);
writetable(resultados_IQ,'resultados_LOG_IQ_NON_IAC.xls','WriteRowNames',true);
NON_IAC_out=NON_IAC(:,variables);
clear resultados_IQ

%% z-score

% IAC
resultados_z = z_score(IAC_out);

% create table with nr of values discarded and percentages
resultados_z=array2table(resultados_z,'VariableNames',{'nr_points_removed' 'perc_removed'}, 'RowNames', variables);
writetable(resultados_z,'resultados_z_IAC.xls','WriteRowNames',true);
clear resultados_z

% NON IAC
resultados_z = z_score(NON_IAC_out);

% create table with nr of values discarded and percentages
resultados_z=array2table(resultados_z,'VariableNames',{'nr_points_removed' 'perc_removed'}, 'RowNames', variables);
writetable(resultados_z,'resultados_z_NON_IAC.xls','WriteRowNames',true);
clear resultados_z


%% modified z-score

% IAC
resultados_z = modified_z(IAC_out);

% create table with nr of values discarded and percentages
resultados_z=array2table(resultados_z,'VariableNames',{'nr_points_removed' 'perc_removed'}, 'RowNames', variables);
writetable(resultados_z,'resultados_mod_z_IAC.xls','WriteRowNames',true);
clear resultados_z

% NON IAC
resultados_z = modified_z(NON_IAC_out);

% create table with nr of values discarded and percentages
resultados_z=array2table(resultados_z,'VariableNames',{'nr_points_removed' 'perc_removed'}, 'RowNames', variables);
writetable(resultados_z,'resultados_mod_z_NON_IAC.xls','WriteRowNames',true);
clear resultados_z


%%%%%%%%%%%%%%%%%%%%
%%% MISSING DATA %%%
%%%%%%%%%%%%%%%%%%%%

pathh='C:\Users\Catia\Desktop\textbook\missing_data\latex\figures\';

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

%% hot deck imputation using kmeans
% get data after imputation and corresponding ids
[after_input, rows_of_input] = hot_deck_input(IAC, pathh);

name='silhouetteIAC';
print_name=strcat(pathh, name, '.eps');
print('-depsc', print_name)

clear after_input rows_of_input

[after_input, rows_of_input] = hot_deck_input(NON_IAC, pathh);

name='silhouetteNONIAC';
print_name=strcat(pathh, name, '.eps');
print('-depsc', print_name)