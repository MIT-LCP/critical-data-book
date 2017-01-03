function [data_in_mdl] = impute_regression_univariate(type,data_in,constraint,indx_class)
% This function imputes data using the mean
% the function use is nanmean because it ignores the NaN
% The data must be already separate by class
missing_all=ismissing(data_in);
% Getting the data from the class
[nrow, ncol]=size(data_in);
indx_i=and(missing_all,repmat(indx_class,1,ncol));
auxiter=sum(indx_i);
[data_in_mdl] = random_sampling(data_in,indx_class);
crit =+inf;
for i=find(auxiter)
        % For the stoping criteria
        switch type
            case 'linear'
                if constraint.max == 1
                [b,dev,stats] = glmfit(data_in_mdl{indx_class,[1:i-1 i+1:end]}...
                    ,data_in_mdl{indx_class,i},'binomial','link','logit'); 
                [estimate] = glmval(b,data_in_mdl{indx_i(:,i),[1:i-1 i+1:end]},'logit')';                    
                else
                % regress function removes all the NaN rows
                mdl = fitlm(data_in_mdl{indx_class,[1:i-1 i+1:end]}, data_in_mdl{indx_class,i});
                % Estimating the new points
                [estimate, NewMPGCI] = predict(mdl,data_in_mdl{indx_i(:,i),[1:i-1 i+1:end]});
                end
            case 'randlinear'
                if constraint.max == 1
                [b,dev,stats] = glmfit(data_in_mdl{indx_class,[1:i-1 i+1:end]}...
                    ,data_in_mdl{indx_class,i},'binomial','link','logit'); 
                [aux_est] = glmval(b,data_in_mdl{indx_i(:,i),[1:i-1 i+1:end]},'logit')';
                [estimate] = normrnd(aux_est,std(aux_est)); 
                else
                % regress function removes all the NaN rows
                mdl = fitlm(data_in_mdl{indx_class,[1:i-1 i+1:end]}, data_in_mdl{indx_class,i});
                % Estimating the new points
                [aux_est, NewMPGCI] = predict(mdl,data_in_mdl{indx_i(:,i),[1:i-1 i+1:end]});
                [estimate] = normrnd(aux_est,std(aux_est));
                end
            case 'quadratic'
                degree = 2;
                mdl=MultiPolyRegress(data_in_mdl{indx_class,[1:i-1 i+1:end]},data_in_mdl{indx_class,i},degree);
                [estimate] = predict_poly(mdl,data_in_mdl{indx_i(:,i),[1:i-1 i+1:end]});
        end
        estimate = max(min(estimate,constraint.max(i)),constraint.min(i));
        if sum(i == constraint.int)
            estimate= round(estimate);
        else
        end
        data_in_mdl{indx_i(:,i),i}= estimate;
        % Impose contraints
        % Round values for integers        
end

end

