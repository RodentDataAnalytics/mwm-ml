function pts = trajectory_speed( traj, varargin )
    [repr] = process_options(varargin, 'DataRepresentation', 1);
            
    pts = trajectory_speed_impl(traj.data_representation(repr, varargin{:}));
end