function [data_in] = create_missing(data_in, perc )
% Given the perc (percentage) of missing data that you want to introduce
% in this input dataset it will be created randomly (uniformly) through
% the number of rows and columns.

[rows, cols] = size(data_in);
n_rem = ceil(perc*rows);
rem = [randi([1 rows],n_rem,1) , randi([1 cols],n_rem,1)];
for i=1:1:n_rem
    data_in(rem(i,1),rem(i,2)) = {nan};
end
end

