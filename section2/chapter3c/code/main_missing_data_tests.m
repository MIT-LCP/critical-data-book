% This file performs all the tests and saves the respective data in the
% the folder that are defined for that end

% this file loads the data and removes the initial missing data
load_data
% Defining random sample and creating the datasets with missing data
perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IAC dataset SEPARATE
%%%%%%%%%%%%%%%%%%%%%%%%
rng(163)
[IAC_M{1},IAC_M{2},IAC_M{3},IAC_M{4}, IAC_M{5}, IAC_M{6}, IAC_M{7}, IAC_M{8}...
    , IAC_M{9}, IAC_M{10}] = create_missing_special(IAC,perc);
IAC =IAC(:,1:end-1);
IAC_M{1}=IAC_M{1}(:,1:end-1);
IAC_M{2}=IAC_M{2}(:,1:end-1);
IAC_M{3}=IAC_M{3}(:,1:end-1);
IAC_M{4}=IAC_M{4}(:,1:end-1);
IAC_M{5}=IAC_M{5}(:,1:end-1);
IAC_M{6}=IAC_M{6}(:,1:end-1);
IAC_M{7}=IAC_M{7}(:,1:end-1);
IAC_M{8}=IAC_M{8}(:,1:end-1);
IAC_M{9}=IAC_M{9}(:,1:end-1);
IAC_M{10} =IAC_M{10}(:,1:end-1);
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
methodindex = [1 2 3 4 6 7];
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
    =logistic_cross_classic(orig_data_in(:,1:end),orig_data_in(:,1:end),data_out,indices);

save('IAC_Separate_multi.mat','perc','AUC','Sen','Spec','kappa','IAC_M','FAUC','FSen','FSpec','Fkappa','method')        
% % Save Files
% dataset = 'IAC';
% table = 'Separate';
% SaveFiles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%
% NON_IAC dataset SEPARATE
%%%%%%%%%%%%%%%%%%%%%%%%
% this file loads the data and removes the initial missing data
load_data
% Defining random sample and creating the datasets with missing data
perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];

rng(163)
[NIAC_M{1},NIAC_M{2},NIAC_M{3},NIAC_M{4}, NIAC_M{5}, NIAC_M{6}, NIAC_M{7}, NIAC_M{8}...
    , NIAC_M{9}, NIAC_M{10}] = create_missing_special(NON_IAC,perc);
NON_IAC =NON_IAC(:,1:end-1);
NIAC_M{1}=NIAC_M{1}(:,1:end-1);
NIAC_M{2}=NIAC_M{2}(:,1:end-1);
NIAC_M{3}=NIAC_M{3}(:,1:end-1);
NIAC_M{4}=NIAC_M{4}(:,1:end-1);
NIAC_M{5}=NIAC_M{5}(:,1:end-1);
NIAC_M{6}=NIAC_M{6}(:,1:end-1);
NIAC_M{7}=NIAC_M{7}(:,1:end-1);
NIAC_M{8}=NIAC_M{8}(:,1:end-1);
NIAC_M{9}=NIAC_M{9}(:,1:end-1);
NIAC_M{10} =NIAC_M{10}(:,1:end-1);
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
save('NON_IAC_Separate_multi.mat','perc','AUC','Sen','Spec','kappa','NIAC_M','FAUC','FSen','FSpec','Fkappa','method')        
        
% % Save Files
% dataset = 'Non_IAC';
% table = 'Separate';
% SaveFiles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this file loads the data and removes the initial missing data
load_data
% Defining random sample and creating the datasets with missing data
perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];
rng(163)
[IAC_M{1},IAC_M{2},IAC_M{3},~, IAC_M{4}, ~, ~, ~...
    , IAC_M{5}, ~]= create_missing_special(IAC,perc);
separate =1;
data_out = IAC_out;
methodindex = [1 2 3 4 6 7];
for i=methodindex
    i
    try
        for j=1:1:length(perc)% cycle for the different percentages of missingness
            rng(163+i)
            data_in = IAC_M{1,j};
            data_in_new{i,j}= data_inpute(method{i},data_in,data_out,separate,constraint);
        end
    catch
    end
end
save('DataForHistogramsIAC.mat','data_in_new','IAC_M')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this file loads the data and removes the initial missing data
load_data
% Defining random sample and creating the datasets with missing data
perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];
rng(163)
[NIAC_M{1},NIAC_M{2},NIAC_M{3},~, NIAC_M{4}, ~, ~, ~...
    , NIAC_M{5}, ~]= create_missing_special(NON_IAC,perc);
separate =1;
data_out = NON_IAC_out;
methodindex = [1 2 3 4 6 7];
for i=methodindex
    i
    try
        for j=1:1:length(perc)% cycle for the different percentages of missingness
            rng(163+i)
            data_in = NIAC_M{1,j};
            data_in_new{i,j}= data_inpute(method{i},data_in,data_out,separate,constraint);
        end
    catch
    end
end
save('DataForHistogramsNONIAC.mat','data_in_new','NIAC_M')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%
%
%
%
%               UNIVARIATE
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this file loads the data and removes the initial missing data
load_data

% Defining random sample and creating the datasets with missing data
perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];
column2remove =1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% IAC dataset SEPARATE
%%%%%%%%%%%%%%%%%%%%%%%%
rng(163)
[IAC_M{1},IAC_M{2},IAC_M{3},IAC_M{4}, IAC_M{5}, IAC_M{6}, IAC_M{7}, IAC_M{8}...
    , IAC_M{9}, IAC_M{10}] = create_missing_special_univariate(IAC,perc,column2remove);
IAC =IAC(:,1:end-1);
IAC_M{1}=IAC_M{1}(:,1:end-1);
IAC_M{2}=IAC_M{2}(:,1:end-1);
IAC_M{3}=IAC_M{3}(:,1:end-1);
IAC_M{4}=IAC_M{4}(:,1:end-1);
IAC_M{5}=IAC_M{5}(:,1:end-1);
IAC_M{6}=IAC_M{6}(:,1:end-1);
IAC_M{7}=IAC_M{7}(:,1:end-1);
IAC_M{8}=IAC_M{8}(:,1:end-1);
IAC_M{9}=IAC_M{9}(:,1:end-1);
IAC_M{10} =IAC_M{10}(:,1:end-1);
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
methodindex = [1 2 3 4 7 8];
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
    =logistic_cross_classic(orig_data_in(:,1:end),orig_data_in(:,1:end),data_out,indices);

save('IAC_Separate_Univariate.mat','perc','AUC','Sen','Spec','kappa','IAC_M','FAUC','FSen','FSpec','Fkappa','method')        

%%%%%%%%%%%%%%%%%%%%%%%%
% NON_IAC dataset SEPARATE
%%%%%%%%%%%%%%%%%%%%%%%%
% this file loads the data and removes the initial missing data
load_data
column2remove =1;

% Defining random sample and creating the datasets with missing data
perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];

rng(163)
[NIAC_M{1},NIAC_M{2},NIAC_M{3},NIAC_M{4}, NIAC_M{5}, NIAC_M{6}, NIAC_M{7}, NIAC_M{8}...
    , NIAC_M{9}, NIAC_M{10}] = create_missing_special_univariate(NON_IAC,perc,column2remove);
NON_IAC =NON_IAC(:,1:end-1);
NIAC_M{1}=NIAC_M{1}(:,1:end-1);
NIAC_M{2}=NIAC_M{2}(:,1:end-1);
NIAC_M{3}=NIAC_M{3}(:,1:end-1);
NIAC_M{4}=NIAC_M{4}(:,1:end-1);
NIAC_M{5}=NIAC_M{5}(:,1:end-1);
NIAC_M{6}=NIAC_M{6}(:,1:end-1);
NIAC_M{7}=NIAC_M{7}(:,1:end-1);
NIAC_M{8}=NIAC_M{8}(:,1:end-1);
NIAC_M{9}=NIAC_M{9}(:,1:end-1);
NIAC_M{10} =NIAC_M{10}(:,1:end-1);
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
methodindex = [1 2 3 4 7 8];
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
save('NON_IAC_Separate_Univariate.mat','perc','AUC','Sen','Spec','kappa','NIAC_M','FAUC','FSen','FSpec','Fkappa','method')        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%
%
%     Histograms univariate
%
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% % Save Files
% dataset = 'Non_IAC';
% table = 'Separate';
% SaveFiles
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this file loads the data and removes the initial missing data
load_data
IACtosave=DATA(find(alinecohortdatajune15.ALINE_FLG==1),:);
IACtosave = IACtosave(:,1:end-1);
column2remove=1;
% Defining random sample and creating the datasets with missing data
perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];
rng(163)
[IAC_M{1},IAC_M{2},IAC_M{3},~, IAC_M{4}, ~, ~, ~...
    , IAC_M{5}, ~]= create_missing_special_univariate(IAC,perc,column2remove);
IAC =IAC(:,1:end-1);
IAC_M{1}=IAC_M{1}(:,1:end-1);
IAC_M{2}=IAC_M{2}(:,1:end-1);
IAC_M{3}=IAC_M{3}(:,1:end-1);
IAC_M{4}=IAC_M{4}(:,1:end-1);
IAC_M{5}=IAC_M{5}(:,1:end-1);

separate =1;
data_out = IAC_out;
methodindex = [1 2 3 4 6 7 8 9];
for i=methodindex
    i
    try
        for j=1:1:5% cycle for the different percentages of missingness
            rng(163+i)
            data_in = IAC_M{1,j};
            data_in_new{i,j}= data_inpute(method{i},data_in,data_out,separate,constraint);
        end
    catch
    end
end
method{10} ='MICE';
method{11} ='Amelia';
percstr = {'5','10','20','40','80'};
j=10;
for i =1:1:5
    filename = strcat(method{j},'_univar_IAC_Imb',percstr{i},'_original.csv');
    data = readtable(filename);
    data_in_new{j,i} = data(:,4:29);
end
j=11;
for i=1:1:5
    filename = strcat(method{j},'_univar_IAC_Imb',percstr{i},'_original.csv');
    data = readtable(filename);
    data_in_new{j,i} = data(:,2:27);
end
IAC =IACtosave;
save('univar_DataForHistogramsIAC.mat','data_in_new','IAC_M','IAC','method')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this file loads the data and removes the initial missing data
load_data
NON_IACtosave=DATA(find(alinecohortdatajune15.ALINE_FLG==0),:);
NON_IACtosave = NON_IACtosave(:,1:end-1);
column2remove=1;
% Defining random sample and creating the datasets with missing data
perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];
rng(163)
[NIAC_M{1},NIAC_M{2},NIAC_M{3},~, NIAC_M{4}, ~, ~, ~...
    , NIAC_M{5}, ~]= create_missing_special_univariate(NON_IAC,perc,column2remove);
NIAC =IAC(:,1:end-1);
NIAC_M{1}=NIAC_M{1}(:,1:end-1);
NIAC_M{2}=NIAC_M{2}(:,1:end-1);
NIAC_M{3}=NIAC_M{3}(:,1:end-1);
NIAC_M{4}=NIAC_M{4}(:,1:end-1);
NIAC_M{5}=NIAC_M{5}(:,1:end-1);
separate =1;
data_out = NON_IAC_out;
methodindex = [1 2 3 4 6 7 8 9];
for i=methodindex
    i
    try
        for j=1:1:5% cycle for the different percentages of missingness
            rng(163+i)
            data_in = NIAC_M{1,j};
            data_in_new{i,j}= data_inpute(method{i},data_in,data_out,separate,constraint);
        end
    catch
    end
end
method{10} ='MICE';
method{11} ='Amelia';
percstr = {'5','10','20','40','80'};
j=10;
for i =1:1:5
    filename = strcat(method{j},'_univar_NON_IAC_Imb',percstr{i},'_original.csv');
    data = readtable(filename);
    data_in_new{j,i} = data(:,4:29);
end
j=11;
for i=1:1:5
    filename = strcat(method{j},'_univar_NON_IAC_Imb',percstr{i},'_original.csv');
    data = readtable(filename);
    data_in_new{j,i} = data(:,2:27);
end
NON_IAC =NON_IACtosave;
save('univar_DataForHistogramsNONIAC.mat','data_in_new','NIAC_M','NON_IAC','method')