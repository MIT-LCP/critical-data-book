function [AUC,Sen,Spec,kappa]  = method_comparison (DATA_in_M,orig_data_in,data_out,separate,constraint,perc,method,kfolds,type,indices)


switch type
    case 'univar'
        methodindex = [1 2 3 4 5 6];       
    case 'multi'
        methodindex = [1 2 3 4 5];     
    otherwise
        error('myApp:argChk1', 'WRONG type of missigness selected, please try: univar or multi')        
end

% Initializing variables
AUC=zeros(length(perc),length(methodindex),kfolds);
Sen=zeros(length(perc),length(methodindex),kfolds);
Spec=zeros(length(perc),length(methodindex),kfolds);
kappa=zeros(length(perc),length(methodindex),kfolds);

for j=methodindex
    disp(strcat('Running method: ',method(j)))
    try
        for i=1:1:length(perc)% cycle for the different percentages of missingness
            rng(163+i) % random sample
            disp(strcat('Percentage: ',num2str(perc(i)*100),'%'))
            data_in = DATA_in_M{1,i};
            [AUC(i,j,:), Sen(i,j,:), Spec(i,j,:), kappa(i,j,:)]...
                =logistic_cross(method{j},orig_data_in,data_in,...
                data_out,indices,separate,constraint);
        end
    catch        
    end
end

end