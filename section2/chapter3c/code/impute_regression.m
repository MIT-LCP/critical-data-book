function [data_in_mdl] = impute_regression(type,data_in,constraint,indx_class,univar)
% This function imputes data using the mean
% the function use is nanmean because it ignores the NaN
% The data must be already separate by class
missing_all=ismissing(data_in);
% Getting the data from the class
[nrow, ncol]=size(data_in);
indx_i=and(missing_all,repmat(indx_class,1,ncol));
auxiter=sum(indx_i);
[data_in_mdl] = random_sampling(data_in,indx_class);
%crit =+inf;
if univar == 1
    nrounds = 1;
elseif univar ==0
    nrounds=10;
else
    error('myApp:argChk1', 'Wrong impute method stated, for data not separated by classes')
    
end
for k = 1:1:nrounds
    for i=find(auxiter)
        % For the stoping criteria
%        aux_crit1 = data_in_mdl{indx_i(:,i),i}; % the missing data values
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
                % Is not working at the moment due to Licenses
                %mdl=MultiPolyRegress(data_in_mdl{indx_class,[1:i-1 i+1:end]},data_in_mdl{indx_class,i},degree);
                %[estimate] = predict_poly(mdl,data_in_mdl{indx_i(:,i),[1:i-1 i+1:end]});
        end
        estimate = max(min(estimate,constraint.max(i)),constraint.min(i));
        if sum(i == constraint.int)
            estimate= round(estimate);
        else
        end
%        aux_crit1 = abs(estimate-aux_crit1);
        data_in_mdl{indx_i(:,i),i}= estimate;
        % Impose contraints
        % Round values for integers        
%        aux_crit2(i) = mean(aux_crit1);
    end
%    crit = mean(aux_crit2);
%    k = k+1;
end
end

