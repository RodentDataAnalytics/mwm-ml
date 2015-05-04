function val = trajectory_centre_displacement( traj, repr )
    global g_config;
    if nargin > 1
        [x, y] = trajectory_boundaries(traj, repr);
    else
        [x, y] = trajectory_boundaries(traj);
    end
        
    val = sqrt( (x - g_config.CENTRE_X)^2 + (y - g_config.CENTRE_Y)^2) / g_config.ARENA_R;
end