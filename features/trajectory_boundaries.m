function [ x, y, a, b, inc ] = trajectory_boundaries( traj, varargin )
    global g_config;
    x = g_config.CENTRE_X;
    y = g_config.CENTRE_Y;
    a = 0;
    b = 0;
    inc = 0;
     
    [repr] = process_options(varargin, 'DataRepresentation', 1);
        
    if repr > 1
        % we have a special data representation - don't look for
        % pre-computed values
        pts = traj.data_representation(repr);                    
        if size(pts, 1) > 3
            [A, cntr] = min_enclosing_ellipsoid(pts(:, 2:3)', 1e-2);
            x = cntr(1);
            y = cntr(2);                
            if sum(isnan(A)) == 0
                [a, b, inc] = ellipse_parameters(A);
            end
        end
    else
        % see we have cached values
        if traj.has_feature_value(g_config.FEATURE_BOUNDARY_CENTRE_X)
            x = traj.compute_feature(g_config.FEATURE_BOUNDARY_CENTRE_X);
            y = traj.compute_feature(g_config.FEATURE_BOUNDARY_CENTRE_Y);
            a = traj.compute_feature(g_config.FEATURE_BOUNDARY_RADIUS_MIN);
            b = traj.compute_feature(g_config.FEATURE_BOUNDARY_RADIUS_MAX);
            inc = traj.compute_feature(g_config.FEATURE_BOUNDARY_INCLINATION);
        else
            if size(traj.points, 1) > 3
                [A, cntr] = min_enclosing_ellipsoid(traj.points(:, 2:3)', 1e-1);
                x = cntr(1);
                y = cntr(2);
                if (sum(isinf(A)) + sum(isnan(A))) == 0
                    [a, b, inc] = ellipse_parameters(A);
                end
                % cache values
                traj.cache_feature_value(g_config.FEATURE_BOUNDARY_CENTRE_X, x);
                traj.cache_feature_value(g_config.FEATURE_BOUNDARY_CENTRE_Y, y);
                traj.cache_feature_value(g_config.FEATURE_BOUNDARY_RADIUS_MIN, a);
                traj.cache_feature_value(g_config.FEATURE_BOUNDARY_RADIUS_MAX, b);
                traj.cache_feature_value(g_config.FEATURE_BOUNDARY_INCLINATION, inc);                
            end
        end
    end                    
end