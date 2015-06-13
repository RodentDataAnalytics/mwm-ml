function ret = trajectory_event_radius( traj, state, varargin )    
    global g_config;
    [repr, col] = process_options(varargin, 'DataRepresentation', 1, ...
                                            'StateColumn', 4);                                                    
                                                
    pts = traj.data_representation(repr);    
    r = [];
    
    for i = 1:size(pts, 1)                
        if pts(i, col) == state
            r = [r, sqrt( (pts(i, 2) - g_config.CENTRE_X)^2 + (pts(i, 3) - g_config.CENTRE_Y)^2 ) / g_config.ARENA_R];            
        end        
    end   
    
    ret = mean(r);
end