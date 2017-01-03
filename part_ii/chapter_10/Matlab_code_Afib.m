% [Afib query code] by [MATLAB]

%This is a detailed example of processing primitive data for ‘hidden’
% exposures. Since atrial fibrillation with rapid ventricular
% response(AfibRVR) is not a defined variable/event in the database,
% recognition of these event requires a separate algorithm to combine
% multiple information and conditions. In this case, we chose Matlab to
% develop a sophisticated algorithm that recognize an event that meets
% multiple criteria, including heart rate(HR) over 110 beats/min, received
% rate control medication when the HR is over 110, HR is over 110 for a
% substantial time, HR subsequently under control over a substantial time.

%% make dataset matrix, adjust column number

dataset = zeros( length(med_s), 21 );

% error tolerance variable control

% this controls the time window of looking for HR >=110 around the 1st_drug time

find_rvr_window = datenum([0 0 0 2 0 0]);

% this controls the time window of looking for drugs administered around the RVR episode

find_drug_window = datenum([0 0 0 2 0 0]);

% This part cleans up the HR data. Although HR data is a structured data
% by definition, several reasons make this data look like an unstructured
% data, including the fact that one patient could have thousands of HR
% data, HR being highly variable as well as missing or incomplete
% recording of HR.

[~,index]=unique(HR_data_ts_sorted(:,12),'stable');

HR_data_ts_sorted = HR_data_ts_sorted(sort(index),:);

% HR data(value and tn) interpolation

% added for revised_new_strategy

HR_dn = HR_data_ts_sorted(:,12);

HR_val = HR_data_ts_sorted(:,4);

min_step = datenum([0 0 0 0 5 0]); % ASSUMING MINS!!!

HR_dn_new = HR_dn(1):min_step:HR_dn(end);

HR_val_new = interp1(HR_dn,HR_val,HR_dn_new,'linear');

interpolated_HR_m =[HR_val_new', HR_dn_new'];

% \*\*\*\*\*now you have all the data of this_subject needed for analysis\*\*\*\*\*

else

meds_data_ts_sorted = [];

vaso_data_ts_sorted = [];

HR_data_ts_sorted = [nan,nan,this_s];

first_drug = nan;

first_drug_dn = nan;

end

% end of get data within ICUSTAY

% % % % % % % % % % % % % % % % % % % % % % % %

%\*\*\*\*\*\*\*\*_Core_Algorithm

% —Recognize a substantial RVR event_\*\*\*\*\*\*\*\*\*

check_hr_start_dn = first_drug_dn - find_rvr_window;

check_hr_stop_dn = first_drug_dn + find_rvr_window;

within_check_index = find(check_hr_start_dn <=
interpolated_HR_m(:,2) & interpolated_HR_m(:,2) <=
check_hr_stop_dn );

interpolated_HR_m_within_check =
interpolated_HR_m(within_check_index,:);

first_rvr_within_check_i = find(
(interpolated_HR_m_within_check(:,1)>=110)==1, 1 ); % find the first hr_tn where HR>=110 within the checking period

% syntax: find(A,1) A: condition

if ~isempty(first_rvr_within_check_i)

rvr_start_dn = interpolated_HR_m_within_check(
first_rvr_within_check_i ,2);

rvr_start_i = find( interpolated_HR_m(:,2)==rvr_start_dn );

rvr_start_HR = interpolated_HR_m(rvr_start_i,1);

else

rvr_start_dn =nan;

rvr_start_i = nan;

rvr_start_HR = nan;

end

% find the end of RVR per criteria 3b

% asign value to controlled_for_4hour label

if ~isnan(rvr_start_i)

check_end = find( interpolated_HR_m(rvr_start_i:end,1)<110 );

check_rvr_end_points_i = check_end + (rvr_start_i-1);

if ~isempty(check_end)

for j = 1:length(check_rvr_end_points_i)

if check_rvr_end_points_i(j)+47<=length(interpolated_HR_m)

if nnz( interpolated_HR_m(
check_rvr_end_points_i(j):check_rvr_end_points_i(j)+47 ,1)
>=110 )<=5

rvr_end_i = check_rvr_end_points_i(j);

rvr_end_dn = interpolated_HR_m(rvr_end_i,2);

controlled_for_4hour = 1; %dataset column 5 output

break

end

elseif check_rvr_end_points_i(j)+47 > length(interpolated_HR_m)

if nnz( interpolated_HR_m( check_rvr_end_points_i(j):end,1)
>=110 )<= (length(interpolated_HR_m) -
length(interpolated_HR_m(1:check_rvr_end_points_i(j))))/10

rvr_end_i = check_rvr_end_points_i(j);

rvr_end_dn = interpolated_HR_m(rvr_end_i,2);

controlled_for_4hour=0.5; %dataset column 5 output

break

end

end

rvr_end_i=nan;

rvr_end_dn=nan;

controlled_for_4hour=0; %dataset column 5 output

end

elseif isempty(check_end)

rvr_end_i=nan;

rvr_end_dn=nan;

controlled_for_4hour=0; %dataset column 5 output

end

elseif isnan(rvr_start_i)

rvr_end_i=nan;

rvr_end_dn=nan;

controlled_for_4hour=nan; %dataset column 5 output

end

% get rvr_duration, if no true end of RVR identified previously, take

% the last HR record tn for calculating the duration

if ~isnan(rvr_start_dn) && ~isnan(rvr_end_dn)

rvr_duration = etime( datevec(rvr_end_dn) , datevec(rvr_start_dn)
)/60.0; %dataset column 4 output

elseif ~isnan(rvr_start_dn) && isnan(rvr_end_dn)

rvr_duration = etime( datevec(interpolated_HR_m(end,2)) ,
datevec(rvr_start_dn) )/60.0; %dataset column 4 output

else

rvr_duration = nan; %dataset column 4 output

end

% find data only within the rvr episode( error tolerance time window considered )

find_drug_start_dn = rvr_start_dn - find_drug_window;

find_drug_end_dn = rvr_end_dn + find_drug_window;

if ~isnan(rvr_start_dn) && ~isnan(rvr_end_dn)

meds_withinrvr_index = find(find_drug_start_dn
<=meds_data_ts_sorted(:,11) & meds_data_ts_sorted(:,11) <=
find_drug_end_dn );

meds_data_ts_withinrvr =
meds_data_ts_sorted(meds_withinrvr_index,:);

vaso_withinrvr_index = find( find_drug_start_dn
<=vaso_data_ts_sorted(:,11) & vaso_data_ts_sorted(:,11) <=
find_drug_end_dn );

vaso_data_ts_withinrvr =
vaso_data_ts_sorted(vaso_withinrvr_index,:);

elseif ~isnan(rvr_start_dn) && isnan(rvr_end_dn)

meds_withinrvr_index = find(find_drug_start_dn
<=meds_data_ts_sorted(:,11) );

meds_data_ts_withinrvr =
meds_data_ts_sorted(meds_withinrvr_index,:);

vaso_withinrvr_index = find( find_drug_start_dn
<=vaso_data_ts_sorted(:,11) );

vaso_data_ts_withinrvr =
vaso_data_ts_sorted(vaso_withinrvr_index,:);

else

meds_data_ts_withinrvr =[];

vaso_data_ts_withinrvr =[];

end

% % % % % % % % % % % % % % % % % % % % % % % %

% end of find data within RVR episode
