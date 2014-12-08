function plot_trajectory_segment( grp, id, trial, li, len )
%PLOT_TRAJECTORY Plots one trajectory by its identification
    global g_trajectories;
    cache_trajectory_data;
    for i = 1:length(g_trajectories)                
        ident = g_trajectories{i}.identification();
        if isequal(ident(1:3), [grp, id, trial])
            seg = g_trajectories{i}.sub_segment(li, len);
            seg.plot
            return
        end
    end
end