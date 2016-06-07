% Load data for the missing data tests

% Clear and Load

load aline
ALL_VARIABLES=alinecohortdatajune15.Properties.VariableNames;

%%%%%%%%%%%%%%%%%%%%%%%
%%% SELECT FEATURES %%%
%%%%%%%%%%%%%%%%%%%%%%%

%DATA=alinecohortdatajune15(:,[10, 11, 17, 19, 50, 51, 52, 53, 54, 55, 56, 57, 58, 60, 71, 72, 73, 74, 75, 76, 77, 78, 79, 96, 97, 110]);
DATA=alinecohortdatajune15(:,[10, 11, 17, 19, 50, 51, 52, 53, 54, 55, 56, 57, 58, 60, 71, 72, 73, 74, 75, 76, 77, 78, 79, 96, 97, 110, 113]);

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

%% Remove Missing Data
% IAC
[IAC, IAC_out ] = remove_missing(IAC,IAC_out );
%NON_IAC
[NON_IAC, NON_IAC_out ] = remove_missing(NON_IAC,NON_IAC_out);

%% Normalize data
% IAC
IAC{:,:} = normalize_matrix(IAC{:,:});
IAC = IAC(:,1:end-1); % remove last column that is a binary variable with a 70% 
%correlation with the output,  making the comparison lose meaning

%NON_IAC
NON_IAC{:,:} = normalize_matrix(NON_IAC{:,:});
NON_IAC = NON_IAC(:,1:end-1);

switch dataset
    case 'IAC'
        data_in =IAC;
        data_out = IAC_out;
    case 'NON_IAC'
        data_in= NON_IAC;
        data_out = NON_IAC_out;
    otherwise
        error('myApp:argChk1', 'WRONG dataset name selected, please try: IAC or NON_IAC')
end
%% Methods used

%method = {'remove','mean','median','linear','quadratic','hotdeck','knn','randlinear','randomsamp'};

