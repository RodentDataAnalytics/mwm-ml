function p = trajectory_first_event( traj, state, varargin )
    [col] = process_options(varargin, 'StateColumn', 4);
     
    pos = find(traj.points(:, col) == state);
    if ~isempty(pos)
        p = traj.points(pos(1), 1);
    else
        p = NaN;
    end
end