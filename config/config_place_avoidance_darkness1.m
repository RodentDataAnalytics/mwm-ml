classdef config_place_avoidance_darkness1 < config_place_avoidance
    % config_mwm Global constants
    properties(Constant)        
        
        TAGS_CONFIG = { ... % values are: file that stores the tags, segment length, overlap, default number of clusters
            { '/home/tiago/neuroscience/place_avoidance/labels_darkness_full.csv', 0, 0}, ...
            { '/home/tiago/neuroscience/place_avoidance/labels_darkeness.csv', 10, config_place_avoidance.SEGMENTATION_PLACE_AVOIDANCE, 1, config_place_avoidance.SECTION_AVOID, 6} ...
        };
        SESSIONS = 6;  
        TRIALS_PER_SESSION = 2*ones(1, config_place_avoidance_darkness1.SESSIONS);
        TRIALS = 12;
        TRIAL_TYPE = ones(1, 12); 
        GROUPS = 2;        
        GROUPS_DESCRIPTION = { ...
            'Darkness -> Light', ...
            'Light -> Darkness', ...                    
        };
        SHOCK_AREA_ANGLE = pi/180*225*ones(1, config_place_avoidance_darkness1.SESSIONS);                         
    end   
        
    methods        
        function inst = config_place_avoidance_darkness1()            
            inst@config_place_avoidance('Place avoidance task (darkness trials)');                                   
        end
               
        % Imports trajectories from Noldus data file's
        function traj = load_data(inst)
            addpath(fullfile(fileparts(mfilename('fullpath')),'../import/place_avoidance'));

            base_folder = '/home/tiago/place_avoidance/darkness/';
            
            %%
            %% darkness -> light rats
            %%
            
            % darkness
            new_traj = load_trajectories([base_folder 'dark_vs_rot_lit'], 1, 'FilterPattern', '*drsc*Arena*.dat', ...
                                         'IdDayMask', 'd%ddrscr%d', 'ReverseDayId', 1);
            % correct trial numbers
            track = 1;
            for t = 1:new_traj.count
                new_traj.items(t).set_trial( new_traj.items(t).trial*2 - 1, config_place_avoidance.TRIAL_TYPE_PAT_DARKNESS);
                new_traj.items(t).set_track( track );
                track = track + 1;
            end                        
            
            traj = new_traj;
            
            % light
            new_traj = load_trajectories([base_folder 'dark_vs_rot_lit'], 1, 'FilterPattern', '*lrsc*Arena*.dat', ...
                                         'IdDayMask', 'd%dlrscr%d', 'ReverseDayId', 1);
            % correct trial numbers
            for t = 1:new_traj.count
                new_traj.items(t).set_trial( new_traj.items(t).trial*2, config_place_avoidance.TRIAL_TYPE_APAT_TRAINING );
                new_traj.items(t).set_track( track );
                track = track + 1;
            end                    
            traj = traj.append(new_traj);
                        
            %%
            %% light -> darkness rats
            %%
            
            % light
            new_traj = load_trajectories([base_folder 'rot_lit_vs_dark'], 2, 'FilterPattern', '*lrsc*Room*.dat', ...
                                         'IdDayMask', 'd%dlrscr%d', 'ReverseDayId', 1);            
            for t = 1:new_traj.count
                new_traj.items(t).set_trial( new_traj.items(t).trial*2 - 1, config_place_avoidance.TRIAL_TYPE_APAT_TRAINING );
                new_traj.items(t).set_track( track );
                track = track + 1;
            end                        
            
            traj = traj.append(new_traj);
            
            % darkness
            new_traj = load_trajectories([base_folder 'rot_lit_vs_dark'], 2, 'FilterPattern', '*drsc*Room*.dat', ...
                                         'IdDayMask', 'd%ddrscr%d', 'ReverseDayId', 1);            
            for t = 1:new_traj.count
                new_traj.items(t).set_trial( new_traj.items(t).trial*2, config_place_avoidance.TRIAL_TYPE_PAT_DARKNESS );
                new_traj.items(t).set_track( track );
                track = track + 1;
            end      

            traj = traj.append(new_traj);            
        end        
    end
end