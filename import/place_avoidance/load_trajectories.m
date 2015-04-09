function traj = load_trajectories(sets, filter, section) 
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
           % pts(:, 3) = pts(:, 3) - g_config.CENTRE_Y;
            % find group for this trajectory
            temp = g_config.TRAJECTORY_GROUPS{i};
            pos = find(temp(:,1) == id); 
            assert(~isempty(pos));
            group = temp(pos(1),2);
            
            switch section
                case config_place_avoidance.SECTION_T1
                    % get points until first entrance to the dark side
                    cuti = find(pts(:, 4) > 0);
                    if ~isempty(cuti)                
                        pts = pts(1:cuti(1), :);
                    end
                    traj = traj.append(trajectory(pts, i, track, group, id, trial, -1, -1, 1));
                    track = track + 1;
                    
                case config_place_avoidance.SECTION_FULL
                    traj = traj.append(trajectory(pts, i, track, group, id, trial, -1, -1, 1));
                    track = track + 1;
                    
                case {config_place_avoidance.SECTION_TMAX, config_place_avoidance.SECTION_AVOID}
                    % partition the trajectories into multiple things
                    beg = 1;
                    s = -1;          
                    cum_dist = [0];
                    sub_seg = [];
                    for k = 1:size(pts, 1)
                        if k > 1
                            cum_dist(k) = cum_dist(k - 1) + sqrt(sum( (pts(k, 2:3) - pts(k - 1, 2:3)).^2 ));
                        end
                        if s ~= pts(k, 4)
                            if s == 0 && k > beg
                                % add sub-trajectory
                                sub_seg = [sub_seg; beg, k - 1];
                            end
                            s = pts(k, 4);
                            beg = k;
                        end                         
                    end
                    
                    if section == config_place_avoidance.SECTION_TMAX
                        % select only the longest sub segment
                        imax = 0;
                        t = 0;
                        for k = 1:size(sub_seg, 1)
                            tseg = pts(sub_seg(k, 2), 1) - pts(sub_seg(k, 1), 1);
                            if tseg > t
                                imax = k;
                                t = tseg;
                            end
                        end
                        traj = traj.append( ...
                            trajectory(pts(sub_seg(imax, 1):sub_seg(imax, 2), :), i, track, group, id, trial, -1, off, beg) ...
                        );
                        track = track + 1;
                    else
                        % add all sub-segments
                        for k = 1:size(sub_seg, 1)                        
                            traj = traj.append( ...
                                trajectory(pts(sub_seg(k, 1):sub_seg(k, 2), :), i, track, group, id, trial, -1, cum_dist(sub_seg(k, 1)), sub_seg(k, 1)) ...
                            );     
                            track = track + 1;
                        end
                    end
            end                      
        end                                  
    end        
    
    fprintf(' done.\n');
end
