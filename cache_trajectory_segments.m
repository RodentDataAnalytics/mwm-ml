function cache_trajectory_segments
% CACHE_TRAJECTORY_SEGMENTS
%   Loads trajectories if not already loaded and segment them using the
%   default segmentation parameters as defined in the global constants
    global g_config;
    % load trajectories
    global g_trajectories;        
        
    global g_segments;
    global g_partitions;
    global g_long_trajectories_idx;
    % compute also some other useful attributes
    global g_segments_start_time;        
    global g_segments_end_time;   
    global g_long_trajectories_map;
    
    cache_trajectories;
    
    if isempty(g_segments)
        % first settings (not-being the "Full set"
        param = g_config.TAGS_CONFIG{2};
        
        [g_segments, g_partitions] = g_trajectories.partition(param{3}, param{4}, param{5:end});
    
        g_long_trajectories_idx = find(g_partitions ~= 0);
        g_long_trajectories_map = 1:length(g_partitions);
        g_long_trajectories_map(g_partitions == 0) = 0;
        g_long_trajectories_map(g_partitions ~= 0) = 1:length(g_long_trajectories_idx);
        g_segments_start_time = arrayfun( @(t) t.start_time, g_segments.items );
        g_segments_end_time= arrayfun( @(t) t.end_time, g_segments.items );    
    end
end
