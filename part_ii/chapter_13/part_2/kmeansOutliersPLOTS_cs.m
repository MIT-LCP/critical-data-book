function [c1,c2,center1,center2,removed_c1,removed_c2]=kmeansOutliersPLOTS_cs(input,weight,criterion)

num_clusters=2;
[idx,centers,~,D] = kmeans(input,num_clusters);
c1 = input(find(idx==1),:);
center1 = centers(1,:);
c2 = input(find(idx==2),:);
center2 = centers(2,:);

       
%Select Criterion
switch criterion
    % - ###### CRITERIO 1: Se a distância entre um ponto e o seu cluster for maior que a distância
    % entre clusters então remove? ##### : Isto pode ser mau pq os outliers
    % estão a puxar os clusters para eles... k-medoid não aconteceria isto.
    % um problema disto é que o facto de ter vários atributos dentro do
    % aceitável faz diminuir a distancia euclidiana e mesmo que um dos
    % atributos esteja muito fora ele não terá peso suficiente para ser
    % eliminado.% usar distância entre clusters como referência para saber o que são
    % outliers?
    case 1
        
        %creates matrix with distances
        for i = 1:size(centers,1)
            for j = 1:size(centers,1)
                if i==j
                    distClusters(i,j)=inf;
                else
                    distClusters(i,j)=pdist([centers(i,:);centers(j,:)],'euclidean');
                end
            end
        end
        
        outlierRem=[];
        storeDistances=zeros(length(idx),1);
        
        for i=1:length(idx)
            storeDistances(i)=pdist([input(i,:);centers(idx(i),:)],'euclidean');
            %             [storeDistances(i) distClusters]
            if storeDistances(i)>min(distClusters(idx(i),:))*weight
                outlierRem=[outlierRem i];
            end
        end
        outlierRem=outlierRem';
        fprintf('nr of patients removed using k-means crit 1: %d \n',size(outlierRem,1));
        
        int=intersect(find(idx==1),outlierRem);
        removed_c1=input(int,:);
        [~,~,ib]=intersect(removed_c1,c1,'rows');
        c1(ib,end+1)=1;
        
        clear int ib
        
        int=intersect(find(idx==2),outlierRem);
        removed_c2=input(int,:);
        [~,~,ib]=intersect(removed_c2,c2,'rows');
        c2(ib,end+1)=1;
        
    case 2
        %             weight=1/(5*num_clusters);
        
        [NN,~]=min(D); % nearest neighour to the cluster center
        [FN,~]=max(D); % furthest neighour to the cluster center
        
        
        %             distortion=NN/FN;
        
        for ii=1:size(D,1)
            for iii=1:size(D,2)
                distortion(ii,iii)=NN(iii)/D(ii,iii);
            end
        end
        [outlierRem,~]=find(distortion<weight);
        outlierRem=unique(outlierRem);
        
        int=intersect(find(idx==1),outlierRem);
        removed_c1=input(int,:);
        [~,~,ib]=intersect(removed_c1,c1,'rows');
        c1(ib,end+1)=1;
        
        clear int ib
        
        int=intersect(find(idx==2),outlierRem);
        removed_c2=input(int,:);
        [~,~,ib]=intersect(removed_c2,c2,'rows');
        c2(ib,end+1)=1;
        
        fprintf('nr of patients removed using k-means crit 2: %d \n',size(outlierRem,1));
end



plot_time_series(c1,center1,removed_c1,1,'c1');
