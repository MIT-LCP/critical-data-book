% This file performs all the tests and saves the respective data in the
% the folder that are defined for that end

% this file loads the data and removes the initial missing data
load_data
% Defining random sample and creating the datasets with missing data
perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IAC dataset NON SEPARATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%
rng(163)
[IAC_M{1},IAC_M{2},IAC_M{3},IAC_M{4}, IAC_M{5}, IAC_M{6}, IAC_M{7}, IAC_M{8}...
    , IAC_M{9}, IAC_M{10}] = create_missing_special(IAC,perc);

% cycle
data_out=IAC_out;
orig_data_in = IAC;
separate = 0;
kfolds=10;
indices = crossvalind('Kfold',data_out,kfolds);
% Initializing variables
AUC=zeros(length(perc),length(method),kfolds);
Sen=zeros(length(perc),length(method),kfolds);
Spec=zeros(length(perc),length(method),kfolds);
kappa=zeros(length(perc),length(method),kfolds);
methodindex = [1 2 3 4 6 7 8];
%for j=1:1:length(method) % cycle for each method  
for j=methodindex
    for i=1:1:length(perc)% cycle for the different percentages of missingness
        data_in = IAC_M{1,i};
        [AUC(i,j,:), Sen(i,j,:), Spec(i,j,:), kappa(i,j,:)]...
            =logistic_cross_exotic(method{j},orig_data_in,data_in,...
            data_out,indices,separate,constraint);
    end
end
% FULL DATA model!!!
        [FAUC, FSen, FSpec, Fkappa]...
            =logistic_cross('fulldata',orig_data_in,orig_data_in,data_out,...
            indices,separate,constraint);
% Save Files
dataset = 'IAC';
table = 'NonSeparate';
SaveFiles
% make figures
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IAC dataset SEPARATE
%%%%%%%%%%%%%%%%%%%%%%%%
rng(163)
[IAC_M{1},IAC_M{2},IAC_M{3},IAC_M{4}, IAC_M{5}, IAC_M{6}, IAC_M{7}, IAC_M{8}...
    , IAC_M{9}, IAC_M{6}] = create_missing_special(IAC,perc);

% cycle
data_out=IAC_out;
orig_data_in = IAC;
separate = 1;
kfolds=10;
indices = crossvalind('Kfold',data_out,kfolds);
% Initializing variables
AUC=zeros(length(perc),length(method),kfolds);
Sen=zeros(length(perc),length(method),kfolds);
Spec=zeros(length(perc),length(method),kfolds);
kappa=zeros(length(perc),length(method),kfolds);
methodindex = [1 2 3 4 6 7 8];
%for j=1:1:length(method) % cycle for each method  
for j=methodindex
    j
    try
        for i=1:1:length(perc)% cycle for the different percentages of missingness
            rng(163+i)
            data_in = IAC_M{1,i};
            [AUC(i,j,:), Sen(i,j,:), Spec(i,j,:), kappa(i,j,:)]...
                =logistic_cross(method{j},orig_data_in,data_in,...
                data_out,indices,separate,constraint);
        end
    catch        
    end
end
% FULL DATA model!!!
rng(163)
[FAUC, FSen, FSpec, Fkappa]...
    =logistic_cross_classic(orig_data_in,orig_data_in,data_out,indices);
        
save('IAC_Separate.mat','perc','AUC','Sen','Spec','kappa','IAC_M','FAUC','FSen','FSpec','Fkappa','method')        
% Save Files
dataset = 'IAC';
table = 'Separate';
SaveFiles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%
% NON_IAC dataset SEPARATE
%%%%%%%%%%%%%%%%%%%%%%%%
rng(163)
[NIAC_M{1},NIAC_M{2},NIAC_M{3},NIAC_M{4}] = create_missing_special(NON_IAC,perc);

% cycle
data_out=NON_IAC_out;
orig_data_in = NON_IAC;
separate = 0;
kfolds=10;
indices = crossvalind('Kfold',data_out,kfolds);

% Initializing variables
AUC=zeros(length(perc),length(method),kfolds);
Sen=zeros(length(perc),length(method),kfolds);
Spec=zeros(length(perc),length(method),kfolds);
kappa=zeros(length(perc),length(method),kfolds);
methodindex = [1 2 3 4 6 7];
%for j=1:1:length(method) % cycle for each method  
for j=methodindex
    for i=1:1:length(perc)% cycle for the different percentages of missingness
        data_in = IAC_M{1,i};
        [AUC(i,j,:), Sen(i,j,:), Spec(i,j,:), kappa(i,j,:)]...
            =logistic_cross_exotic(method{j},orig_data_in,data_in,...
            data_out,indices,separate,constraint);
    end
end
% FULL DATA model!!!
        [FAUC, FSen, FSpec, Fkappa]...
            =logistic_cross(orig_data_in,orig_data_in,data_out,indices);        
% Save Files
dataset = 'Non_IAC';
table = 'NONSeparate';
SaveFiles

%%%%%%%%%%%%%%%%%%%%%%%%
% NON_IAC dataset SEPARATE
%%%%%%%%%%%%%%%%%%%%%%%%
rng(163)
[NIAC_M{1},NIAC_M{2},NIAC_M{3},NIAC_M{4}, NIAC_M{5}, NIAC_M{6}, NIAC_M{7}, NIAC_M{8}...
    , NIAC_M{9}, NIAC_M{10}] = create_missing_special(NON_IAC,perc);

% cycle
data_out=NON_IAC_out;
orig_data_in = NON_IAC;
separate = 1;
kfolds=10;
indices = crossvalind('Kfold',data_out,kfolds);

% Initializing variables
AUC=zeros(length(perc),length(method),kfolds);
Sen=zeros(length(perc),length(method),kfolds);
Spec=zeros(length(perc),length(method),kfolds);
kappa=zeros(length(perc),length(method),kfolds);
methodindex = [1 2 3 4 6 7];
%for j=1:1:length(method) % cycle for each method  
for j=methodindex
    j
    try
        for i=1:1:length(perc)% cycle for the different percentages of missingness
            rng(163+i)
            data_in = NIAC_M{1,i};
            [AUC(i,j,:), Sen(i,j,:), Spec(i,j,:), kappa(i,j,:)]...
                =logistic_cross(method{j},orig_data_in,data_in,...
                data_out,indices,separate,constraint);
        end
    catch
    end
end
% FULL DATA model!!!
        [FAUC, FSen, FSpec, Fkappa]...
            =logistic_cross_classic(orig_data_in,orig_data_in,data_out,indices); 
save('NON_IAC_Separate.mat','perc','AUC','Sen','Spec','kappa','NIAC_M','FAUC','FSen','FSpec','Fkappa','method')        
        
% Save Files
dataset = 'Non_IAC';
table = 'Separate';
SaveFiles

