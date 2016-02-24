function [r, var] = trajectory_radius(traj, varargin)    
    global g_config;
    [repr, x0, y0, f, f_avg, f_dis] = process_options(varargin, 'DataRepresentation', 1, ...
                                               'CentreX', g_config.CENTRE_X, ...
                                               'CentreY', g_config.CENTRE_Y, ...
                                               'TransformationFunc', [], ...
                                               'AveragingFunc', @(X) median(X), ...
                                               'DispertionFunc', @(X) iqr(X) );
                                               
    pts = traj.data_representation(repr);                                                   
    d = sqrt( power(pts(:, 2) - x0, 2) + power(pts(:, 3) - y0, 2) ) / g_config.ARENA_R;       
    % d(d == 0) = 1e-5; % avoid zero-radius
    if ~isempty(f)
        d = f(d);
    end
    r = f_avg(d);
    if nargout > 1
        var = f_dis(d);
    end
end