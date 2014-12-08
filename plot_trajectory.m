function plot_trajectory( grp, id, trial )
%PLOT_TRAJECTORY Plots one trajectory by its identification
    global g_trajectories;
    cache_trajectory_data;
    for i = 1:length(g_trajectories)                
        ident = g_trajectories{i}.identification();
        if isequal(ident(1:3), [grp, id, trial])
            g_trajectories{i}.plot
            return
        end
    end
end