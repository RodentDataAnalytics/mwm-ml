function [ len, dt ] = trajectory_length( pts )
%TRAJECTORY_LENGTH Computes length of a trajectory
    len = 0;
    dt = 0;    
    for i = 2:size(pts, 1)
        % compute the length in cm and seconds
        len = len + norm( pts(i, 2:3) - pts(i-1, 2:3) );
        dt = dt + pts(i, 1) - pts(i - 1, 1);   
    end   
end