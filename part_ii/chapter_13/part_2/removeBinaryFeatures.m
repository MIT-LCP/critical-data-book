function [data,dataBinary]=removeBinaryFeatures(data)


featRem=[];
for i=1:size(data,2)
    if (nansum(table2array(data(:,i))==0) + nansum(table2array(data(:,i))==1)) + sum(isnan(table2array(data(:,i)))) == length(table2array(data(:,i)))
        featRem=[featRem i];
        
    end
end
dataBinary=data(:,featRem);
data(:,featRem)=[];
