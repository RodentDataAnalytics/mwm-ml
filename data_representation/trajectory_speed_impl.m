function pts = trajectory_speed_impl( pts )
    spd = zeros(1, size(pts, 1));
    for i = 2:size(pts, 1)
        % compute the length in cm and seconds
        len = norm( pts(i, 2:3) - pts(i-1, 2:3) );
        dt = pts(i, 1) - pts(i - 1, 1);
        spd(i) = len / dt;  
    end   
    pts = [pts(:, 1), pts(:, 2), pts(:, 3), spd'];    
end