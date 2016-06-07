%% analyse clusters

close all; clearvars;clc;load normalized_data;
num_clusters=2;


% IAC class 1
weight=1.5;
criterion=1;
[c1,c2,center1,center2,removed_c1,removed_c2]=kmeansOutliersPLOTS_cs(dataIAC1,weight,criterion);
center1(:,end+1)=0;
center2(:,end+1)=0;
xlswrite('KM_c1',[c1;center1],'KM_c1');
xlswrite('KM_c2',[c2;center2],'KM_c2');

weight=1.5;
criterion=1;
[c1,c2,center1,center2,removed_c1,removed_c2]=kmedoidsOutliersPLOTS_cs(dataIAC1,weight,criterion);
center1(:,end+1)=0;
center2(:,end+1)=0;
xlswrite('KMed_c1',[c1;center1],'KMed_c1');
xlswrite('KMed_c2',[c2;center2],'KMed_c2');



