classdef config_place_avoidance < base_config
    % config_mwm Global constants
    properties(Constant)
        RESULTS_DIR = 'results/place_avoidance_t1';
                
        TRIAL_TYPE_APAT_HABITUATION = 1;
        TRIAL_TYPE_APAT_TRAINING = 2;
        TRIAL_TYPE_APAT_TEST = 3;
        TRIAL_TYPE_PAT_DARKNESS = 4;        
        
        TRIAL_TYPES_DESCRIPTION = { ...            
            'APAT/Habituation', ...
            'APAT/Training', ...
            'APAT/Testing', ...
            'PAT/Darkness', ...
        };                    
                    	
        REGULARIZE_GROUPS = 0;
        NDISCARD = 0;        
                        
        % trajectory sample status
        POINT_STATE_OUTSIDE = 0;
        POINT_STATE_ENTRANCE_LATENCY = 1;
        POINT_STATE_SHOCK = 2;
        POINT_STATE_INTERSHOCK_LATENCY = 3;
        POINT_STATE_OUTSIDE_LATENCY = 4;
        POINT_STATE_BAD = 5;
                                    
        CLUSTER_CLASS_MINIMUM_SAMPLES_P = 0.01; % 2% o
        CLUSTER_CLASS_MINIMUM_SAMPLES_EXP = 0.75;
        
        FEATURE_AVERAGE_SPEED_ARENA = base_config.FEATURE_LAST + 1;
        FEATURE_VARIANCE_SPEED_ARENA = base_config.FEATURE_LAST + 2;
        FEATURE_LENGTH_ARENA = base_config.FEATURE_LAST + 3;
        FEATURE_LOG_RADIUS = base_config.FEATURE_LAST + 4;
        FEATURE_IQR_RADIUS_ARENA = base_config.FEATURE_LAST + 5;        
        FEATURE_TIME_CENTRE = base_config. FEATURE_LAST + 6; 
        FEATURE_NUMBER_OF_SHOCKS = base_config.FEATURE_LAST + 7; 
        FEATURE_FIRST_SHOCK = base_config.FEATURE_LAST + 8; 
        FEATURE_MAX_INTER_SHOCK = base_config.FEATURE_LAST + 9; 
        FEATURE_ENTRANCES_SHOCK = base_config.FEATURE_LAST + 10; 
        FEATURE_ANGULAR_DISTANCE_SHOCK = base_config.FEATURE_LAST + 11;        
        FEATURE_SHOCK_RADIUS = base_config.FEATURE_LAST + 12;            
                                                             
        FEATURE_SET_APAT = [ base_config.FEATURE_LATENCY, ...
                             config_place_avoidance.FEATURE_AVERAGE_SPEED_ARENA, ...                                                                                                
                             config_place_avoidance.FEATURE_VARIANCE_SPEED_ARENA, ...
                             config_place_avoidance.FEATURE_TIME_CENTRE, ...
                             config_place_avoidance.FEATURE_NUMBER_OF_SHOCKS, ... 
                             config_place_avoidance.FEATURE_FIRST_SHOCK, ...
                             config_place_avoidance.FEATURE_MAX_INTER_SHOCK, ...
                             config_place_avoidance.FEATURE_ENTRANCES_SHOCK, ...
                             config_place_avoidance.FEATURE_SHOCK_RADIUS, ...
                             base_config.FEATURE_LENGTH ...                                
                           ];
                          
        CLUSTERING_FEATURE_SET_APAT = [ base_config.FEATURE_DENSITY, ...
                                        config_place_avoidance.FEATURE_ANGULAR_DISTANCE_SHOCK, ...
                                        config_place_avoidance.FEATURE_LOG_RADIUS ...
                                      ];
                                                                          
        % plot properties
        OUTPUT_DIR = '/home/tiago/results/'; % where to put all the graphics and other generated output
        CLASSES_COLORMAP = @jet;   
                 
        % which part of the trajectories are to be taken
        SECTION_T1 = 1; % segment until first entrance to the shock area
        SECTION_TMAX = 2; % longest segment between shocks
        SECTION_AVOID = 3; % segments between shocks
        SECTION_FULL = 0; % complete trajectories
        
        DATA_REPRESENTATION_ARENA_COORD = base_config.DATA_REPRESENTATION_LAST + 1;
        DATA_REPRESENTATION_ARENA_SPEED = base_config.DATA_REPRESENTATION_LAST + 2;
        DATA_REPRESENTATION_SHOCKS = base_config.DATA_REPRESENTATION_LAST + 3;
        DATA_REPRESENTATION_ARENA_SHOCKS = base_config.DATA_REPRESENTATION_LAST + 4;
                         
        %%%
        %%% Segmentation
        %%%
        SEGMENTATION_PLACE_AVOIDANCE = base_config.SEGMENTATION_LAST + 1;                                               
    end
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        DEFAULT_FEATURE_SET = [];
        CLUSTERING_FEATURE_SET = [];
        % centre point of arena in cm        
        CENTRE_X = [];
        CENTRE_Y = [];
        % radius of the arena
        ARENA_R = [];
        ROTATION_FREQUENCY = [];        
    end
            
    methods        
        function inst = config_place_avoidance(name, varargin)
            addpath(fullfile(fileparts(mfilename('fullpath')), 'place_avoidance'));
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern'));
            [feat_set, clus_feat_set, r, x, y, rot] = process_options(varargin, ...
                'FeatureSet', config_place_avoidance.FEATURE_SET_APAT, ...
                'ClusteringFeatureset', config_place_avoidance.CLUSTERING_FEATURE_SET_APAT, ...
                'ArenaRadius', 127, ...
                'CentreX', 127, ...
                'CentreY', 127, ...
                'RotationFrequency', 1);
                          
            
            inst@base_config(name, ...                
               [ tag('TT', 'thigmotaxis', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 1), ... % default tags
                 tag('IC', 'incursion', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 2), ...
                 tag('SS', 'scanning-surroundings', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 7), ...                 
                 tag('CP', 'close pass', base_config.TAG_TYPE_TRAJECTORY_ATTRIBUTE), ...
                 tag('S1', 'selected 1', base_config.TAG_TYPE_TRAJECTORY_ATTRIBUTE) ], ...                 
               { {'Arena coordinates', base_config.DATA_TYPE_COORDINATES, 'trajectory_arena_coord' }, ...
                 {'Speed (arena)', base_config.DATA_TYPE_SCALAR_FIELD, 'trajectory_speed', 'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD}, ...
                 {'Shock events', base_config.DATA_TYPE_EVENTS, 'trajectory_events', config_place_avoidance.POINT_STATE_SHOCK}, ...
                 {'Shock events (arena)', base_config.DATA_TYPE_EVENTS, 'trajectory_events', config_place_avoidance.POINT_STATE_SHOCK, 'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD} ...
               }, ...
               { {'Va', 'Average speed (arena)', 'trajectory_average_speed', 1, 'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD}, ...
                 {'Va_var', 'Log variance speed (arena)', 'feature_transform', 1, @log, 'trajectory_variance_speed', 'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD}, ...
                 {'L_A', 'Length (arena)', 'trajectory_length', 1, 'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD}, ...
                 {'log_R12', 'Log radius  ', 'trajectory_radius', 1, 'TransformationFunc', @(x) -log(x), 'AveragingFunc', @(X) mean(X)}, ...
                 {'Riqr_A', 'IQR radius (arena)', 'trajectory_radius', 2, 'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD}, ...
                 {'Tc_A', 'Time centre', 'trajectory_time_within_radius', 1, 0.75*r, 'DataRepresentation', config_place_avoidance.DATA_REPRESENTATION_ARENA_COORD}, ...
                 {'N_s', 'Number of shocks', 'trajectory_count_events', 1, config_place_avoidance.POINT_STATE_SHOCK}, ...
                 {'T1', 'Time for first shock', 'trajectory_first_event', 1, config_place_avoidance.POINT_STATE_SHOCK}, ...
                 {'Tmax', 'Maximum time between shocks', 'trajectory_max_inter_event', 1, config_place_avoidance.POINT_STATE_SHOCK}, ...
                 {'Nent', 'Number of entrances', 'trajectory_entrances_shock', 1}, ...
                 {'D_ang', 'Angular dist. shock', 'trajectory_angular_distance_shock', 1}, ...                 
                 {'R_s', 'Shock radius', 'trajectory_event_radius', 1, config_place_avoidance.POINT_STATE_SHOCK}, ...                 
               }, ...config_place_avoidanceconfig_place_avoidance
               { {'Place avoidance', 'segmentation_place_avoidance'} } ...
            );                                   
        
            inst.DEFAULT_FEATURE_SET = feat_set;
            inst.CLUSTERING_FEATURE_SET = clus_feat_set;            
            inst.ARENA_R = r;
            inst.CENTRE_X = x;
            inst.CENTRE_Y = y;
            inst.ROTATION_FREQUENCY = rot;
        end                       
    end
end