function nr_missing = missing_data(data)

missing_IAC=ismissing(data);
for i=1:size(missing_IAC,2)
    nr_missing(i,1)=size(find(missing_IAC(:,i)),1);
    nr_missing(i,2)=nr_missing(i,1)/size(data,1);
end



 
