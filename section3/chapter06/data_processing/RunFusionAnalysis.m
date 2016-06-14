function RunFusionAnalysis

%% Set up universal parameters

% edit these to ensure that this will run on your computer
up = SetupUniversalParams;

%% Pre-processing

% Load data from SQL CSV exports
LoadData(up)

% Perform pre-processing
PreProcessing(up)

%% Methods

% Perform multinomial regression for nominal responses
CreateDataFusionAlgs(up)

%% Analysis

% Determine the performance of each algorithm
AnalysePerformances(up)

end

function up = SetupUniversalParams

fprintf('\n - Setting up Universal Params')

% Setup paths
up.paths.root_folder = [fileparts(mfilename('fullpath')), '\'];
up.paths.data_folder = 'C:\Documents\Data\FUSION\';
up.paths.analysis_folder = [up.paths.data_folder, 'analysis\'];
up.paths.plots_folder = [up.paths.data_folder, 'plots\'];
up.paths.data_matrices = 'data_matrices';
up.paths.pre_processing = 'pre_processing';
up.paths.reg_nom = 'reg_nom';
up.paths.analyse_perfs = 'analyse_perf';

% if you want .eps illustrations, then do as follows:
up.eps_figs = 0;
if up.eps_figs
    % you need to download 'export_fig' from:
    % http://uk.mathworks.com/matlabcentral/fileexchange/23629-export-fig
    export_fig_dir_path = 'C:\Users\pc13\Documents\GitHub\phd\Tools\Other Scripts\export_fig\';
    addpath(export_fig_dir_path)
end

% set current directory to that of this file
cd(up.paths.root_folder)

% add scripts to path
addpath(genpath(up.paths.root_folder))

% make folders
if ~exist(up.paths.analysis_folder, 'dir')
    mkdir(up.paths.analysis_folder)
end
if ~exist(up.paths.plots_folder, 'dir')
    mkdir(up.paths.plots_folder)
end

end
