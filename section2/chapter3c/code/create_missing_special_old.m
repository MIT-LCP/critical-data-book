function [data_05,data_10,data_20,data_30,data_40, data_50, data_60,data_70, data_80, data_90] = create_missing_special_old(data_in,perc)
% Given the perc (percentage) of missing data that you want to introduce
% in this input dataset it will be created randomly (uniformly) through
% the number of rows and columns.
[rows, cols] = size(data_in);
scale = rows*cols;
n_rem = ceil(perc(end)*rows*cols);
aux_rem = [randi([1 rows],n_rem*3,1) , randi([1 cols],n_rem*3,1)];
% Eleminate multiple entries
[rem]= unique(aux_rem,'rows','stable'); 
% Create missing data with 5%
data_05 = data_in;
for i=1:1:ceil(perc(1)*scale)
    data_05(rem(i,1),rem(i,2)) = {nan};
end
% Create missing data with 10%
data_10 = data_05;
for i =ceil(perc(1)*scale):1:ceil(perc(2)*scale)
    data_10(rem(i,1),rem(i,2)) = {nan};
end
% Create missing data with 20%
data_20 = data_10;
for i =ceil(perc(2)*scale):1:ceil(perc(3)*scale)
    data_20(rem(i,1),rem(i,2)) = {nan};
end
% Create missing data with 40%
data_30 = data_20;
for i =ceil(perc(3)*scale):1:ceil(perc(4)*scale)
    data_30(rem(i,1),rem(i,2)) = {nan};
end
data_40 = data_30;
for i =ceil(perc(4)*scale):1:ceil(perc(5)*scale)
    data_40(rem(i,1),rem(i,2)) = {nan};
end
data_50 = data_40;
for i =ceil(perc(5)*scale):1:ceil(perc(6)*scale)
    data_50(rem(i,1),rem(i,2)) = {nan};
end
data_60 = data_50;
for i =ceil(perc(6)*scale):1:ceil(perc(7)*scale)
    data_60(rem(i,1),rem(i,2)) = {nan};
end
data_70 = data_60;
for i =ceil(perc(7)*scale):1:ceil(perc(8)*scale)
    data_70(rem(i,1),rem(i,2)) = {nan};
end
data_80 = data_70;
for i =ceil(perc(8)*scale):1:ceil(perc(9)*scale)
    data_80(rem(i,1),rem(i,2)) = {nan};
end
data_90 = data_80;
for i =ceil(perc(9)*scale):1:ceil(perc(10)*scale)
    data_90(rem(i,1),rem(i,2)) = {nan};
end
end

