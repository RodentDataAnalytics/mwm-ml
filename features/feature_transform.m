function x = feature_transform(traj, f, gn, varargin)   
    % get reference to the function that computes a feature
    g = str2func(gn);
    % return transformed value
    x = f(g(traj, varargin{:}));
end