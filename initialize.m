%% Initialize the WEKA library (java stuff)
%% CALL THIS JUST ONCE PER SESSION
% somewhere in the loading procedure the global variables are cleared and
% this messes up everything so don't call it more than once
addpath(fullfile(fileparts(mfilename('fullpath')),'/extern/weka'));
weka_init;
disp('Weka library now initialized. Cheers.');
% add also some other folders to the path
addpath(fullfile(fileparts(mfilename('fullpath')),'/results'));
addpath(fullfile(fileparts(mfilename('fullpath')),'/gui'));
addpath(fullfile(fileparts(mfilename('fullpath')),'/utility'));