% LOADDATA loads data and builds design matrix
function LoadData(up)

% skip this processing if it's already been done
save_path = [up.paths.analysis_folder, up.paths.data_matrices, '.mat'];
if exist(save_path, 'file')
    return
end

fprintf('\n - Loading Data')

%% Demographic data

filename = [up.paths.data_folder, 'data\export_demog.csv'];
[~,~,iid,~,~,~,~,~,dischTime,gender,~,~,age,~,~,~,outcome] = ...
    ImportDemographicFile(filename);

gender = strcmpi(gender,'"M"');
age(age >= 91) = 91;

N = length(iid);                                      % number of subjects
design_header{1} = 'iid';
design_header{2} = 'age';
design_header{3} = 'gender';
design_header{4} = 'charttime';
v = 5;

WSIZE = 4*60;                                       % sample every 4 hours
n = 1;
DATA = -1*ones(100000,30);
response_data = -1*ones(100000,3);
response_header = {'icu_death','death_in_24hours','time2death'};

%% Import each parameter in turn
% identify parameter files
filenames = dir([up.paths.data_folder, 'data\']);
rel_filename_log = true(length(filenames),1);
% exclude irrelevant files
for s = 1 : length(filenames)
    if length(filenames(s).name) <= 2 || strcmpi(filenames(s).name,'export_demog.csv')
        rel_filename_log(s) = false;
    end
end
filenames = filenames(rel_filename_log);

% loop over each file - specific to a particular parameter
for i = 1 : length(filenames)                            
    
    design_header{v} = filenames(i).name(8:end-4);     %   create header
    
    % import ICU stay IDs, times and values of parameters
    [~,iidp,~,~,time,val,~,~] = ...
        ImportCsvDataFile([up.paths.data_folder, 'data\' filenames(i).name]);
    
    % loop over each patient
    for j = 1 : N
        % generate time periods for this patient
        WIN2 = WSIZE:WSIZE:dischTime(j);
        WIN1 = WIN2-WSIZE;
        % identify measurements which were taken from this patient
        ind = find(iidp == iid(j));
        timep = time(ind); valp = val(ind);
        % identify measurements as the last measurement which was taken during each time period
        [timep, isort] = sort(timep); valp = valp(isort);
        f = ...
            arrayfun(@(x,y) valp(find(x < timep & timep <= y,1,'last')),WIN1',WIN2','UniformOutput',0);
        
        % loop over each time period
        for k = 1 : length(WIN1)
            % If this is the first parameter then fill in the fixed variables
            if i == 1
                DATA(n,1) = iid(j);
                DATA(n,2) = age(j);
                DATA(n,3) = gender(j);
                DATA(n,4) = WIN2(k);
                response_data(n,1) = outcome(j);
                if outcome(j) == 1
                    if WIN2(k) >= (dischTime(j) - 24*60)
                        response_data(n,2) = 1;
                    else
                        response_data(n,2) = 0;
                    end
                    response_data(n,3) = dischTime(j) - WIN2(k);
                else
                    response_data(n,2) = 0;
                    response_data(n,3) = nan(1);
                end
            end
            % fill in the parameter value
            if ~isempty(f{k})
                DATA(n,v) = f{k};
            else
                DATA(n,v) = nan(1);
            end
            n = n + 1;
        end
    end
    v = v + 1;
    n = 1;
end

index = sum(response_data,2) == -3;
DATA(index,:) = [];
response_data(index,:) = [];
design_data = DATA;

%% Save

save(save_path,'design_data','design_header','response_data','response_header');
end