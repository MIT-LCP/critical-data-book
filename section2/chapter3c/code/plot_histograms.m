function plot_histograms(IAC, NON_IAC, pathh, ftsize)

for i=1:size(IAC,2)
    var=IAC(:,i).Properties.VariableNames;
    var = strtok(var, '_');
    figure;
    [nb,xb]=hist(table2array(IAC(:,i)));
    bh=bar(xb,nb);
    set(bh,'FaceColor',[0 0 0],'EdgeColor',[0 0 0], 'LineWidth', 2);
    ylabel('Frequency');
%         histfit(blood_matrix_IAC(:,i),'EdgeColor',[0 0 0]);
    h = get(gca, 'ylabel');
    set(h, 'FontSize', ftsize);
    hold on
    [nb,xb]=hist(table2array(NON_IAC(:,i)));
    bh=bar(xb,nb);
    set(bh,'FaceColor',[0 0.5 0.5],'EdgeColor',[0 0.5 0.5], 'LineWidth', 2);
%         histfit(blood_matrix_NON_IAC(:,i));
    ylabel('Frequency');
    h_legend=legend('IAC','Non-IAC');
    set(h_legend,'FontSize',14);
    
    h = get(gca, 'ylabel');
    set(h, 'FontSize', ftsize);
    xt = get(gca, 'XTick');
    set(gca, 'FontSize', ftsize)
    
    xlabel(var);
        
    print_name=strcat(pathh, var, '.eps');
    print('-depsc', print_name{:})
end

%%%%%%%%%%%%%% end plot categorical