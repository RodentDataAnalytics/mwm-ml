classdef config_place_avoidance_mem < config_place_avoidance
    % config_mwm Global constants
    properties(Constant)                                        	                                                                                                                                           
        % centre point of arena in cm        
        CENTRE_X = 127.5;
        CENTRE_Y = 127.5;
        % radius of the arena
        ARENA_R = 127.5;
        ROTATION_FREQUENCY = 1;
        
        % groups for the large group
        GROUP_CONTROL = 1;
        GROUP_MK_HIGH = 2;
        GROUP_MK_MEDIUM = 3;
        GROUP_MK_LOW = 4;
        GROUP_MEM_HIGH = 5;
        GROUP_MEM_MEDIUM = 6;
        GROUP_MEM_LOW = 7;      
        
        TAGS_CONFIG = { ... % values are: file that stores the tags, segment length, overlap, default number of clusters
            { '/home/tiago/neuroscience/place_avoidance/labels_full_large.csv', 0, 0}, ...
            { '/home/tiago/neuroscience/place_avoidance/labels_t1_large.csv', 10, config_place_avoidance.SEGMENTATION_PLACE_AVOIDANCE, 1, config_place_avoidance.SECTION_AVOID, 6} ...
        };
               
        TRIAL_TIMEOUT = 1200; % seconds
        TRIALS_PER_SESSION = [4 4 4 4];
        TRIALS = 16;
        SESSIONS = 4;                                     
        TRIAL_TYPE = repmat([ config_place_avoidance.TRIAL_TYPE_APAT_HABITUATION, ...
                              config_place_avoidance.TRIAL_TYPE_APAT_TRAINING, ...
                              config_place_avoidance.TRIAL_TYPE_APAT_TRAINING, ...
                              config_place_avoidance.TRIAL_TYPE_APAT_TEST ], 1, 4);
        GROUPS = 7;
        GROUPS_DESCRIPTION = { ...
            'Control', ...
            'MK-801H', ...
            'MK-801M', ...
            'MK-801L', ...
            'MemH', ...
            'MemM', ...
            'MemL' ...
        };
        SHOCK_AREA_ANGLE = pi/180*[225, 315, 135, 45];                           
    end   
        
    methods        
        function inst = config_place_avoidance_mem()            
            inst@config_place_avoidance('Place avoidance task (memantine)');                                               
        end
               
        % Imports trajectories from Noldus data file's
        function traj = load_data(inst)
            addpath(fullfile(fileparts(mfilename('fullpath')),'../import/place_avoidance'));
            
            root = '/home/tiago/place_avoidance/data2/';
            traj = trajectories([]);
            sub_folders = {'control', 'MK_high', 'MK_medium', 'MK_low', 'mem_high', 'mem_medium', 'mem_low' };
            groups = [ config_place_avoidance_mem.GROUP_CONTROL, ...
                       config_place_avoidance_mem.GROUP_MK_HIGH, ...
                       config_place_avoidance_mem.GROUP_MK_MEDIUM, ...
                       config_place_avoidance_mem.GROUP_MK_LOW, ...
                       config_place_avoidance_mem.GROUP_MEM_HIGH, ...
                       config_place_avoidance_mem.GROUP_MEM_MEDIUM, ...
                       config_place_avoidance_mem.GROUP_MEM_LOW ];

            % renumber tracks - otherwise we will have collisions
            track = 1;
            % for all days
            for d = 1:5
                day = d;                    
                real_day = d;
                if d == 5
                    day = 21; % == day 4 too
                    real_day = 4;
                end

                for f = 1:length(sub_folders)
                    % load training part (divided in 3 x 5 min trials)
                    pat = sprintf('*d%dtr*Room*.dat', day);     
                    new_traj = load_trajectories([root, sub_folders{f}], groups(f), 'FilterPattern', pat, 'IdDayMask', 'r%dd%d'); 
                    % break them down in 3 trajectories
                    for t = 1:new_traj.count
                        pos1 = find(new_traj.items(t).points(:, 1) > 5*60);
                        if isempty(pos1)
                            continue;
                        end
                        traj = traj.append( trajectory( new_traj.items(t).points(1:pos1(1) - 1, :), ...
                                                 new_traj.items(t).set, ...
                                                 track, ...
                                                 new_traj.items(t).group, ...
                                                 new_traj.items(t).id, ...
                                                 (real_day - 1)*4 + 1, ...
                                                 1, ...
                                                 0, ...
                                                 1 ) );
                        track = track + 1;
                        pos2 = find(new_traj.items(t).points(:, 1) > 10*60);
                        if isempty(pos2)
                            continue;
                        end
                        traj = traj.append( trajectory( new_traj.items(t).points(pos1(1):pos2(1) - 1, :), ...
                                                 new_traj.items(t).set, ...
                                                 track, ...
                                                 new_traj.items(t).group, ...
                                                 new_traj.items(t).id, ...
                                                 (real_day - 1)*4 + 2, ...
                                                 1, ...
                                                 0, ...
                                                 1 ) );
                        track = track + 1;
                        pos3 = find(new_traj.items(t).points(:, 1) > 15*60);
                        if isempty(pos3)
                            pos3 = size(new_traj.items(t).points, 1) + 1;
                        end
                        traj = traj.append( trajectory( new_traj.items(t).points(pos2(1):pos3(1) - 1, :), ...
                                                 new_traj.items(t).set, ...
                                                 track, ...
                                                 new_traj.items(t).group, ...
                                                 new_traj.items(t).id, ...
                                                 (real_day - 1)*4 + 3, ...
                                                 1, ...
                                                 0, ...
                                                 1 ) );                                                 
                        track = track + 1;
                    end

                    % load testing part (5 min)
                    pat = sprintf('*d%dts*Room*.dat', day);     
                    new_traj = load_trajectories([root, sub_folders{f}], groups(f), 'FilterPattern', pat, 'IdDayMask', 'r%dd%d');
                    % correct trial and track number
                    for t = 1:new_traj.count
                        new_traj.items(t).set_trial( real_day*4 );
                        new_traj.items(t).set_track( track );
                        track = track + 1;
                    end
                    traj = traj.append(new_traj);
                end
            end            
        end        
    end
end