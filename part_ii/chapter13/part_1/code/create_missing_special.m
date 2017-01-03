function [data_m] = create_missing_special(data_in,perc)
% Given the perc (percentage) of missing data that you want to introduce
% in this input dataset it will be created randomly (uniformly) through
% the number of rows and columns.
[rows, cols] = size(data_in);
scale = rows*cols;
n_rem = ceil(perc(end)*rows*cols);
% Create more random numbers than necessary to eleminate the repetitions
% later on
aux_rem = [randi([1 rows],n_rem*3,1) , randi([1 cols],n_rem*3,1)];
% Eleminate multiple entries (or repetitions)
[rem]= unique(aux_rem,'rows','stable');

data_m{1} = data_in;
for i=1:1:ceil(perc(1)*scale)
    data_m{1}(rem(i,1),rem(i,2)) = {nan};
end

for jjj = 2:1:length(perc)
    data_m{jjj} = data_m{jjj-1};
    for i =ceil(perc(jjj-1)*scale):1:ceil(perc(jjj)*scale)
        data_m{jjj}(rem(i,1),rem(i,2)) = {nan};
    end
end
end

