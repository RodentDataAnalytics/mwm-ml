classdef base_config    
    properties(Constant)        
        UNDEFINED_TAG_ABBREVIATION = 'UD'; 
        UNDEFINED_TAG_INDEX = 1;        

        % tag types
        TAG_TYPE_ALL = 0;
        TAG_TYPE_BEHAVIOUR_CLASS = 1;
        TAG_TYPE_TRAJECTORY_ATTRIBUTE = 2;               
        
        % default tags               
        
        % plot properties
        AXIS_LINE_WIDTH = 1.5;    % AxesLineWidth
        FONT_SIZE = 20;      % Fontsize
        LINE_WIDTH = 1.4;        
        
        %%%
        %%% Features
        %%%
        FEATURE_LENGTH = 1;
        FEATURE_LATENCY = 2;
        FEATURE_AVERAGE_SPEED = 3;
        FEATURE_BOUNDARY_CENTRE_X = 4;
        FEATURE_BOUNDARY_CENTRE_Y = 5;
        FEATURE_BOUNDARY_RADIUS_MIN = 6;
        FEATURE_BOUNDARY_RADIUS_MAX = 7;
        FEATURE_BOUNDARY_INCLINATION = 8;        
        FEATURE_BOUNDARY_ECCENTRICITY= 9;        
        FEATURE_MEDIAN_RADIUS = 10;
        FEATURE_IQR_RADIUS = 11;
        FEATURE_FOCUS = 12;
        FEATURE_LAST = 12; % always make sure that this points to the last feature index
        
        DEFAULT_FEATURES = { ...
            {'L', 'Path length', 'trajectory_length'}, ...
            {'Lat', 'Latency', 'trajectory_latency'}, ...
            {'v_m', 'Average speed', 'trajectory_average_speed'}, ...
            {'x', 'Boundary centre x', 'trajectory_boundary', 1}, ...
            {'y', 'Boundary centre y', 'trajectory_boundary', 2}, ...
            {'r_a', 'Boundary min radius', 'trajectory_boundary', 3}, ...
            {'r_b', 'Boundary max radius', 'trajectory_boundary', 4}, ...
            {'inc', 'Boundary inclination', 'trajectory_boundary', 5}, ...
            {'ecc', 'Boundary eccentricity', 'trajectory_eccentricity'}, ...
            {'r_12', 'Median radius', 'trajectory_radius', 1}, ...
            {'r_iqr', 'IQR radius', 'trajectory_radius', 2}, ...
            {'f', 'Focus', 'trajectory_focus'} ...
        };
        
        %%%
        %%% Data representations
        %%%
        DEFAULT_DATA_REPRESENTATION = { ...
            {'Coordinates', 'trajectory_points'}, ...
            {'Speed', 'trajectory_speed'}, ...
            {'Acceleration', 'trajectory_acceleration'}           
        }; 
        DEFAULT_TAGS = [ tag('UD', 'undefined', base_config.TAG_TYPE_BEHAVIOUR_CLASS) ];           
        
        DATA_REPRESENTATION_COORD = 1;
        DATA_REPRESENTATION_SPEED = 2;
        DATA_REPRESENTATION_ACCEL = 3;
        
        % let this always point out to the last index above
        DATA_REPRESENTATION_LAST = 3;
        
        
    end
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        DESCRIPTION = '';  
        TAGS = [];
        DATA_REPRESENTATION = [];
        FEATURES = [];
    end
    
    methods
        function inst = base_config(desc, extr_tags, extr_data_repr, extr_features)
            inst.DESCRIPTION = desc;          
            inst.TAGS = [base_config.DEFAULT_TAGS, extr_tags];
            inst.DATA_REPRESENTATION = [base_config.DEFAULT_DATA_REPRESENTATION, extr_data_repr];
            inst.FEATURES = [base_config.DEFAULT_FEATURES, extr_features];
        end
        
        function val = hash(inst)
           val = hash_value(inst.DESCRIPTION);
        end               
    end        
end