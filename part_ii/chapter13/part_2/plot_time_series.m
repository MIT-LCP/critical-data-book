function []= plot_time_series(input,centros_cluster,outliers,cluster,item)

map=colormap(gray(size(input,1)));

map(1:(size(map,1)/2),:)=map((size(map,1)/2)+1:(size(map,1)/2+size(map,1)/2),:);


figure
str = [char(item),' ', 'cluster ', num2str(cluster)];
title(str);
str2 = [char(item),'cluster', num2str(cluster)];
% hold on % uncomment para tirar titulo do plot

for i=1:size(input,1)
    % plot(var_cluster(i,:), 'color', map(i,:));
    plot(input(i,:),'color',  [0.5 0.5 0.5]);
    hold on
end

for i=1:size(outliers,1)
    % plot(var_cluster(i,:), 'color', map(i,:));
    plot(outliers(i,:),'color', 'r');
    hold on
end

plot(centros_cluster,'Color',[0 0 0],'LineWidth',3);


% print('-depsc', item)

