function n = trajectory_count_events( traj, state, varargin )
    [col] = process_options(varargin, 'StateColumn', 4);
        
    n = sum(traj.points(:, col) == state);    
end