AUC(10,:,:)=AUC(6,:,:);
Sen(10,:,:)=Sen(6,:,:);
Spec(10,:,:)=Spec(6,:,:);
kappa(10,:,:)=kappa(6,:,:);

% Initializing variables
AUC1=zeros(length(perc),length(method),kfolds);
Sen1=zeros(length(perc),length(method),kfolds);
Spec1=zeros(length(perc),length(method),kfolds);
kappa1=zeros(length(perc),length(method),kfolds);
methodindex = [1 2 3 4 6 7];
for j=methodindex
    j
    try
        i=6;% cycle for the different percentages of missingness
            rng(163+i)
            data_in = IAC_M{1,i};
            [AUC1(i,j,:), Sen1(i,j,:), Spec1(i,j,:), kappa1(i,j,:)]...
                =logistic_cross(method{j},orig_data_in,data_in,...
                data_out,indices,separate,constraint);

    catch        
    end
end

AUC(6,:,:)=AUC1(6,:,:);
Sen(6,:,:)=Sen1(6,:,:);
Spec(6,:,:)=Spec1(6,:,:);
kappa(6,:,:)=kappa1(6,:,:);