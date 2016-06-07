function [data_in, data_out ] = remove_missing(data_in,data_out )
% This function removes the rows of the dataset where data is missing
% it also removes the corresponding missing rows of the output vector

missing=ismissing(data_in); % Get missing data
% Remove rows with missing data
data_in = data_in(~any(missing,2),:);
data_out=data_out(~any(missing,2),1); 
end

