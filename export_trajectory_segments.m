function export_trajectory_segments( grp, id, trial, lseg, ovlp, dest )
%EXPORT_TRAJECTORY_SEGMENTS Well, this exports trajectory segments
    global g_trajectories;
    cache_trajectory_data;
    idx = -1;
    for i = 1:length(g_trajectories)                
        ident = g_trajectories{i}.identification();
        if isequal(ident(1:3), [grp, id, trial])
            idx = i;
            break            
        end
    end
    if idx == -1
        error('Na ja');
    end
    
    % the fun part
    seg = g_trajectories{idx}.divide_into_segments(lseg, ovlp);    
    for i = 1:length(seg)                
        hfig = figure;        
        seg{i}.plot;        
        save_figure(hfig, sprintf('%s/traj_g%did%dt%dseg%d.eps', dest, grp, id, trial, i));        
    end
end