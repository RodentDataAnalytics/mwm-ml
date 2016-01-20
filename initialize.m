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
addpath(fullfile(fileparts(mfilename('fullpath')),'/config/morris_water_maze'));
% addpath(fullfile(fileparts(mfilename('fullpath')),'/config/place_avoidance'));

global g_config;
%% Change for desired configuration
g_config = config_mwm; 

fprintf('Configuration selected: %s\n', g_config.DESCRIPTION);
addpath(fullfile(fileparts(mfilename('fullpath')), g_config.RESULTS_DIR)); 

% add also some other folders to the path
addpath(fullfile(fileparts(mfilename('fullpath')), '/extern'));     
addpath(fullfile(fileparts(mfilename('fullpath')), '/results'));
addpath(fullfile(fileparts(mfilename('fullpath')), '/gui'));
addpath(fullfile(fileparts(mfilename('fullpath')), '/utility'));

% for the GUILayout package we have 2 different versions for (Matlab 2014a
% and below and newer versions)

v = version();
if str2num(v(1:3)) <= 8.3 % <= Matlab 2014a
    addpath(fullfile(fileparts(mfilename('fullpath')), '/extern/export_fig/v1'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '/extern/GUILayout/v1'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '/extern/GUILayout/v1/Patch'));
else
    addpath(fullfile(fileparts(mfilename('fullpath')), '/extern/export_fig/v2'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '/extern/GUILayout/v2'));
end