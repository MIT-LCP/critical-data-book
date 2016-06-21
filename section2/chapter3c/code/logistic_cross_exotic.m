function [AUC, Sen, Spec, kappa] = logistic_cross_exotic(method,orig_data_in,data_in,data_out,indices,separate,constraint)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
num_folds=max(indices);
% Crossvalidation cycle
token2=zeros(10,1);
for i = 1:num_folds
    test = (indices == i); train = ~test;
    if strcmp(method,'fulldata')
        data_in_new=data_in(train,:);
    else
        token1=10;
        if strcmp(method,'remove') || strcmp(method,'hotdeck') || strcmp(method,'knn')
            if separate == 0
                Tmiss = ismissing(data_in(train,:));
                token1 = size(Tmiss,1)-sum(any(Tmiss,2));
            elseif separate ==1
                [indx0,indx1] = index_by_class(data_out);
                indx0=logical(indx0);
                indx1=logical(indx1);
                Tmiss0 = ismissing(data_in(train,:));
                Tmiss1 = ismissing(data_in(train,:));
                token1 = min(sum(indx0)-sum(any(Tmiss0,2)),sum(indx1)-sum(any(Tmiss1,2)));
            end
        end
        if token1 > 0
            data_in_new= data_impute(method,data_in(train,:),data_out(train),separate,constraint);
        else
            token2(i) = 1;
        end
    end
    if token2(i) == 0
        if sum(sum(ismissing(data_in_new)))
            % Remove data case
            [input, output ] = remove_missing(data_in_new,data_out(train));
            % Logistic regression
            [b,dev,stats] = glmfit(input{:,:},output,'binomial','link','logit'); % Logistic regression
        else
            % Logistic regression
            [b,dev,stats] = glmfit(data_in_new{:,:},data_out(train),'binomial','link','logit');
        end
        Fit = glmval(b,orig_data_in{test,:},'logit')';
        % Compute performance measures
        % AUC
        [X,Y,T,AUC(i),OPTROCPT,SUBY,SUBYNAMES] = perfcurve(data_out(test),Fit,1);
        % Compute kappa, sensitivity specificity using AUC optimal threshold
        [c,cm,ind,per] = confusion(data_out(test)',Fit);
        Sen(i) = OPTROCPT(2);
        Spec(i) = 1 - OPTROCPT(1);
        optT=T(X==OPTROCPT(1) & Y == OPTROCPT(2)); % find roc optimal threshold
        % Compute the confusion matrix for the first ROC optimal threshold
        [c,cm,ind,per] = confusion(data_out(test)',round(Fit+(0.5-optT(1))));
        cm=cm/sum(test);
        pc = (cm(1,1)+cm(1,2))*(cm(1,1)+cm(2,1))+(cm(2,1)+cm(2,2))*(cm(1,2)+cm(2,2));
        kappa(i) = (cm(1,1)+cm(2,2)-pc)/(1-pc);
    end
end
if sum(and(token2, ones(10,1)))
    AUC =zeros(10,1);
    Sen = zeros(10,1);
    Spec =zeros(10,1);
    kappa =zeros(10,1);
end

end




