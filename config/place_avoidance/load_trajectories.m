function traj = load_trajectories(path, traj_group, varargin) 
%LOAD_TRAJECTORIES Loads a set of trajectories from a given folder
    % filter: 
    % 0 == all, 
    % 1 == room coordinate system only, 
    % 2 == arena coordinate system only
    % 3 == whatever, I don't care      
    [filt_pat, id_day_mask, rev_day] = process_options(varargin, 'FilterPattern', '*Room*.dat', ...
                                                                 'IdDayMask', 'r%dd%d', ...
                                                                 'ReverseDayId', 0);
        
    % contruct object to hold trajectories
    traj = trajectories([]);
    persistent track;
    if isempty(track)        
        track = 1;
    end
                              
    if path(end) ~= '/'
        path = [path '/'];
    end
    files = dir(fullfile(path, filt_pat));
    if length(files) == 0
        return;
    end
    
    fprintf('Importing %d trajectories...\n', length(files));

    for j = 1:length(files)  
        % read trajectory from fiel
        pts = read_trajectory(strcat(path, '/', files(j).name));
        if size(pts, 1) == 0
            continue;
        end

        temp = sscanf(files(j).name, id_day_mask);
        if rev_day
            id = temp(2);
            trial = temp(1);
        else
            id = temp(1);
            trial = temp(2);
        end
        
        % find group for this trajectory
        if length(traj_group) == 1
            % fixed group
            group = traj_group;
        else
            % look up group from the list of rat ids            
            pos = find(traj_group(:,1) == id); 
            assert(~isempty(pos));
            group = traj_group(pos(1),2);
        end
        
        traj = traj.append(trajectory(pts, 1, track, group, id, trial, -1, -1, 1));  
        track = track + 1;
    end                                              
    
    fprintf(' done.\n');
end