function [r, var] = trajectory_radius(traj, varargin)    
    global g_config;
    [repr, x0, y0] = process_options(varargin, 'DataRepresentation', 1, ...
                                               'CentreX', g_config.CENTRE_X, ...
                                               'CentreY', g_config.CENTRE_Y);
                                               
    pts = traj.data_representation(repr);                                                   
    d = sqrt( power(pts(:, 2) - x0, 2) + power(pts(:, 3) - y0, 2) ) / g_config.ARENA_R;       
    r = median(d);    
    if nargout > 1
        var = iqr(d);
    end
end