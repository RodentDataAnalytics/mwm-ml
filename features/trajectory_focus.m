function [ f, cntr, a, b, inc ] = trajectory_focus( pts, len )
%TRAJECTORY_FOCUS Returns the focus of a trajectory
    % first we need the center point of the trajectory                
    if size(pts, 1) <= 3
        f = 1;
        cntr = [0, 0];
        a = 0;
        b = 0;
        inc = 0;
    else
        % compute the enclosing ellipsoid parameters
        [A, cntr] = min_enclosing_ellipsoid(pts(:, 2:3)', 1e-2);

        if sum(isnan(A)) == 0
            % using the A matrix returned above compute the ellipse parameters
            [a, b, inc] = ellipse_parameters(A);

            % the final focus is computed based on the area of the circle with
            % perimeter = trajectory length        
            f = 1 - a*b/(len^2 / (4*pi));        
        else
            f = 1;
            cntr = [0, 0];
            a = 0;
            b = 0;
            inc = 0;
        end
    end
end