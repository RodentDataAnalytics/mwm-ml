classdef config_place_avoidance < base_config
    % config_mwm Global constants
    properties(Constant)
        RESULTS_DIR = 'results/place_avoidance_t1';
        
        TRIALS_PER_SESSION = 1;
        SESSIONS = 5;
        TRIALS = config_place_avoidance.TRIALS_PER_SESSION*config_place_avoidance.SESSIONS;
        TRIAL_TIMEOUT = 1200; % seconds
        GROUPS = 2;
        % centre point of arena in cm        
        CENTRE_X = 127.5;
        CENTRE_Y = 127.5;
        % radius of the arena
        ARENA_R = 127.5;
        
        TRAJECTORY_DATA_DIRS = {... % 1st set
            '/home/tiago/neuroscience/place_avoidance/data1' ...
        }; 
        	
        REGULARIZE_GROUPS = 0;
        NDISCARD = 0;        
    
        % relation between animal ids and groups (1 = control, 2 = test)
        TRAJECTORY_GROUPS = {...
                 %1st set   
                [1093, 1; ...
                 1094, 1; ...
                 1095, 1; ...
                 1096, 1; ...
                 1097, 2; ...
                 1098, 2; ...
                 1099, 2; ...
                 1100, 2; ...
                 1101, 2; ...
                 1102, 2; ...
                 1103, 2; ...
                 1104, 2; ...                 
                 1105, 1; ...
                 1106, 1; ...
                 1107, 1; ...
                 1108, 1; ...                 
                ] ...
         };        
                    
        % trajectory sample status
        POINT_STATE_OUTSIDE = 0;
        POINT_STATE_ENTRANCE_LATENCY = 1;
        POINT_STATE_SHOCK = 2;
        POINT_STATE_INTERSHOCK_LATENCY = 3;
        POINT_STATE_OUTSIDE_LATENCY = 4;
        POINT_STATE_BAD = 5;
                                    
        CLUSTER_CLASS_MINIMUM_SAMPLES_P = 0.01; % 2% o
        CLUSTER_CLASS_MINIMUM_SAMPLES_EXP = 0.75;
           
        DEFAULT_SEGMENT_LENGTH = 250;
        DEFAULT_SEGMENT_OVERLAP = 0.90;        
        DEFAULT_NUMBER_OF_CLUSTERS = 120;
                
        DEFAULT_FEATURE_SET = [features.MEDIAN_RADIUS, features.IQR_RADIUS, features.FOCUS, features.BOUNDARY_ECCENTRICITY];
                                                          
        %%
        %% Tags sets - number/indices have to match the list below        
        %%
        TAGS_FULL = 1; 
        TAGS500_70 = 2; % Important: go from "more detailed" to less detailed ones
        
        TAGS_CONFIG = { ... % values are: file that stores the tags, segment length, overlap, default number of clusters
            { '/home/tiago/neuroscience/place_avoidance/labels_full.csv', 0, 0, 0}, ...
            { '/home/tiago/neuroscience/place_avoidance/labels_t1_500_70.csv', 500, 0.70, 50} ...             
        };
                
        % plot properties
        OUTPUT_DIR = '/home/tiago/results/'; % where to put all the graphics and other generated output
        CLASSES_COLORMAP = @jet;   
                 
        % which part of the trajectories are to be taken
        SECTION_T1 = 1; % segment until first entrance to the shock area
        SECTION_TMAX = 2; % longest segment between shocks
        SECTION_AVOID = 3; % segments between shocks
        SECTION_FULL = 0; % complete trajectories
        
        DATA_REPRESENTATION_ARENA_COORD = base_config.DATA_REPRESENTATION_LAST + 1;
    end   
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        section = config_place_avoidance.SECTION_FULL;
        rotation_frequency = 1;
    end
    
    methods        
        function inst = config_place_avoidance(sec)
            addpath(fullfile(fileparts(mfilename('fullpath')), 'place_avoidance'));    
   
            switch sec
                case config_place_avoidance.SECTION_T1
                    desc = 't < T1';                    
                case config_place_avoidance.SECTION_TMAX
                    desc = 't < Tmax';
                case config_place_avoidance.SECTION_AVOID
                    desc = 'Ti < t < Ti+1';
                case config_place_avoidance.SECTION_FULL
                    desc = 'full trajectories';
            end
            inst@base_config(sprintf('Place avoidance task (%s)', desc), ...                
               [ tag('TT', 'thigmotaxis', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 1), ... % default tags
                 tag('IC', 'incursion', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 2), ...
                 tag('SS', 'scanning-surroundings', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 7), ...                 
                 tag('CP', 'close pass', base_config.TAG_TYPE_TRAJECTORY_ATTRIBUTE), ...
                 tag('S1', 'selected 1', base_config.TAG_TYPE_TRAJECTORY_ATTRIBUTE) ], ...
               { {'Arena coordinates', 'trajectory_arena_coord' } } ...
            );   
            inst.section = sec;
        end
        
        function val = hash(inst)
            val = hash_combine(hash@base_config(inst), inst.section);
        end
        
        % Imports trajectories from Noldus data file's
        function traj = load_data(inst)
            addpath(fullfile(fileparts(mfilename('fullpath')),'../import/place_avoidance'));
            % load only paths in the room reference frame and up to the
            % point of first entrance in the shock area
            traj = load_trajectories(1, 1, inst.section_);
        end        
    end
end