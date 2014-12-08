global g_partitions;
global g_trajectories;
cache_trajectory_segments;

browse_trajectories(constants.SHORT_TRAJECTORIES_TAGS_PATH, trajectories(g_trajectories.items(g_partitions == 0)), constants.TAGS, constants.DEFAULT_FEATURE_SET, sel);