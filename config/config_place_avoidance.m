classdef config_place_avoidance        
    % config_mwm Global constants
    properties(Constant)
        DESCRIPTION = 'Place avoidance task (Room frame, t < T1)';
        RESULTS_DIR = 'results/place_avoidance_t1';
        
        TRIALS_PER_SESSION = 1;
        SESSIONS = 3;
        TRIALS = config_mwm.TRIALS_PER_SESSION*config_mwm.SESSIONS;
        TRIAL_TIMEOUT = 1200; % seconds
        % centre point of arena in cm        
        CENTRE_X = 127.5;
        CENTRE_Y = 127.5;
        % radius of the arena
        ARENA_R = 127.5;
        
        TRAJECTORY_DATA_DIRS = {... % 1st set
            '/home/tiago/neuroscience/place_avoidance/data1' ...
        }; 
        	
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
        
        % tag types
        TAG_TYPE_ALL = 0;
        TAG_TYPE_BEHAVIOUR_CLASS = 1;
        TAG_TYPE_TRAJECTORY_ATTRIBUTE = 2;
        
        % major/minor classes weights
        CLASS_WEIGHT_MINOR = 10;
        CLASS_WEIGHT_MAJOR = 1;
        
        % default tags               
        TAGS = [ tag('UD', 'undefined', config_mwm.TAG_TYPE_BEHAVIOUR_CLASS), ...
                 tag('TT', 'thigmotaxis', config_mwm.TAG_TYPE_BEHAVIOUR_CLASS, 1, [], config_mwm.CLASS_WEIGHT_MAJOR), ...
                 tag('IC', 'incursion', config_mwm.TAG_TYPE_BEHAVIOUR_CLASS, 2, [], config_mwm.CLASS_WEIGHT_MAJOR), ...
                 tag('SS', 'scanning-surroundings', config_mwm.TAG_TYPE_BEHAVIOUR_CLASS, 7, [], config_mwm.CLASS_WEIGHT_MAJOR), ...                 
                 tag('SC', 'scanning', config_mwm.TAG_TYPE_BEHAVIOUR_CLASS, 3, [], config_mwm.CLASS_WEIGHT_MAJOR), ...
                 tag('FS', 'focused search', config_mwm.TAG_TYPE_BEHAVIOUR_CLASS, 4, [], config_mwm.CLASS_WEIGHT_MINOR), ...                                  
                 tag('SO', 'self orienting', config_mwm.TAG_TYPE_BEHAVIOUR_CLASS, 6, [], config_mwm.CLASS_WEIGHT_MINOR), ...
                 tag('CR', 'chaining response', config_mwm.TAG_TYPE_BEHAVIOUR_CLASS, 5, [], config_mwm.CLASS_WEIGHT_MINOR), ...
                 tag('ST', 'target scanning', config_mwm.TAG_TYPE_BEHAVIOUR_CLASS, 8, [], config_mwm.CLASS_WEIGHT_MINOR), ...
                 tag('TS', 'target sweep', config_mwm.TAG_TYPE_BEHAVIOUR_CLASS, 3), ...             
                 tag('DF', 'direct finding', config_mwm.TAG_TYPE_BEHAVIOUR_CLASS), ...
                 tag('AT', 'approaching_target', config_mwm.TAG_TYPE_BEHAVIOUR_CLASS), ...                              
                 tag('CI', 'circling', config_mwm.TAG_TYPE_BEHAVIOUR_CLASS, 8), ...                                   
                 tag('CP', 'close pass', config_mwm.TAG_TYPE_TRAJECTORY_ATTRIBUTE), ...
                 tag('S1', 'selected 1', config_mwm.TAG_TYPE_TRAJECTORY_ATTRIBUTE)];
   
        REDUCED_BEHAVIOURAL_CLASSES = [ ...
            tag.combine_tags( [config_mwm.TAGS(tag.tag_position(config_mwm.TAGS, 'TT')), config_mwm.TAGS(tag.tag_position(config_mwm.TAGS, 'IC'))]), ...
            config_mwm.TAGS(tag.tag_position(config_mwm.TAGS, 'FS')), ...
            config_mwm.TAGS(tag.tag_position(config_mwm.TAGS, 'SC')), ...
            config_mwm.TAGS(tag.tag_position(config_mwm.TAGS, 'SS')), ...
            config_mwm.TAGS(tag.tag_position(config_mwm.TAGS, 'CR')), ...
            tag.combine_tags( [config_mwm.TAGS(tag.tag_position(config_mwm.TAGS, 'SO')), config_mwm.TAGS(tag.tag_position(config_mwm.TAGS, 'ST'))])  ...                          
        ];
    
        % trajectory sample status
        POINT_STATE_OUTSIDE = 0;
        POINT_STATE_ENTRANCE_LATENCY = 1;
        POINT_STATE_SHOCK = 2;
        POINT_STATE_INTERSHOCK_LATENCY = 3;
        POINT_STATE_OUTSIDE_LATENCY = 4;
        POINT_STATE_BAD = 5;

        UNDEFINED_TAG_ABBREVIATION = 'UD'; 
        UNDEFINED_TAG_INDEX = 1;        
                                    
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
        AXIS_LINE_WIDTH = 1.5;    % AxesLineWidth
        FONT_SIZE = 20;      % Fontsize
        LINE_WIDTH = 1.4;      
        OUTPUT_DIR = '/home/tiago/results/'; % where to put all the graphics and other generated output
        CLASSES_COLORMAP = jet;   
        
        
        REFERENCE_FRAME_ROOM = 1;
        REFERENCE_FRAME_ARENA = 0;        
        
        SECTION_T1 = 1;
        SECTION_ALL = 0;
    end   
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        ref_frame_ = 0;
        section_ = config_place_avoidance.SECTION_ALL;
    end
    
    methods
        function inst = config_place_avoidance(ref_frame, sec)
            inst.ref_frame_ = ref_frame;
            inst.section_ = sec;
        end
        
        % Imports trajectories from Noldus data file's
        function traj = load_data(inst)
            addpath(fullfile(fileparts(mfilename('fullpath')),'../import/place_avoidance'));
            % load only paths in the room reference frame and up to the
            % point of first entrance in the shock area
            traj = load_trajectories(1, inst.ref_frame_, inst.section_);
        end        
    end
end