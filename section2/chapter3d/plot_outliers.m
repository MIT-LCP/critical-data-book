function plot_outliers(data, output, var, pathh, units, ftsize, size_marker)

data=data.(var); 

figure;
idx=isnan(data);
data(idx,:)=[];
output(idx,:)=[];

data1=data(find(output==1),:);
data0=data(find(output==0),:);

h0=scatter(data0,1:length(data0));
hold on
h1=scatter(data1,length(data0)+1:length(data0)+length(data1));

xlabel(units);
ylabel('Patient ID');

cdata1 = get(h1, 'CData');
cdata0 = get(h0, 'CData');

var = strtok(var, '_');

%% IQ

% find numerical and non binary variables

IQR=iqr(data0);
lowr=prctile(data0,25)-1.5*IQR;
highr=prctile(data0,75)+1.5*IQR;
id=find(data0<=lowr | data0>=highr);

hold on
h4=scatter(data0(id,:), id, 'x');
set(h4, 'CData', cdata0);
clear id lowr highr

hold on

IQR=iqr(data1);
lowr=prctile(data1,25)-1.5*IQR;
highr=prctile(data1,75)+1.5*IQR;
id=find(data1<=lowr | data1>=highr);

h3=scatter(data1(id,:), id+length(data0), 'x');
set(h3, 'CData', cdata1);
clear id

% legend('class 0 w/o outliers', 'class 1 w/o outliers', 'class 0 w/ outliers', 'class 1 w/ outliers', 'Location', 'best', 'Orientation', 'horizontal');

set(h1, 'SizeData', size_marker)
set(h0, 'SizeData', size_marker)
set(h3, 'SizeData', size_marker*2)
set(h4, 'SizeData', size_marker*2)

set(gca, 'FontSize', ftsize);
    
name='iq_';
print_name=strcat(pathh, name, var, '.eps');
print('-depsc', print_name)

%% Log IQ
figure;
h0=scatter(data0,1:length(data0));
hold on
h1=scatter(data1,length(data0)+1:length(data0)+length(data1));

xlabel(units);
ylabel('Patient ID');

% find numerical and non binary variables
IQR=iqr(log(data0));
lowr=prctile(log(data0),25)-1.5*IQR;
highr=prctile(log(data0),75)+1.5*IQR;
id=find(log(data0)<=lowr | log(data0)>=highr);

hold on
h4=scatter(data0(id,:), id, 'x');
set(h4, 'CData', cdata0);
clear id lowr highr


IQR=iqr(log(data1));
lowr=prctile(log(data1),25)-1.5*IQR;
highr=prctile(log(data1),75)+1.5*IQR;
id=find(log(data1)<=lowr | log(data1)>=highr);

hold on
h3=scatter(data1(id,:), id+length(data0), 'x');
set(h3, 'CData', cdata1);
clear id

% legend('class 0 w/o outliers', 'class 1 w/o outliers', 'class 0 w/ outliers', 'class 1 w/ outliers', 'Location', 'best');
clear id
set(h1, 'SizeData', size_marker)
set(h0, 'SizeData', size_marker)
set(h3, 'SizeData', size_marker*2)
set(h4, 'SizeData', size_marker*2)
set(gca, 'FontSize', ftsize);
name='log_iq_';
print_name=strcat(pathh, name, var, '.eps');
print('-depsc', print_name)

%% Z score
% IAC

figure;
h0=scatter(data0,1:length(data0));
hold on
h1=scatter(data1,length(data0)+1:length(data0)+length(data1));

xlabel(units);
ylabel('Patient ID');

% class 0
meann=nanmean(data0);
sd=nanstd(data0);
for ii=1:size(data0,1)
    z(ii,1)=(data0(ii)-meann)/sd;
end

% z-score > 3 is an outlier
id=find(abs(z)>3);

hold on
h4=scatter(data0(id,:), id, 'x');
set(h4, 'CData', cdata0);
clear id z

% class 1

meann=nanmean(data1);
sd=nanstd(data1);
for ii=1:size(data1,1)
    z(ii,1)=(data1(ii)-meann)/sd;
end

% z-score > 3 is an outlier
id=find(abs(z)>3);

hold on
h3=scatter(data1(id,:), id+length(data0), 'x');
set(h3, 'CData', cdata1);

clear id
set(h1, 'SizeData', size_marker)
set(h0, 'SizeData', size_marker)
set(h3, 'SizeData', size_marker*2)
set(h4, 'SizeData', size_marker*2)
% legend('class 0 w/o outliers', 'class 1 w/o outliers', 'class 0 w/ outliers', 'class 1 w/ outliers', 'Location', 'best');
set(gca, 'FontSize', ftsize);
name='z_';
print_name=strcat(pathh, name, var, '.eps');
print('-depsc', print_name)

%% modified Z score
% IAC
figure;
h0=scatter(data0,1:length(data0));
hold on
h1=scatter(data1,length(data0)+1:length(data0)+length(data1));

xlabel(units);
ylabel('Patient ID');

% class 0
mediann=nanmedian(data0);
for ii=1:size(data0,1)
    modified_z(ii,1)=(0.6745*(data0(ii)-mediann))/nanmedian(abs(data0-mediann));
end
% modified z-score > 3.5 is an outlier
id=find(abs(modified_z)>3.5);

hold on
h4=scatter(data0(id,:), id, 'x');
set(h4, 'CData', cdata0);
clear id modified_z


% class 1
mediann=nanmedian(data1);
for ii=1:size(data1,1)
    modified_z(ii,1)=(0.6745*(data1(ii)-mediann))/nanmedian(abs(data1-mediann));
end
% modified z-score > 3.5 is an outlier
id=find(abs(modified_z)>3.5);

hold on
h3=scatter(data1(id,:), id+length(data0), 'x');
set(h3, 'CData', cdata1);set(h1, 'SizeData', size_marker)
set(h0, 'SizeData', size_marker)
set(h3, 'SizeData', size_marker*2)
set(h4, 'SizeData', size_marker*2)
set(gca, 'FontSize', ftsize);
name='modified_z_';
print_name=strcat(pathh, name, var, '.eps');
print('-depsc', print_name)

