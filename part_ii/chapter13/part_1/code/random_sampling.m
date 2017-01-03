function [data_in] = random_sampling(data_in,indx_class)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
missing=ismissing(data_in);
[nrow, ncol]=size(data_in);

indx_i=and(missing,repmat(indx_class,1,ncol));
for i=find(sum(indx_i))
    clear substitute_value
    substitute_value = randsample(data_in{(~indx_i(:,i))&indx_class,i},sum(indx_i(:,i)),true); 
    data_in{indx_i(:,i),i}= substitute_value;
%    sum(ismissing(data_in(indx_class,i)))
end
end

