function [ spd ] = trajectory_average_speed( pts, min_len )
%TRAJECTORY_AVERAGE_SPEED 
    temp = [];
    for i = 2:length(pts)
        % compute the length in cm and seconds
        len = norm( pts(i, 2:3) - pts(i-1, 2:3) );
        if len > min_len % discard points which are too close together
            dt = pts(i, 1) - pts(i - 1, 1);
            temp = [temp, len / dt];
        end
    end 
    spd = mean(temp);
end

