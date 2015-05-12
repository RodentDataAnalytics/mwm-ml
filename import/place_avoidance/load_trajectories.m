function traj = load_trajectories(sets, filter) 
%LOAD_TRAJECTORIES Loads a set of trajectories from a given folder
    % filter: 
    % 0 == all, 
    % 1 == room coordinate system only, 
    % 2 == arena coordinate system only
    % 3 == whatever, I don't care
    global g_config;
      
    % contruct object to hold trajectories
    traj = trajectories([]);
    track = 1;
                              
    for i = 1:length(g_config.TRAJECTORY_DATA_DIRS)        
        if isempty(find(sets == i))
            continue;
        end
                                        
        files = dir(fullfile(g_config.TRAJECTORY_DATA_DIRS{i}, '/*.dat'));
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
            
            % find group for this trajectory
            temp = g_config.TRAJECTORY_GROUPS{i};
            pos = find(temp(:,1) == id); 
            assert(~isempty(pos));
            group = temp(pos(1),2);
            
            traj = traj.append(trajectory(pts, i, track, group, id, trial, -1, -1, 1));                      
            track = track + 1;
        end                                  
    end        
    
    fprintf(' done.\n');
end