function CATIA_plot_histogramsC_classes(IAC, NON_IAC, pathh, ftsize,unitsFig,nbins)


% Test if variable IAC is the same as NON_IAC
j=1;
for i=IAC.Properties.VariableNames
    if ~strcmp(i,NON_IAC.Properties.VariableNames(j))   
        error('variable names of IAC and NON_IAC are not the same')
    end
    j=j+1;
end

varNames=strtok(IAC.Properties.VariableNames,'_');

binary_legend(1,:)={{'Female','Male'},...
    {'Medical ICU','Surgical ICU'},...
    {'No','Yes'},...
    {'No','Yes'},...
    {'No','Yes'},...
    {'No','Yes'},...
    {'No','Yes'},...
    {'No','Yes'},...
    {'No','Yes'},...
    {'No','Yes'},...
    {'No','Yes'},...
    {'No','Yes'},...
    {'No','Yes'},...
    {'No','Yes'},...
    }
% Tables to array
IAC=table2array(IAC);
NON_IAC=table2array(NON_IAC);

for i=1:size(IAC,2)
  
    figure;
    
    barPositioning=linspace(min(min(IAC(:,i)),min(NON_IAC(:,i))),max(max(IAC(:,i)),max(NON_IAC(:,i))),nbins);
    
    [counts,xb]=hist(IAC(:,i),barPositioning);
    normalizedCounts= 100 * counts / sum(counts);  

    if nbins==2
        bh=bar(xb,normalizedCounts,0.1);
    else
        bh=bar(xb,normalizedCounts,1);
    end
    
    set(bh,'FaceColor',[0 0 0],'EdgeColor',[0 0 0], 'LineWidth', 2);
    
    if nbins==2
        set(gca,'XTickLabel',binary_legend{1,i})
    end
    
    
    ylabel('Normalized Count [%]');
%         histfit(blood_matrix_IAC(:,i),'EdgeColor',[0 0 0]);
    h = get(gca, 'ylabel');
    set(h, 'FontSize', ftsize);
    hold on
    [counts,xb]=hist(NON_IAC(:,i),barPositioning);
    normalizedCounts= 100 * counts / sum(counts);  

    
    if nbins==2
    bh=bar(xb,normalizedCounts,0.05);
    else
    bh=bar(xb,normalizedCounts,0.6);
    end
    
    set(bh,'FaceColor',[0 0.5 0.5],'EdgeColor',[0 0.5 0.5], 'LineWidth', 2);
%         histfit(blood_matrix_NON_IAC(:,i));
    ylabel('Normalized Count [%]');
    h_legend=legend('Class 0','Class 1');
    set(h_legend,'FontSize',ftsize);
    
    h = get(gca, 'ylabel');
    set(h, 'FontSize', ftsize);
    xt = get(gca, 'XTick');
    set(gca, 'FontSize', ftsize)
    
    xlabel(unitsFig(i));
    
    print_name=strcat(pathh, varNames(i), '.eps');
    print('-depsc', print_name{:})
end

%%%%%%%%%%%%%% end plot categorical