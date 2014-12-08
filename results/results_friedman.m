function results_friedman
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));  
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/sigstar'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../'));

    % global data initialized elsewhere
    global g_segments_classification;
    global g_trajectories_trial;        
    global g_trajectories_group;          
    global g_animals_trajectories_map;
    global g_long_trajectories_map;
    global g_segments;
    global g_long_trajectories_idx;
    
    % classify trajectories
    cache_trajectories_classification; 
        
    bins = [90]; % [20, 25, 45];    
    % bins = [90];
    
    % classes = constants.REDUCED_BEHAVIOURAL_CLASSES;
    classes = g_segments_classification.classes; 
    [~, full_strat_distr] = g_segments.classes_mapping_time(g_segments_classification, bins, 'Classes', classes, 'DiscardUnknown', 0);
    
    % count animals
    n = sum(g_trajectories_trial(g_long_trajectories_idx) == 1);
    
    for c = 1:length(classes)            
        for b = 1:length(bins)        
            % construct matrix for the Friedman test
            m = zeros(constants.TRIALS*n, 2);                        
            for t = 1:constants.TRIALS      
                for g = 1:2                    
                    sel = find( g_trajectories_trial(g_long_trajectories_idx) == t & g_trajectories_group(g_long_trajectories_idx) == g);                
                    for i = 1:length(sel)                        
                        tmp = full_strat_distr{sel(i)};
                        if tmp(b, c) ~= -1
                            m((t - 1)*n + i, g) = tmp(b, c);
                        end
                    end
                end                
            end

            % run friedman test            
            p = friedman(m, n);
            pa = anova2(m, n);
            str = sprintf('Class: %s\tSection: %d\tp_frdm: %g\tp_anova: %g', classes(c).description, b, p, pa);
            disp(str);
            % export_fig(fullfile(constants.OUTPUT_DIR, sprintf('control_stress_evol_s%d_b%d.eps', s, b)));
        end
    end   
        
    for c = 1:length(classes)
        for b = 1:length(bins)        
            % construct matrix for the Friedman test
            m = zeros(constants.SESSIONS*n, 2);            
            for s = 1:constants.SESSIONS                          
                for g = 1:2                    
                    map = g_animals_trajectories_map{g};
                    sel = map( (s - 1)*constants.TRIALS_PER_SESSION + 1 : s*constants.TRIALS_PER_SESSION, :);
                    for i = 1:size(sel, 2)      
                        val = 0;
                        nval = 0;
                        for t = 1:size(sel, 1)          
                            if g_long_trajectories_map(sel(t, i)) ~= 0                                
                                tmp = full_strat_distr{g_long_trajectories_map(sel(t, i))};
                                if tmp(b, c) ~= -1                            
                                    val = val + tmp(b, c);
                                    nval = nval + 1;
                                end
                            end
                        end
                        if nval > 0
                            val = val / nval;
                            m((s - 1)*n + i, g) = val;                            
                        end
                    end
                end                
            end

            % run friedman test            
            p = friedman(m, n);
            pa = anova2(m, n);
            str = sprintf('Class: %s\tSection: %d\tp_frdm: %g\tp_anova: %g', classes(c).description, b, p, pa);
            disp(str);
            % export_fig(fullfile(constants.OUTPUT_DIR, sprintf('control_stress_evol_s%d_b%d.eps', s, b)));
        end
    end   
end

