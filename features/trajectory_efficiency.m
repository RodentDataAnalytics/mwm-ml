function eff = trajectory_efficiency( traj )
    global g_config;
    min_path = norm( traj.points(1, 2) - g_config.PLATFORM_X, traj.points(1,3) - g_config.PLATFORM_Y);
    len = traj.compute_feature(g_config.FEATURE_LENGTH);
    if len ~= 0
        eff = min_path / len;
    else
        eff = 0.;
    end        
end