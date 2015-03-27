classdef trajectory < handle
    %TRAJECTORY Stores points of a trajectory or segment of trajectory
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        points = [];
        % trajectory/segment identification
        set = -1;
        track = -1;
        group = -1;
        id = -1;
        trial = -1;
        segment = -1;
        offset = -1;        
        session = -1;
        start_time = -1;
        end_time = -1;
        start_index = -1;
    end
    
    properties(GetAccess = 'protected', SetAccess = 'protected')        
        centre_ = [];
        % boundary ellipse parameters and related values
        ecentre_ = [];
        focus_ = -1;
        a_ = -1;
        b_ = -1;
        inc_ = -1;
        % other cached values
        hash_ = -1;
        len_ = -1;
        r12_ = -1;
        riqr_ = -1;        
        loops_ = -1;
        spin_ = -1;
        kiqr_ = -1;        
        ri_ = -1;
        iqrri_ = -1;
        covang_ = -1;        
        centralpts_ = [];
    end
    
    methods
        % constructor
        function traj = trajectory(pts, set, track, group, id, trial, segment, off, starti)   
            global g_config;
            traj.points = pts;                       
            traj.set = set;
            traj.track = track;
            traj.start_index = starti;
            traj.group = group;
            traj.id = id;
            traj.trial = trial;
            traj.segment = segment;
            traj.offset = off;            
            traj.session = floor(((traj.trial - 1) / g_config.TRIALS_PER_SESSION) + 1);        
            traj.start_time = pts(1, 1);
            traj.end_time = pts(end, 1);
        end
        
        % returns the full trajectory (or segment identification)
        function [ ident ] = identification(traj)
            ident = [traj.group, traj.id, traj.trial, traj.segment];
        end
        
        function out = hash_value(traj)            
            if traj.hash_ == -1                                          
                % compute hash
                len = 0;
                if traj.offset ~= -1
                    % length taken only into account when offset is used
                    len = traj.compute_feature(features.LENGTH);
                end
                traj.hash_ = trajectory.compute_hash(traj.set, traj.session, traj.track, traj.offset, len);
            end
            out = traj.hash_;
        end
        
        % returns the data set and track number where the data originated
        function [ ident ] = data_identification(traj)
            ident = [traj.set, traj.session, traj.track];
        end                              
        
        function [ eff ] = efficiency(traj)
            global g_config;
            min_path = norm( traj.points(1,2) - g_config.PLATFORM_X, traj.points(1,3) - g_config.PLATFORM_Y);
            len = traj.compute_feature(features.LENGTH);
            if len ~= 0
                eff = min_path / len;
            else
                eff = 0.;
            end
        end
                
        function [ segment ] = sub_segment(traj, beg, len)
            %SUB_SEGMENT returns a segment from the trajectory
            pts = [];
            dist = 0;
            starti = 0;
            for i = 2:length(traj.points)
               dist = dist + norm( traj.points(i, 2:3) - traj.points(i - 1, 2:3) );
               if dist >= beg
                   if starti == 0
                       starti = i;
                   end
                   if dist > beg + len
                       % done we are
                       break;
                   end
                   % append point to segment
                   pts = [pts; traj.points(i, :)];
               end
            end
             
            segment = trajectory(pts, traj.set, traj.track, traj.group, traj.id, traj.trial, 0, beg, starti);   
        end
        
        function C = centre(traj)           
            if isempty(traj.centre_)
                traj.centre_ = trajectory_centre(traj.points);
            end
            C = traj.centre_;
        end
        
        function pts = central_points(traj, p)
            C = traj.centre;
        
            % then we compute the distance of each point to the center
            d = sqrt(power(traj.points(:, 2) - C(1), 2) + power(traj.points(:, 3) - C(2), 2));

            % now sort the values by the distance
            [~, ind] = sort(d);    
            % sort the points now    
            pts = traj.points(ind, :);
            % select only the first p percent of them
            pts = pts(1:floor(p*size(traj.points, 1)), :);
        end    
        
        function [ segments ] = divide_into_segments(traj, lseg, ovlp)
            %SEGMENT_TRAJECTORY Splits the trajectory in segments of length
            % lseg with an overlap of ovlp %
            % Returns an array of instances of the same trajectory class (now repesenting segments)
            n = length(traj.points);
    
            % compute cumulative distance vector
            cumdist = zeros(1, n);    
            for i = 2:n
                cumdist(i) = cumdist(i - 1) + norm( traj.points(i, 2:3) - traj.points(i - 1, 2:3) );        
            end
         
            % step size
            off = lseg*(1. - ovlp);
            % total number of segments - at least 1
            if cumdist(end) > lseg                
                nseg = ceil((cumdist(end) - lseg) / off) + 1;
                off = off + (cumdist(end) - lseg - off*(nseg - 1))/nseg;
            else
                nseg = 1;
            end
            % segments are trajectories again -> construct empty object
            segments = trajectories([]);
                                                    
            for seg = 0:(nseg - 1)
                starti = 0;
                seg_off = 0;
                pts = [];
                if nseg == 1
                    % special case: only 1 segment, don't discard it
                    pts = traj.points;
                else
                    for i = 1:n
                       if cumdist(i) >= seg*off                           
                           if starti == 0
                               starti = i;
                           end
                           if cumdist(i) > (seg*off + lseg)
                               % done we are
                               break;
                           end
                           if isempty(pts)
                               seg_off = cumdist(i);
                           end
                           % otherwise append point to segment
                           pts = [pts; traj.points(i, :)];
                       end
                    end
                end

                segments = segments.append(trajectory(pts, traj.set, traj.track, traj.group, traj.id, traj.trial, seg + 1, seg_off, starti));
            end                        
        end
        
        function [ V ] = compute_features(traj, feat)
        %COMPUTE_FEATURES Computes a set of features for a trajectory
        %   COMPUTE_FEATURES(traj, [F1, F2, ... FN]) computes features F1, F2, ..
        %   FN for trajectory traj (features are identified by g_config defined 
        %   at the beginning of this class    
            V = [];
            for i = 1:length(feat)
                V = [V, traj.compute_feature(feat(i))];
            end
        end            
        
        function [ v ] = compute_feature(traj, f)
            global g_config;
            switch(f)
                case features.LATENCY                    
                    [~, v] = trajectory_length(traj.points);
                    if v > 89.5
                        v = g_config.TRIAL_TIMEOUT;
                    end                  
                case features.LENGTH 
                    % this is used so often that we cache it
                    if traj.len_ == -1
                        traj.len_ = trajectory_length(traj.points);
                    end
                    v = traj.len_;
                case features.EFFICIENCY
                    v = traj.efficiency();
                case features.MEDIAN_RADIUS
                    if traj.r12_ == -1
                        [traj.r12_, traj.riqr_] = trajectory_radius(traj.points, g_config.CENTRE_X, g_config.CENTRE_Y);
                    end
                    v = traj.r12_; 
                case features.IQR_RADIUS
                    if traj.riqr_ == -1
                        [traj.r12_, traj.riqr_] = trajectory_radius(traj.points, g_config.CENTRE_X, g_config.CENTRE_Y);
                    end
                    v = traj.riqr_;                                    
                case features.FOCUS                    
                    % cache this since computation can take some time                                        
                    traj.compute_boundary;
                    v = traj.focus_;                    
                case features.BOUNDARY_CENTRE_RADIUS                
                    traj.compute_boundary;
                    v = sqrt( (traj.ecentre_(1) - g_config.CENTRE_X)^2 + (traj.ecentre_(2) - g_config.CENTRE_Y)^2);
                case features.BOUNDARY_CENTRE_ANGLE 
                    traj.compute_boundary;
                    v = atan2(traj.ecentre_(2) - g_config.CENTRE_Y, traj.ecentre_(1) - g_config.CENTRE_X);
                case features.BOUNDARY_CENTRE_DISTANCE_PLATFORM
                    traj.compute_boundary;
                    v = sqrt( (traj.ecentre_(1) - g_config.PLATFORM_X)^2 + (traj.ecentre_(2) - g_config.PLATFORM_Y)^2) / g_config.ARENA_R;
                case features.BOUNDARY_MINOR_RADIUS
                    traj.compute_boundary;
                    v = traj.a_;
                case features.BOUNDARY_MAJOR_RADIUS
                    traj.compute_boundary;
                    v = traj.b_;
                case features.BOUNDARY_INCLINATION
                    traj.compute_boundary;
                    v = traj.inc_;
                case features.BOUNDARY_ECCENTRICITY                    
                    traj.compute_boundary;
                    v = sqrt(1 - (traj.a_^2)/(traj.b_^2));
                %case features.PLATFORM_CENTRALITY
                 %   traj.compute_boundary;
                  %  v = sqrt( (traj.ecentre_(1) - g_config.PLATFORM_X)^2 + (traj.ecentre_(2) - g_config.PLATFORM_Y)^2);
                    
                case features.ANGULAR_DISTANCE_PLATFORM
                    v = trajectory_angular_distance(traj.points, g_config.CENTRE_X, g_config.CENTRE_Y, g_config.PLATFORM_X, g_config.PLATFORM_Y);
                case features.MEDIAN_DISTANCE_PLATFORM
                    v = trajectory_distance_platform(traj.points, g_config.PLATFORM_X, g_config.PLATFORM_Y);
                case features.MINIMUM_DISTANCE_PLATFORM
                    [~, ~, v] = trajectory_distance_platform(traj.points, g_config.PLATFORM_X, g_config.PLATFORM_Y) / g_config.ARENA_R;
                case features.PLATFORM_PROXIMITY
                    v = trajectory_platform_proximity(traj.points, g_config.PLATFORM_X, g_config.PLATFORM_Y, g_config.PLATFORM_R*3);                    
                case features.PLATFORM_SURROUNDINGS
                    v = trajectory_platform_proximity(traj.points, g_config.PLATFORM_X, g_config.PLATFORM_Y, g_config.PLATFORM_R*6);                    
                case features.IQR_DISTANCE_PLATFORM
                    [~, v] = trajectory_distance_platform(traj.points, g_config.PLATFORM_X, g_config.PLATFORM_Y);
                case features.LOOPS
                    if traj.loops_ == -1
                        [traj.loops_, traj.spin_, traj.kiqr_] = trajectory_loops_spin(traj.points);
                    end
                    v = traj.loops_;
                case features.SPIN
                    if traj.spin_ == -1
                        [traj.loops_, traj.spin_, traj.kiqr_] = trajectory_loops_spin(traj.points);
                    end
                    v = traj.spin_;
                case features.AVERAGE_SPEED
                    v = trajectory_average_speed(traj.points, 1);
                case features.CENTRE_DISTANCE_PLATFORM
                    C = traj.centre;                        
                    v = sqrt( (C(1) - g_config.PLATFORM_X)^2 + (C(2) - g_config.PLATFORM_Y)^2);
                case features.BOUNDARY_COVERED_ANGLE
                    if traj.covang_ == -1
                        traj.compute_boundary;
                        traj.covang_ = trajectory_covered_angle(traj.points, traj.ecentre_);
                    end              
                    v = traj.covang_;
                case features.MEDIAN_INNER_RADIUS
                    if traj.ri_ == -1
                        % need the centre of the covering ellipe for this
                        % traj.compute_boundary;                        
                        [traj.ri_, traj.iqrri_] = trajectory_radius(traj.centralpts_, traj.ecentre_(1), traj.ecentre_(2));
                    end              
                    v = traj.ri_;    
                case features.IQR_INNER_RADIUS
                    if traj.iqrri_ == -1
                        % need the centre of the covering ellipe for this
                        % traj.compute_boundary;                        
                        [traj.ri_, traj.iqrri_] = trajectory_radius(traj.centralpts_, traj.ecentre_(1), traj.ecentre_(2));
                    end              
                    v = traj.iqrri_;    
                case features.CV_INNER_RADIUS
                    if traj.iqrri_ == -1
                        % need the centre of the covering ellipse for this
                        % traj.compute_boundary;                        
                        [traj.ri_, traj.iqrri_] = trajectory_radius(traj.centralpts_, traj.ecentre_(1), traj.ecentre_(2));
                    end       
                    v = traj.iqrri_ / traj.ri_;                    
                case features.LONGEST_LOOP
                    v= trajectory_longest_loop(traj.points, 40);
                case features.CENTRE_DISPLACEMENT
                    traj.compute_boundary;
                    v = sqrt( (traj.ecentre_(1))^2 + (traj.ecentre_(2))^2) / g_config.ARENA_R;                
                otherwise
                    error('!!!');
            end
        end    
        
        function plot(traj, varargin)
            global g_config;
            addpath(fullfile(fileparts(mfilename('fullpath')), '/extern'));
            [clr, arn, ls, lw] = process_options(varargin, ...
                'Color', [0 0 0], 'DrawArena', 1, 'LineSpec', '-', 'LineWidth', 1);
            if arn
                axis off;
                daspect([1 1 1]);                      
                rectangle('Position',[g_config.CENTRE_X - g_config.ARENA_R, g_config.CENTRE_X - g_config.ARENA_R, g_config.ARENA_R*2, g_config.ARENA_R*2],...
                    'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3);
                hold on;
                axis square;
                % see if we have a platform to draw
                if exist('g_config.PLATFORM_X')
                    rectangle('Position',[g_config.PLATFORM_X - g_config.PLATFORM_R, g_config.PLATFORM_Y - g_config.PLATFORM_R, 2*g_config.PLATFORM_R, 2*g_config.PLATFORM_R],...
                        'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3);             
                end
            end
            plot(traj.points(:,2), traj.points(:,3), ls, 'LineWidth', lw, 'Color', clr);           
            set(gca, 'LooseInset', [0,0,0,0]);
        end        
    end
    
    methods(Static)
        % compute a hash for a trajectory segment
        % defined here as it is useful in other situations as well
        function hash = compute_hash(set, session, track, offset, len) 
            % compute hash            
            hash = hash_value(set);
            hash = hash_combine(hash, hash_value(session));
            hash = hash_combine(hash, hash_value(track));
            hash = hash_combine(hash, hash_value(floor(offset)));
            hash = hash_combine(hash, hash_value(floor(len)));
        end
    end
    
    methods(Access = 'protected')
        function compute_boundary(traj)
            if traj.focus_ == -1                
                if isempty(traj.centralpts_)
                    traj.centralpts_ = traj.central_points(1.);
                end
                [traj.focus_, traj.ecentre_, traj.a_, traj.b_, traj.inc_] = trajectory_focus(traj.centralpts_, traj.compute_feature(features.LENGTH));
            end
        end
    end    
end
    
