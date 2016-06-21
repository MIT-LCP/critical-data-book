function [data_in] = impute_value(func,data_in,constraint,indx_class)
% This function imputes data using the mean
% the function use is nanmean because it ignores the NaN
% The data must be already separate by class
missing=ismissing(data_in);
[nrow, ncol]=size(data_in);
substitute_value = feval(func,data_in{indx_class,1:ncol});
substitute_value(constraint.int)=round(substitute_value(constraint.int));
indx_i=and(missing,repmat(indx_class,1,ncol));
for i=find(sum(indx_i))
    data_in{indx_i(:,i),i}= repmat(substitute_value(i),sum(indx_i(:,i)),1);
end
end

