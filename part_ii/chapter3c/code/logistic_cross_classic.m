function [AUC, Sen, Spec, kappa] = logistic_cross_classic(orig_data_in,data_in,data_out,indices)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
num_folds=max(indices);
% Crossvalidation cycle
for i = 1:num_folds
    test = (indices == i); train = ~test;
    if sum(sum(ismissing(data_in(train,:))))
        % Remove data case
        [input, output ] = remove_missing(data_in(train,:),data_out(train));
        % Logistic regression
        [b,dev,stats] = glmfit(input{:,:},output,'binomial','link','logit'); % Logistic regression
    else
        % Logistic regression
        [b,dev,stats] = glmfit(data_in{train,:},data_out(train),'binomial','link','logit'); 
    end
    Fit = glmval(b,orig_data_in{test,:},'logit')';
    % Compute performance measures
    % AUC
    [X,Y,T,AUC(i),OPTROCPT,SUBY,SUBYNAMES] = perfcurve(data_out(test),Fit,1);
    % Compute kappa, sensitivity specificity using AUC optimal threshold
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




