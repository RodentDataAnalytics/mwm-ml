function results_export_random_segments    
%RESULTS_EXPORT_SELECTED Export some trajectories/segments of interest
    global g_segments;    
    % initialize data
    cache_trajectory_segments;                    
            
    % now export segments of interest..    
    N = 50;
    
    pos = randsample(g_segments.count, N);
    figure;
    
    for p = pos'        
       clf;
       % look for trajectories of interest            
       g_segments.items(p).plot;
       set(gcf, 'Color', 'w');
       %%%%export_fig(sprintf('/tmp/segment_s%d_d%d_t%d_o%d.eps', g_segments.items(p).set, g_segments.items(p).session, ...
        %%   g_segments.items(p).track, round(g_segments.items(p).offset)...
       %%));
       export_figure(1, gcf, './results/generated/', ...
          sprintf('segment_s%d_d%d_t%d_o%d', g_segments.items(p).set, g_segments.items(p).session,g_segments.items(p).track, round(g_segments.items(p).offset)));
    end 
   
    close;
end
