% Initializations and crossvalidation

indices = crossvalind('Kfold',data_out,kfolds);
% Initializing variables
AUC=zeros(length(perc),length(method),kfolds);
Sen=zeros(length(perc),length(method),kfolds);
Spec=zeros(length(perc),length(method),kfolds);
kappa=zeros(length(perc),length(method),kfolds);

switch type
    case 'univar'
        methodindex = [1 2 3 4 7 8];       
    case 'multi'
        methodindex = [1 2 3 4 7];     
    otherwise
        error('myApp:argChk1', 'WRONG type of missigness selected, please try: univar or multi')        
end