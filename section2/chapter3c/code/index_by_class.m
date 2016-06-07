function [indx0,indx1] = index_by_class(data_out)
%UNTITLED7 Summary of this function goes here
%   Detailed explanation goes here

% for the case of two classes
indx0 = data_out == 0;
indx1 = data_out == 1;
end

