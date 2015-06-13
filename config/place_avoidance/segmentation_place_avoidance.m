function segments = segmentation_place_avoidance(traj, section, dt_min)
    segments = trajectories([]);
    switch section
        case config_place_avoidance.SECTION_T1
            % get points until first entrance to the dark side
            cuti = find(traj.points(:, 4) > 0);
            if ~isempty(cuti)                                      
                pts = traj.points(1:cuti(1), :);
            else
                pts = traj.points;
            end
            segments = segments.append(trajectory(pts, traj.set, traj.track, traj.group, traj.id, traj.trial, 1, 0, 1));
            
        case config_place_avoidance.SECTION_FULL
            segments = segments.append(traj);

        case {config_place_avoidance.SECTION_TMAX, config_place_avoidance.SECTION_AVOID}
            % partition the trajectories into multiple things
            beg = 1;
            s = -1;          
            cum_dist = [0];
            sub_seg = [];
            for k = 1:size(traj.points, 1)
                if k > 1
                    cum_dist(k) = cum_dist(k - 1) + sqrt(sum( (traj.points(k, 2:3) - traj.points(k - 1, 2:3)).^2 ));
                end
                if s ~= traj.points(k, 4)
                    if s == 0 && k > beg
                        % add sub-trajectory
                        sub_seg = [sub_seg; beg, k - 1];
                    end
                    s = traj.points(k, 4);
                    beg = k;
                end                         
            end
            if s == 0 && k > beg
                sub_seg = [sub_seg; beg, k - 1];
            end

            if section == config_place_avoidance.SECTION_TMAX
                % select only the longest sub segment
                imax = 0;
                t = 0;
                for k = 1:size(sub_seg, 1)
                    tseg = traj.points(sub_seg(k, 2), 1) - traj.points(sub_seg(k, 1), 1);
                    if tseg > t
                        imax = k;
                        t = tseg;
                    end
                end
                segments = segments.append( ...
                    trajectory(traj.points(sub_seg(imax, 1):sub_seg(imax, 2), :), traj.set, traj.track, traj.group, traj.id, traj.trial, 1, cum_dist(sub_seg(imax, 1)), sub_seg(imax, 1)) ...
                );                
            else
                % add all sub-segments
                idx = 0;
                for k = 1:size(sub_seg, 1)                        
                    if traj.points(sub_seg(k, 2), 1) - traj.points(sub_seg(k, 1), 1) >= dt_min
                        idx = idx + 1;
                        segments = segments.append( ...
                            trajectory(traj.points(sub_seg(k, 1):sub_seg(k, 2), :), traj.set, traj.track, traj.group, traj.id, traj.trial, idx, cum_dist(sub_seg(k, 1)), sub_seg(k, 1)) ...
                        );                             
                    end
                end
            end
    end
end