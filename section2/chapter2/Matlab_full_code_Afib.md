\[Afib query code\] by \[MATLAB\]

load('b1\_HR\_data.mat','HR\_data')

load('b2\_icutime\_data.mat','icutime\_data')

%load meds

load('b3.1\_amio\_data.mat','amio\_data') %Amiodarone, alias:1

load('b3.2\_digi\_data.mat','digi\_data') %Digoxin, alias:2

load('b3.3\_dil\_data.mat','dil\_data') %Diltiazem, alias:3

load('b3.4\_esmo\_data.mat','esmo\_data') %Esmolol, alias:4

load('b3.5\_ibu\_data.mat','ibu\_data') %Ibutilide, alias:5

load('b3.6\_meto\_data.mat','meto\_data') %Metoprolol, alias:6

load('b3.7\_proc\_data.mat','proc\_data') %Procainamide, alias:7

load('b3.8\_prop\_data.mat','prop\_data') %Propafenone, alias:8

load('b3.9\_vaso\_data.mat','vaso\_data') %All vasopressors

% make subject list by icustay\_id of rate control drugs

amio\_s = unique( amio\_data(:,3) );

digi\_s = unique( digi\_data(:,3) );

dil\_s = unique( dil\_data(:,3) );

esmo\_s = unique( esmo\_data(:,3) );

ibu\_s = unique( ibu\_data(:,3) );

meto\_s = unique( meto\_data(:,3) );

proc\_s = unique( proc\_data(:,3) );

prop\_s = unique( prop\_data(:,3) );

% % % % % % % % % % % % % % % % % % % % % % % %

med\_s = unique( \[amio\_s' digi\_s' dil\_s' esmo\_s' ibu\_s' meto\_s'
proc\_s' prop\_s'\] )';

% % % % % % % % % % % % % % % % % % % % % % % %

clear amio\_s digi\_s dil\_s esmo\_s ibu\_s meto\_s proc\_s prop\_s

%% make dataset matrix, adjust column number

dataset = zeros( length(med\_s), 21 );

% error tolerance variable control

% this controls the time window of looking for HR &gt;=110 around the
1st\_drug time

find\_rvr\_window = datenum(\[0 0 0 2 0 0\]);

% this controls the time window of looking for drugs administered around
the RVR episode

find\_drug\_window = datenum(\[0 0 0 2 0 0\]);

%% extract subject for analysis

for i= 1: length(med\_s);

%% unique icustay as this\_subject identifier

this\_s = med\_s(i);

% get data of this\_s

% tsi: this\_subject\_index

HR\_tsi = find( HR\_data(:,3)==this\_s );

icutime\_tsi = find( icutime\_data(:,3)==this\_s );

amio\_tsi = find( amio\_data(:,3)==this\_s );

digi\_tsi = find( digi\_data(:,3)==this\_s );

dil\_tsi = find( dil\_data(:,3)==this\_s );

esmo\_tsi = find( esmo\_data(:,3)==this\_s );

ibu\_tsi = find( ibu\_data(:,3)==this\_s );

meto\_tsi = find( meto\_data(:,3)==this\_s );

proc\_tsi = find( proc\_data(:,3)==this\_s );

prop\_tsi = find( prop\_data(:,3)==this\_s );

vaso\_tsi = find( vaso\_data(:,3)==this\_s );

% A\_get this\_subject icu\_dn

icuin\_tstn = datenum(icutime\_data(icutime\_tsi,4:9));

icuout\_tstn = datenum(icutime\_data(icutime\_tsi,10:15));

% B\_make data matrix of this subject

HR\_data\_ts = HR\_data(HR\_tsi,:);

amio\_data\_ts = amio\_data(amio\_tsi,:);

digi\_data\_ts = digi\_data(digi\_tsi,:);

dil\_data\_ts = dil\_data(dil\_tsi,:);

esmo\_data\_ts = esmo\_data(esmo\_tsi,:);

ibu\_data\_ts = ibu\_data(ibu\_tsi,:);

meto\_data\_ts = meto\_data(meto\_tsi,:);

proc\_data\_ts = proc\_data(proc\_tsi,:);

prop\_data\_ts = prop\_data(prop\_tsi,:);

vaso\_data\_ts = vaso\_data(vaso\_tsi,:);

% created a combined matrix for meds

meds\_data\_ts = zeros(1,12);

if\~isempty(amio\_data\_ts)

meds\_data\_ts = \[meds\_data\_ts; amio\_data\_ts\];

end

if\~isempty(digi\_data\_ts)

meds\_data\_ts = \[meds\_data\_ts; digi\_data\_ts\];

end

if\~isempty(dil\_data\_ts)

meds\_data\_ts = \[meds\_data\_ts; dil\_data\_ts\];

end

if\~isempty(esmo\_data\_ts)

meds\_data\_ts = \[meds\_data\_ts; esmo\_data\_ts\];

end

if\~isempty(ibu\_data\_ts)

meds\_data\_ts = \[meds\_data\_ts; ibu\_data\_ts\];

end

if\~isempty(meto\_data\_ts)

meds\_data\_ts = \[meds\_data\_ts; meto\_data\_ts\];

end

if\~isempty(proc\_data\_ts)

meds\_data\_ts = \[meds\_data\_ts; proc\_data\_ts\];

end

if\~isempty(prop\_data\_ts)

meds\_data\_ts = \[meds\_data\_ts; prop\_data\_ts\];

end

if size(meds\_data\_ts,1)&gt;=2

meds\_data\_ts = meds\_data\_ts(2:end,:);

elseif size(meds\_data\_ts,1)==1

meds\_data\_ts =\[\];

end

% B1: get data only within the ICUSTAY

if \~isempty(icuin\_tstn)

meds\_within\_index = find( icuin\_tstn &lt;=meds\_data\_ts(:,11) &
meds\_data\_ts(:,11) &lt;= icuout\_tstn );

meds\_data\_ts\_within = meds\_data\_ts(meds\_within\_index,:);

vaso\_within\_index = find( icuin\_tstn &lt;=vaso\_data\_ts(:,11) &
vaso\_data\_ts(:,11) &lt;= icuout\_tstn );

vaso\_data\_ts\_within = vaso\_data\_ts(vaso\_within\_index,:);

HR\_within\_index = find( icuin\_tstn &lt;= HR\_data\_ts(:,12) &
HR\_data\_ts(:,12) &lt;= icuout\_tstn );

HR\_data\_ts\_within = HR\_data\_ts(HR\_within\_index,:);

% C\_sort this\_subject\_data subset by time sequence

meds\_data\_ts\_sorted = sortrows(meds\_data\_ts\_within,11);

vaso\_data\_ts\_sorted = sortrows(vaso\_data\_ts\_within,11);

HR\_data\_ts\_sorted = sortrows(HR\_data\_ts\_within,12);

% find the min dn of rate control drug given (within the entire ICUSTAY)

if \~isempty(meds\_data\_ts\_sorted)

first\_drug = meds\_data\_ts\_sorted(1,12);

first\_drug\_dn = meds\_data\_ts\_sorted(1,11);

else

first\_drug = nan;

first\_drug\_dn = nan;

end

%

% clean up tn of HR(remove multiple tn, will cause trouble during
interpolation)

% added for revised\_new\_strategy

\[\~,index\]=unique(HR\_data\_ts\_sorted(:,12),'stable');

HR\_data\_ts\_sorted = HR\_data\_ts\_sorted(sort(index),:);

% HR data(value and tn) interpolation

% added for revised\_new\_strategy

HR\_dn = HR\_data\_ts\_sorted(:,12);

HR\_val = HR\_data\_ts\_sorted(:,4);

min\_step = datenum(\[0 0 0 0 5 0\]); % ASSUMING MINS!!!

HR\_dn\_new = HR\_dn(1):min\_step:HR\_dn(end);

HR\_val\_new = interp1(HR\_dn,HR\_val,HR\_dn\_new,'linear');

interpolated\_HR\_m =\[HR\_val\_new', HR\_dn\_new'\];

% \*\*\*\*\*now you have all the data of this\_subject needed for
analysis\*\*\*\*\*

else

meds\_data\_ts\_sorted = \[\];

vaso\_data\_ts\_sorted = \[\];

HR\_data\_ts\_sorted = \[nan,nan,this\_s\];

first\_drug = nan;

first\_drug\_dn = nan;

end

% end of get data within ICUSTAY

% % % % % % % % % % % % % % % % % % % % % % % %

% % % % % % % % % % % % % % % % % % % % % % % %

%\*\*\*\*\*\*\*\*\_Core\_Algorithm\_\*\*\*\*\*\*\*\*\*

check\_hr\_start\_dn = first\_drug\_dn - find\_rvr\_window;

check\_hr\_stop\_dn = first\_drug\_dn + find\_rvr\_window;

within\_check\_index = find(check\_hr\_start\_dn &lt;=
interpolated\_HR\_m(:,2) & interpolated\_HR\_m(:,2) &lt;=
check\_hr\_stop\_dn );

interpolated\_HR\_m\_within\_check =
interpolated\_HR\_m(within\_check\_index,:);

first\_rvr\_within\_check\_i = find(
(interpolated\_HR\_m\_within\_check(:,1)&gt;=110)==1, 1 ); % find the
first hr\_tn where HR&gt;=110 within the checking period

% syntax: find(A,1) A: condition

if \~isempty(first\_rvr\_within\_check\_i)

rvr\_start\_dn = interpolated\_HR\_m\_within\_check(
first\_rvr\_within\_check\_i ,2);

rvr\_start\_i = find( interpolated\_HR\_m(:,2)==rvr\_start\_dn );

rvr\_start\_HR = interpolated\_HR\_m(rvr\_start\_i,1);

else

rvr\_start\_dn =nan;

rvr\_start\_i = nan;

rvr\_start\_HR = nan;

end

% find the end of RVR per criteria 3b

% asign value to controlled\_for\_4hour label

if \~isnan(rvr\_start\_i)

check\_end = find( interpolated\_HR\_m(rvr\_start\_i:end,1)&lt;110 );

check\_rvr\_end\_points\_i = check\_end + (rvr\_start\_i-1);

if \~isempty(check\_end)

for j = 1:length(check\_rvr\_end\_points\_i)

if check\_rvr\_end\_points\_i(j)+47&lt;=length(interpolated\_HR\_m)

if nnz( interpolated\_HR\_m(
check\_rvr\_end\_points\_i(j):check\_rvr\_end\_points\_i(j)+47 ,1)
&gt;=110 )&lt;=5

rvr\_end\_i = check\_rvr\_end\_points\_i(j);

rvr\_end\_dn = interpolated\_HR\_m(rvr\_end\_i,2);

controlled\_for\_4hour = 1; %dataset column 5 output

break

end

elseif check\_rvr\_end\_points\_i(j)+47 &gt; length(interpolated\_HR\_m)

if nnz( interpolated\_HR\_m( check\_rvr\_end\_points\_i(j):end,1)
&gt;=110 )&lt;= (length(interpolated\_HR\_m) -
length(interpolated\_HR\_m(1:check\_rvr\_end\_points\_i(j))))/10

rvr\_end\_i = check\_rvr\_end\_points\_i(j);

rvr\_end\_dn = interpolated\_HR\_m(rvr\_end\_i,2);

controlled\_for\_4hour=0.5; %dataset column 5 output

break

end

end

rvr\_end\_i=nan;

rvr\_end\_dn=nan;

controlled\_for\_4hour=0; %dataset column 5 output

end

elseif isempty(check\_end)

rvr\_end\_i=nan;

rvr\_end\_dn=nan;

controlled\_for\_4hour=0; %dataset column 5 output

end

elseif isnan(rvr\_start\_i)

rvr\_end\_i=nan;

rvr\_end\_dn=nan;

controlled\_for\_4hour=nan; %dataset column 5 output

end

% get rvr\_duration, if no true end of RVR identified previously, take

% the last HR record tn for calculating the duration

if \~isnan(rvr\_start\_dn) && \~isnan(rvr\_end\_dn)

rvr\_duration = etime( datevec(rvr\_end\_dn) , datevec(rvr\_start\_dn)
)/60.0; %dataset column 4 output

elseif \~isnan(rvr\_start\_dn) && isnan(rvr\_end\_dn)

rvr\_duration = etime( datevec(interpolated\_HR\_m(end,2)) ,
datevec(rvr\_start\_dn) )/60.0; %dataset column 4 output

else

rvr\_duration = nan; %dataset column 4 output

end

% find data only within the rvr episode( error tolerance time window
considered )

find\_drug\_start\_dn = rvr\_start\_dn - find\_drug\_window;

find\_drug\_end\_dn = rvr\_end\_dn + find\_drug\_window;

if \~isnan(rvr\_start\_dn) && \~isnan(rvr\_end\_dn)

meds\_withinrvr\_index = find(find\_drug\_start\_dn
&lt;=meds\_data\_ts\_sorted(:,11) & meds\_data\_ts\_sorted(:,11) &lt;=
find\_drug\_end\_dn );

meds\_data\_ts\_withinrvr =
meds\_data\_ts\_sorted(meds\_withinrvr\_index,:);

vaso\_withinrvr\_index = find( find\_drug\_start\_dn
&lt;=vaso\_data\_ts\_sorted(:,11) & vaso\_data\_ts\_sorted(:,11) &lt;=
find\_drug\_end\_dn );

vaso\_data\_ts\_withinrvr =
vaso\_data\_ts\_sorted(vaso\_withinrvr\_index,:);

elseif \~isnan(rvr\_start\_dn) && isnan(rvr\_end\_dn)

meds\_withinrvr\_index = find(find\_drug\_start\_dn
&lt;=meds\_data\_ts\_sorted(:,11) );

meds\_data\_ts\_withinrvr =
meds\_data\_ts\_sorted(meds\_withinrvr\_index,:);

vaso\_withinrvr\_index = find( find\_drug\_start\_dn
&lt;=vaso\_data\_ts\_sorted(:,11) );

vaso\_data\_ts\_withinrvr =
vaso\_data\_ts\_sorted(vaso\_withinrvr\_index,:);

else

meds\_data\_ts\_withinrvr =\[\];

vaso\_data\_ts\_withinrvr =\[\];

end

% % % % % % % % % % % % % % % % % % % % % % % %

% end of find data within RVR episode

% % % % % % % % % % % % % % % % % % % % % % % %

% sequence rate control drug within RVR episode

if \~isempty(meds\_data\_ts\_withinrvr)

rate\_drug\_withinrvr = unique( meds\_data\_ts\_withinrvr(:,12));

total\_rate\_drug\_num\_withinrvr = length(rate\_drug\_withinrvr);

withinrvr\_rate\_drug\_sequence =
zeros(total\_rate\_drug\_num\_withinrvr,2);

for k=1:total\_rate\_drug\_num\_withinrvr

this\_drug = rate\_drug\_withinrvr(k);

this\_drug\_first\_index = find(
meds\_data\_ts\_withinrvr(:,12)==this\_drug,1 );

this\_drug\_first\_dn =
meds\_data\_ts\_withinrvr(this\_drug\_first\_index,11);

withinrvr\_rate\_drug\_sequence(k,:)=\[this\_drug,
this\_drug\_first\_dn\];

end

withinrvr\_rate\_drug\_sequence\_sorted =
sortrows(withinrvr\_rate\_drug\_sequence,2);

% % % % % % % % % % % % % % % % % % % % % % % %

% % % % % % % % % % % % % % % % % % % % % % % %

% asign (rate control) drug ssequence within RVR episode

if total\_rate\_drug\_num\_withinrvr&gt;=5

first\_drug\_withinrvr = withinrvr\_rate\_drug\_sequence\_sorted(1,1);

first\_drug\_withinrvr\_tsdn =
withinrvr\_rate\_drug\_sequence\_sorted(1,2);

second\_drug\_withinrvr = withinrvr\_rate\_drug\_sequence\_sorted(2,1);

second\_drug\_withinrvr\_tsdn =
withinrvr\_rate\_drug\_sequence\_sorted(2,2);

third\_drug\_withinrvr = withinrvr\_rate\_drug\_sequence\_sorted(3,1);

fourth\_drug\_withinrvr = withinrvr\_rate\_drug\_sequence\_sorted(4,1);

fifth\_drug\_withinrvr = withinrvr\_rate\_drug\_sequence\_sorted(5,1);

elseif total\_rate\_drug\_num\_withinrvr==4

first\_drug\_withinrvr = withinrvr\_rate\_drug\_sequence\_sorted(1,1);

first\_drug\_withinrvr\_tsdn =
withinrvr\_rate\_drug\_sequence\_sorted(1,2);

second\_drug\_withinrvr = withinrvr\_rate\_drug\_sequence\_sorted(2,1);

second\_drug\_withinrvr\_tsdn =
withinrvr\_rate\_drug\_sequence\_sorted(2,2);

third\_drug\_withinrvr = withinrvr\_rate\_drug\_sequence\_sorted(3,1);

fourth\_drug\_withinrvr = withinrvr\_rate\_drug\_sequence\_sorted(4,1);

fifth\_drug\_withinrvr = 0;

elseif total\_rate\_drug\_num\_withinrvr==3

first\_drug\_withinrvr = withinrvr\_rate\_drug\_sequence\_sorted(1,1);

first\_drug\_withinrvr\_tsdn =
withinrvr\_rate\_drug\_sequence\_sorted(1,2);

second\_drug\_withinrvr = withinrvr\_rate\_drug\_sequence\_sorted(2,1);

second\_drug\_withinrvr\_tsdn =
withinrvr\_rate\_drug\_sequence\_sorted(2,2);

third\_drug\_withinrvr = withinrvr\_rate\_drug\_sequence\_sorted(3,1);

fourth\_drug\_withinrvr = 0;

fifth\_drug\_withinrvr = 0;

elseif total\_rate\_drug\_num\_withinrvr==2

first\_drug\_withinrvr = withinrvr\_rate\_drug\_sequence\_sorted(1,1);

first\_drug\_withinrvr\_tsdn =
withinrvr\_rate\_drug\_sequence\_sorted(1,2);

second\_drug\_withinrvr = withinrvr\_rate\_drug\_sequence\_sorted(2,1);

second\_drug\_withinrvr\_tsdn =
withinrvr\_rate\_drug\_sequence\_sorted(2,2);

third\_drug\_withinrvr = 0;

fourth\_drug\_withinrvr = 0;

fifth\_drug\_withinrvr = 0;

elseif total\_rate\_drug\_num\_withinrvr==1

first\_drug\_withinrvr = withinrvr\_rate\_drug\_sequence\_sorted(1,1);

first\_drug\_withinrvr\_tsdn =
withinrvr\_rate\_drug\_sequence\_sorted(1,2);

second\_drug\_withinrvr = 0;

second\_drug\_withinrvr\_tsdn = nan;

third\_drug\_withinrvr = 0;

fourth\_drug\_withinrvr = 0;

fifth\_drug\_withinrvr = 0;

end

elseif isempty(meds\_data\_ts\_withinrvr)

rate\_drug\_withinrvr=\[\];

total\_rate\_drug\_num\_withinrvr=0;

withinrvr\_rate\_drug\_sequence=\[\];

withinrvr\_rate\_drug\_sequence\_sorted=\[\];

first\_drug\_withinrvr = 0;

first\_drug\_withinrvr\_tsdn =0;

second\_drug\_withinrvr = 0;

second\_drug\_withinrvr\_tsdn = nan;

third\_drug\_withinrvr = 0;

fourth\_drug\_withinrvr = 0;

fifth\_drug\_withinrvr = 0;

end

if \~isnan(second\_drug\_withinrvr\_tsdn)

second\_rate\_drug\_kick\_in\_time =
etime(datevec(second\_drug\_withinrvr\_tsdn),datevec(first\_drug\_withinrvr\_tsdn))/60.0;

else

second\_rate\_drug\_kick\_in\_time = 9999;

end

%\*\*\*\*\*\*\*\*end of core algorithm\*\*\*\*\*\*\*\*\*\*\*

% % % % % % % % % % % % % % % % % % % % % % % %

% % % % % % % % % % % % % % % % % % % % % % % %

% Get vasopressor data

% % % % % % % % % % % % % % % % % % % % % %

if \~isempty(vaso\_data\_ts\_withinrvr)

vasopressor\_withinrvr = unique( vaso\_data\_ts\_withinrvr(:,12));

total\_vasopressor\_num\_withinrvr = length(vasopressor\_withinrvr);

withinrvr\_vasopressor\_sequence =
zeros(total\_vasopressor\_num\_withinrvr,2);

for k=1:total\_vasopressor\_num\_withinrvr

this\_vaso = vasopressor\_withinrvr(k);

this\_vaso\_first\_index = find(
vaso\_data\_ts\_withinrvr(:,12)==this\_vaso,1 );

this\_vaso\_first\_dn =
vaso\_data\_ts\_withinrvr(this\_vaso\_first\_index,11);

withinrvr\_vasopressor\_sequence(k,:)=\[this\_vaso,
this\_vaso\_first\_dn\];

end

withinrvr\_vasopressor\_sequence\_sorted =
sortrows(withinrvr\_vasopressor\_sequence,2);

% % % % % % % % % % % % % % % % % % % % % % % %

% asign vasopressor sequence within RVR episode

if total\_vasopressor\_num\_withinrvr&gt;=3

first\_vasopressor\_withinrvr =
withinrvr\_vasopressor\_sequence\_sorted(1,1);

first\_vasopressor\_withinrvr\_tsdn =
withinrvr\_vasopressor\_sequence\_sorted(1,2);

second\_vasopressor\_withinrvr =
withinrvr\_vasopressor\_sequence\_sorted(2,1);

third\_vasopressor\_withinrvr =
withinrvr\_vasopressor\_sequence\_sorted(3,1);

elseif total\_vasopressor\_num\_withinrvr==2

first\_vasopressor\_withinrvr =
withinrvr\_vasopressor\_sequence\_sorted(1,1);

first\_vasopressor\_withinrvr\_tsdn =
withinrvr\_vasopressor\_sequence\_sorted(1,2);

second\_vasopressor\_withinrvr =
withinrvr\_vasopressor\_sequence\_sorted(2,1);

third\_vasopressor\_withinrvr = 0;

elseif total\_vasopressor\_num\_withinrvr==1

first\_vasopressor\_withinrvr =
withinrvr\_vasopressor\_sequence\_sorted(1,1);

first\_vasopressor\_withinrvr\_tsdn =
withinrvr\_vasopressor\_sequence\_sorted(1,2);

second\_vasopressor\_withinrvr = 0;

third\_vasopressor\_withinrvr = 0;

end

elseif isempty(vaso\_data\_ts\_withinrvr)

vasopressor\_withinrvr=\[\];

total\_vasopressor\_num\_withinrvr=0;

withinrvr\_vasopressor\_sequence=\[\];

withinrvr\_vasopressor\_sequence\_sorted=\[\];

first\_vasopressor\_withinrvr = 0;

first\_vasopressor\_withinrvr\_tsdn =0;

second\_vasopressor\_withinrvr = 0;

third\_vasopressor\_withinrvr = 0;

end

% look into vasopressor dose before and after the start of RVR

if first\_vasopressor\_withinrvr \~=0

first\_vaso\_within\_i = find(
vaso\_data\_ts\_withinrvr(:,12)==first\_vasopressor\_withinrvr );

first\_vaso\_within\_m =
vaso\_data\_ts\_withinrvr(first\_vaso\_within\_i,:);

first\_vaso\_within\_dose = mean( first\_vaso\_within\_m(:,4) );

first\_vaso\_before\_i = find(
vaso\_data\_ts\_sorted(:,12)==first\_vasopressor\_withinrvr &
vaso\_data\_ts\_sorted(:,11)&lt; find\_drug\_start\_dn );

first\_vaso\_before\_m =
vaso\_data\_ts\_sorted(first\_vaso\_before\_i,:);

if \~isempty(first\_vaso\_before\_m)

first\_vaso\_before\_dose = mean( first\_vaso\_before\_m(:,4) );

elseif isempty(first\_vaso\_before\_m)

first\_vaso\_before\_dose =0;

end

elseif first\_vasopressor\_withinrvr ==0

first\_vaso\_within\_dose =0;

first\_vaso\_before\_dose =0;

end

% % % % % % % % % % % % % % % % % % % % % % % %

% any vasopressor before RVR

if \~isempty(vaso\_data\_ts\_sorted)

any\_vaso\_before\_rvr\_i = find( vaso\_data\_ts\_sorted(:,11) &lt;
find\_drug\_start\_dn );

if \~isempty(any\_vaso\_before\_rvr\_i)

any\_vaso\_before\_rvr =1;

else

any\_vaso\_before\_rvr =0;

end

elseif isempty(vaso\_data\_ts\_sorted)

any\_vaso\_before\_rvr =0;

end

% % % % % % % % % % % % % % % % % % % % % % % %

% % % % % % % % % % % % % % % % % % % % % % % %

dataset(i,1:21) = \[ HR\_data\_ts\_sorted(1,1:3), rvr\_duration,
controlled\_for\_4hour, total\_rate\_drug\_num\_withinrvr,
first\_drug\_withinrvr, ...

second\_drug\_withinrvr, third\_drug\_withinrvr,
fourth\_drug\_withinrvr, fifth\_drug\_withinrvr, before\_drug\_map,
trough\_MAP\_withinrvr,...

any\_vaso\_before\_rvr, total\_vasopressor\_num\_withinrvr,
first\_vasopressor\_withinrvr, second\_vasopressor\_withinrvr,
third\_vasopressor\_withinrvr, ...

first\_vaso\_before\_dose, first\_vaso\_within\_dose,
second\_rate\_drug\_kick\_in\_time\];

% dataset column specification:

% 1.SUBJECT\_ID 2.HADM\_ID 3.ICUSTAY\_ID 4.RVR\_duration(mins) 5.reached
control for sustained four-hour period or not(binary)

% 6.Total num of rate control meds received 7.first rate control med
8.second rate control med 9.third rate control med

% 10.fourth rate control med 11.fifth rate control med 12.MAP before
first drug 13.trough MAP within RVR episode

% 14. any\_vasopressor before RVR 15.total types of vaso pressor
received during RVR 16.first vasopressor 17.second vasopressor

% 18.third vasopressor 19. mean dose of the first vasopressore before
RVR 20. mean dose of the first vasopressore during RVR

% 21. time lapse between 1st and 2nd rate drug

end

% clean dataset

trash1 = find( isnan(dataset(:,4)) );

dataset(trash1,:)=\[\];
