
function plot_multivariate(dataX,dataY,VarNames,fontsize)


figure

% data, [], grouping variable, colors, markers, []
[h,ax,~] =gplotmatrix(dataX,[],dataY,'br','..',[4 4],'on','', VarNames, VarNames);
% set(h,'FontSize',fontsize);

%% uncomment for changing font size
% for i=1:size(ax,1), % rows
%     ytic=get(ax(i,1),'ytick');
%     set(ax(i,1),'YTick',[ytic(1) ytic(end)]);
%     ylab=get(ax(i,1),'YLabel');
%     set(ylab,'Rotation',0);
%     set(ax(i,1),'FontSize',fontsize );
%     set(ylab,'FontSize',fontsize);
% end
% for j=1:size(ax,2), % cols
%     xtic=get(ax(1,j),'xtick');
%     set(ax(end,j),'XTick',[xtic(1) xtic(end)]);
%     xlab=get(ax(end,j),'XLabel');
%     set(ax(end,j),'FontSize',fontsize);
%     set(xlab,'FontSize',fontsize);
% end

% % set(sget(h,'YLabel'),'Rotation',0)
% ax = gca;
% %     set(gca,'XTick', [1.1:0.1:3])  % This automatically sets
%     set(gca,'YLim', [lim_inf, lim_sup])  
%     set(gca,'FontSize',ftsize);