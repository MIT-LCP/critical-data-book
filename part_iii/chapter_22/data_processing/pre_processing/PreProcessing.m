% PREPROCESSING performs additional pre processing steps
function PreProcessing(up)

% skip this processing if it's already been done
save_path = [up.paths.analysis_folder, up.paths.pre_processing, '.mat'];
if exist(save_path, 'file')
    return
end

fprintf('\n - Performing Pre-Processing')

%% Load design and response matrices
load_path = [up.paths.analysis_folder, up.paths.data_matrices, '.mat'];
matrices = load(load_path);

%% Convert Fahrenheit temperature values into Celcius
temp = ExtractDesignParam(matrices, 'temperature');
% determine median values
cut_off = 60;
c_values = temp(temp < cut_off); c_median = median(c_values);
f_values = temp(temp > cut_off); f_median = median(f_values);
% make vector of new temp values:
temp(temp> cut_off) = (temp(temp> cut_off)-30)/2;
% re-insert temp values
matrices = InsertDesignParam(matrices, temp, 'temperature');

%% Merge non-invasive and invasive blood pressures
bp.i.s = ExtractDesignParam(matrices, 'sysibp');
bp.i.d = ExtractDesignParam(matrices, 'diaibp');
bp.i.m = ExtractDesignParam(matrices, 'mapibp');
bp.n.s = ExtractDesignParam(matrices, 'sysnbp');
bp.n.d = ExtractDesignParam(matrices, 'dianbp');
bp.n.m = ExtractDesignParam(matrices, 'mapnbp');
% - use invasive blood pressures where possible since they are measured
% more frequently
freqs.i = sum(~isnan(bp.i.s));
freqs.n = sum(~isnan(bp.n.s));
bp.corr = bp.i;
% - if using a non-invasive blood pressure, correct for the bias using those time periods at which both were measured
for type = {'s', 'd', 'm'}   % repeat for systolic and diastolic BPs
    eval(['rel_els = ~isnan(bp.n.' type{1,1} ') & ~isnan(bp.i.' type{1,1} ');']);
    eval(['bias = nanmedian(bp.i.' type{1,1} '(rel_els))-nanmedian(bp.n.' type{1,1} '(rel_els));']);    % use the median to reduce the effect of outliers.
    eval(['els_for_correction = ~isnan(bp.n.' type{1,1} ') & isnan(bp.i.' type{1,1} ');']);
    eval(['bp.corr.' type{1,1} '(els_for_correction) = bp.n.' type{1,1} '(els_for_correction) + bias;']);
end
% put back into the design matrix
matrices = InsertDesignParam(matrices, bp.corr.s, 'sysibp');
matrices = InsertDesignParam(matrices, bp.corr.d, 'diaibp');
matrices = InsertDesignParam(matrices, bp.corr.m, 'mapibp');
% remove non-invasive BPs
matrices = RemoveDesignParam(matrices, {'sysnbp', 'dianbp', 'mapnbp'});

%% Impute missing values
% find median values
no_fixed_vars = 4;
id_col = find(strcmp(matrices.design_header, 'iid'));
ids = unique(matrices.design_data(:,id_col));
time_col = find(strcmp(matrices.design_header, 'charttime'));
for param_no = (no_fixed_vars+1) : length(matrices.design_header) % cycle through each parameter
    % extract data for this parameter
    param_data = ExtractDesignParam(matrices, matrices.design_header{param_no});
    param_times = matrices.design_data(:,time_col);
    median_val = nanmedian(param_data);
    
    for ICUstayID = ids(:)'      % cycle through each ICU stay
        
        % extract rel data for this stay:
        rel_els = matrices.design_data(:,1) == ICUstayID;
        rel_data = param_data(rel_els);
        rel_times = param_times(rel_els);
        
        % - if the parameter has not been measured before then impute the median
        % value for the population.
        
        if isnan(rel_data(1))
            rel_data(1) = median_val;
        end
        
        % - if a value is missing, and this parameter has been measured before for
        % this patient, then impute it.
        for s = 2 : length(rel_data)
            if isnan(rel_data(s))
                rel_data(s) = rel_data(s-1);
            end
        end
        
        % re-insert data
        param_data(rel_els) = rel_data;
        
        clear rel_els rel_data rel_times
    end
    % re-insert data
    matrices = InsertDesignParam(matrices, param_data, matrices.design_header{param_no});
    clear median_val param_data param_times
end

%% Split into training and validation datasets
% identify rows of data to be in each dataset
prop_training = 0.5;
id_col = find(strcmp(matrices.design_header, 'iid'));
ids = unique(matrices.design_data(:,id_col));
training_ids = ids(1:(ceil(numel(ids)/2)));
validation_ids = ids((1+(ceil(numel(ids)/2))):end);
training_row_log = false(length(matrices.design_data(:,id_col)),1);
for row_no = 1 : length(matrices.design_data(:,id_col))
    training_row_log(row_no,1) = sum(training_ids == matrices.design_data(row_no,id_col));
end
training_row_log = logical(training_row_log);
% split the dataset
training.design_data = matrices.design_data(training_row_log,:);
training.response_data = matrices.response_data(training_row_log,:);
training.design_header = matrices.design_header;
training.response_header = matrices.response_header;
validation.design_data = matrices.design_data(~training_row_log,:);
validation.response_data = matrices.response_data(~training_row_log,:);
validation.design_header = matrices.design_header;
validation.response_header = matrices.response_header;

%% Save
vars = fieldnames(matrices);
for s = 1 : length(vars)
    eval([vars{s} ' = matrices.' vars{s} ';']);
end
save(save_path,'training', 'validation');
end

function data = ExtractDesignParam(matrices, param_name)

rel_col = strcmp(matrices.design_header, param_name);
data = matrices.design_data(:, rel_col);

end

function matrices = InsertDesignParam(matrices, param_data, param_name)

rel_col = strcmp(matrices.design_header, param_name);

matrices.design_data(:, rel_col) = param_data;

end

function matrices = RemoveDesignParam(matrices, params_to_remove)

for param_no = 1 : length(params_to_remove)
    
    % identify column to remove
    param_name = params_to_remove{param_no};
    rel_col = find(strcmp(matrices.design_header, param_name));
    
    % eliminate column
    els = 1 : length(matrices.design_header);
    good_els = find(els ~= rel_col);
    matrices.design_header = matrices.design_header(good_els);
    matrices.design_data = matrices.design_data(:, good_els);
    
end

end