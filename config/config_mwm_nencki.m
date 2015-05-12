classdef config_mwm_nencki < base_config
    % config_mwm Global constants
    properties(Constant)
        RESULTS_DIR = 'results/mwm';
                
        TRIALS_PER_SESSION = [4, 4, 4, 4, 4];
        SESSIONS = length(config_mwm_nencki.TRIALS_PER_SESSION);
        TRIALS = sum(config_mwm_nencki.TRIALS_PER_SESSION);        
        TRIAL_TIMEOUT = 90; % seconds
        GROUPS = 1;
        
        % centre point of arena in cm        
        CENTRE_X = 0;
        CENTRE_Y = 0;
        % radius of the arena
        ARENA_R = 90;
        % platform position and radius
        PLATFORM_X = -32;
        PLATFORM_Y = 32;
        PLATFORM_R = 6;               
        
        TRAJECTORY_DATA_DIRS = {... % 1st set
            '/home/tiago/rat_data_china/test', ...                                                  
            '/home/tiago/rat_data_china/training', ...                                                  
            '/home/tiago/rat_data_china/reversal', ...
        }; 
        	
        % number of animals to discard from each group
        REGULARIZE_GROUPS = 0;
        NDISCARD = 0;
        DISCARD_FEATURE = base_config.FEATURE_AVERAGE_SPEED;
            
        CLUSTER_CLASS_MINIMUM_SAMPLES_P = 0.01; % 2% o
        CLUSTER_CLASS_MINIMUM_SAMPLES_EXP = 0.75;
        
        FEATURE_LONGEST_LOOP = base_config.FEATURE_LAST + 1;
        FEATURE_CENTRE_DISPLACEMENT = base_config. FEATURE_LAST + 2;
        FEATURE_PLATFORM_PROXIMITY = base_config.FEATURE_LAST + 3;
        FEATURE_CV_INNER_RADIUS = base_config.FEATURE_LAST + 4;        
                        
        DEFAULT_FEATURE_SET = [config_mwm_nencki.FEATURE_MEDIAN_RADIUS, ...
                               config_mwm_nencki.FEATURE_IQR_RADIUS, ...
                               config_mwm_nencki.FEATURE_FOCUS, ...
                               config_mwm_nencki.FEATURE_CENTRE_DISPLACEMENT, ... 
                               config_mwm_nencki.FEATURE_CV_INNER_RADIUS, ...
                               config_mwm_nencki.FEATURE_PLATFORM_PROXIMITY, ...
                               config_mwm_nencki.FEATURE_BOUNDARY_ECCENTRICITY ];
                                                                   
        %%
        %% Tags sets - number/indices have to match the list below        
        %%
        TAGS_FULL = 1; 
        TAGS250_90 = 2; % Important: go from "more detailed" to less detailed 
        
        TAGS_CONFIG = { ... % values are: file that stores the tags, segment length, overlap, default number of clusters
            { '/home/tiago/rat_data_china/labels_training_full.csv', 0, 0}, ...
            { '/home/tiago/rat_data_china/labels_training_250.csv', 37, base_config.SEGMENTATION_CONSTANT_LENGTH, 6, 250, 0.90} ...
        };
                
        OUTPUT_DIR = '/home/tiago/results/'; % where to put all the graphics and other generated output
        CLASSES_COLORMAP = @jet;
        
        TRAJECTORY_GROUPS = [];
    end 
    
    methods    
        function inst = config_mwm_nencki()
            inst@base_config('Morris water maze (NENCKI)', ...                
               [ tag('TT', 'thigmotaxis', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 1), ... % default tags
                 tag('SC', 'scanning', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 3), ...
                 tag('FS', 'focused search', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 4), ...                                  
                 tag('CR', 'chaining response', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 5), ...
                 tag('ST', 'target scanning', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 8), ...
                 tag('DF', 'direct finding', base_config.TAG_TYPE_BEHAVIOUR_CLASS), ...
                 tag('AT', 'approaching target', base_config.TAG_TYPE_BEHAVIOUR_CLASS), ...
                 tag('SO', 'self-orienting', base_config.TAG_TYPE_BEHAVIOUR_CLASS), ...                 
                 tag('OT', 'scanning other', base_config.TAG_TYPE_BEHAVIOUR_CLASS, 2), ...                
                 tag('S1', 'selected 1', base_config.TAG_TYPE_TRAJECTORY_ATTRIBUTE) ], ...
               [], ...% no additional data representation
               { {'L_max', 'Longest loop', 'trajectory_longest_loop', 1, 40}, ...
                 {'D_ctr', 'Centre displacement', 'trajectory_centre_displacement'}, ...                 
                 {'P_plat', 'Platform proximity', 'trajectory_time_within_radius', 1, 3*config_mwm.PLATFORM_R, 'X0', config_mwm_nencki.PLATFORM_X, 'Y0', config_mwm_nencki.PLATFORM_Y}, ...
                 {'Ri_CV', 'Inner radius variation', 'trajectory_cv_inner_radius'} }, ...
               {} ...
            );   
        end
                
        % Imports trajectories from Noldus data file's
        function traj = load_data(inst)
            addpath(fullfile(fileparts(mfilename('fullpath')),'../import/noldus'));
            traj = load_trajectories([2], 0, 'AnimalTags', {'mouse no.'}, ...
                        'DeltaX', -195, 'DeltaY', -120, 'FlipY', 1, 'DayFormat', 'training day %d');
        end        
    end
end