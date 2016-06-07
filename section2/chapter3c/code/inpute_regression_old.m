function [data_in] = inpute_regression(type,data_in,constraint,indx_class)
% This function inputes data using the mean
% the function use is nanmean because it ignores the NaN
% The data must be already separate by class
missing_all=ismissing(data_in);
% Getting the data from the class
data_class = data_in(indx_class,:);
% Remove NaNs
data_class = data_class(~any(ismissing(data_class),2),:);
%data_class = data_class(~any(missing_class,2),:);
[nrow, ncol]=size(data_in);
indx_i=and(missing_all,repmat(indx_class,1,ncol));
auxiter=sum(indx_i);
for i=find(auxiter)
    [data_in_aux] = inpute_value(@nanmean,data_in,constraint,indx_class);
    switch type
        case 'linear'
            % regress function removes all the NaN rows
            mdl = fitlm(data_class{:,[1:i-1 i+1:end]}, data_class{:,i});
            % Estimating the new points
            [estimate, NewMPGCI] = predict(mdl,data_in_aux{indx_i(:,i),[1:i-1 i+1:end]});
        case 'quadratic'
            degree = 2;
            mdl=MultiPolyRegress(data_class{:,[1:i-1 i+1:end]},data_class{:,i},degree); 
            [estimate] = predict_poly(degree,newdata);                  
    end    
    % Impose contraints
    estimate = max(min(estimate,constraint.max(i)),constraint.min(i));
    % Round values for integers
    if sum(i == constraint.int)
        data_in{indx_i(:,i),i}= round(estimate);
    else
        data_in{indx_i(:,i),i}= estimate;
    end
end
end

