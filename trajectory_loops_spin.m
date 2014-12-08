function [ loop, spin, var ] = trajectory_loops_spin( traj )
%TRAJECTORY_WINDING Computes the tortosuity (turning) of the trajectory per
% unit length
    % first "simplify" the trajectory as to not have any points closer than
    % 2 cm from one another
    
    traj = trajectory_simplify(traj, 2);
    loop = 0;
    spin = 0;
    accum = 0;
    len = 0;        
    llen = 0;
    ang = 0;
    for i = 1:(length(traj) - 2)                
        u = traj(i + 1, 2:3) - traj(i, 2:3);        
        v = traj(i + 2, 2:3) - traj(i + 1, 2:3);
        if det([u; v]') > 0
            sign_ang = 1;
        else
            sign_ang = -1;
        end            
        ang = sign_ang*acos(dot(u, v)/(norm(u)*norm(v)))*.2 + .8*ang;        
        
%         if ang > pi/2
%             if llen > 20
%                 loop = loop + abs(accum)/(llen / 100);
%                 spin = spin + accum/(llen / 100);        
%             end        
%             accum = 0;
%             llen = 0;
%         else
            accum = accum + ang;
            llen = llen + norm(v);
       if sign(accum)*sign_ang == -1 || ang < 0.02*pi
            % loop finished
            if abs(accum) > 2*pi/3
                if llen > 25
                    loop = loop + abs(accum);
                    spin = spin + accum;
                end
                accum = 0;
                llen = 0;
            end            
%         end
        len = len + norm(v);                        
        end        
    end        
    
    if llen > 25 && abs(accum) > 2*pi/3% last few cm
        loop = loop + abs(accum);
        spin = spin + accum;        
    end
    %loop = loop + abs(accum);
    %spin = spin + accum;
    
    spin = abs(spin);
%     loop = loop;
%     var = 0; %iqr(ang);yes
    var = 0;
end