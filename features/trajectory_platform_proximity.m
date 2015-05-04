function prox = trajectory_platform_proximity( traj, rarea)
    global g_config;
    prox = 0;
    ltot = 0;
    lins = 0;
    for i = 2:size(traj.points, 1)
       % direction vector of trajectory segment
       d = traj.points(i, 2:3) - traj.points(i - 1, 2:3);
       % vector from centre of platform to segment start
       f = traj.points(i - 1, 2:3) - [g_config.PLATFORM_X, g_config.PLATFORM_Y];
       
       a = d*d';
       b = 2*(f*d');
       c = f*f' - rarea^2;
       disc = b^2 - 4*a*c;
       
       lseg = norm(traj.points(i, 2:3) - traj.points(i - 1, 2:3));
       ltot = ltot + lseg;
       if disc >= 0           
           % there is an intersection with the platform
           disc = sqrt(disc);
           t1 = (-b - disc) / (2*a);
           t2 = (-b + disc) / (2*a);
           % check cases
           if t1 >= 0 && t1 <= 1
               % beginning of segment crossed the circle
               if t2 >= 0 && t2 <= 1
                    % segment crosses and overshoots the circle
                   lins = lins + (t2 - t1)*lseg;
               else
                   % entered the circle area
                   lins = lins + (1 - t1)*lseg;                   
               end
           elseif t2 >= 0 && t2 <= 1
               % left the circle area
               lins = lins + t2*lseg;
           elseif norm(traj.points(i - 1, 2:3) - [g_config.PLATFORM_X, g_config.PLATFORM_Y]) <= rarea ...
               && norm(traj.points(i, 2:3) - [g_config.PLATFORM_X, g_config.PLATFORM_Y]) <= rarea
               % segment fully contained in the circle
               lins = lins + lseg;
           end
       end
       
       prox = lins / ltot;
    end    
end