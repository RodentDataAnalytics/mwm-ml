function spd = trajectory_speed( traj)
    spd = [];
    for i = 2:size(pts, 1)
        % compute the length in cm and seconds
        len = norm( traj.points(i, 2:3) - traj.points(i-1, 2:3) );
        if len > min_len % discard points which are too close together
            dt = traj.points(i, 1) - traj.points(i - 1, 1);
            spd = [spd, len / dt];
        end
    end    
end