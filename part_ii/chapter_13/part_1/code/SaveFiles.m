% Save the data in a folder

clear all
load NON_IAC_Separate
dataset='NON_IAC';
table = 'Separate';

dir = strcat(dataset,'_results');
mkdir(dir);

%%  Table 1 
name_table =strcat(dir,'/',dataset,'_',table);
fileName = strcat(name_table,'_Results.xlsx');

% Save workspace 
%save(strcat(name_table,'_data'));
m_idx = [1 2 3 4 7];
p_idx = [1 2 3 5 9];


% Create tables
AUCmeanTable = array2table([repmat(mean(FAUC),1,length(p_idx)); mean(AUC(p_idx,m_idx,:),3)']);
SenmeanTable = array2table([repmat(mean(FSen),1,length(p_idx)); mean(Sen(p_idx,m_idx,:),3)']);
SpecmeanTable = array2table([repmat(mean(FSpec),1,length(p_idx)); mean(Spec(p_idx,m_idx,:),3)']);
kappameanTable = array2table([repmat(mean(Fkappa),1,length(p_idx)); mean(kappa(p_idx,m_idx,:),3)']);

AUCstdTable = array2table([repmat(std(FAUC),1,length(p_idx)); std(AUC(p_idx,m_idx,:),[],3)']);
SenstdTable = array2table([repmat(std(FSen),1,length(p_idx)); std(Sen(p_idx,m_idx,:),[],3)']);
SpecstdTable = array2table([repmat(std(FSpec),1,length(p_idx)); std(Spec(p_idx,m_idx,:),[],3)']);
kappastdTable = array2table([repmat(std(Fkappa),1,length(p_idx)); std(kappa(p_idx,m_idx,:),[],3)']);

% Give names to table columns 
AUCmeanTable.Properties.VariableNames =     {'Imb05' 'Imb10' 'Imb20' 'Imb40' 'Imb80'};
SenmeanTable.Properties.VariableNames  =    {'Imb05' 'Imb10' 'Imb20' 'Imb40' 'Imb80' };
SpecmeanTable.Properties.VariableNames  =   {'Imb05' 'Imb10' 'Imb20' 'Imb40' 'Imb80'};
kappameanTable.Properties.VariableNames  =  {'Imb05' 'Imb10' 'Imb20' 'Imb40' 'Imb80'};
AUCstdTable.Properties.VariableNames  =     {'Imb05' 'Imb10' 'Imb20' 'Imb40' 'Imb80'};
SenstdTable.Properties.VariableNames  =     {'Imb05' 'Imb10' 'Imb20' 'Imb40' 'Imb80'};
SpecstdTable.Properties.VariableNames  =    {'Imb05' 'Imb10' 'Imb20' 'Imb40' 'Imb80'};
kappastdTable.Properties.VariableNames  =   {'Imb05' 'Imb10' 'Imb20' 'Imb40' 'Imb80'};

% Give names to the table rows
AUCmeanTable.Properties.RowNames =      {'Ref' 'Rem' 'Mean' 'Median' 'Linear'  'KNN'};
SenmeanTable.Properties.RowNames  =     {'Ref' 'Rem' 'Mean' 'Median' 'Linear'  'KNN'};
SpecmeanTable.Properties.RowNames  =    {'Ref' 'Rem' 'Mean' 'Median' 'Linear'  'KNN'};
kappameanTable.Properties.RowNames  =   {'Ref' 'Rem' 'Mean' 'Median' 'Linear'  'KNN'};
AUCstdTable.Properties.RowNames  =      {'Ref' 'Rem' 'Mean' 'Median' 'Linear'  'KNN'};
SenstdTable.Properties.RowNames  =      {'Ref' 'Rem' 'Mean' 'Median' 'Linear'  'KNN'};
SpecstdTable.Properties.RowNames  =     {'Ref' 'Rem' 'Mean' 'Median' 'Linear'  'KNN'};
kappastdTable.Properties.RowNames  =    {'Ref' 'Rem' 'Mean' 'Median' 'Linear'  'KNN'};

% % Write tables to excel
% writetable(AUCmeanTable,fileName,'Sheet',1,'Range','A1:E9')
% writetable(AUCmeanTable,fileName,'Sheet',1,'Range','G1:K9')
% writetable(SenmeanTable,fileName,'Sheet',2,'Range','A1:E9')
% writetable(SenmeanTable,fileName,'Sheet',2,'Range','G1:K9')
% writetable(SpecmeanTable,fileName,'Sheet',3,'Range','A1:E9')
% writetable(SpecmeanTable,fileName,'Sheet',3,'Range','G1:K9')
% writetable(kappameanTable,fileName,'Sheet',4,'Range','A1:E9')
% writetable(kappameanTable,fileName,'Sheet',4,'Range','G1:K9')

fileName = strcat(name_table,'_Results.xlsx');
xlswrite(strcat(name_table,'AUC_','mean','_Results.xlsx'),AUCmeanTable{:,:},1,'A1:E9');
xlswrite(strcat(name_table,'AUC_','std','_Results.xlsx'),AUCstdTable{:,:},1,'A1:E9');
xlswrite(strcat(name_table,'Sen_','mean','_Results.xlsx'),SenmeanTable{:,:},1,'A1:E9');
xlswrite(strcat(name_table,'Sen_','std','_Results.xlsx'),SenstdTable{:,:},1,'A1:E9');
xlswrite(strcat(name_table,'Spec_','mean','_Results.xlsx'),SpecmeanTable{:,:},1,'A1:E9');
xlswrite(strcat(name_table,'Spec_','std','_Results.xlsx'),SpecstdTable{:,:},1,'A1:E9');
xlswrite(strcat(name_table,'kappa_','mean','_Results.xlsx'),kappameanTable{:,:},1,'A1:E9');
xlswrite(strcat(name_table,'kappa_','std','_Results.xlsx'),kappastdTable{:,:},1,'A1:E9');

% xlswrite(fileName,AUCmeanTable{:,:},1,'A1:E9');
% xlswrite(fileName,AUCstdTable{:,:},2,'G1:K9');
% xlswrite(filename,SenmeanTable,2,A1:E9);
% xlswrite(filename,SenstdTable,2,G1:K9);
% xlswrite(filename,SpecmeanTable,3,A1:E9);
% xlswrite(filename,SpecstdTable,3,G1:K9);
% xlswrite(filename,kappameanTable,4,A1:E9);
% xlswrite(filename,kappastdTable,4,G1:K9);
% % Save table to file
% fileID = fopen(fileName,'w');
% % Used Parameters
% fprintf(fileID,'This .txt contains the results of missing data tests. \n ');
% fprintf(fileID,'The methods used are (by this order):0 - full_data; 1- remove;2-mean  \n');
% fprintf(fileID,'   3 - median; 4-linear; 5-quadratic; 6- hot-deck kmeans; 7 - knn  \n');
% 
% fprintf(fileID,'\n The dataset used was: %s',dataset);
% fprintf(fileID,'\n \n  ');
% % For AUC
% fprintf(fileID,'Performance Measure: AUC \n');
% fprintf(fileID,'Imbalance: \n');
% fprintf(fileID,'%5.4f %5.4f %5.4f \n ', perc(1),perc(2),perc(3),perc(4));
% fprintf(fileID,'TABLE \n ');
% fprintf(fileID,'%s : %5.4f+%5.4f \n','Reference',mean(FAUC),std(FAUC));
% for j=1:1:length(method) % cycle for the different percentages of missingness
%     fprintf(fileID,'%s :',method{j});
%     for i=1:1:length(perc) % cycle for each method
%         fprintf(fileID,'%5.4f+%5.4f,',mean(AUC(i,j,:)),std(AUC(i,j,:)));
%     end
%     fprintf(fileID,'\n');
% end
% % For Kappa
% fprintf('\n');
% fprintf(fileID,'Performance Measure: Cohen s Kappa \n');
% fprintf(fileID,'Imbalance \n');
% fprintf(fileID,'%5.4f %5.4f %5.4f \n ', perc(1),perc(2),perc(3),perc(4));
% fprintf(fileID,'%s : %5.4f+%5.4f \n','Reference',mean(Fkappa),std(Fkappa));
% for j=1:1:length(method) % cycle for the different percentages of missingness
%     fprintf(fileID,'%s',method{j});
%     
%     for i=1:1:length(perc) % cycle for each method
%         fprintf(fileID,'%5.4f+%5.4f,',mean(kappa(i,j,:)),std(kappa(i,j,:)));
%     end
%     fprintf(fileID,'\n');
% end
% % For Sensitivity
% fprintf('\n');
% fprintf(fileID,'Performance Measure: Sensitivity \n');
% fprintf(fileID,'Imbalance \n');
% fprintf(fileID,'%5.4f %5.4f %5.4f \n ', perc(1),perc(2),perc(3),perc(4));
% fprintf(fileID,'%s : %5.4f+%5.4f \n','Reference',mean(FSen),std(FSen));
% for j=1:1:length(method) % cycle for the different percentages of missingness
%     fprintf(fileID,'%s',method{j});
%     for i=1:1:length(perc) % cycle for each method
%         fprintf(fileID,'%5.4f+%5.4f,',mean(Sen(i,j,:)),std(Sen(i,j,:)));
%     end
%     fprintf(fileID,'\n');
% end
% % For Specificity
% fprintf('\n');
% fprintf(fileID,'Performance Measure: Specificity \n');
% fprintf(fileID,'Imbalance \n');
% fprintf(fileID,'%5.4f %5.4f %5.4f \n ', perc(1),perc(2),perc(3),perc(4));
% fprintf(fileID,'%s : %5.4f+%5.4f \n','Reference',mean(FSpec),std(FSpec));
% for j=1:1:length(method) % cycle for the different percentages of missingness
%     fprintf(fileID,'%s',method{j});
%     for i=1:1:length(perc) % cycle for each method
%         fprintf(fileID,'%5.4f+%5.4f,',mean(Spec(i,j,:)),std(Spec(i,j,:)));
%     end
%     fprintf(fileID,'\n');
% end
% fclose(fileID);
% 
% 
