function results_friedman
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));  
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/sigstar'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../'));

    % global data initialized elsewhere
    global g_segments_classification;
    global g_trajectories_trial;    
    global g_long_trajectories_map;
    global g_trajectories_group;          
    global g_segments;
    
    % classify trajectories
    cache_trajectories_classification; 
        
    % bins = [30, 60];    
    bins = [90];
    
    classes = g_config.REDUCED_BEHAVIOURAL_CLASSES;
    % classes = g_segments_classification.classes; 
    [~, full_strat_distr] = g_segments.classes_mapping_time(g_segments_classification, bins, 'Classes', classes, 'DiscardUnknown', 0);
    
    % count animals
    n = 27; % sum(g_trajectories_trial(g_long_trajectories_idx) == 1);
    
    for c = 1:length(classes)            
        for b = 1:length(bins)        
            % construct matrix for the Friedman test
            m = zeros(g_config.TRIALS*n, 2);                        
            for t = 1:g_config.TRIALS      
                for g = 1:2                                        
                    sel = find( g_trajectories_trial == t & g_trajectories_group == g);                
                    
                    for i = 1:n         
                        if g_long_trajectories_map(sel(i)) > 0
                            tmp = full_strat_distr{g_long_trajectories_map(sel(i))};
                            if tmp(b, c) ~= -1
                                m((t - 1)*n + i, g) = tmp(b, c);
                            end
                        end
                    end
                end                
            end

            % run friedman test            
            p = friedman(m, n);
            pa = anova2(m, n);
            str = sprintf('Class: %s\tSection: %d\tp_frdm: %g\tp_anova: %g', classes(c).description, b, p, pa);
            disp(str);
            % export_fig(fullfile(g_config.OUTPUT_DIR, sprintf('control_stress_evol_s%d_b%d.eps', s, b)));
        end
    end   
end

