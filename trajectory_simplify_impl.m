function out = trajectory_simplify_impl( pts, tol)   
    if tol > 0
        [coord, ix] = dpsimplify(pts(:, 2:3), tol);
    
        % take the times of the simplified trajectory
        out = [pts(ix, 1), coord, pts(ix, 4:end)];
    else
        out = pts;
    end
end   