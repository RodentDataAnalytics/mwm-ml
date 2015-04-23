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
                
        DEFAULT_DATA_REPRESENTATION = { ...
            {'Coordinates', 'trajectory_points'}, ...
            {'Speed', 'trajectory_speed'}, ...
            {'Acceleration', 'trajectory_acceleration'} ...
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
    end
    
    methods
        function inst = base_config(desc, extr_tags, extr_data_repr)
            inst.DESCRIPTION = desc;          
            inst.TAGS = [base_config.DEFAULT_TAGS, extr_tags];
            inst.DATA_REPRESENTATION = [base_config.DEFAULT_DATA_REPRESENTATION, extr_data_repr];
        end
        
        function val = hash(inst)
           val = hash_value(inst.DESCRIPTION);
        end               
    end        
end