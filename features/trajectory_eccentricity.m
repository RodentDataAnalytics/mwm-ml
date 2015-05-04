function ecc = trajectory_eccentricity( traj, varargin )
    [~, ~, a, b] = trajectory_boundaries(traj, varargin{:});
    ecc = sqrt(1 - a^2/b^2);
end

