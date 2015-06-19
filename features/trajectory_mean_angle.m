function ang = trajectory_mean_angle( traj, varargin )
    %TRAJECTORY_ANGLE Compute mean angle of the trajectory    
    global g_config;
    [repr, x0, y0, dx, dy] = process_options(varargin, 'DataRepresentation', 1, 'X0', g_config.CENTRE_X, 'Y0', g_config.CENTRE_Y, 'DirX', 1, 'DirY', 0);
    pts = traj.data_representation(repr);

    d = [pts(:, 2) - x0, pts(:, 3) - y0];
    % normalize it
    norm_d = sqrt( d(:,1).^2 + d(:,2).^2);
    norm_d(norm_d == 0) =1e-5;
    
    d = d ./ repmat(norm_d, 1, 2);
        
    u = [dx, dy];
    v = [sum(d(:, 1)), sum(d(:, 2))];
        
    ang = abs(acos(dot(u, v)/(norm(u)*norm(v))));  
    
    assert(~isnan(ang));
    if ang > pi
        ang = 2*pi - ang;
    end    
end