% The plots that I make 

clear all
close all
dataset='IAC';
namedataset = 'IAC_Separate_univar';
load (namedataset)

%%  Comparing various methods

% AUC plot
leng =length(perc(1:9));
fig1=figure(1);
hold on;
%methodindex = [1 2 3 4 5 7 8];
methodindex = [1 2 3 4 5 7 8 9];
%colorvector = ['g','b','c','m','k','m','r','y','b'];
legendnames = {'Ref.','Complete','Mean','Median','Linear','Stc. Linear','KNN','MI-Linear','MI-MVN'};
%legendnames = {'Ref.','Complete','Mean','Median','Linear','KNN','MI-Cond.','MI-MVN'};
colorvector = {[166,206,227]/255,[31,120,180]/255,[178,223,138]/255,...
    [51,160,44]/255,[251,154,153]/255,[227,26,28]/255,[253,191,111]/255,...
    [255,127,0]/255,[202,178,214]/255};
% if length(methodindex) == 8
%     colorvector{7} = colorvector{8};
%     colorvector{8} =  colorvector{9};  
% end
ref = plot(perc(1:9),repmat(mean(FAUC),1,leng),'color',colorvector{6});
%refrandom = plot(perc,repmat(0.5,1,leng));
for j=methodindex
    value = mean(AUC(1:leng,j,:),3);
    plot_m{j}=plot(perc(value > 0),value(value > 0),'-x','color',colorvector{j});
end
%hTitle  = title (['AUC performance for',' ',dataset]);
hXLabel = xlabel('Missingness');
hYLabel = ylabel('AUC');
plot_charact
print('-depsc','-painters', strcat(namedataset,'_AUC','.eps'))       

%saveas(fig1,strcat(namedataset,'_AUC','.png'))
% Sen plot
fig2=figure(2);
hold on;
ref = plot(perc(1:9),repmat(mean(FSen),1,leng),'color',colorvector{6});
for j=methodindex
    value = mean(Sen(1:leng,j,:),3);
    plot_m{j}=plot(perc(value > 0),value(value > 0),'-x','color',colorvector{j});
end
%hTitle  = title (['Sensitivity performance for',' ',dataset]);
hXLabel = xlabel('Missingness');
hYLabel = ylabel('Sensitivity');
plot_charact
ylim([0.0 0.6])
print('-depsc','-painters', strcat(namedataset,'_Spec','.eps'))        
%saveas(fig2,strcat(namedataset,'_Sen','.png'))

% Spec plot
fig3=figure(3);
hold on;
ref = plot(perc(1:9),repmat(mean(FSpec),1,leng),'color',colorvector{6});

%refrandom = plot(perc,repmat(0.5,1,leng));
for j=methodindex
    value = mean(Spec(1:leng,j,:),3);
    plot_m{j}=plot(perc(value > 0),value(value > 0),'-x','color',colorvector{j});
end
%hTitle  = title (['Specificity performance for',' ',dataset]);
hXLabel = xlabel('Missingness');
hYLabel = ylabel('Specificity');
ylim([0.9 1.0])
plot_charact
print('-depsc','-painters', strcat(namedataset,'_Sen','.eps'))        
%saveas(fig3,strcat(namedataset,'_Spec','.png'))

% Kappa plot
fig4=figure(4);
hold on;
ref = plot(perc(1:9),repmat(mean(Fkappa),1,leng),'color',colorvector{6});

%refrandom = plot(perc,repmat(0.5,1,leng));
for j=methodindex
    value = mean(kappa(1:leng,j,:),3);
    plot_m{j}=plot(perc(value > 0),value(value > 0),'-x','color',colorvector{j});
end
%hTitle  = title (['Cohens kappa performance for',' ',dataset]);
hXLabel = xlabel('Missingness');
hYLabel = ylabel('Kappa');
plot_charact
ylim([0.0 0.6])
print('-depsc','-painters', strcat(namedataset,'_kappa','.eps'))        
%saveas(fig4,strcat(namedataset,'_kappa','.png'))



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%
%           How did the most revlevant or most correlated variable change 
%           with the introduction of the imputations
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% IAC
% Check the most correlated variable with the output
%corrplot(IAC)
%corrplot([IAC{:,:}, IAC_out]);
R1 = corrcoef([IAC{:,:},IAC_out]);
R2 = corrcoef([NON_IAC{:,:},NON_IAC_out]);

edges = (0:0.1:0.9);
rng(163)
[IAC_M{1},IAC_M{2},IAC_M{3},~, IAC_M{4}, ~, ~, ~...
    , IAC_M{5}, ~]= create_missing_special(IAC,perc);
for i=methodindex
    i
    try
        for j=1:1:length(perc)% cycle for the different percentages of missingness
            rng(163+i)
            data_in = IAC_M{1,j};
            data_in_new{i,j}= data_inpute(method{i},data_in(train,:),data_out(train),separate,constraint);
        end
    catch
    end
end
save('DataForHistograms.mat','data_in_new','IAC_M')
% plot histograms of the original most correlated variable
% AUC plot

leng =length(perc);
figure;
hold on;
% Verify edges of the variable 
h = histogram(IAC{:,col},edges);

for i=methodindex
    lenj=length(data_in_new{i,:});
    for j=1:1:lenj
        h_im{i,j}= histogram(IAC{:,col},edges);
    end
end
%% NON_IAC
% Check the most correlated variable with the output
corrplot([NON_IAC{:,:}, IAC_out]);
edges = [-10 -2:0.25:2 10];
rng(163)
[NIAC_M{1},NIAC_M{2},NIAC_M{3},~, NIAC_M{4}, ~, ~, ~...
    , NIAC_M{5}, ~]= create_missing_special(NON_IAC,perc);
for i=methodindex
    i
    try
        for j=1:1:length(perc)% cycle for the different percentages of missingness
            rng(163+i)
            data_in = NIAC_M{1,j};
            data_in_new{i,j}= data_inpute(method{i},data_in(train,:),data_out(train),separate,constraint);
        end
    catch        
    end
end
% plot histograms of the original most correlated variable
% AUC plot
leng =length(perc);
figure;
hold on;
% Verify edges of the variable 
h = histogram(NIAC{:,col},edges);
for i=methodindex
    lenj=length(data_in_new{i,:});
    for j=1:1:lenj
        h_im{i,j}= histogram(NIAC{:,col},edges);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

