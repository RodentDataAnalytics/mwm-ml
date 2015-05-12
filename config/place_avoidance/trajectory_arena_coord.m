function pts = trajectory_arena_coord( traj, varargin )
    global g_config;
    
    [tol] = process_options(varargin, 'SimplificationTolerance', 0);
    
    pts = [];
    for i = 2:size(traj.points, 1)                
        dt = -(traj.points(1, 1) - traj.points(i - 1, 1));
        x = traj.points(i, 2) - g_config.CENTRE_X;
        y = traj.points(i, 3) - g_config.CENTRE_X;
        
        xx = x*cos(-dt*g_config.ROTATION_FREQUENCY) - y*sin(-dt*g_config.ROTATION_FREQUENCY);
        yy = x*sin(-dt*g_config.ROTATION_FREQUENCY) + y*cos(-dt*g_config.ROTATION_FREQUENCY);
        
        pts = [pts; traj.points(i, 1), xx + g_config.CENTRE_X, yy + g_config.CENTRE_Y];
    end
 
    pts = trajectory_simplify_impl(pts, tol);    
end