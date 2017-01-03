% The plots for the comparison of the logistic regression comparison
% throughout the methods and percentages

clear all
close all
dataset='IAC';
type = 'univar';
name_saved_file = strcat(dataset,'_',type);

%% LOAD
load (namedataset)

%%  Comparing various methods
leng =length(perc(1:9)); % only going until 80%
% vector of colors
colorvector = {[166,206,227]/255,[31,120,180]/255,[178,223,138]/255,...
    [51,160,44]/255,[251,154,153]/255,[253,191,111]/255,...
    [255,127,0]/255,[202,178,214]/255,[227,26,28]/255};
% The univariate case has one more method than the multivariate case
switch type
    case 'univar'
        methodindex = [1 2 3 4 5 6 7 8];
        legendnames = {'Ref.','Complete','Mean','Median','Linear','Stc. Linear','KNN','MI-Linear','MI-MVN'};
    case 'multi'
        methodindex = [1 2 3 4 5 6 7];
        legendnames = {'Ref.','Complete','Mean','Median','Linear','KNN','MI-Cond.','MI-MVN'};
        if length(methodindex) == 7
            colorvector{6} = colorvector{7};
            colorvector{7} =  colorvector{8};
        end
    otherwise
        
end

%% AUC plot
perf_name='AUC';
perf = AUC;
comp_perf =FAUC;
number_figure = 1;
[figAUC] = make_plot(number_figure,perc,leng,methodindex,legendnames,perf_name,perf,comp_perf,colorvector);
print('-depsc','-painters', strcat(namedataset,'_',perf_name,'.eps'))       

%% Sensitivity plot
perf_name='Sensitivity';
perf = Sen;
comp_perf =FSen;
number_figure = 2;
[figSen] = make_plot(number_figure,perc,leng,methodindex,legendnames,perf_name,perf,comp_perf,colorvector);
print('-depsc','-painters', strcat(namedataset,'_',perf_name,'.eps'))         

%% Specificity plot
perf_name='Specificity';
perf = Spec;
comp_perf =FSpec;
number_figure = 3;
[figSpec] = make_plot(number_figure,perc,leng,methodindex,legendnames,perf_name,perf,comp_perf,colorvector);
print('-depsc','-painters', strcat(namedataset,'_',perf_name,'.eps'))  

%% Cohen's Kappa plot
perf_name='Kappa';
perf = kappa;
comp_perf =Fkappa;
number_figure = 4;
[figkappa] = make_plot(number_figure,perc,leng,methodindex,legendnames,perf_name,perf,comp_perf,colorvector);
print('-depsc','-painters', strcat(namedataset,'_',perf_name,'.eps'))  



