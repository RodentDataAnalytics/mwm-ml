function cache_trajectories
% CACHE_TRAJECTORIES 
%   Loads the trajectories if not already loaded
    global g_config;
    global g_trajectories;
    % also load a bunch of other useful properties about the trajectories
    global g_trajectories_group;    
    global g_trajectories_session;    
    global g_trajectories_trial;
    global g_trajectories_length;
    global g_trajectories_speed;    
        
    if isempty(g_trajectories)        
        % see if we have them cached
        cache_dir = fullfile(fileparts(mfilename('fullpath')),'/cache');
        if ~exist(cache_dir, 'dir')
            mkdir(cache_dir);
        end
        
        id = g_config.hash();
        fn = fullfile(cache_dir, ['trajetories_', num2str(id), '.mat']);
        if exist(fn, 'file')            
            load(fn);
        else                    
            g_trajectories = g_config.load_data();
            save(fn, 'g_trajectories');
        end
        
        % select only groups inside the range set in the config
        g_trajectories_group = arrayfun( @(t) t.group, g_trajectories.items);                         
        g_trajectories = trajectories(g_trajectories.items(g_trajectories_group >= 1 & g_trajectories_group <= g_config.GROUPS));    
                        
        g_trajectories_group = arrayfun( @(t) t.group, g_trajectories.items);          
        g_trajectories_session = arrayfun( @(t) t.session, g_trajectories.items);
        g_trajectories_trial = arrayfun( @(t) t.trial, g_trajectories.items);
        g_trajectories_length = arrayfun( @(t) t.compute_feature(g_config.FEATURE_LENGTH), g_trajectories.items);
        g_trajectories_speed = arrayfun( @(t) t.compute_feature(g_config.FEATURE_AVERAGE_SPEED), g_trajectories.items);                                 
    end    
end
