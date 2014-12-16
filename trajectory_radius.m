function [ r, var ] = trajectory_radius( traj, cx, cy )
%SEGMENT_RADIUS Computes the median and iqr of the radius of a
%trajectory/segment
%   traj should be a vector of time, X and Y coordinates
    %center = trajectory_centre(traj);
    d = sqrt( power(traj(:, 2) - cx, 2) + power(traj(:, 3) - cy, 2) ) / g_config.ARENA_R;   
    %d = sqrt( power(traj(:, 2) - center(1), 2) + power(traj(:, 3) - center(2), 2) );   
    r = median(d);
    var = iqr(d);
end
