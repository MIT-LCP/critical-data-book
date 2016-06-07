function [dataTable,sel_dataTable,sel_var_IAC,sel_var_NON_IAC,sel_var_IAC_nonBinary,sel_var_NON_IAC_nonBinary,IAC_output,NON_IAC_output,sel_var_IAC_Binary,sel_var_NON_IAC_Binary]=initializeData()

load aline;

dataTable=alinecohortdatajune15;

all_var_names=dataTable.Properties.VariableNames;

%%%%%%%%%%%%%%%%%%%%%%%
%%% SELECT FEATURES %%%
%%%%%%%%%%%%%%%%%%%%%%%

% 1 10 AGE                 age
% 2 11 GENDER_NUM          gender
% 3 17 SOFA                sofa score
% 4 19 SERVICE_NUM         service unit

% 5 50 CHF_FLG             congestive heart failure 
% 6 51 AFIB_FLG            arterial fibrillation 
% 7 52 RENAL_FLG           chronic kidney disease
% 8 53 LIVER_FLG           chronic liver disease
% 9 54 COPD_FLG            chronic obstructive pulmonary disease
% 10 55 CAD_FLG             coronary artery disease
% 11 56 STROKE_FLG          stroke
% 12 57 MAL_FLG             malignancy
% 13 58 RESP_FLG            respiratory disease
% 14 60 PNEUMONIA_FLG       pneumonia
% ###################################################
% 15 71 WBC_FIRST           white blood cells
% 16 72 HGB_FIRST           hemoglobin
% 17 73 PLATELET_FIRST      platelets
% 18 74 SODIUM_FIRST        sodium
% 19 75 POTASSIUM_FIRST     potassium
% 20 76 TCO2_FIRST          bicarbonate or total CO2 
% 21 77 CHLORIDE_FIRST      chloride
% 22 78 BUN_FIRST           blood urea nitrogen
% 23 79 CREATININE_FIRST    creatinine
% 24 96 PO2_FIRST           partial pressure of oxygen 
% 25 97 PCO2_FIRST          partial pressure of carbon dioxide

% 26 110 DNR_ADM_FLG        DNR at admission
% 113                    DNR_CMO_SWITCH_FLG  change in code status during ICU admission

sel_dataTable=dataTable(:,[10, 11, 17, 19, 50, 51, 52, 53, 54, 55, 56, 57, 58, 60, 71, 72, 73, 74, 75, 76, 77, 78, 79, 96, 97, 110, 28]);
sel_var_names=sel_dataTable.Properties.VariableNames;

%% DEFINE LABELS USING ALINE_FLG
% Features Selecionadas
sel_var_IAC=sel_dataTable(find(dataTable.ALINE_FLG==1),:);
sel_var_NON_IAC=sel_dataTable(find(dataTable.ALINE_FLG==0),:);

% Com todas as Features
% all_var_IAC=dataTable(find(dataTable.ALINE_FLG==1),:);
% all_var_NON_IAC=dataTable(find(dataTable.ALINE_FLG==0),:);

% REMOVE NANS
sel_var_IAC=removeNaNsTables(sel_var_IAC);
IAC_output=sel_var_IAC(:,end);
sel_var_IAC=sel_var_IAC(:,1:end-1);

sel_var_NON_IAC=removeNaNsTables(sel_var_NON_IAC);
NON_IAC_output=sel_var_NON_IAC(:,end);
sel_var_NON_IAC=sel_var_NON_IAC(:,1:end-1);




%% Eliminate binary features from data with selected variables:

[sel_var_IAC_nonBinary,sel_var_IAC_Binary]=removeBinaryFeatures(sel_var_IAC);
[sel_var_NON_IAC_nonBinary,sel_var_NON_IAC_Binary]=removeBinaryFeatures(sel_var_NON_IAC);

