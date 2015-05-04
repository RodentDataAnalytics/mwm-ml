function val = trajectory_cv_inner_radius(traj, varargin)
    % need first the centre of the trajectory
    [x0, y0] = trajectory_boundaries(traj, varargin{:});

    [r, iqr] = trajectory_radius(traj, 'CentreX', x0, 'CentreY', y0, varargin{:});    
    val = r / iqr;                    
end