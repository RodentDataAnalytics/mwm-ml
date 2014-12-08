function [ C ] = trajectory_centre( traj )
%TRAJECTORY_CENTER Returns the center point of the trajectory
    C = [median(traj(:,2)), median(traj(:,3))];
end