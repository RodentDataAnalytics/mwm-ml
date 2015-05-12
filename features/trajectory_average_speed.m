function [ spd ] = trajectory_average_speed( traj, varargin )                                                  
    spd = trajectory_length(traj, varargin{:}) / trajectory_latency(traj);
end