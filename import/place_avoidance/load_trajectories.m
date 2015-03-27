function traj = load_trajectories(sets, filter, t1) 
%LOAD_TRAJECTORIES Loads a set of trajectories from a given folder
    % filter: 
    % 0 == all, 
    % 1 == room coordinate system only, 
    % 2 == arena coordinate system only
    % 3 == whatever, I don't care
    global g_config;
      
    % contruct object to hold trajectories
    traj = trajectories([]);
                      
    for i = 1:length(g_config.TRAJECTORY_DATA_DIRS)        
        if isempty(find(sets == i))
            continue;
        end
                                        
        files = dir(fullfile(g_config.TRAJECTORY_DATA_DIRS{i}, '/*.dat') );
        fprintf('Importing %d trajectories...\n', length(files));
        
        for j = 1:length(files)  
            switch filter
                case 1
                    if isempty(strfind(files(j).name, 'Room'))
                       continue;
                    end
                case 2
                    if isempty(strfind(files(j).name, 'Arena'))
                       continue;
                    end
            end
            % read trajectory from fiel
            [id, trial, pts] = read_trajectory(strcat(g_config.TRAJECTORY_DATA_DIRS{i}, '/', files(j).name));
            
            % move centre to 0, 0 please
           % pts(:, 2) = pts(:, 2) - g_config.CENTRE_X;
          %  pts(:, 3) = pts(:, 3) - g_config.CENTRE_Y;
            
            if t1
                % get points until first entrance to the dark side
                cuti = find(pts(:, 4) > 0);
                if ~isempty(cuti)                
                    pts = pts(1:cuti(1), :);
                end
            end
            
            % find group for this trajectory
            temp = g_config.TRAJECTORY_GROUPS{i};
            pos = find(temp(:,1) == id); 
            group = temp(pos(1),2);
            % construct trajectory object and append it to list of trajectories
            traj = traj.append(trajectory(pts, i, id, group, id, trial, -1, -1, 1));
        end                                  
    end        
    
    fprintf(' done.\n');
end
