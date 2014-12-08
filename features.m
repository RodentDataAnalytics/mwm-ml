classdef features
    %FEATURES Just define some constants here since it seems that there is
    %   no other way to do this in Matlab   
    %   (Oh, and there is no way to put it in the trajectory class either
    %   so we need a separate class for this)
    properties(Constant)
        % escape latency [s]
        LATENCY = 1;
        % efficiency (distance fom starting point to platform divided by
        % length of trajectory)
        EFFICIENCY = 2;
        % trajectory length
        LENGTH = 3;
        % median distance to the centre of the arena
        MEDIAN_RADIUS = 4;
        % IQR of radius to the centre of the arena
        IQR_RADIUS = 5;        
        % distance from centre of trajectory (computed from the surrounding
        % ellipse) to the centre of the arena
        BOUNDARY_CENTRE_RADIUS = 6;
        % angular distance of the centre of the surrounding ellipse to the
        % platform
        BOUNDARY_CENTRE_ANGLE = 7;
        % euclidean distance of the centre of the boundary to the platform
        BOUNDARY_CENTRE_DISTANCE_PLATFORM = 8;
        % major and minor radius of the surrounding ellipse
        BOUNDARY_MINOR_RADIUS = 9;
        BOUNDARY_MAJOR_RADIUS = 10;
        % inclination of the surrounding ellipse
        BOUNDARY_INCLINATION = 11;
        % eccentricity of the surrounding ellipse        
        BOUNDARY_ECCENTRICITY = 12;        
        BOUNDARY_COVERED_ANGLE = 13;
        MEDIAN_INNER_RADIUS = 14;
        IQR_INNER_RADIUS = 15;
        % ratio of the area of the surrounding ellipse to the area of the 
        % circle with perimeter equal to the length of the trajectory        
        FOCUS = 16;               
        % number of loops per length
        LOOPS = 17;
        % 
        SPIN = 18;                 
        ANGULAR_DISTANCE_PLATFORM = 19;      
        MEDIAN_DISTANCE_PLATFORM = 20;
        IQR_DISTANCE_PLATFORM = 21;
        AVERAGE_SPEED = 22;
        MINIMUM_DISTANCE_PLATFORM = 23;
        CENTRE_DISTANCE_PLATFORM = 25;
        CV_INNER_RADIUS = 26;
        PLATFORM_PROXIMITY = 27;        
        PLATFORM_SURROUNDINGS = 28;
        LONGEST_LOOP = 29;
    end
    
    methods(Static)
        function [ name ] = feature_name(f)
            switch f
                case features.LATENCY
                    name = 'Escape latency';
                case features.EFFICIENCY
                    name = 'Efficiency';
                case features.LENGTH
                    name = 'Path length';
                case features.MEDIAN_RADIUS
                    name = 'Median radius';
                case features.IQR_RADIUS
                    name = 'IQR radius';
                case features.BOUNDARY_CENTRE_RADIUS                
                    name = 'Distance to the centre';
                case features.BOUNDARY_CENTRE_ANGLE 
                    name = 'Angular distance';
                case features.BOUNDARY_CENTRE_DISTANCE_PLATFORM
                    name = 'Central distance to platform';
                case features.BOUNDARY_MINOR_RADIUS
                    name = 'Boundary minor radius';
                case features.BOUNDARY_MAJOR_RADIUS
                    name = 'Boundary major radius';
                case features.BOUNDARY_INCLINATION
                    name = 'Boundary inclination';
                case features.BOUNDARY_ECCENTRICITY
                    name = 'Boundary eccentricity';
                case features.MEDIAN_INNER_RADIUS
                    name = 'Median inner radius';
                case features.IQR_INNER_RADIUS
                    name = 'IQR inner radius';                
                case features.CV_INNER_RADIUS
                    name = 'CV inner radius';                                
                case features.FOCUS
                    name = 'Focus';                    
                case features.LOOPS
                    name = 'Loops per length';
                case features.SPIN
                    name = 'Spin';
                case features.ANGULAR_DISTANCE_PLATFORM
                    name = 'Angular distance to platform';
                case features.MEDIAN_DISTANCE_PLATFORM
                    name = 'Median distance to platform';
                case features.IQR_DISTANCE_PLATFORM
                    name = 'IQR distance to platform';
                case features.AVERAGE_SPEED
                    name = 'Average speed';
                case features.MINIMUM_DISTANCE_PLATFORM
                    name = 'Minimum distance platform';
                case features.CENTRE_DISTANCE_PLATFORM
                    name = 'Distance to platform';
                case features.BOUNDARY_COVERED_ANGLE
                    name = 'Covered angle';
                case features.PLATFORM_PROXIMITY
                    name = 'Platform proximity' ;                
                case features.PLATFORM_SURROUNDINGS
                    name = 'Platform surroundings' ;                                 
                case features.LONGEST_LOOP
                    name = 'Longest loop';
                otherwise
                    error('Ouch!');
            end
        end
            
        function [ name ] = feature_abbreviation(f)
            switch f
                case features.LATENCY
                    name = 'Lat';
                case features.EFFICIENCY
                    name = 'Eff';
                case features.LENGTH
                    name = 'L';
                case features.MEDIAN_RADIUS
                    name = 'R_12';
                case features.IQR_RADIUS
                    name = 'R_iqr';
                case features.BOUNDARY_CENTRE_RADIUS                
                    name = 'C_r';
                case features.BOUNDARY_CENTRE_ANGLE 
                    name = 'B_ang';
                case features.BOUNDARY_CENTRE_DISTANCE_PLATFORM
                    name = 'D_plat';
                case features.BOUNDARY_MINOR_RADIUS
                    name = 'B_a';
                case features.BOUNDARY_MAJOR_RADIUS
                    name = 'B_b';
                case features.BOUNDARY_INCLINATION
                    name = 'B_inc';
                case features.BOUNDARY_ECCENTRICITY
                    name = 'Ecc';  
                case features.MEDIAN_INNER_RADIUS
                    name = 'Ri_12';
                case features.IQR_INNER_RADIUS
                    name = 'Ri_iqr';
                case features.CV_INNER_RADIUS
                    name = 'CV_ri';                                
                case features.FOCUS                    
                    name = 'F';                    
                case features.LOOPS
                    name = 'Loop';
                case features.SPIN
                    name = 'Spin';
                case features.AVERAGE_SPEED
                    name = 'V_m';
                case features.ANGULAR_DISTANCE_PLATFORM
                    name = 'P_ang';
                case features.MEDIAN_DISTANCE_PLATFORM
                    name = 'D_m';
                case features.IQR_DISTANCE_PLATFORM
                    name = 'D_iqr';                
                case features.MINIMUM_DISTANCE_PLATFORM
                    name = 'D_min';                
                case features.CENTRE_DISTANCE_PLATFORM
                    name = 'C_d';
                case features.BOUNDARY_COVERED_ANGLE
                    name = 'A_cov';
                case features.PLATFORM_PROXIMITY
                    name = 'P_plat';                
                case features.PLATFORM_SURROUNDINGS
                    name = 'S_plat';              
                case features.LONGEST_LOOP
                    name = 'L_max';
                otherwise                    
                    error('Ouch!');
            end
        end
    end
end
