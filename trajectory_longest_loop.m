function max_loop = trajectory_longest_loop( traj, ext )
    traj = trajectory_simplify(traj ,4);
    d = zeros(size(traj, 1) - 1, 2);
    % compute direction vectors for each pair of points
    for i = 2:size(traj, 1)
        d(i - 1, :) = traj(i, 2:3) - traj(i - 1, 2:3);
    end

    max_loop = 0;
    % for each pair of line segments
    i = 1;
    while i < length(d)
        for j = (i + 2):length(d)
            rs = cross(d(i, :), d(j, :));
            if rs ~= 0  % check if they intersect               
                % vector from starting points of the 2 segments            
                pq = traj(j, 2:3) - traj(i, 2:3);
                t = cross(pq, d(j, :)) / rs;
                u = cross(pq, d(i, :)) / rs;
                
                intersect = 0;
                if t >= 0 && t <= 1 && u >= 0 && u <= 1
                    % they intersect, compute length of loop
                    intersect = 1;                    
                elseif (i == 1 && u >= 0 && u<= 1)
                   % first segment would self-cross the trajectory if
                   % extended further; see how far                   
                   e = norm(d(i, :))*abs(t) + norm(d(j, :))*u;
                   if t < 0 && e <= ext
                       intersect = 1;
                   end                    
                elseif (j == size(d, 1) && t >=0 && t<= 1)
                   % last segment, to the same check if we project if
                   % further                   
                   e = norm(d(i, :))*(1 - t) + norm(d(j, :))*abs(u);
                   if u > 0 && e < ext 
                       intersect = 1;
                   end
                end
                
                if intersect
                    l = sum(sqrt( d( (i + 1):(j - 1), 1).^2 + d( (i + 1):(j - 1), 2).^2 ));                    
                    l = l + norm(d(i, :))*(1 - t) + norm(d(j, :))*u;
                    max_loop = max(l, max_loop);       
                    i = j;
                    break;
                end
            end            
        end
        i = i + 1;
    end
    
    
    function v = cross(x, y)
        v = x(1)*y(2) - x(2)*y(1);
    end    
end

%     accum = 0;
%     llen = 0;    
%     ang = 0;
%     max_loop = 0;
%     traj = trajectory_simplify(traj, 4);
%     for i = 1:(length(traj) - 2)                
%         u = traj(i + 1, 2:3) - traj(i, 2:3);        
%         v = traj(i + 2, 2:3) - traj(i + 1, 2:3);
%         if det([u; v]') > 0
%             sign_ang = 1;
%         else
%             sign_ang = -1;
%         end
%         if i == 1
%             ang = sign_ang*acos(dot(u, v)/(norm(u)*norm(v)));
%         else            
%             ang = sign_ang*acos(dot(u, v)/(norm(u)*norm(v)))*.8 + .2*ang;        
%         end
%         if sign(accum)*sign(ang) == -1
%             % changed direction            
%             if abs(accum) >= 3*pi/2 %&& accum/llen > .002 % && accum/llen < .1
%                 max_loop = max(max_loop, llen);
%             end
%             llen = 0;
%             accum = 0;
%         end         
%         
%         accum = accum + ang;
%         llen = llen + norm(v);        
%     end   
%     if abs(accum) >= 3*pi/2 % && accum/llen > .002 % && accum/llen < .1
%         max_loop = max(max_loop, llen);            
%     end
%     max_loop = max_loop / 100;
%end