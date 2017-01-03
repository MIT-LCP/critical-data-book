function [data_new] = hot_deck_input(data)

wo_missing=data;
[row,~]=find(ismissing(data));
row=unique(row);
wo_missing(row,:)=[];

%disp(['nr of patients removed because of missing data: ', num2str(length(row))]);

need_input=data(row,:);

need_input=table2array(need_input);
wo_missing=table2array(wo_missing);
cluster_data=wo_missing;
% ISTO E' UMA NORMALIZACAO???
% for i=1:size(wo_missing,2)
%     % NAO PERCEBO???
%     if ~(sum(wo_missing(i)==0) + sum(wo_missing(i)==1) == length(wo_missing(i)))  &&  ~(sum(wo_missing(i)==1) + sum(wo_missing(i)==-1) == length(wo_missing(i)))
%         cluster_data(:,i)=normalize_matrix(wo_missing(:,i));
%     else
%         cluster_data(:,i)=wo_missing(:,i);
%     end
% end

% check best number of clusters using silhouette
E = evalclusters(cluster_data,'kmeans','silhouette','klist',[1:10]);
% figure;
% plot(E)
% name='silhouetteIAC';
% print_name=strcat(pathh, name, '.eps');
% print('-depsc', print_name)

[IDX, center, ~, ~] = kmeans(cluster_data, E.OptimalK);

% Computation of the distance of the samples to the clusters
aux = size(need_input,1);
dist = zeros(aux,E.OptimalK);
for j = 1:1:E.OptimalK
    dist(:,j) = (nansum((need_input-repmat(center(j,:),aux,1)).^2,2)).^0.5;
end
[~,new_idx] = min(dist,[],2);

% Mean of every cluster
for i=1:size(center,1)
    data_cluster=cluster_data(IDX==i,:);
    for ii=1:size(data_cluster,2)
        mean_cluster(i,ii)=nanmean(data_cluster(:,ii));
    end
end

% after_input is the matrix after missing data imputation
% input is based on the mean values of the patients in the cluster
after_input=need_input;
for i=1:size(need_input,1)
    id=find(isnan(need_input(i,:)));
    for ii=1:length(id)
        after_input(i,id(ii))=mean_cluster(new_idx(i),id(ii));
    end
end
% create data to go out 
data_new = table2array(data);
data_new(row,:)=after_input;




