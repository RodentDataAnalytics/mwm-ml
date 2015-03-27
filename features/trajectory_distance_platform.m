function [ dist, var, minimum ] = trajectory_distance_platform( traj, xplat, yplat )
%TRAJECTORY_DISTANCE_PLATFORM Compute mean angle of the trajectory    
    minimum = 1e6;
    for i = 2:size(traj, 1)
        A = xplat - traj(i - 1, 2);
        B = yplat - traj(i - 1, 3);
        C = traj(i, 2) - traj(i - 1, 2);    
        D = traj(i, 3) - traj(i - 1, 3);
        dot = A*C + B*D;
        len2 = C*C + D*D;
        param = dot / len2;	 
        if param < 0
            xx = traj(i - 1, 2);
            yy = traj(i - 1, 3);
        elseif param > 1
            xx = traj(i, 2);
            yy = traj(i, 3);
        else
            xx = traj(i - 1, 2) + param * C;
            yy = traj(i - 1, 3) + param * D;
        end
        d = sqrt( (xplat - xx)^2 + (yplat - yy)^2 );	 
        
        minimum = min([minimum, d]);        
    end
    minimum = max(minimum - g_config.PLATFORM_R, 0);
    dist = 0;
    var = 0;
end
