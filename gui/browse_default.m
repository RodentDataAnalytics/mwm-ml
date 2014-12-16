global g_segments;
global g_partitions;
global g_trajectories_latency;
cache_trajectory_segments;

off = 0;
sel = zeros(1, length(g_partitions));
for i = 1:length(g_partitions)
    off = off + g_partitions(i);
    sel(i) = off;  
end
sel = sel(g_trajectories_latency < g_config.TRIAL_TIMEOUT);

browse_trajectories(g_config.DEFAULT_TAGS_PATH, g_segments, g_config.TAGS, g_config.DEFAULT_FEATURE_SET, sel);
