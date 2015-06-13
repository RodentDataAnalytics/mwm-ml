function n = trajectory_entrances_shock( traj, varargin )
    [col] = process_options(varargin, 'StateColumn', 4);
            
    n = sum(diff(traj.points(:, col) > 0 & traj.points(:, col) < 5) == 1);
end