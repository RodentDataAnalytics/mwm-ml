function [ T ] = trajectory_simplify( traj, lmin )
%TRAJECTORY_SIMPLIFY Takes one trajectory and removes points that are very
%close together; returns the simplified trajectory
    cur = 1;
    T = traj(1, :);
    prev = traj(1,:);
    for i = 2:size(traj,1)
        pt = traj(i,:);       
        if norm(prev(:, 2:3) - pt(:, 2:3)) >= lmin            
            T = [T; pt];    
            prev = pt;
        end
    end
end

