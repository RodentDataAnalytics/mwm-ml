classdef config_place_avoidance_silver < config_place_avoidance
    % config_mwm Global constants
    properties(Constant)     
        % centre point of arena in cm        
        CENTRE_X = 127.5;
        CENTRE_Y = 127.5;
        % radius of the arena
        ARENA_R = 127.5;
        ROTATION_FREQUENCY = 1;
        
        TAGS_CONFIG = { ... % values are: file that stores the tags, segment length, overlap, default number of clusters
            { '/home/tiago/neuroscience/place_avoidance/labels_silver_large.csv', 0, 0}, ...
            { '/home/tiago/neuroscience/place_avoidance/labels_t1_silver.csv', 10, config_place_avoidance.SEGMENTATION_PLACE_AVOIDANCE, 1, config_place_avoidance.SECTION_AVOID, 6} ...
        };
        SESSIONS = 6;  
        TRIALS_PER_SESSION = ones(1, config_place_avoidance_silver.SESSIONS);
        TRIALS = 6;
        TRIAL_TYPE = [ config_place_avoidance.TRIAL_TYPE_TRAINING ...
                            config_place_avoidance.TRIAL_TYPE_TRAINING, ...
                            config_place_avoidance.TRIAL_TYPE_TRAINING, ...
                            config_place_avoidance.TRIAL_TYPE_TRAINING, ...
                            config_place_avoidance.TRIAL_TYPE_TRAINING, ...
                            config_place_avoidance.TRIAL_TYPE_TEST ];
        GROUPS = 2;        
        GROUPS_DESCRIPTION = { ...
            'Control', ...
            'Silver', ...                    
        };
        SHOCK_AREA_ANGLE = pi/180*225*ones(1, config_place_avoidance_silver.SESSIONS);                         
    end   
        
    methods        
        function inst = config_place_avoidance_silver()            
            inst@config_place_avoidance('Place avoidance task (silver)');                                   
        end
               
        % Imports trajectories from Noldus data file's
        function traj = load_data(inst)
            addpath(fullfile(fileparts(mfilename('fullpath')),'../import/place_avoidance'));

            % "Silver" set
            folder = '/home/tiago/place_avoidance/data3/';
            % control
            traj = load_trajectories(folder, 1, 'FilterPattern', 'ho*Room*.dat', 'IdDayMask', 'hod%dr%d', 'ReverseDayId', 1); 
            % silver
            traj = traj.append(load_trajectories(folder, 2, 'FilterPattern', 'nd*Room*.dat', 'IdDayMask', 'nd%dr%d', 'ReverseDayId', 1));           
        end        
    end
end