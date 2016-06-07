function [data]=removeNaNsTables(data)

aux=table2cell(data);
findNaN = cellfun(@(aux) any(isnan(aux)),aux);
indexToRem=[];
for i = 1:size(findNaN,1)
    if sum(findNaN(i,:))>0
        indexToRem=[indexToRem i];
    end
end

data(indexToRem,:)=[];

fprintf('%d removed bc NaN \n',length(indexToRem));
