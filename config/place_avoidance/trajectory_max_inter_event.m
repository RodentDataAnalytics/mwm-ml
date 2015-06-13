function tmax = trajectory_max_inter_event( traj, state, varargin )
    % TRAJECTORY_INTER_EVENT_TIMES Summary of this function goes here
    %   Detailed explanation goes here
    [col] = process_options(varargin, 'StateColumn', 4);
         
    pos = find(traj.points(:, col) == state);
    if ~isempty(pos)
        ts = traj.points(pos, 1);
        tmax = ts(1);
        for i = 2:length(ts)
            if ts(i) - ts(i - 1) > tmax
                tmax = ts(i) - ts(i - 1);
            end                
        end
    else
        tmax = 0;
    end
end