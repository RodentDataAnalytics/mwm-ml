function plot_trajectory_segments( grp, id, trial, lseg, ovlp )
%PLOT_TRAJECTORY Plots all segments from one trajectory
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
    % see how many subplots we need
    n = -1;
    for i = 1:8     
        if length(seg) <= i^2
            n = i;
            break
        end        
    end
    if n == -1
        error('Too many segments to be plotted')
    end
                
    str = sprintf('Group %d, rat %d, trial %d', grp, id, trial);
    hfig = figure('name', str, 'NumberTitle','off');
    set(hfig, 'Position', [50 50 1000 800]);
    for i = 1:length(seg)                
        subaxis(n, n, i, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0.05);        
        len = seg{i}.compute_feature(features.LENGTH);
        str = sprintf('#%d (%.1f-%.1f)', i, seg{i}.offset,  seg{i}.offset + len(1));
        title(str, 'FontSize', 8);
        seg{i}.plot;               
    end
end