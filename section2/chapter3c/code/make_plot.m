function [fig] = make_plot(number_figure,perc,leng,methodindex,legendnames,perf_name,perf,comp_perf,colorvector)

fig=figure(number_figure);
hold on;
ref = plot(perc(1:9),repmat(mean(comp_perf),1,leng),'color',colorvector{9});
for j=methodindex
    value = mean(perf(1:leng,j,:),3);
    plot_m{j}=plot(perc(value > 0),value(value > 0),'-x','color',colorvector{j});
end
hXLabel = xlabel('Missingness');
hYLabel = ylabel(perf_name);
plot_charact