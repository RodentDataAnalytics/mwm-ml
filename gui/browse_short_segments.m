global g_partitions;
global g_trajectories;
cache_trajectory_segments;

browse_trajectories(g_config.SHORT_TRAJECTORIES_TAGS_PATH, trajectories(g_trajectories.items(g_partitions == 0)), g_config.TAGS, g_config.DEFAULT_FEATURE_SET, sel);
