%% Initialize the WEKA library (java stuff)
%% CALL THIS JUST ONCE PER SESSION
% somewhere in the loading procedure the global variables are cleared and
% this messes up everything so don't call it more than once
addpath(fullfile(fileparts(mfilename('fullpath')),'/extern/weka'));
weka_init;
disp('Weka library now initialized. Cheers.');
% need to add this first
addpath(fullfile(fileparts(mfilename('fullpath')),'/features'));
addpath(fullfile(fileparts(mfilename('fullpath')),'/data_representation'));

% select configuration
addpath(fullfile(fileparts(mfilename('fullpath')),'/config'));
global g_config;
%% Change for desired configuration
% g_config = config_place_avoidance(config_place_avoidance.SECTION_AVOID); 
% g_config = config_mwm; 
g_config = config_mwm_nencki;
% g_config = config_mwm_nencki_short;

fprintf('Configuration selected: %s\n', g_config.DESCRIPTION);
addpath(fullfile(fileparts(mfilename('fullpath')), g_config.RESULTS_DIR)); 

% add also some other folders to the path
addpath(fullfile(fileparts(mfilename('fullpath')), '/extern')); 
addpath(fullfile(fileparts(mfilename('fullpath')), '/results'));
addpath(fullfile(fileparts(mfilename('fullpath')), '/gui'));
addpath(fullfile(fileparts(mfilename('fullpath')), '/utility'));