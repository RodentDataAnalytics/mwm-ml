function len = trajectory_length( traj, varargin )
%TRAJECTORY_LENGTH Computes length of a trajectory
    [repr] = process_options(varargin, 'DataRepresentation', 1);
    pts = traj.data_representation(repr);
    len = 0;    
    for i = 2:size(pts, 1)
        % compute the length in cm and seconds
        len = len + norm( pts(i, 2:3) - pts(i-1, 2:3) );        
    end   
end