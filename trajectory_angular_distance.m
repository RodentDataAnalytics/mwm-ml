function [ ang ] = trajectory_angle( traj, x0, y0, dx, dy )
%TRAJECTORY_ANGLE Compute mean angle of the trajectory    
    d = [traj(:, 2) - x0, traj(:, 3) - y0];
    % normalize it
    d = d ./ repmat(sqrt( d(:,1).^2 + d(:,2).^2), 1, 2);
        
    u = [dx, dy];
    v = [sum(d(:, 1)), sum(d(:, 2))];
    
    ang = abs(acos(dot(u, v)/(norm(u)*norm(v))));  
end