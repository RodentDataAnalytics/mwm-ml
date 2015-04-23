function pts = trajectory_speed( traj)
    spd = [0];
    for i = 2:size(traj.points, 1)
        % compute the length in cm and seconds
        len = norm( traj.points(i, 2:3) - traj.points(i-1, 2:3) );
        dt = traj.points(i, 1) - traj.points(i - 1, 1);
        spd = [spd, len / dt];        
    end   
    pts = [traj.points(:, 1), traj.points(:, 2), traj.points(:, 3), spd'];    
end