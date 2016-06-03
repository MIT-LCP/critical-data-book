% New schema_revised 0626: 
% 1. find the first rate control drug within ICUSTAY
%     ** rate control druges:  amiodarone(1),digoxin(2), diltiazem(3), esmolol(4), ibutilide(5), metoprolol(6), procainamide(7), propafenone(8) 
% 2. look at HR values within a 4-hour window before and after the 1st drug
%     2a. if there is HR>=110 within the 4-hour window, include as a possible AfibRVR subject
%     2b. Use the 1st HR >=110 within the window as the start of RVR
% 3. Identify the end of RVR
%     **HR < 110 for at least 90% of the time for 4 hours after a "less-than-110" HR
% 4. Use the START and END of RVR to identify all drugs received/other vital signs within the RVR episode
%     ( **error tolerance can be set before the looping code, i.e. extend the
%     window of looking for drug 4 hour before the start of RVR & 4 hour after the end of RVR** )
%     4a. drugs for rate control: amiodarone(1),digoxin(2), diltiazem(3), esmolol(4), ibutilide(5), metoprolol(6), procainamide(7), propafenone(8) 
%           (specify the sequence of receiving these drugs)
%     4b. vasopressors: 
%           dobutamine(42), dopamine(43), epinephrine(44), levophed(47), epinephrine-k(119), 
%           dobutamine drip(306), dopamine drip(307), epinephrine drip(309)
%           ** for those who received vasopressors, compare the (mean) does before and after the start of RVR
%     4d. identify vitals, CBC, BMP before/and closest to the start of RVR(give a window to look for these values) 
%           and trough MAP within the RVR episode
% 5. make dataset
%      dataset column specification: 
%      1.SUBJECT_ID 2.HADM_ID 3.ICUSTAY_ID 4.RVR_duration(mins) 5.reached control for sustained 4-hour period or not(binary) 
%      6.Total num of rate control meds received 7.first rate control med 8.second rate control med 9.third rate control med 
%      10.fourth rate control med 11.fifth rate control med 12.MAP before first drug 13.trough MAP within RVR episode
%      14. any_vasopressor before RVR 15.total types of vaso pressor received during RVR 16.first vasopressor 17.second vasopressor 
%      18.third vasopressor 19. mean dose of the first vasopressore before RVR 20. mean dose of the first vasopressore during RVR
%      21. SOFA score nearest to the start of RVR 22. temperature before first drug 23. SpO2 before first drug 24. Hb before first drug
%      25. WBC before first drug 26. Plt before first drug 27. Hct before first drug 28. Na+ before first drug 29. K+ before first drug
%      30. Cl- before first drug 31. BUN before first drug 32. Cre before first drug 33. HCO3- before first drug 34. Glucose before first drug
%
%      Remove observations with 1st_rate_drug other than amiodarone(1), diltiazem(3), or metoprolol(6)
%% load data
clear all
load('b1_HR_data.mat','HR_data')
load('b2_icutime_data.mat','icutime_data')
%load meds
load('b3.1_amio_data.mat','amio_data') %Amiodarone, alias:1
load('b3.2_digi_data.mat','digi_data') %Digoxin, alias:2
load('b3.3_dil_data.mat','dil_data') %Diltiazem, alias:3
load('b3.4_esmo_data.mat','esmo_data') %Esmolol, alias:4
load('b3.5_ibu_data.mat','ibu_data') %Ibutilide, alias:5
load('b3.6_meto_data.mat','meto_data') %Metoprolol, alias:6
load('b3.7_proc_data.mat','proc_data') %Procainamide, alias:7
load('b3.8_prop_data.mat','prop_data') %Propafenone, alias:8
load('b3.9_vaso_data.mat','vaso_data') %All vasopressors
%load vitals
load('b4.2_map_data.mat','map_data') %Mean Arterial Pressure, alias:1
load('b4.3_temp_data.mat','temp_data') %temperature (F), alias:2
load('b4.4_oxy_data.mat','oxy_data') % SpO2 or SaO2, alias:3
%CBC & BMP
load('b5.1_hb_data.mat','hb_data') %alias:4
load('b5.2_wbc_data.mat','wbc_data') %alias:5
load('b5.3_plt_data.mat','plt_data') %alias:6
load('b5.4_hct_data.mat','hct_data') %alias:7
load('b6.1_na_data.mat','na_data') %alias:8
load('b6.2_k_data.mat','k_data') %alias:9
load('b6.3_cl_data.mat','cl_data') %alias:10
load('b6.4_bun_data.mat','bun_data') %alias:11
load('b6.5_cre_data.mat','cre_data') %alias:12
load('b6.6_hco3_data.mat','hco3_data') %alias:13
load('b6.7_glu_data.mat','glu_data') %alias:14

load('b9_sofa_data','sofa_data') %SOFA score

% make subject list by icustay_id of rate control drugs
amio_s = unique( amio_data(:,3) );
digi_s = unique( digi_data(:,3) );
dil_s = unique( dil_data(:,3) );
esmo_s = unique( esmo_data(:,3) );
ibu_s = unique( ibu_data(:,3) );
meto_s = unique( meto_data(:,3) );
proc_s = unique( proc_data(:,3) );
prop_s = unique( prop_data(:,3) );
% % % % % % % % % % % % % % % % % % % % % % % %
med_s = unique( [amio_s' digi_s' dil_s' esmo_s' ibu_s' meto_s' proc_s' prop_s'] )';
% % % % % % % % % % % % % % % % % % % % % % % %
clear amio_s digi_s dil_s esmo_s ibu_s meto_s proc_s prop_s

%% make dataset matrix, adjust column number
dataset_0626 = zeros( length(med_s), 15 );

% error tolerance variable control 
% this controls the time window of looking for HR >=110 around the 1st_drug time
find_rvr_window = datenum([0 0 0 2 0 0]); 

% this controls the time window of looking for drugs administered around the RVR episode
find_drug_window = datenum([0 0 0 2 0 0]); 
% this controls the time window of looking for vitals/Labs before the RVR episode
find_vitals_labs_windows = datenum([0 0 1 0 0 0]); 

%% extract subject for analysis

for i= 1: length(med_s);
    i
    %% unique icustay as this_subject identifier
    this_s = med_s(i);
    % get data of this_s
    % tsi: this_subject_index
    HR_tsi = find( HR_data(:,3)==this_s );
    icutime_tsi = find( icutime_data(:,3)==this_s );
    
    amio_tsi = find( amio_data(:,3)==this_s );
    digi_tsi = find( digi_data(:,3)==this_s );
    dil_tsi = find( dil_data(:,3)==this_s );
    esmo_tsi = find( esmo_data(:,3)==this_s );
    ibu_tsi = find( ibu_data(:,3)==this_s );
    meto_tsi = find( meto_data(:,3)==this_s );
    proc_tsi = find( proc_data(:,3)==this_s );
    prop_tsi = find( prop_data(:,3)==this_s );
    vaso_tsi = find( vaso_data(:,3)==this_s );
    
    map_tsi = find( map_data(:,3)==this_s );
    temp_tsi = find( temp_data(:,3)==this_s );
    oxy_tsi = find( oxy_data(:,3)==this_s );
    hb_tsi = find( hb_data(:,3)==this_s );
    wbc_tsi = find( wbc_data(:,3)==this_s );
    plt_tsi = find( plt_data(:,3)==this_s );
    hct_tsi = find( hct_data(:,3)==this_s );
    na_tsi = find( na_data(:,3)==this_s );
    k_tsi = find( k_data(:,3)==this_s );
    cl_tsi = find( cl_data(:,3)==this_s );
    bun_tsi = find( bun_data(:,3)==this_s );
    cre_tsi = find( cre_data(:,3)==this_s );
    hco3_tsi = find( hco3_data(:,3)==this_s );
    glu_tsi = find( glu_data(:,3)==this_s );
    
    sofa_tsi = find( sofa_data(:,3)==this_s );
    
    % A_get this_subject icu_dn
    icuin_tstn = datenum(icutime_data(icutime_tsi,4:9));
    icuout_tstn = datenum(icutime_data(icutime_tsi,10:15));
  
    % B_make data matrix of this subject 
    HR_data_ts = HR_data(HR_tsi,:);
    
    amio_data_ts = amio_data(amio_tsi,:);
    digi_data_ts = digi_data(digi_tsi,:);
    dil_data_ts = dil_data(dil_tsi,:);
    esmo_data_ts = esmo_data(esmo_tsi,:);
    ibu_data_ts = ibu_data(ibu_tsi,:);
    meto_data_ts = meto_data(meto_tsi,:);
    proc_data_ts = proc_data(proc_tsi,:);
    prop_data_ts = prop_data(prop_tsi,:);
    
    vaso_data_ts = vaso_data(vaso_tsi,:);
    
    map_data_ts = map_data(map_tsi,:);
    temp_data_ts = temp_data(temp_tsi,:);
    oxy_data_ts = oxy_data(oxy_tsi,:);
    hb_data_ts = hb_data(hb_tsi,:);
    wbc_data_ts = wbc_data(wbc_tsi,:);
    plt_data_ts = plt_data(plt_tsi,:);
    hct_data_ts = hct_data(hct_tsi,:);
    na_data_ts = na_data(na_tsi,:);
    k_data_ts = k_data(k_tsi,:);
    cl_data_ts = cl_data(cl_tsi,:);
    bun_data_ts = bun_data(bun_tsi,:);
    cre_data_ts = cre_data(cre_tsi,:);
    hco3_data_ts = hco3_data(hco3_tsi,:);
    glu_data_ts = glu_data(glu_tsi,:);
    
    sofa_data_ts = sofa_data(sofa_tsi,:);
    % created a combined matrix for meds
    meds_data_ts = zeros(1,12);
    if~isempty(amio_data_ts)
        meds_data_ts = [meds_data_ts; amio_data_ts];
    end
    if~isempty(digi_data_ts)
        meds_data_ts = [meds_data_ts; digi_data_ts];
    end
    if~isempty(dil_data_ts)
        meds_data_ts = [meds_data_ts; dil_data_ts];
    end
    if~isempty(esmo_data_ts)
        meds_data_ts = [meds_data_ts; esmo_data_ts];
    end
    if~isempty(ibu_data_ts)
        meds_data_ts = [meds_data_ts; ibu_data_ts];
    end
    if~isempty(meto_data_ts)
        meds_data_ts = [meds_data_ts; meto_data_ts];
    end
    if~isempty(proc_data_ts)
        meds_data_ts = [meds_data_ts; proc_data_ts];
    end
    if~isempty(prop_data_ts)
        meds_data_ts = [meds_data_ts; prop_data_ts];
    end
    if size(meds_data_ts,1)>=2
        meds_data_ts = meds_data_ts(2:end,:); 
    elseif size(meds_data_ts,1)==1
        meds_data_ts =[];
    end
    % created a combined matrix for vitals and labs
    vitals_labs_ts = zeros(1,12);
    if~isempty(map_data_ts)
        vitals_labs_ts = [vitals_labs_ts; map_data_ts];
    end
    if~isempty(temp_data_ts)
        vitals_labs_ts = [vitals_labs_ts; temp_data_ts];
    end
    if~isempty(oxy_data_ts)
        vitals_labs_ts = [vitals_labs_ts; oxy_data_ts];
    end
    if~isempty(hb_data_ts)
        vitals_labs_ts = [vitals_labs_ts; hb_data_ts];
    end
    if~isempty(wbc_data_ts)
        vitals_labs_ts = [vitals_labs_ts; wbc_data_ts];
    end
    if~isempty(plt_data_ts)
        vitals_labs_ts = [vitals_labs_ts; plt_data_ts];
    end
    if~isempty(hct_data_ts)
        vitals_labs_ts = [vitals_labs_ts; hct_data_ts];
    end
    if~isempty(na_data_ts)
        vitals_labs_ts = [vitals_labs_ts; na_data_ts];
    end
    if~isempty(k_data_ts)
        vitals_labs_ts = [vitals_labs_ts; k_data_ts];
    end
    if~isempty(cl_data_ts)
        vitals_labs_ts = [vitals_labs_ts; cl_data_ts];
    end
    if~isempty(bun_data_ts)
        vitals_labs_ts = [vitals_labs_ts; bun_data_ts];
    end
    if~isempty(cre_data_ts)
        vitals_labs_ts = [vitals_labs_ts; cre_data_ts];
    end
    if~isempty(hco3_data_ts)
        vitals_labs_ts = [vitals_labs_ts; hco3_data_ts];
    end
    if~isempty(glu_data_ts)
        vitals_labs_ts = [vitals_labs_ts; glu_data_ts];
    end
    if size(vitals_labs_ts,1)>=2
        vitals_labs_ts = vitals_labs_ts(2:end,:); 
    elseif size(vitals_labs_ts,1)==1
        vitals_labs_ts =[];
    end
    
    
    % B1: get data only within the ICUSTAY
    if ~isempty(icuin_tstn)
            meds_within_index = find( icuin_tstn <=meds_data_ts(:,11) & meds_data_ts(:,11) <= icuout_tstn );
            meds_data_ts_within = meds_data_ts(meds_within_index,:);
            
            vaso_within_index = find( icuin_tstn <=vaso_data_ts(:,11) & vaso_data_ts(:,11) <= icuout_tstn );
            vaso_data_ts_within = vaso_data_ts(vaso_within_index,:);
            
            HR_within_index = find( icuin_tstn <= HR_data_ts(:,12) & HR_data_ts(:,12) <= icuout_tstn );
            HR_data_ts_within = HR_data_ts(HR_within_index,:);
            
            map_within_index = find( icuin_tstn <= map_data_ts(:,11) & map_data_ts(:,11) <= icuout_tstn );
            map_data_ts_within = map_data_ts(map_within_index,:);
            
            vitals_labs_within_index = find( (icuin_tstn - find_vitals_labs_windows) <= vitals_labs_ts(:,11) & vitals_labs_ts(:,11) <= icuout_tstn );
            vitals_labs_ts_within = vitals_labs_ts(vitals_labs_within_index,:);
            
            % C_sort this_subject_data subset by time sequence
            meds_data_ts_sorted = sortrows(meds_data_ts_within,11);
            vaso_data_ts_sorted = sortrows(vaso_data_ts_within,11);
            HR_data_ts_sorted = sortrows(HR_data_ts_within,12);
            map_data_ts_sorted = sortrows(map_data_ts_within,11);
            vitals_labs_ts_sorted = sortrows(vitals_labs_ts_within,11);
            
             % find the min dn of rate control drug given (within the entire ICUSTAY)
            if ~isempty(meds_data_ts_sorted)
                first_drug = meds_data_ts_sorted(1,12);
                first_drug_dn = meds_data_ts_sorted(1,11);
            else
                first_drug = nan;
                first_drug_dn = nan;
            end
            
            %
            % clean up tn of HR(remove multiple tn, will cause trouble during interpolation)
            % added for revised_new_strategy
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

            % *****now you have all the data of this_subject needed for analysis*****
    else
            meds_data_ts_sorted = [];
            vaso_data_ts_sorted = [];
            HR_data_ts_sorted = [nan,nan,this_s];
            map_data_ts_sorted = [];
            vitals_labs_ts_sorted = [];
            first_drug = nan;
            first_drug_dn = nan;
    end
   % end of get data within ICUSTAY

    % % % % % % % % % % % % % % % % % % % % % % % %
   % % % % % % % % % % % % % % % % % % % % % % % %
   %********Revised_New_Strategy*********
   check_hr_start_dn = first_drug_dn - find_rvr_window;
   check_hr_stop_dn = first_drug_dn + find_rvr_window;
   within_check_index = find(check_hr_start_dn <= interpolated_HR_m(:,2) & interpolated_HR_m(:,2) <= check_hr_stop_dn );
   interpolated_HR_m_within_check = interpolated_HR_m(within_check_index,:);
   first_rvr_within_check_i = find( (interpolated_HR_m_within_check(:,1)>=110)==1, 1 ); % find the first hr_tn where HR>=110 within the checking period
   % syntax: find(A,1) A: condition
   if ~isempty(first_rvr_within_check_i)
        rvr_start_dn = interpolated_HR_m_within_check( first_rvr_within_check_i ,2);
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
                          if nnz( interpolated_HR_m( check_rvr_end_points_i(j):check_rvr_end_points_i(j)+47 ,1) >=110 )<=5
                             rvr_end_i = check_rvr_end_points_i(j);
                             rvr_end_dn = interpolated_HR_m(rvr_end_i,2);
                             controlled_for_4hour = 1; %dataset column 5 output
                             break   
                          end
                      elseif check_rvr_end_points_i(j)+47 > length(interpolated_HR_m)
                          if nnz( interpolated_HR_m( check_rvr_end_points_i(j):end,1) >=110 )<= (length(interpolated_HR_m) - length(interpolated_HR_m(1:check_rvr_end_points_i(j))))/10
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
    rvr_duration = etime( datevec(rvr_end_dn) , datevec(rvr_start_dn) )/60.0; %dataset column 4 output
   elseif ~isnan(rvr_start_dn) && isnan(rvr_end_dn)
    rvr_duration = etime( datevec(interpolated_HR_m(end,2)) , datevec(rvr_start_dn) )/60.0; %dataset column 4 output
   else 
    rvr_duration = nan; %dataset column 4 output
   end
   
   % find data only within the rvr episode( error tolerance time window considered )
   find_drug_start_dn = rvr_start_dn - find_drug_window;
   find_drug_end_dn = rvr_end_dn + find_drug_window;
   
   if ~isnan(rvr_start_dn) && ~isnan(rvr_end_dn)
       
       meds_withinrvr_index = find(find_drug_start_dn <=meds_data_ts_sorted(:,11) & meds_data_ts_sorted(:,11) <= find_drug_end_dn );
       meds_data_ts_withinrvr = meds_data_ts_sorted(meds_withinrvr_index,:);
       
       vaso_withinrvr_index = find( find_drug_start_dn <=vaso_data_ts_sorted(:,11) & vaso_data_ts_sorted(:,11) <= find_drug_end_dn );
       vaso_data_ts_withinrvr = vaso_data_ts_sorted(vaso_withinrvr_index,:);
       
       map_withinrvr_index = find( find_drug_start_dn <= map_data_ts_sorted(:,11) & map_data_ts_sorted(:,11) <= find_drug_end_dn );
       map_data_ts_withinrvr = map_data_ts_sorted(map_withinrvr_index,:);
       
   elseif ~isnan(rvr_start_dn) && isnan(rvr_end_dn)
       meds_withinrvr_index = find(find_drug_start_dn <=meds_data_ts_sorted(:,11) );
       meds_data_ts_withinrvr = meds_data_ts_sorted(meds_withinrvr_index,:);
       
       vaso_withinrvr_index = find( find_drug_start_dn <=vaso_data_ts_sorted(:,11) );
       vaso_data_ts_withinrvr = vaso_data_ts_sorted(vaso_withinrvr_index,:);
       
       map_withinrvr_index = find( find_drug_start_dn <= map_data_ts_sorted(:,11) );
       map_data_ts_withinrvr = map_data_ts_sorted(map_withinrvr_index,:);
   else
       meds_data_ts_withinrvr =[];
       vaso_data_ts_withinrvr =[];
       map_data_ts_withinrvr =[];
   end
  % % % % % % % % % % % % % % % % % % % % % % % %
  % end of find data within RVR episode
 
   % % % % % % % % % % % % % % % % % % % % % % % %
   % sequence rate control drug within RVR episode
 if ~isempty(meds_data_ts_withinrvr)
           rate_drug_withinrvr = unique( meds_data_ts_withinrvr(:,12));
           total_rate_drug_num_withinrvr = length(rate_drug_withinrvr);
           withinrvr_rate_drug_sequence = zeros(total_rate_drug_num_withinrvr,2);
           for k=1:total_rate_drug_num_withinrvr
            this_drug = rate_drug_withinrvr(k);
            this_drug_first_index = find( meds_data_ts_withinrvr(:,12)==this_drug,1 );
            this_drug_first_dn = meds_data_ts_withinrvr(this_drug_first_index,11);
            withinrvr_rate_drug_sequence(k,:)=[this_drug, this_drug_first_dn];
           end
            withinrvr_rate_drug_sequence_sorted = sortrows(withinrvr_rate_drug_sequence,2);
   % % % % % % % % % % % % % % % % % % % % % % % %
   % % % % % % % % % % % % % % % % % % % % % % % %
  % asign (rate control) drug ssequence within RVR episode       
          if total_rate_drug_num_withinrvr>=5
              first_drug_withinrvr = withinrvr_rate_drug_sequence_sorted(1,1);
              first_drug_withinrvr_tsdn = withinrvr_rate_drug_sequence_sorted(1,2);
              second_drug_withinrvr = withinrvr_rate_drug_sequence_sorted(2,1);
              second_drug_withinrvr_tsdn = withinrvr_rate_drug_sequence_sorted(2,2);
              third_drug_withinrvr = withinrvr_rate_drug_sequence_sorted(3,1);
              fourth_drug_withinrvr = withinrvr_rate_drug_sequence_sorted(4,1);
              fifth_drug_withinrvr = withinrvr_rate_drug_sequence_sorted(5,1);
          elseif total_rate_drug_num_withinrvr==4
              first_drug_withinrvr = withinrvr_rate_drug_sequence_sorted(1,1);
              first_drug_withinrvr_tsdn = withinrvr_rate_drug_sequence_sorted(1,2);
              second_drug_withinrvr = withinrvr_rate_drug_sequence_sorted(2,1);
              second_drug_withinrvr_tsdn = withinrvr_rate_drug_sequence_sorted(2,2);
              third_drug_withinrvr = withinrvr_rate_drug_sequence_sorted(3,1);
              fourth_drug_withinrvr = withinrvr_rate_drug_sequence_sorted(4,1);
              fifth_drug_withinrvr = 0;
          elseif total_rate_drug_num_withinrvr==3
              first_drug_withinrvr = withinrvr_rate_drug_sequence_sorted(1,1);
              first_drug_withinrvr_tsdn = withinrvr_rate_drug_sequence_sorted(1,2);
              second_drug_withinrvr = withinrvr_rate_drug_sequence_sorted(2,1);
              second_drug_withinrvr_tsdn = withinrvr_rate_drug_sequence_sorted(2,2);
              third_drug_withinrvr = withinrvr_rate_drug_sequence_sorted(3,1);
              fourth_drug_withinrvr = 0;
              fifth_drug_withinrvr = 0;
          elseif total_rate_drug_num_withinrvr==2
              first_drug_withinrvr = withinrvr_rate_drug_sequence_sorted(1,1);
              first_drug_withinrvr_tsdn = withinrvr_rate_drug_sequence_sorted(1,2);
              second_drug_withinrvr = withinrvr_rate_drug_sequence_sorted(2,1);
              second_drug_withinrvr_tsdn = withinrvr_rate_drug_sequence_sorted(2,2);
              third_drug_withinrvr = 0;
              fourth_drug_withinrvr = 0;
              fifth_drug_withinrvr = 0;
          elseif total_rate_drug_num_withinrvr==1
              first_drug_withinrvr = withinrvr_rate_drug_sequence_sorted(1,1);
              first_drug_withinrvr_tsdn = withinrvr_rate_drug_sequence_sorted(1,2);
              second_drug_withinrvr = 0;
              second_drug_withinrvr_tsdn = nan;
              third_drug_withinrvr = 0;
              fourth_drug_withinrvr = 0;
              fifth_drug_withinrvr = 0;
          end
 elseif isempty(meds_data_ts_withinrvr)
     rate_drug_withinrvr=[];
     total_rate_drug_num_withinrvr=0;
     withinrvr_rate_drug_sequence=[];
     withinrvr_rate_drug_sequence_sorted=[];
     first_drug_withinrvr = 0;
     first_drug_withinrvr_tsdn =0;
     second_drug_withinrvr = 0;
     second_drug_withinrvr_tsdn = nan;
     third_drug_withinrvr = 0;
     fourth_drug_withinrvr = 0;
     fifth_drug_withinrvr = 0;
 end
 
 if ~isnan(second_drug_withinrvr_tsdn)
    second_rate_drug_kick_in_time = etime(datevec(second_drug_withinrvr_tsdn),datevec(first_drug_withinrvr_tsdn))/60.0;
 else
     second_rate_drug_kick_in_time = 9999;
 end
   %********end of revised new strategy code***********
   % % % % % % % % % % % % % % % % % % % % % % % %
   % % % % % % % % % % % % % % % % % % % % % % % %
    
% get the vitals_labs immediately before 1st_rate_drug
% % % % % % % % % % % % % % % % % % % % % % % %
        if ~isempty(vitals_labs_ts_sorted) && ~isnan(first_drug_withinrvr_tsdn)
            before_drug_vitals_labs_i = find( vitals_labs_ts_sorted(:,11) <= first_drug_withinrvr_tsdn) ; 
            before_drug_vitals_labs = vitals_labs_ts_sorted(before_drug_vitals_labs_i , : );
            
            before_drug_map_i = find( before_drug_vitals_labs(:,12)==1,1,'last');
            if ~isempty(before_drug_map_i)
                before_drug_map = before_drug_vitals_labs(before_drug_map_i,4);
            else
                before_drug_map=nan;
            end
            before_drug_temp_i = find( before_drug_vitals_labs(:,12)==2,1,'last');
            if ~isempty(before_drug_temp_i)
                before_drug_temp = before_drug_vitals_labs(before_drug_temp_i,4);
            else
                before_drug_temp=nan;
            end
            before_drug_oxy_i = find( before_drug_vitals_labs(:,12)==3,1,'last');
            if ~isempty(before_drug_oxy_i)
                before_drug_oxy = before_drug_vitals_labs(before_drug_oxy_i,4);
            else
                before_drug_oxy=nan;
            end
            before_drug_hb_i = find( before_drug_vitals_labs(:,12)==4,1,'last');
            if ~isempty(before_drug_hb_i)
                before_drug_hb = before_drug_vitals_labs(before_drug_hb_i,4);
            else
                before_drug_hb=nan;
            end
            before_drug_wbc_i = find( before_drug_vitals_labs(:,12)==5,1,'last');
            if ~isempty(before_drug_wbc_i)
                before_drug_wbc = before_drug_vitals_labs(before_drug_wbc_i,4);
            else
                before_drug_wbc=nan;
            end
            before_drug_plt_i = find( before_drug_vitals_labs(:,12)==6,1,'last');
            if ~isempty(before_drug_plt_i)
                before_drug_plt = before_drug_vitals_labs(before_drug_plt_i,4);
            else
                before_drug_plt=nan;
            end
            before_drug_hct_i = find( before_drug_vitals_labs(:,12)==7,1,'last');
            if ~isempty(before_drug_hct_i)
                before_drug_hct = before_drug_vitals_labs(before_drug_hct_i,4);
            else
                before_drug_hct=nan;
            end
            before_drug_na_i = find( before_drug_vitals_labs(:,12)==8,1,'last');
            if ~isempty(before_drug_na_i)
                before_drug_na = before_drug_vitals_labs(before_drug_na_i,4);
            else
                before_drug_na=nan;
            end
            before_drug_k_i = find( before_drug_vitals_labs(:,12)==9,1,'last');
            if ~isempty(before_drug_k_i)
                before_drug_k = before_drug_vitals_labs(before_drug_k_i,4);
            else
                before_drug_k=nan;
            end
            before_drug_cl_i = find( before_drug_vitals_labs(:,12)==10,1,'last');
            if ~isempty(before_drug_cl_i)
                before_drug_cl = before_drug_vitals_labs(before_drug_cl_i,4);
            else
                before_drug_cl=nan;
            end
            before_drug_bun_i = find( before_drug_vitals_labs(:,12)==11,1,'last');
            if ~isempty(before_drug_bun_i)
                before_drug_bun = before_drug_vitals_labs(before_drug_bun_i,4);
            else
                before_drug_bun=nan;
            end
            before_drug_cre_i = find( before_drug_vitals_labs(:,12)==12,1,'last');
            if ~isempty(before_drug_cre_i)
                before_drug_cre = before_drug_vitals_labs(before_drug_cre_i,4);
            else
                before_drug_cre=nan;
            end
            before_drug_hco3_i = find( before_drug_vitals_labs(:,12)==13,1,'last');
            if ~isempty(before_drug_hco3_i)
                before_drug_hco3 = before_drug_vitals_labs(before_drug_hco3_i,4);
            else
                before_drug_hco3=nan;
            end
            before_drug_glu_i = find( before_drug_vitals_labs(:,12)==14,1,'last');
            if ~isempty(before_drug_glu_i)
                before_drug_glu = before_drug_vitals_labs(before_drug_glu_i,4);
            else
                before_drug_glu=nan;
            end
        else
            before_drug_map=nan;
            before_drug_temp=nan;
            before_drug_oxy=nan;
            before_drug_hb=nan;
            before_drug_wbc=nan;
            before_drug_plt=nan;
            before_drug_hct=nan;
            before_drug_na=nan;
            before_drug_k=nan;
            before_drug_cl=nan;
            before_drug_bun=nan;
            before_drug_cre=nan;
            before_drug_hco3=nan;
            before_drug_glu=nan;
        end
    
        %get trough MAP within RVR episode(consider error tolerance window)
        if ~isempty(map_data_ts_withinrvr)
            trough_MAP_withinrvr = min( map_data_ts_withinrvr(:,4) );
        elseif isempty(map_data_ts_withinrvr)
            trough_MAP_withinrvr = nan;
        end
        % % % % % % % % % % % % % % % % % % % % % % % %
        
% Get vasopressor data
% % % % % % % % % % % % % % % % % % % % % %
 if ~isempty(vaso_data_ts_withinrvr)
           vasopressor_withinrvr = unique( vaso_data_ts_withinrvr(:,12));
           total_vasopressor_num_withinrvr = length(vasopressor_withinrvr);
           withinrvr_vasopressor_sequence = zeros(total_vasopressor_num_withinrvr,2);
           for k=1:total_vasopressor_num_withinrvr
            this_vaso = vasopressor_withinrvr(k);
            this_vaso_first_index = find( vaso_data_ts_withinrvr(:,12)==this_vaso,1 );
            this_vaso_first_dn = vaso_data_ts_withinrvr(this_vaso_first_index,11);
            withinrvr_vasopressor_sequence(k,:)=[this_vaso, this_vaso_first_dn];
           end
            withinrvr_vasopressor_sequence_sorted = sortrows(withinrvr_vasopressor_sequence,2);
  % % % % % % % % % % % % % % % % % % % % % % % %
  % asign vasopressor sequence within RVR episode       
          if total_vasopressor_num_withinrvr>=3
              first_vasopressor_withinrvr = withinrvr_vasopressor_sequence_sorted(1,1);
              first_vasopressor_withinrvr_tsdn = withinrvr_vasopressor_sequence_sorted(1,2);
              second_vasopressor_withinrvr = withinrvr_vasopressor_sequence_sorted(2,1);
              third_vasopressor_withinrvr = withinrvr_vasopressor_sequence_sorted(3,1);
          elseif total_vasopressor_num_withinrvr==2
              first_vasopressor_withinrvr = withinrvr_vasopressor_sequence_sorted(1,1);
              first_vasopressor_withinrvr_tsdn = withinrvr_vasopressor_sequence_sorted(1,2);
              second_vasopressor_withinrvr = withinrvr_vasopressor_sequence_sorted(2,1);
              third_vasopressor_withinrvr = 0;
          elseif total_vasopressor_num_withinrvr==1
              first_vasopressor_withinrvr = withinrvr_vasopressor_sequence_sorted(1,1);
              first_vasopressor_withinrvr_tsdn = withinrvr_vasopressor_sequence_sorted(1,2);
              second_vasopressor_withinrvr = 0;
              third_vasopressor_withinrvr = 0;
          end
 elseif isempty(vaso_data_ts_withinrvr)
     vasopressor_withinrvr=[];
     total_vasopressor_num_withinrvr=0;
     withinrvr_vasopressor_sequence=[];
     withinrvr_vasopressor_sequence_sorted=[];
     first_vasopressor_withinrvr = 0;
     first_vasopressor_withinrvr_tsdn =0;
     second_vasopressor_withinrvr = 0;
     third_vasopressor_withinrvr = 0;
 end
 % look into vasopressor dose before and after the start of RVR
 if first_vasopressor_withinrvr ~=0
     first_vaso_within_i = find( vaso_data_ts_withinrvr(:,12)==first_vasopressor_withinrvr );
     first_vaso_within_m = vaso_data_ts_withinrvr(first_vaso_within_i,:);
     first_vaso_within_dose = mean( first_vaso_within_m(:,4) );
     first_vaso_before_i = find( vaso_data_ts_sorted(:,12)==first_vasopressor_withinrvr & vaso_data_ts_sorted(:,11)< find_drug_start_dn );
     first_vaso_before_m = vaso_data_ts_sorted(first_vaso_before_i,:);
     if ~isempty(first_vaso_before_m)
         first_vaso_before_dose = mean( first_vaso_before_m(:,4) );
     elseif isempty(first_vaso_before_m)
         first_vaso_before_dose =0;
     end
 elseif first_vasopressor_withinrvr ==0
     first_vaso_within_dose =0;
     first_vaso_before_dose =0;
 end
 % % % % % % % % % % % % % % % % % % % % % % % %
 % any vasopressor before RVR
 if ~isempty(vaso_data_ts_sorted)
         any_vaso_before_rvr_i = find( vaso_data_ts_sorted(:,11) < find_drug_start_dn );
         if ~isempty(any_vaso_before_rvr_i)
             any_vaso_before_rvr =1;
         else
             any_vaso_before_rvr =0;
         end
 elseif isempty(vaso_data_ts_sorted)
     any_vaso_before_rvr =0;
 end
 % % % % % % % % % % % % % % % % % % % % % % % %
 % % % % % % % % % % % % % % % % % % % % % % % %
     

    % Get the SOFA score closest to rvr_start_dn
    if ~isnan(rvr_start_dn) && ~isempty(sofa_data_ts)
            for k =1:size(sofa_data_ts,1)
                sofa_to_rvr_start_timelap = etime(datevec(sofa_data_ts(k,11)), datevec(rvr_start_dn));
                sofa_to_rvr_start_timelap_m(k,1) = sofa_to_rvr_start_timelap ;
            end
            sofa_closest_timelap = min( abs( sofa_to_rvr_start_timelap_m ) );
            sofa_closest_to_start_i = find( abs( sofa_to_rvr_start_timelap_m(:,1) )==sofa_closest_timelap );
            sofa_closest_to_start = sofa_data_ts(sofa_closest_to_start_i(1),4);
    elseif isnan(rvr_start_dn)
            sofa_closest_to_start_i = nan;
            sofa_closest_to_start = nan;
    else
            sofa_closest_to_start_i = nan;
            sofa_closest_to_start = nan;
    end
    % clear temp variable for sofa extraction
    clear sofa_to_rvr_start_timelap_m sofa_closest_timelap sofa_to_rvr_start_timelap
    
    %
        dataset_0626(i,1:15) = [ HR_data_ts_sorted(1,1:3), datevec(rvr_start_dn), datevec(rvr_end_dn)];
%      dataset column specification: 
%      1.SUBJECT_ID 2.HADM_ID 3.ICUSTAY_ID 4.RVR_duration(mins) 5.reached control for sustained four-hour period or not(binary) 
%      6.Total num of rate control meds received 7.first rate control med 8.second rate control med 9.third rate control med 
%      10.fourth rate control med 11.fifth rate control med 12.MAP before first drug 13.trough MAP within RVR episode
%      14. any_vasopressor before RVR 15.total types of vaso pressor received during RVR 16.first vasopressor 17.second vasopressor 
%      18.third vasopressor 19. mean dose of the first vasopressore before RVR 20. mean dose of the first vasopressore during RVR
%      21. SOFA score nearest to the start of RVR 22. temperature before first drug 23. SpO2 before first drug 24. Hb before first drug
%      25. WBC before first drug 26. Plt before first drug 27. Hct before first drug 28. Na+ before first drug 29. K+ before first drug
%      30. Cl- before first drug 31. BUN before first drug 32. Cre before first drug 33. HCO3- before first drug 34. Glucose before first drug
%      35. time lapse between 1st and 2nd rate drug
clear this_s rvr_duration controlled_for_4hour total_rate_drug_num_withinrvr first_drug_withinrvr ...
        second_drug_withinrvr third_drug_withinrvr fourth_drug_withinrvr fifth_drug_withinrvr before_drug_MAP trough_MAP_withinrvr...
        total_vasopressor_num_withinrvr first_vasopressor_withinrvr second_vasopressor_withinrvr third_vasopressor_withinrvr ...
        first_vaso_before_dose first_vaso_within_dose sofa_closest_to_start before_drug_temp  before_drug_oxy before_drug_hb before_drug_wbc...
        before_drug_plt before_drug_hct before_drug_na before_drug_k before_drug_cl before_drug_bun before_drug_cre before_drug_hco3...
        before_drug_glu
    
end


% clean dataset
trash1 = find( isnan(dataset_0626(:,4)) );
dataset_0626(trash1,:)=[];

%%
save('dataset_0626.mat','dataset_0626')
csvwrite('dataset_0626.csv',dataset_0626)

%% clear variable

clear all