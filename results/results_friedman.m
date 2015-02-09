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
    global g_partitions;
    
    % classify trajectories
    cache_trajectories_classification; 
        
    % bins = [30, 60];    
    bins = repmat(6, 1, 15);
    
    classes = g_config.REDUCED_BEHAVIOURAL_CLASSES;
    
    % classes = g_segments_classification.classes; 
    % strat_distr = g_segments.classes_mapping_ordered(g_segments_classification, -1, 'Classes', classes, 'DiscardUnknown', 1, 'MinSegments', 4, 'ClassesWeights', [1 1 2 5 5 5 1 5]);    
    strat_distr = g_segments.classes_mapping_time(g_segments_classification, bins, 'Classes', classes, 'DiscardUnknown', 1, 'MinSegments', 4, 'ClassesWeights', [1 1 2 5 5 5 1 5]);    
    
    % count animals
    n = 27; % sum(g_trajectories_trial(g_long_trajectories_idx) == 1);
    
    for c = 1:length(classes)            
       % for b = 1:length(bins)        
            % construct matrix for the Friedman test
            m = zeros(g_config.TRIALS*n, 2);                        
            for t = 1:g_config.TRIALS      
                for g = 1:2                                        
                    sel = find( g_trajectories_trial == t & g_trajectories_group == g);                
                    
                    for i = 1:n                                 
                        if g_long_trajectories_map(sel(i)) > 0
                             nseg = g_partitions(sel(i));
                             seg0 = 1;
                             if sel(i) > 1
                                 s = cumsum(g_partitions);        
                                 seg0 = s(sel(i) - 1);
                             end
%                             lasti = 1;
%                             for k = seg0:(seg0 + nseg)
%                                 if g_segments.items(k).start_time > 50
%                                     lasti = k - seg0 + 1;
%                                     break;
%                                 end
%                             end
                            
                            tmp = g_segments_classification.class_map(seg0:seg0 + nseg); % g_long_trajectories_map(sel(i)), :);                                                        
                            %m((t - 1)*n + i, g) = sum(find(tmp(1:lasti) == c)) / sum(find(tmp(1:lasti) > 0));         
                          %  if sum(find(tmp > 0))
                           %     m((t - 1)*n + i, g) = sum(find(tmp  == c)) / sum(find(tmp > 0));                                                     
                            %end
                            if sum(find(tmp > 0))
                                 m((t - 1)*n + i, g) = sum(find(tmp  == c)) / sum(find(tmp > 0));                                                     
                            end                            
                        end
                    end
                end                
            end

            % run friedman test            
            p = friedman(m, n);
            pa = anova2(m, n);
            str = sprintf('Class: %s\tSection: %d\tp_frdm: %g\tp_anova: %g', classes(c).description, 1, p, pa);
            disp(str);
            % export_fig(fullfile(g_config.OUTPUT_DIR, sprintf('control_stress_evol_s%d_b%d.eps', s, b)));
        end
  %  end   
end

