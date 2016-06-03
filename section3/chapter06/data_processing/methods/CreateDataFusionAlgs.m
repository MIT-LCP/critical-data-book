% CREATEDATAFUSIONALGS performs the calculations for multinomial regression for nominal responses
function CreateDataFusionAlgs(up)

% skip this processing if it's already been done
save_path = [up.paths.analysis_folder, up.paths.reg_nom, '.mat'];
if exist(save_path, 'file')
    %return
end

%% Load design and response matrices
load_path = [up.paths.analysis_folder, up.paths.pre_processing, '.mat'];
load(load_path);
% select the training dataset
matrices = training;

%% Define the response variable
% death within 24 hours
resp_var = 'icu_death'; % 'death_in_24hours'; % 
rel_col = find(strcmp(matrices.response_header, resp_var));
resp = matrices.response_data(:,rel_col);

%% Define the predictor variables
% don't want to use ID or charttime:
rel_cols = find(~strcmp(matrices.design_header, 'iid') ...
    & ~strcmp(matrices.design_header, 'charttime'));
pred = matrices.design_data(:,rel_cols);
pred_names = matrices.design_header(rel_cols);

%% Model 1: linear logistic regression (only vital signs)
rel_preds = strcmp(pred_names, 'hr') | ...
    strcmp(pred_names, 'sysibp') | ...
    strcmp(pred_names, 'gcs') | ...
    strcmp(pred_names, 'rr') | ...
    strcmp(pred_names, 'temperature') | ...
    strcmp(pred_names, 'spo2');

tbl_names = pred_names(rel_preds); tbl_names{end+1} = resp_var;
ds = mat2dataset([pred(:,rel_preds),resp],'VarNames',tbl_names);
name = 'lin_vital_signs';
mdl = fitglm(ds,'linear','Distribution','binomial','Link','logit');
eval(['algorithms.' name ' = mdl;']);

%% Model 2: linear logistic regression (all params)
tbl_names = pred_names; tbl_names{end+1} = resp_var;
ds = mat2dataset([pred,resp],'VarNames',tbl_names);
name = 'lin_all_params';
mdl = fitglm(ds,'linear','Distribution','binomial','Link','logit');
eval(['algorithms.' name ' = mdl;']);

%% Model 3: Linear logistic regression (all params, stepwise)
tbl_names = pred_names; tbl_names{end+1} = resp_var;
ds = mat2dataset([pred,resp],'VarNames',tbl_names);
name = 'lin_stepwise_all_params';
mdl = stepwiseglm(ds,[resp_var, ' ~ sysibp + hr + gcs + rr + temperature + spo2'],'upper','linear','Distribution','binomial','Link','logit');
eval(['algorithms.' name ' = mdl;']);

%% Model 4: PureQuadratic logistic regression (only vital signs)
rel_preds = strcmp(pred_names, 'hr') | ...
    strcmp(pred_names, 'sysibp') | ...
    strcmp(pred_names, 'gcs') | ...
    strcmp(pred_names, 'rr') | ...
    strcmp(pred_names, 'temperature') | ...
    strcmp(pred_names, 'spo2');

tbl_names = pred_names(rel_preds); tbl_names{end+1} = resp_var;
ds = mat2dataset([pred(:,rel_preds),resp],'VarNames',tbl_names);
name = 'quad_vital_signs';
mdl = fitglm(ds,'purequadratic','Distribution','binomial','Link','logit');
eval(['algorithms.' name ' = mdl;']);

%% Model 5: PureQuadratic logistic regression (all params)
tbl_names = pred_names; tbl_names{end+1} = resp_var;
ds = mat2dataset([pred,resp],'VarNames',tbl_names);
name = 'quad_all_params';
mdl = fitglm(ds,'purequadratic','Distribution','binomial','Link','logit');
eval(['algorithms.' name ' = mdl;']);

%% Model 6: PureQuadratic logistic regression (all params, stepwise)
tbl_names = pred_names; tbl_names{end+1} = resp_var;
ds = mat2dataset([pred,resp],'VarNames',tbl_names);
name = 'quad_stepwise_all_params';
mdl = stepwiseglm(ds,[resp_var, ' ~ gcs + hr + rr + spo2 + sysibp + temperature + gcs^2 + hr^2 + spo2^2 + sysibp^2 + temperature^2'],'upper','purequadratic','Distribution','binomial','Link','logit');
eval(['algorithms.' name ' = mdl;']);

%% Make comparison figures for single variables
sensitivity_plotter('diaibp', algorithms, pred, pred_names, resp, up) % linear - could be helpful with ICU death
sensitivity_plotter('sodium', algorithms, pred, pred_names, resp, up) % quad - could be helpful with ICU death

%% Save
save(save_path,'algorithms');
end

function sensitivity_plotter(var_name, algorithms, pred, pred_names, resp, up)

close all

rel_col = find(strcmp(pred_names, var_name));
rel_pred = pred(:,rel_col);
f_pred = rel_pred(~resp);
t_pred = rel_pred(logical(resp));

%% setup plots
lwidth = 2;
ftsize = 12;

%% Plot PDFs

[f_f,f_xi] = ksdensity(f_pred);
[t_f,t_xi] = ksdensity(t_pred);

paper_size = [4, 6];
figure('Position', [200, 200, 100*paper_size(1), 100*paper_size(2)])
subplot(2,1,2)
h1 = plot(f_xi, f_f, 'Color', [1, 0.6, 0.6], 'LineWIdth', lwidth); hold on,
h2 = plot(t_xi,t_f, 'Color', [0, 0, 1], 'LineWIdth', lwidth);
[~, max_el] = max(f_f);
% false
bad_els = find(f_f<(0.01*max(f_f)));
xlim_min(1) = max(f_xi(bad_els(bad_els<max_el)));
xlim_max(1) = min(f_xi(bad_els(bad_els>max_el)));
% true
bad_els = find(t_f<(0.01*max(t_f)));
xlim_min(2) = max(t_xi(bad_els(bad_els<max_el)));
xlim_max(2) = min(t_xi(bad_els(bad_els>max_el)));
xlims = [min(xlim_min), max(xlim_max)];
xlim(xlims)
xtext = var_name;
if strcmp(var_name, 'sodium')
    xtext = 'Sodium [mEq/liter]';
    loc = 'NorthEast';
elseif strcmp(var_name, 'diaibp')
    xtext = 'Diastolic Blood Pressure [mmHg]';
    loc = 'NorthWest';
end
xlabel(xtext, 'FontSize', ftsize)
ylabel('Kernel Density Estimate', 'FontSize', ftsize)
set(gca, 'FontSize', ftsize)
legend({'Survived ICU', 'Died'}, 'Location', 'Best')

%% Plot estimated probabilities
subplot(2,1,1)
model_names = fieldnames(algorithms);
for model_no = [3,6] %1 : length(model_names)
    
    eval(['mdl = algorithms.' model_names{model_no} ';']);
    mdl_names = mdl.CoefficientNames;
    rel_mdl_els = false(length(mdl_names),1);
    x = strfind(mdl.CoefficientNames, var_name);
    els = find(~cellfun(@isempty,x));
    
    beta = mdl.Coefficients.Estimate(els);
    
    var = linspace(xlims(1), xlims(2));
    if length(beta) > 1
        eqn = beta(1)*var + beta(2)*(var.^2);
    else
        eqn = beta(1)*var;
    end
    % normalise
    eqn = eqn-min(eqn);    % make minimum zero
    if model_no == 3
        rel_c = [1, 0.6, 0.6];
    else
        rel_c = [0,0,1];
    end
    plot(var, eqn, 'LineWidth', lwidth, 'Color', rel_c), hold on
end
% plot ref values
% if strcmp(var_name, 'rr')
%     ref_vals = [12 20];
% elseif strcmp(var_name, 'sodium')
%     ref_vals = [136 145];
% end
% if exist('ref_vals', 'var')
%     plot(ref_vals, 1.5*[1,1], '--ko', 'LineWidth', lwidth, ...
%         'MarkerEdgeColor','k',...
%         'MarkerFaceColor',[.49 1 .63],...
%         'MarkerSize',10)
% end
% plot specs
xlim([min(xlim_min), max(xlim_max)])
legend({'Linear', 'Quadratic'}, 'Location', loc)
ylabel('Contribution to Y', 'FontSize', ftsize)
set(gca, 'FontSize', ftsize)
savepath = [up.paths.plots_folder, 'sen_', var_name];
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
