function [ cal_data ] = load_calibration_data(sets)
%LOAD_CALIBRATION_DATA Summary of this function goes here
%   Detailed explanation goes here
    addpath(fullfile(fileparts(mfilename('fullpath')), '/calibration'));
            
    cache_fn = fullfile(constants.OUTPUT_DIR, ['calibration_data_' arrayfun( @(x) num2str(x), sets) '.mat']);
    if exist(cache_fn ,'file')
        load(cache_fn);
    else                                              
        cal_data = {[], [], []};

        for i = 1:length(constants.TRAJECTORY_SNAPSHOTS_DIRS)        
            if isempty(find(sets == i))
                continue;
            end

            % for the 1st and 2nd set the calibration is the same, take
            % this into account to improve the calibration
            if i == 3
                target = 3;
            else
                target = 1;
            end

            % load calibration data            
            files = dir(constants.TRAJECTORY_SNAPSHOTS_DIRS{i});                
            for j = 3:length(files)
                if files(j).isdir
                   % get day and track number from directory
                   temp = sscanf(files(j).name, 'day%d_track%d');
                   day = temp(1);
                   track = temp(2);
                   % find corresponding track file
                   fn = sprintf('%sday%d_%.4d_00.csv', constants.TRAJECTORY_DATA_DIRS{i}, day, track);
                   if ~exist(fn, 'file')
                       error('Non-existent file');
                   end
                   cal_data{target} = [cal_data{target}; trajectory_calibration_data(fn, strcat(constants.TRAJECTORY_SNAPSHOTS_DIRS{i}, files(j).name), 100, 100, 100)];                                      
                end
            end    

            % as mentioned above calibration for set 1 and 2 is the same
            cal_data{2} = cal_data{1};
        end
        save(cache_fn, 'cal_data');                
    end
end

