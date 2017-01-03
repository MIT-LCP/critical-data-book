% pass data to .csv file
% This file saves the folds to a .csv so it can be read in R for the 
% multiple imputation methods

% Clear everything in the workspace
clearvars
close all
% this file loads the data and removes the initial missing data
% Defining random sample and creating the datasets with missing data
perc = [0.05, 0.10, 0.20, 0.30, 0.40, 0.50, 0.60,0.70, 0.80, 0.90];
column2remove= 1;
all_dataset = {'IAC','NON_IAC'};
all_type= {'univar','multi'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create the datasets
%%%%%%%%%%%%%%%%%%%%%%%%
dirn = 'CSV';
mkdir('CSV');
for kk = 1:1:length(all_dataset)
    dataset = all_dataset{kk};
    disp(strcat('Dataset: ',dataset))
    for gg= 1:1:length(all_type)
        type = all_type{gg};
        disp(strcat('Type of missingness: ',type))
        load_data
        rng(163)
        [DATA_in_M,orig_data_in] = create_missingness_datasets(data_in,perc,column2remove,type);
        % cycle
        kfolds=10;
        rng(163)
        indices = crossvalind('Kfold',data_out,kfolds);
        for i=1:1:length(perc)% cycle for the different percentages of missingness
            disp(strcat('Percentage: ',num2str(perc(i)*100),'%'))
            filename = strcat(dirn,'/',dataset,'_',type,'_perc',num2str(perc(i)*100),'_original','.csv');
            auxT = table(data_out);
            auxT.Properties.VariableNames = {'output'};
            T = [DATA_in_M{i}(:,:),auxT];
            writetable(T,filename);
            for j=1:1:kfolds
                clear auxT T
                test = (indices == j); train = ~test;
                auxT = table(data_out(train));
                auxT.Properties.VariableNames = {'output'};
                filename = strcat(dirn,'/',dataset,'_',type,'_perc',num2str(perc(i)*100),'_Fold',num2str(j),'.csv');
                T = [DATA_in_M{i}(train,:),auxT];
                writetable(T,filename);
            end
        end
    end
end