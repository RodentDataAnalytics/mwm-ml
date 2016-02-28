function [ spd ] = trajectory_average_speed( traj, varargin )                                                  
    [repr, min_len ] = process_options(varargin, 'DataRepresentation', 1, 'MinLength', 1);
    pts = traj.data_representation(repr);       
    
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