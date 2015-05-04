function lat = trajectory_latency( traj )
    lat = traj.points(end, 1) - traj.points(1, 1);
end