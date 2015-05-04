function [ traj, cal_data ] = load_trajectories(sets, calibrate, varargin)
%LOAD_TRAJECTORIES Loads a set of trajectories from a given folder
    global g_config;
    addpath(fullfile(fileparts(mfilename('fullpath')), '/calibration'));
          
    [dx, dy, flip_x, flip_y] = process_options(varargin, 'DeltaX', 0, 'DeltaY', 0, 'FlipX', 0, 'FlipY', 0);
    % contruct object to hold trajectories
    traj = trajectories([]);
              
    if calibrate
        cal_data = load_calibration_data(sets);
    end
        
    for i = 1:length(g_config.TRAJECTORY_DATA_DIRS)        
        if isempty(find(sets == i))
            continue;
        end
                                        
        files = dir(fullfile(g_config.TRAJECTORY_DATA_DIRS{i}, '/*.csv') );
        fprintf('Importing %d trajectories...\n', length(files));
        
        for j = 1:length(files)           
            % read trajectory from fiel
            [id, trial, pts, day] = read_trajectory(strcat(g_config.TRAJECTORY_DATA_DIRS{i}, '/', files(j).name), varargin{:});
            
            assert(~isempty(id));
            % extract the day number and check if we need to correct the
            % trial number
            temp = sscanf(files(j).name, 'day%d_%d');
            if ~isempty(temp)
                day = temp(1);
                track = temp(2);
                if trial <= (day - 1)*4
                    trial = trial + (day - 1)*4;
                end                        
            else
                temp = sscanf(files(j).name, 'track_%d');
                track = temp(1);                
                if day == 0
                    assert('could not identify day');
                end                                   
            end
            
            % correct trial number if necessary
            if day > 1
                itrial = sum(g_config.TRIALS_PER_SESSION(1:day - 1)) + 1;
                if trial < itrial                   
                    trial = trial + itrial - 1;
                end
            end                        
                
            % calibrate it
            if calibrate
                pts = calibrate_trajectory(pts, cal_data{i});
            end
            % move centre to 0, 0 please
            pts(:, 2) = pts(:, 2) + dx;
            pts(:, 3) = pts(:, 3) + dy;
            if flip_x
                pts(:, 2) = -pts(:, 2);
            end
            if flip_y
                pts(:, 3) = -pts(:, 3);
            end           
            
            % chop points at the end on top of the platform            
             npts = size(pts, 1);
             cuti = npts;
             for k = 0:(size(pts, 1) - 1)
                 if sqrt((pts(npts - k, 2) - g_config.PLATFORM_X)^2 + (pts(npts - k, 3) - g_config.PLATFORM_Y)^2) > g_config.PLATFORM_R
                     break;
                 end
                 cuti = npts - k - 1;
             end
             pts = pts(1:cuti, :);
            
            % find group for this trajectory
            if ~isempty(g_config.TRAJECTORY_GROUPS)
                temp = g_config.TRAJECTORY_GROUPS{i};
                pos = find(temp(:,1) == id); 
                group = temp(pos(1),2);
                % construct trajectory object and append it to list of trajectories
            else
                group = 1;
            end
            if size(pts, 1) > 0
                traj = traj.append(trajectory(pts, i, track, group, id, trial, -1, -1, 1));
            end
        end                                  
    end        
    
    fprintf(' done.\n');
end
