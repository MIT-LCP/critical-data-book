%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%
%
%               Create data for Histograms
%
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all
close all
% SELECT DATASET
dataset = 'IAC';
type = 'univar';
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this file loads the data and removes the initial missing data
separate =1;
load_data
method = {'remove','mean','median','linear','knn','randlinear','MI-Cond',...
'MI-MVN'};
switch dataset
    case 'IAC'
        Orig_2_save=DATA(find(alinecohortdatajune15.ALINE_FLG==1),:);
        out=alinecohortdatajune15(find(alinecohortdatajune15.ALINE_FLG==1),:);
        Orig_2_save = Orig_2_save(:,1:end-1);
    case 'NON_IAC'
        Orig_2_save=DATA(find(alinecohortdatajune15.ALINE_FLG==0),:);
        out=alinecohortdatajune15(find(alinecohortdatajune15.ALINE_FLG==0),:);        
        Orig_2_save = Orig_2_save(:,1:end-1);
    otherwise     
end
[Orig_2_save, out] = remove_missing(Orig_2_save,out);
column2remove=1;
% Defining random sample and creating the datasets with missing data
perc = [0.05, 0.10, 0.20, 0.40, 0.80];
rng(163)
[DATA_in_M,orig_data_in] = create_missingness_datasets(data_in,perc,column2remove,type);
switch type
    case 'univar'
        methodindex = [1 2 3 4 5 6 7 8];
 method = {'remove','mean','median','linear','knn','randlinear','MI-Cond',...
'MI-MVN'};       
    case 'multi'
        methodindex = [1 2 3 4 5 6 7]; 
        method = {'remove','mean','median','linear','knn','MI-Cond',...
'MI-MVN'};
    otherwise
        error('myApp:argChk1', 'WRONG type of missigness selected, please try: univar or multi')        
end
for i=methodindex(1:end-2)
    i
    try
        for j=1:1:5% cycle for the different percentages of missingness
            rng(163+i)
            data_in = DATA_in_M{1,j};
            data_in_new{i,j}= data_impute(method{i},data_in,data_out,separate,constraint);
        end
    catch
    end
end

j=methodindex(end-1);
for i =1:1:5
    filename = strcat('MICE','_',dataset,'_',type,'_perc',num2str(perc(i)*100),'_original.csv');
    data = readtable(filename);
    data_in_new{j,i} = data(:,4:29);
end
j=methodindex(end);
for i=1:1:5
    filename = strcat('Amelia','_',dataset,'_',type,'_perc',num2str(perc(i)*100),'_original.csv');
    data = readtable(filename);
    data_in_new{j,i} = data(:,2:27);
end
ORIG_DATA =Orig_2_save;
saveFilename= strcat(type,'_','DataForHistograms',dataset,'.mat');
save(saveFilename,'data_in_new','DATA_in_M','ORIG_DATA','method')

