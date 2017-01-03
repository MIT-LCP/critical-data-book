clear all
close all
%% Select the type of analysis
dataset = 'IAC';
type='univar';
foldern=strcat(type,'_Histograms_',dataset);
mkdir(foldern)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
loadFilename= strcat(type,'_','DataForHistograms',dataset,'.mat');
load(loadFilename)
edges = [10 15:5:105 110];
centers = 12.5:5:107.5;
col=1; % column of the variable to observe in the histograms
maxf = max(ORIG_DATA{:,:});
minf = min(ORIG_DATA{:,:});
dataorig =ORIG_DATA{:,col};
missdata{1} = DATA_in_M{3};
missdata{2} = DATA_in_M{4};
if strcmp(dataset,'IAC')
    limityval = [400, 400, 140, 120,200,100,120,100];
elseif strcmp(dataset,'NON_IAC')
    limityval = [250, 250, 100, 80, 80,100,80,80];
end
% Histograma referência
%% MEAN
missj=[3,4]; perc = [20,40];
switch type
    case 'univar'
        methindx = [1,2,3,4,5,6,7,8];
    case 'multi'
        methindx = [1,2,3,4,5,6,7];
    otherwise
        error('myApp:argChk1', 'WRONG type of missigness selected, please try: univar or multi')
end
names = {'Complete','Mean','Median','Linear','StcLinear','KNN','MI-Linear','MI-MVN','Full Inf.'};
k=0;
for i = 1:1:length(methindx)  % methods
    for j=1:1:2 % missingness jj
        k=k+1;
        if i < methindx(end)+1
            auxdata=data_in_new{methindx(i),missj(j)}{:,:};
            tData=auxdata.*(repmat(maxf,size(auxdata,1),1)-repmat(minf,size(auxdata,1),1))+repmat(minf,size(auxdata,1),1);                
        else
            auxdata=missdata{j}{:,:};
            tData=auxdata.*(repmat(maxf,size(auxdata,1),1)-repmat(minf,size(auxdata,1),1))+repmat(minf,size(auxdata,1),1);
        end
        if i > methindx(end-2)
            row = size(auxdata,1)/10;
            col = size(auxdata,2);
           auxaux = zeros(row,col,10);
           for kkk=1:10 % for 10 multiple imputation datasets
               auxaux(:,:,kkk) = tData(row*(kkk-1)+1:row*kkk,:) ;
           end
           tData= mean(auxaux,3);           
        end
        h2 = histogram(tData(:,1),edges);
        [counts2] = h2.Values;        
        h2.FaceColor = [255/256  39/256 58/256];
        h1 = histogram(dataorig,edges);
        [counts1] = h1.Values;
        h1.FaceColor = [14/256 178/256 52/256];
        clf
        fig{k}=figure(k);
        axis([10 110 0 limityval(i)])
        bh1=bar(centers,counts1,1);
        set(bh1,'FaceColor',[0 0 0],'EdgeColor',[0 0 0], 'LineWidth', 2);
        hold on
        bh2=bar(centers,counts2,0.6);
        set(bh2,'FaceColor',[0 0.5 0.5],'EdgeColor',[0 0.5 0.5], 'LineWidth', 2);
        %
        xlim([10 110])
        ylim([0 limityval(i)])
        hXLabel = xlabel('Age (years)');
        hYLabel = ylabel('Frequency');
        hLegend = legend( ...
            [bh1,bh2], ...
            'Original',...
            'Imputed', ...
            'location', 'NorthEast');
        set( gca,'FontName','Helvetica' );
        set([hXLabel, hYLabel],'FontName','AvantGarde');
        set([hLegend, gca],'FontSize', 16);
        set([hXLabel, hYLabel] ,'FontSize',16);
        xlim([10 110])
        ylim([0 limityval(i)])
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
        filename = strcat(foldern,'\',type,dataset,names{i},'_miss',num2str(perc(j)),'_Hist','_age','.eps');
      set(gcf, 'PaperPositionMode', 'auto');       
        print('-depsc','-painters', filename)        
    end
end
