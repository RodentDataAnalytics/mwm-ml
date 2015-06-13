function vals = trajectory_events( traj, state, varargin )    
    [repr, col] = process_options(varargin, 'DataRepresentation', 1, 'StateColumn', 4);
    pts = traj.data_representation(repr);
    
    vals = zeros(size(pts, 1), 4);
    vals(:, 1:3) = pts(:, 1:3);
    for i = 1:size(pts, 1)                
        if pts(i, col) == state
            vals(i, 4) = 1;
        end        
    end     
end