% initialize data
clearvars;clc;close all;


%%%%%%%%%%%%%%%%%%%%%
% LOAD DATA %%%
%%%%%%%%%%%%%%%%%%%%%
[dataTable,sel_dataTable,sel_var_IAC,sel_var_NON_IAC,sel_var_IAC_nonBinary,sel_var_NON_IAC_nonBinary,IAC_output,NON_IAC_output,sel_var_IAC_Binary,sel_var_NON_IAC_Binary]=initializeData();
%datasets={'dataTable','sel_dataTable','sel_var_IAC','sel_var_NON_IAC,all_var_IAC','all_var_NON_IAC,IAC_output','NON_IAC_output','sel_var_IAC_nonBinary','sel_var_NON_IAC_nonBinary'};
% datasets={'IGNORETHIS'};
% #### DESCRIPTION ####
% dataTable - All data
% sel_dataTable - data with selected variables
% sel_var_IAC - IAC selected variables
% sel_var_NON_IAC - non IAC selected variables
% all_var_IAC - all variables IAC
% all_var_NON_IAC - all variables non IAC
% IAC_output - output IAC
% NON_IAC_output - output non IAC
% sel_var_IAC_nonBinary; - IAC selected variables \{binary features}
% sel_var_NON_IAC_nonBinary; - non IAC selected variables \{binary features}


%% plot some other variables HISTOGRAMS (check whats missing)
% varNames={'WEIGHT_FIRST','MAP_1ST','TEMP_1ST','HR_1ST','SPO2_1ST','CVP_1ST',...
%     'HCT_MED','HCT_LOWEST','HCT_HIGHEST','WBC_FIRST','PCO2_FIRST','PO2_FIRST','HGB_FIRST','PLATELET_FIRST',...
%     'SODIUM_FIRST','POTASSIUM_FIRST','TCO2_FIRST','CHLORIDE_FIRST','BUN_FIRST','CREATININE_FIRST','GLUCOSE_FIRST','CALCIUM_FIRST',...
%     'MAGNESIUM_FIRST','PHOSPHATE_FIRST','AST_FIRST','ALT_FIRST','LDH_FIRST','BILIRUBIN_FIRST','ALP_FIRST','ALBUMIN_FIRST',...
%     'TROPONIN_T_FIRST','CK_FIRST','BNP_FIRST','LACTATE_FIRST','PH_FIRST','SVO2_FIRST','ABG_COUNT'};% (aminotrans-(d)-ferase) ?????% (aminotrans-ferase) ?????% lactate dehydrogenase????
% varNames(2,:)={'Kg','mmHg','deg K','bpm','%','mmHg',...
%     '%','%','%','x 10^9/L','mmHg','mmHg','g/dL','x 10^9/L',...
%     'mmol/L','mmol/L','mmol/L','mmol/L','mg/dL','mg/dL','mg/dL','mg/dL',...
%     'mmol/L','mg/dL','U/L','U/L','U/L','micromol/L','U/L','g/dL',...
%     'ng/mL','U/L','pg/nL','mmol/L','unitless','%','unitless'};

font_size=16;
% % IAC and NON IAC - > NON BINARY
% nbins=15;
% clear varNames;
% varNames(1,:)=sel_var_IAC_nonBinary.Properties.VariableNames;
% varNames(2,:)={'years','','x 10^9/L','g/dL','x 10^9/L','mmol/L','mmol/L','mmol/L','mmol/L','mg/dL','mg/dL','mmHg','mmHg'}
% 
% plot_histogramsC(sel_var_IAC_nonBinary, sel_var_NON_IAC_nonBinary, pathh, font_size,varNames(2,:),nbins);

% [dataIAC, dataIACNoBin, dataIAC0, dataIAC1, dataIACNoBin0, dataIACNoBin1]=create_data(sel_var_IAC,IAC_output, sel_var_IAC_nonBinary);
% [data_NONIAC, data_NONIACNoBin, data_NONIAC0, data_NONIAC1, data_NONIACNoBin0, data_NONIACNoBin1]=create_data(sel_var_NON_IAC,NON_IAC_output, sel_var_NON_IAC_nonBinary);
% 
% save data_catia_2
% 
load data_catia_2
pathh_classes = strcat(fileparts(pwd),'\outliers\figures\hist_classes_NON_IAC\');

varNames(1,:)=sel_var_NON_IAC_nonBinary.Properties.VariableNames;
data0=array2table(data_NONIACNoBin0(:,1:end-1));
data1=array2table(data_NONIACNoBin1(:,1:end-1));

data0.Properties.VariableNames=varNames(1,:);
data1.Properties.VariableNames=varNames(1,:);
plot_histogramsC_classes(data0, data1, pathh_classes, font_size,varNames(2,:),nbins);


pathh_classes = strcat(fileparts(pwd),'\outliers\figures\hist_classes_IAC\');

varNames(1,:)=sel_var_IAC_nonBinary.Properties.VariableNames;
data0=array2table(dataIACNoBin0(:,1:end-1));
data1=array2table(dataIACNoBin1(:,1:end-1));

data0.Properties.VariableNames=varNames(1,:);
data1.Properties.VariableNames=varNames(1,:);
plot_histogramsC_classes(data0, data1, pathh_classes, font_size,varNames(2,:),nbins);

%% plot outliers using statistical methods
load data_catia_2
pathh = strcat(fileparts(pwd),'\outliers\figures\outliers\');

ftsize=16;
size_marker=70;

units(1,:)={'years','','x 10^9/L','g/dL','x 10^9/L','mmol/L','mmol/L','mmol/L','mmol/L','mg/dL','mg/dL','mmHg','mmHg'};

vars={'AGE','SOFA_FIRST' 'WBC_FIRST' 'HGB_FIRST' 'PLATELET_FIRST' 'SODIUM_FIRST' 'POTASSIUM_FIRST' 'TCO2_FIRST' 'CHLORIDE_FIRST' 'BUN_FIRST' 'CREATININE_FIRST' 'PO2_FIRST' 'PCO2_FIRST'};
% vars={'TCO2'}


tabela1=array2table(dataIACNoBin(:,1:end-1));
tabela1.Properties.VariableNames=vars;


for i=1:length(vars)
    plot_outliers(tabela1, dataIACNoBin(:,end), vars{1,i}, pathh, units{i}, ftsize, size_marker);
end

