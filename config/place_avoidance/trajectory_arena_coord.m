function pts = trajectory_arena_coord( traj )
    global g_config;
    pts = [];
    for i = 2:size(traj.points, 1)                
        dt = -(traj.points(1, 1) - traj.points(i - 1, 1))/1000;
        x = traj.points(i, 2) - g_config.CENTRE_X;
        y = traj.points(i, 3) - g_config.CENTRE_X;
        
        xx = x*cos(-dt*g_config.rotation_frequency) - y*sin(-dt*g_config.rotation_frequency);
        yy = x*sin(-dt*g_config.rotation_frequency) + y*cos(-dt*g_config.rotation_frequency);
        
        pts = [pts; traj.points(i, 1), xx + g_config.CENTRE_X, yy + g_config.CENTRE_Y];
    end
end