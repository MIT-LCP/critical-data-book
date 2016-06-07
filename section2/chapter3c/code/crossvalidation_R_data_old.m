% Use the data from R to make an analysis


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%                   MICE
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% IAC 
load_data
dataset='IAC';
method='MICE_';
dirn = 'CSV';
perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];
kfolds = 10;
rng(163)
[IAC_M{1},IAC_M{2},IAC_M{3},IAC_M{4}, IAC_M{5}, IAC_M{6}, IAC_M{7}, IAC_M{8}...
    , IAC_M{9}, IAC_M{10}] = create_missing_special(IAC,perc);
% cycle
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
data_out=IAC_out;
separate = 1;
kfolds=10;
indices = crossvalind('Kfold',data_out,kfolds);
for i=1:1:10
    for j=1:1:kfolds
        test = (indices == j); train = ~test;
        filename = strcat(method,dataset,'_Imb',num2str(perc(i)*100),'_Fold',num2str(j),'.csv');
        data = readtable(filename);
        grouping = data{:,2};
        data_in=data{:,4:end-1};
        data_out=data{:,end};
        orig_data_in=IAC{test,:};
        orig_data_out=IAC_out(test);
        [AUC1(i,j), Sen1(i,j), Spec1(i,j), kappa1(i,j)] =...
            logistic_cross_classic_fromR(orig_data_in,orig_data_out,data_in,data_out,grouping);             
    end   
end
method_name = 'MICE';
savefile =strcat('IAC_results/',method_name,'_',dataset,'.mat');
save(savefile,'AUC1','Sen1','Spec1','kappa1','method_name');

%% NON IAC 
load_data
dataset='NON_IAC';
method='MICE_';
dirn = 'CSV';
perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];
kfolds = 10;
rng(163)
[NIAC_M{1},NIAC_M{2},NIAC_M{3},NIAC_M{4}, NIAC_M{5}, NIAC_M{6}, NIAC_M{7}, NIAC_M{8}...
    , NIAC_M{9}, NIAC_M{10}] = create_missing_special(NON_IAC,perc);
% cycle
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
data_out=NON_IAC_out;
separate = 1;
kfolds=10;
indices = crossvalind('Kfold',data_out,kfolds);
for i=1:1:10
    for j=1:1:kfolds
        test = (indices == j); train = ~test;
        filename = strcat(method,dataset,'_Imb',num2str(perc(i)*100),'_Fold',num2str(j),'.csv');
        data = readtable(filename);
        grouping = data{:,2};
        data_in=data{:,4:end-1};
        data_out=data{:,end};
        orig_data_in=NON_IAC{test,:};
        orig_data_out=NON_IAC_out(test);
        [AUC1(i,j), Sen1(i,j), Spec1(i,j), kappa1(i,j)] =...
            logistic_cross_classic_fromR(orig_data_in,orig_data_out,data_in,data_out,grouping);             
    end   
end
method_name = 'MICE';
savefile =strcat('NON_IAC_results/',method_name,'_',dataset,'.mat');
save(savefile,'AUC1','Sen1','Spec1','kappa1','method_name');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%                   AMELIA II
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% IAC 
load_data
dataset='IAC';
method='Amelia_';
dirn = 'CSV';
perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];
kfolds = 10;
rng(163)
[IAC_M{1},IAC_M{2},IAC_M{3},IAC_M{4}, IAC_M{5}, IAC_M{6}, IAC_M{7}, IAC_M{8}...
    , IAC_M{9}, IAC_M{10}] = create_missing_special(IAC,perc);
% cycle
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
data_out=IAC_out;
separate = 1;
kfolds=10;
indices = crossvalind('Kfold',data_out,kfolds);
for i=1:1:5
    for j=1:1:kfolds
        test = (indices == j); train = ~test;
        filename = strcat(method,dataset,'_Imb',num2str(perc(i)*100),'_Fold',num2str(j),'.csv');
        data = readtable(filename);
        grouping = data{:,end};
        data_in=data{:,2:end-2};
        data_out=data{:,end-1};
        orig_data_in=IAC{test,:};
        orig_data_out=IAC_out(test);
        [AUC1(i,j), Sen1(i,j), Spec1(i,j), kappa1(i,j)] =...
            logistic_cross_classic_fromR(orig_data_in,orig_data_out,data_in,data_out,grouping);             
    end   
end
method_name = 'Amelia';
savefile =strcat('IAC_results/',method_name,'_',dataset,'.mat');
save(savefile,'AUC1','Sen1','Spec1','kappa1','method_name');
%% NON IAC 
load_data
dataset='NON_IAC';
method='Amelia_';
dirn = 'CSV';
perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];
kfolds = 10;
rng(163)
[NIAC_M{1},NIAC_M{2},NIAC_M{3},NIAC_M{4}, NIAC_M{5}, NIAC_M{6}, NIAC_M{7}, NIAC_M{8}...
    , NIAC_M{9}, NIAC_M{10}] = create_missing_special(NON_IAC,perc);
% cycle
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
data_out=NON_IAC_out;
separate = 1;
kfolds=10;
indices = crossvalind('Kfold',data_out,kfolds);
for i=1:1:5
    for j=1:1:kfolds
        test = (indices == j); train = ~test;
        filename = strcat(method,dataset,'_Imb',num2str(perc(i)*100),'_Fold',num2str(j),'.csv');
        data = readtable(filename);
        grouping = data{:,end};
        data_in=data{:,2:end-2};
        data_out=data{:,end-1};
        orig_data_in=NON_IAC{test,:};
        orig_data_out=NON_IAC_out(test);
        [AUC1(i,j), Sen1(i,j), Spec1(i,j), kappa1(i,j)] =...
            logistic_cross_classic_fromR(orig_data_in,orig_data_out,data_in,data_out,grouping);             
    end   
end
method_name = 'Amelia';
savefile =strcat('NON_IAC_results/',method_name,'_',dataset,'.mat');
save(savefile,'AUC1','Sen1','Spec1','kappa1','method_name');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%                                                                         %
%                                                                         %
%                                                                         %
%                                                                         %
%                       UNIVARIATE                                        %
%                                                                         %
%                                                                         %
%                                                                         %
%                                                                         %
%                                                                         %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Use the data from R to make an analysis


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%                   MICE
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% IAC 
load_data
dataset='IAC';
method='MICE_';
dirn = 'CSV';
column2remove =1;
perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];
kfolds = 10;
rng(163)
[IAC_M{1},IAC_M{2},IAC_M{3},IAC_M{4}, IAC_M{5}, IAC_M{6}, IAC_M{7}, IAC_M{8}...
    , IAC_M{9}, IAC_M{10}] = create_missing_special_univariate(IAC,perc,column2remove);
% cycle
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
data_out=IAC_out;
separate = 1;
kfolds=10;
indices = crossvalind('Kfold',data_out,kfolds);
caso = 'univar_';
for i=1:1:length(IAC_M)
    for j=1:1:kfolds
        test = (indices == j); train = ~test;
        filename = strcat(method,caso,dataset,'_Imb',num2str(perc(i)*100),'_Fold',num2str(j),'.csv');
        data = readtable(filename);
        grouping = data{:,2};
        data_in=data{:,4:end-1};
        data_out=data{:,end};
        orig_data_in=IAC{test,:};
        orig_data_out=IAC_out(test);
        [AUC1(i,j), Sen1(i,j), Spec1(i,j), kappa1(i,j)] =...
            logistic_cross_classic_fromR(orig_data_in,orig_data_out,data_in,data_out,grouping);             
    end   
end
method_name = 'MICE';
foldername= strcat(caso,'IAC_results/');
mkdir(foldername)
savefile =strcat(foldername,method_name,'_',dataset,'.mat');
save(savefile,'AUC1','Sen1','Spec1','kappa1','method_name');

%% NON IAC 
load_data
column2remove = 1;
dataset='NON_IAC';
method='MICE_';
dirn = 'CSV';
caso = 'univar_';

perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];
kfolds = 10;
rng(163)
[NIAC_M{1},NIAC_M{2},NIAC_M{3},NIAC_M{4}, NIAC_M{5}, NIAC_M{6}, NIAC_M{7}, NIAC_M{8}...
    , NIAC_M{9}, NIAC_M{10}] = create_missing_special_univariate(NON_IAC,perc,column2remove);
% cycle
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
data_out=NON_IAC_out;
separate = 1;
kfolds=10;
indices = crossvalind('Kfold',data_out,kfolds);
for i=1:1:length(NIAC_M)
    for j=1:1:kfolds
        test = (indices == j); train = ~test;
        filename = strcat(method,caso,dataset,'_Imb',num2str(perc(i)*100),'_Fold',num2str(j),'.csv');
        data = readtable(filename);
        grouping = data{:,2};
        data_in=data{:,4:end-1};
        data_out=data{:,end};
        orig_data_in=NON_IAC{test,:};
        orig_data_out=NON_IAC_out(test);
        [AUC1(i,j), Sen1(i,j), Spec1(i,j), kappa1(i,j)] =...
            logistic_cross_classic_fromR(orig_data_in,orig_data_out,data_in,data_out,grouping);             
    end   
end
method_name = 'MICE';
foldername= strcat(caso,'NON_IAC_results/');
mkdir(foldername)
savefile =strcat(foldername,method_name,'_',dataset,'.mat');
save(savefile,'AUC1','Sen1','Spec1','kappa1','method_name');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%                   AMELIA II
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% IAC 
load_data
dataset='IAC';
method='Amelia_';
dirn = 'CSV';
caso = 'univar_';
column2remove=1;
perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];
kfolds = 10;
rng(163)
[IAC_M{1},IAC_M{2},IAC_M{3},IAC_M{4}, IAC_M{5}, IAC_M{6}, IAC_M{7}, IAC_M{8}...
    , IAC_M{9}, IAC_M{10}] = create_missing_special_univariate(IAC,perc,column2remove);
% cycle
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
data_out=IAC_out;
separate = 1;
kfolds=10;
indices = crossvalind('Kfold',data_out,kfolds);
for i=1:1:length(IAC_M)
    for j=1:1:kfolds
        test = (indices == j); train = ~test;
        filename = strcat(method,caso,dataset,'_Imb',num2str(perc(i)*100),'_Fold',num2str(j),'.csv');
        data = readtable(filename);
        grouping = data{:,29};
        data_in=data{:,2:27};
        data_out=data{:,28};
        orig_data_in=IAC{test,:};
        orig_data_out=IAC_out(test);
        [AUC1(i,j), Sen1(i,j), Spec1(i,j), kappa1(i,j)] =...
            logistic_cross_classic_fromR(orig_data_in,orig_data_out,data_in,data_out,grouping);             
    end   
end
method_name = 'Amelia';
foldername= strcat(caso,'IAC_results/');
mkdir(foldername)
savefile =strcat(foldername,method_name,'_',dataset,'.mat');
save(savefile,'AUC1','Sen1','Spec1','kappa1','method_name');
%% NON IAC 
load_data
dataset='NON_IAC';
method='Amelia_';
dirn = 'CSV';
caso = 'univar_';
column2remove=1;
perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];
kfolds = 10;
rng(163)
[NIAC_M{1},NIAC_M{2},NIAC_M{3},NIAC_M{4}, NIAC_M{5}, NIAC_M{6}, NIAC_M{7}, NIAC_M{8}...
    , NIAC_M{9}, NIAC_M{10}] = create_missing_special_univariate(NON_IAC,perc,column2remove);
% cycle
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
data_out=NON_IAC_out;
separate = 1;
kfolds=10;
indices = crossvalind('Kfold',data_out,kfolds);
for i=1:1:length(NIAC_M)
    for j=1:1:kfolds
        test = (indices == j); train = ~test;
        filename = strcat(method,caso,dataset,'_Imb',num2str(perc(i)*100),'_Fold',num2str(j),'.csv');
        data = readtable(filename);
        grouping = data{:,29};
        data_in=data{:,2:27};
        data_out=data{:,28};
        orig_data_in=NON_IAC{test,:};
        orig_data_out=NON_IAC_out(test);
        [AUC1(i,j), Sen1(i,j), Spec1(i,j), kappa1(i,j)] =...
            logistic_cross_classic_fromR(orig_data_in,orig_data_out,data_in,data_out,grouping);             
    end   
end
method_name = 'Amelia';
foldername= strcat(caso,'NON_IAC_results/');
mkdir(foldername)
savefile =strcat(foldername,method_name,'_',dataset,'.mat');
save(savefile,'AUC1','Sen1','Spec1','kappa1','method_name');
