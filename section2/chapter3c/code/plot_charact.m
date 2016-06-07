% Plot characteristics
hLegend = legend(legendnames{:},'location', 'SouthEast');
set(gca,   'XTick'       , 0:0.1:1)
set(ref,'LineWidth', 2);
for j=methodindex 
    set(plot_m{j},'MarkerSize', 10,...
      'LineWidth', 2);
end
set( gca,'FontName','Helvetica' );
set([hXLabel, hYLabel],'FontName','AvantGarde');
set([hLegend, gca],'FontSize', 12);
set([hXLabel, hYLabel] ,'FontSize',16);
%set( hTitle,'FontSize',14, 'FontWeight','bold');
set(gca, ...
    'Units', 'centimeters');
set(gca, ...
    'OuterPosition', [0 0 16 12]);
set(gcf, ...
    'Units', 'centimeter');
set(gcf, ...
    'Position', [16 20 16 12]);
set(gcf, ...
    'PaperUnits','centimeters');
set(gcf, ...
    'PaperSize',[16 12]);
set(gcf, ...
    'PaperPosition',[0 0 16 12]);
        %saveas(fig{k},filename);
      set(gcf, 'PaperPositionMode', 'auto');