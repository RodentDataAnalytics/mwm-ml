%% INITIALIZATION FILE %%
%%---------------------%%

% CALL THIS JUST ONCE PER SESSION
% somewhere in the loading procedure the global variables are cleared and
% this messes up everything so don't call it more than once 

main_path = cd(fileparts(mfilename('fullpath')));
addpath(genpath(main_path));

%% Initialize the WEKA library
weka_init;
disp('Weka library now initialized. Cheers.');

%% Initialize the configuration file
global g_config;

%% Select desired configuration
g_config = config_mwm;  %Morris water maze
fprintf('Configuration selected: %s\n', g_config.DESCRIPTION);

%% MATLAB version check
% Two gui versions are available, one for MATLAB 2014a and older and one
% for MATLAB 2014b and newer
v = version();
if str2num(v(1:3)) <= 8.3 % <= Matlab 2014a
    rmpath(genpath(fullfile(fileparts(mfilename('fullpath')), '/extern/GUILayout/v2')));
else
    rmpath(genpath(fullfile(fileparts(mfilename('fullpath')), '/extern/GUILayout/v1')));
end
