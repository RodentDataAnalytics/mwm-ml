function val = trajectory_variance_speed( traj, varargin )
    [repr] = process_options(varargin, 'DataRepresentation', 1);
            
    pts = trajectory_speed_impl(traj.data_representation(repr, varargin{:}));
    val = var(pts(:, 4));
end