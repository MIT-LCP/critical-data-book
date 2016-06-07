function [AUC, Sen, Spec, kappa] = logistic_cross_classic_fromR_old(orig_data_in,orig_data_out,data_in,data_out)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    [b,dev,stats] = glmfit(data_in,data_out,'binomial','link','logit'); 
    Fit = glmval(b,orig_data_in,'logit')';
    % Compute performance measures
    % AUC
    [X,Y,T,AUC,OPTROCPT,SUBY,SUBYNAMES] = perfcurve(orig_data_out,Fit,1);
    % Compute kappa, sensitivity specificity using AUC optimal threshold
    Sen= OPTROCPT(2);
    Spec = 1 - OPTROCPT(1);
    optT=T(X==OPTROCPT(1) & Y == OPTROCPT(2)); % find roc optimal threshold
    % Compute the confusion matrix for the first ROC optimal threshold
    [c,cm,ind,per] = confusion(orig_data_out',round(Fit+(0.5-optT(1))));
    cm=cm/length(orig_data_out);
    pc = (cm(1,1)+cm(1,2))*(cm(1,1)+cm(2,1))+(cm(2,1)+cm(2,2))*(cm(1,2)+cm(2,2));
    kappa = (cm(1,1)+cm(2,2)-pc)/(1-pc);
end




