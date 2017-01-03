clear all
close all
%load DataForHistogramsIAC
%load DataForHistogramsNONIAC
%load univar_DataForHistogramsIAC
load univar_DataForHistogramsNONIAC
univar ='univ_';
dataset ='NON_IAC';
foldern='univar_NON_IAC_results\';
edges = [10 15:5:105 110];
col=1;
if strcmp(dataset,'IAC')
maxf = max(IAC{:,:});
minf = min(IAC{:,:});
dataorig =IAC{:,col};
missdata{1} = IAC_M{3};
missdata{2} = IAC_M{4};
limityval = [400, 400, 140, 120,200,100,120,100];
elseif strcmp(dataset,'NON_IAC')
 maxf = max(NON_IAC{:,:});
minf = min(NON_IAC{:,:});
dataorig =NON_IAC{:,col};
missdata{1} = NIAC_M{3};
missdata{2} = NIAC_M{4};
limityval = [250, 250, 100, 80, 80,100,80,80];
end
% Histograma referência
%h1 = histogram(IAC{:,col},edges);
%% MEAN
missj=[3,4]; perc = [20,40];
methindx = [2, 3,4,8,7,10,11];
names = {'Mean','Median','Linear','StcLinear','KNN','MI-Linear','MI-MVN','Complete','Full Inf.'};
k=0;
for i = 1:1:8  % methods
    %j=2
    for j=1:1:2 % missingness jj
        k=k+1;
        fig{k}=figure(k);
        hold on
        if i < 8
        auxdata=data_in_new{methindx(i),missj(j)}{:,:};
        tData=auxdata.*(repmat(maxf,size(auxdata,1),1)-repmat(minf,size(auxdata,1),1))+repmat(minf,size(auxdata,1),1);
        else
        auxdata=missdata{j}{:,:};
        tData=auxdata.*(repmat(maxf,size(auxdata,1),1)-repmat(minf,size(auxdata,1),1))+repmat(minf,size(auxdata,1),1);            
        end
        if i > 5 && i < 8
            row = size(auxdata,1)/10;
            col = size(auxdata,2);
               auxaux = zeros(row,col,10);
           for kkk=1:10
               auxaux(:,:,kkk) = tData(row*(kkk-1)+1:row*kkk,:) ;
           end
           tData= mean(auxaux,3);           
        end
        h2 = histogram(tData(:,1),edges);
        h2.FaceColor = [255/256  39/256 58/256];
        h1 = histogram(dataorig,edges);
        h1.FaceColor = [14/256 178/256 52/256];
        %

        %hTitle  = title (['Histogram of the variable age',' - ',dataset]);
        hXLabel = xlabel('Age (years)');
        hYLabel = ylabel('Frequency');
        hLegend = legend( ...
            [h1,h2], ...
            'Complete',...
            'Imputed', ...
            'location', 'NorthEast');
        set( gca,'FontName','Helvetica' );
        set([hXLabel, hYLabel],'FontName','AvantGarde');
        set([hLegend, gca],'FontSize', 16);
        set([hXLabel, hYLabel] ,'FontSize',16);
        %set( hTitle,'FontSize',14, 'FontWeight','bold');
        xlim([10 110])
        ylim([0 limityval(i)])
        filename = strcat(foldern,univar,dataset,names{i},'_miss',num2str(perc(j)),'_Hist','_age','.png');
        saveas(fig{k},filename);
    end
end
