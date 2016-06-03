% ANALYSEPERFORMANCES analyses the performances of each of the algorithms created in the methods
function AnalysePerformances(up)

% skip this processing if it's already been done
save_path = [up.paths.analysis_folder, up.paths.analyse_perfs, '.mat'];
if exist(save_path, 'file')
    return
end

fprintf('\n - Analysing Performances')

%% Load validation data
load_path = [up.paths.analysis_folder, up.paths.pre_processing, '.mat'];
load(load_path);
% select the validation dataset
matrices = validation;
% select the appropriate response variable
resp_var = 'icu_death'; % 'death_in_24hours'; % 
rel_col = find(strcmp(matrices.response_header, resp_var));
resp = matrices.response_data(:,rel_col);
% Select the predictor variables
rel_cols = find(~strcmp(matrices.design_header, 'iid') ...
    & ~strcmp(matrices.design_header, 'charttime')); % don't want to use ID or charttime
pred = matrices.design_data(:,rel_cols);
charttimes = matrices.design_data(:,find(strcmp(matrices.design_header, 'charttime')));
pred_names = matrices.design_header(rel_cols);

%% Load algorithms
load_path = [up.paths.analysis_folder, up.paths.reg_nom, '.mat'];
load(load_path);

%% Determine ROCs for different cut-offs
model_names = fieldnames(algorithms);
no_models = length(model_names);

% Setup dataset
pred_ds = mat2dataset(pred,'VarNames',pred_names);
resp_ds = mat2dataset(resp,'VarNames',resp_var);
[x,y,T,auroc,OPTROCPT] = deal(cell(0));

% cycle through each model
[no_false, no_all, prop_all, no_true, ppv, nne, fdr] = deal(cell(0));
for model_no = 1 : length(model_names)
    
    eval(['rel_model = algorithms.' model_names{model_no} ';']);
    
    %  trial bit
    scores(:,model_no) = feval(rel_model,pred_ds);
    labels = resp;
    posclass = 1;
    
    % Find AUROC
    [x{1,model_no},y{1,model_no},T{1,model_no},auroc{1,model_no},OPTROCPT{1,model_no}] = perfcurve(labels,scores(:,model_no),posclass);
    
    % Find sen:
    sen{1,model_no} = y{1,model_no};
    
    % Find no of false alerts:
    %no_obs = 600; prop_of_test_pop = no_obs/length(scores);
    [no_false{1,model_no}, no_all{1,model_no}, no_true{1,model_no}] = deal(nan(length(T{1,model_no}),1));
    for thresh_no = 1:length(T{1,model_no})
        thresh = T{1,model_no}(thresh_no)';
        no_true{1,model_no}(thresh_no) = sum(scores(:,model_no) >= thresh & labels);
        no_false{1,model_no}(thresh_no) = sum(scores(:,model_no) >= thresh & ~labels);
        no_all{1,model_no}(thresh_no) = sum(scores(:,model_no) >= thresh);
    end
    
    % ppv
    ppv{1,model_no} = no_true{1,model_no}./no_all{1,model_no};
    % nne
    nne{1,model_no} = 1./ppv{1,model_no};
    % fdr (1-ppv)
    fdr{1,model_no} = no_false{1,model_no}./(no_all{1,model_no});
    % prop_all
    prop_all{1,model_no} = 100*no_all{1,model_no}./length(scores(:,model_no));
    
    
    % Plot ROC
%     plot(x{:,model_no},y{:,model_no})
%     xlabel('False positive rate')
%     ylabel('True positive rate')
%     title('ROC for Classification by Logistic Regression')
end

%% Find sensitivities at fixed values of PPV and rate of alerts
ppv_min = 1/3;
rate_max = 100*1/6;
for model_no = 1 : length(model_names)
    sen_ppv(model_no) = max(sen{1,model_no}(ppv{1,model_no} > ppv_min));
    sen_rate(model_no) = max(sen{1,model_no}(prop_all{1,model_no} < rate_max));
end

%% Create results table

Algorithm = fieldnames(algorithms);
for alg_no = 1:length(Algorithm)
    eval(['temp = algorithms.' Algorithm{alg_no} ';']);
    No_Predictors(alg_no,1) = temp.NumPredictors;
end
clear alg_no
AUROC = cell2mat(auroc)';
Max_Sen_PPV = 100*sen_ppv';
Max_Sen_Alert = 100*sen_rate';
results_table = table(Algorithm, No_Predictors, AUROC, Max_Sen_PPV, Max_Sen_Alert);
save(save_path, 'results_table');
clear results_table Algorithm No_Predictors AUROC Max_Sen_PPV Max_Sen_Alert

%% Create plot of sensitivities based on clinical requirements
paper_size = [4, 7];
figure('Position', [200, 200, 100*paper_size(1), 100*paper_size(2)])
lwidth = 2; ftsize = 12;
rel_models = [4,6]; colors = [1,0.6,0.6; 0,0,1];
for model_no = 1:length(rel_models)
    subplot(2,1,1), plot(sen{1,rel_models(model_no)}, ppv{1,rel_models(model_no)}, 'LineWidth', lwidth, 'Color', colors(model_no,:)), hold on,
    subplot(2,1,2), plot(sen{1,rel_models(model_no)}, prop_all{1,rel_models(model_no)}, 'LineWidth', lwidth, 'Color', colors(model_no,:)), hold on,
end
temp = strrep(model_names(rel_models), '_', ' ');
subplot(2,1,1)
legend(temp, 'Location', 'Best')
xlabel('Sensitivity', 'FontSize', ftsize)
ylabel('PPV', 'FontSize', ftsize)
plot([0, 1], ppv_min*[1, 1], '--k')
subplot(2,1,2)
legend(temp, 'Location', 'Best')
xlabel('Sensitivity', 'FontSize', ftsize)
ylabel('Observation sets resulting in alerts [%]', 'FontSize', ftsize)
plot([0, 1], rate_max*[1, 1], '--k')
savepath = [up.paths.plots_folder, 'sens_clin_req'];
PrintFigs(gcf, paper_size, savepath, up)

%% Create plot of ROCs
paper_size = [5, 4.4];
figure('Position', [200, 200, 100*paper_size(1), 100*paper_size(2)])
lwidth = 2; ftsize = 12;
for model_no = 1 : length(model_names)
    plot(x{1,model_no}, y{1,model_no}, 'LineWidth', lwidth), hold on
end
xlim([0 1])
temp = strrep(model_names, '_', ' ');
legend(temp, 'Location', 'Best')
xlabel('1 - specificity', 'FontSize', ftsize)
ylabel('Sensitivity', 'FontSize', ftsize)
set(gca, 'XTick', 0:0.2:1, 'YTick', 0:0.2:1, 'FontSize', ftsize)
savepath = [up.paths.plots_folder, 'ROC'];
PrintFigs(gcf, paper_size, savepath, up)

%% Create plot of relevant ROCs
paper_size = [5, 4.4];
figure('Position', [200, 200, 100*paper_size(1), 100*paper_size(2)])
lwidth = 2; ftsize = 12;
rel_models = [4,6];
for model_no = 1:length(rel_models)
    plot(x{1,rel_models(model_no)}, y{1,rel_models(model_no)}, 'LineWidth', lwidth, 'Color', colors(model_no,:)), hold on
end
xlim([0 1])
temp = strrep(model_names(rel_models), '_', ' '); temp = strrep(temp, 'quad ', '');
legend(temp, 'Location', 'SouthEast')
xlabel('1 - specificity', 'FontSize', ftsize)
ylabel('Sensitivity', 'FontSize', ftsize)
set(gca, 'XTick', 0:0.2:1, 'YTick', 0:0.2:1, 'FontSize', ftsize)
savepath = [up.paths.plots_folder, 'rel_ROC'];
PrintFigs(gcf, paper_size, savepath, up)

%% Create plot of max score against % of patients who reach it for each patient category
model_no = 1;
% find out max score for each patient
id_col = find(strcmp(matrices.design_header, 'iid'));
iids = unique(matrices.design_data(:,id_col));
[max_score, id_resp] = deal(nan(length(iids),1));
for id_no = 1 : length(iids)
    id = iids(id_no);
    rel_rows = find(matrices.design_data(:,id_col) == id);
    max_score(id_no) = max(scores(rel_rows, model_no));
    id_resp(id_no) = resp(rel_rows(1));
end
% plot max score curves for each category
lwidth = 2;
max_scores = linspace(0,1,101);
surv_vals = max_score(id_resp == 0);
death_vals = max_score(id_resp == 1);
[surv_perc, death_perc] = deal(nan(length(max_scores),1));
for cand_max_score_no = 1:length(max_scores)
    cand_max_score = max_scores(cand_max_score_no);
    for group = {'surv', 'death'}
        eval(['rel_data = ' group{1,1} '_vals;']);
        perc = 100*sum(rel_data >= cand_max_score)/length(rel_data);
        eval([group{1,1} '_perc(cand_max_score_no,1) = perc;']);        
    end    
end
paper_size = [6, 3];
figure('Position', [200, 200, 100*paper_size(1), 100*paper_size(2)])
plot(max_scores, surv_perc, 'LineWIdth', lwidth, 'Color', colors(1,:)), hold on
plot(max_scores, death_perc, 'LineWIdth', lwidth, 'Color', colors(2,:))
xlim([0,1]), ylim([0, 100])
xlabel('Max output, Y, during stay', 'FontSize', ftsize)
ylabel('Percent', 'FontSize', ftsize)
set(gca, 'FontSize', ftsize)
legend({'Survivors', 'Non-Survivors'}, 'Location', 'Best')
savepath = [up.paths.plots_folder, 'Max_Score'];
PrintFigs(gcf, paper_size, savepath, up)

%% Create plot of mean score vs hours before death
model_no = 1;
% find out mean score for each patient who didn't die
id_col = find(strcmp(matrices.design_header, 'iid'));
iids = unique(matrices.design_data(:,id_col));
surv_iids = iids(~id_resp);
death_iids = iids(logical(id_resp));
mean_score_surv = nan(length(surv_iids),1);
start_time = 52;
no_time_ints = round(start_time/4);
mean_score_death = nan(length(death_iids),no_time_ints);
% select the appropriate response variable
resp_var = 'time2death';
rel_col = find(strcmp(matrices.response_header, resp_var));
resp = matrices.response_data(:,rel_col)./60;
% cycle through each patient
for id_no = 1 : length(surv_iids)
    id = iids(id_no);
    rel_rows = find(matrices.design_data(:,id_col) == id);
    mean_score_surv(id_no) = mean(scores(rel_rows, model_no));
end
dur_time_int = start_time/no_time_ints;
start_times = (start_time+dur_time_int)-(dur_time_int*[1:no_time_ints]);
end_times = start_time-(dur_time_int*[1:no_time_ints]);
for id_no = 1 : length(death_iids)
    id = death_iids(id_no);
    for time_int = 1 : no_time_ints
        st_t = start_times(time_int);
        en_t = end_times(time_int);
        rel_rows = find(matrices.design_data(:,id_col) == id);
        rel_vals = scores(rel_rows, model_no);
        rel_times = resp(rel_rows);
        time_int_els = rel_times<=st_t & rel_times > en_t;
        time_int_times = rel_times(time_int_els);
        time_int_vals = rel_vals(time_int_els);
        mean_score_death(id_no, time_int) = mean(time_int_vals);
    end
end
mean_scores_death = nanmean(mean_score_death,1);
mean_scores_surv = nanmean(mean_score_surv)*ones(no_time_ints,1);
% create plot
paper_size = [6, 3];
figure('Position', [200, 200, 100*paper_size(1), 100*paper_size(2)])
plot(end_times, mean_scores_surv, 'LineWidth', lwidth, 'Color', colors(1,:)), hold on
exp_mean_scores_death = fit(end_times(:),mean_scores_death(:),'exp1');
temp = feval(exp_mean_scores_death, end_times);
h = plot(end_times, temp, 'Color', colors(2,:));
set(h, 'LineWidth', lwidth)
xlim([0, start_time-dur_time_int])
set(gca, 'XTick', sort(end_times))
xlabel('Hours before death', 'FontSize', ftsize)
ylabel('Mean Output, Y', 'FontSize', ftsize)
set(gca, 'FontSize', ftsize)
set(gca,'XDir','reverse');
legend({'Survivors', 'Non-Survivors'}, 'Location', 'NorthWest')
savepath = [up.paths.plots_folder, '48_hours'];
PrintFigs(gcf, paper_size, savepath, up)

%% Create plots of trajectories
PatientPlotter(4, matrices, algorithms, pred_ds, resp_ds, charttimes, up)   % clear (died)
PatientPlotter(9, matrices, algorithms, pred_ds, resp_ds, charttimes, up)   % clear (survived)
PatientPlotter(13, matrices, algorithms, pred_ds, resp_ds, charttimes, up)  % unclear (died)
PatientPlotter(20, matrices, algorithms, pred_ds, resp_ds, charttimes, up)  % unclear (survived)

%% Save
%save(save_path,'perfs');
end

function PatientPlotter(pt, matrices, algorithms, pred_ds, resp_ds, charttimes, up)

%% Plot sample patient
close all
ftsize = 12;
lwidth = 2;
figure('Position', [200, 200, 600, 300])

% select relevant data points for this patient
pt_ids = unique(matrices.design_data(:,1));
pt_id = pt_ids(pt);
rel_rows = find(matrices.design_data(:,1) == pt_id);

% create time vector
days = charttimes(rel_rows)./(60*24);

paper_size = [6, 3];
figure('Position', [200, 200, 100*paper_size(1), 100*paper_size(2)])


model_names = fieldnames(algorithms);
for model_no = 6 %: length(model_names)
    
    eval(['rel_model = algorithms.' model_names{model_no} ';']);
    
    % evaluate model at all rows
    newf = feval(rel_model,pred_ds(rel_rows,:));
    [ypred, yci] = predict(rel_model,pred_ds(rel_rows,:));
    temp(:,1) = yci(:,1); temp(:,2) = yci(:,2)-yci(:,1);
    h = area(days, temp); hold on
    h(1).FaceColor = [1 1 1]; h(1).LineStyle = 'none';
    h(2).FaceColor = 0.6*[1 1 1]; h(2).LineStyle = 'none';
    plot(days, ypred, 'LineWidth', lwidth)
    ylim([0 1])
end
ylim([0, 1])
xlim([0 max(days)])
set(gca, 'YTick', 0:0.2:1, 'FontSize', ftsize)
xlabel('Days since ICU admission', 'FontSize', ftsize)
ylabel('Y', 'FontSize', ftsize)
%legend(strrep(model_names, '_', ' '))
%plot(newf, 'r'), hold on, plot(newc(:,1), 'b'), plot(newc(:,2), 'b'), ylim([0 1])

resp = matrices.response_data(rel_rows(1),1)

savepath = [up.paths.plots_folder, 'pt', num2str(pt)];
PrintFigs(gcf, paper_size, savepath, up)

end

function PrintFigs(h, paper_size, savepath, up)
set(h,'PaperUnits','inches');
set(h,'PaperSize', [paper_size(1), paper_size(2)]);
set(h,'PaperPosition',[0 0 paper_size(1) paper_size(2)]);
print(h,'-dpdf',savepath)
print(h,'-dpng',savepath)

if up.eps_figs
    export_fig(savepath, '-eps')
end
close all
end
