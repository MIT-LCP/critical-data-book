function [AUC, Sen, Spec, kappa] = crossvalidation_R_data(dataset,orig_data_in,data_out,perc,kfolds,type,indices)

mi_methods={'MICE','Amelia'};
AUC=zeros(length(perc),length(mi_methods),kfolds);
Sen=zeros(length(perc),length(mi_methods),kfolds);
Spec=zeros(length(perc),length(mi_methods),kfolds);
kappa=zeros(length(perc),length(mi_methods),kfolds);
w = warning ('off','all');
for kk=1:1:length(mi_methods)
    used_method = mi_methods{kk};
    disp(strcat('Running method: ',used_method))
    for i=1:1:length(perc)
        try
            disp(strcat('Percentage: ',num2str(perc(i)*100),'%'))
            for j=1:1:kfolds
                test = (indices == j); train = ~test;
                filename = strcat(used_method,'_',dataset,'_',type,'_perc',num2str(perc(i)*100),'_Fold',num2str(j),'.csv');
                data = readtable(filename);
                if strcmp(used_method,'MICE')
                    grouping = data{:,2};
                    data_in_impute=data{:,4:end-1};
                    data_out_impute=data{:,end};
                elseif strcmp(used_method,'Amelia')
                    grouping = data{:,end};
                    data_in_impute=data{:,2:end-2};
                    data_out_impute=data{:,end-1};
                end
                orig_data_out_test=data_out(test);
                orig_data_in_test=orig_data_in{test,:};
                [AUC(i,kk,j), Sen(i,kk,j), Spec(i,kk,j), kappa(i,kk,j)] =...
                    logistic_cross_classic_fromR(orig_data_in_test,orig_data_out_test,data_in_impute,data_out_impute,grouping);
            end
        catch
        end
    end
end