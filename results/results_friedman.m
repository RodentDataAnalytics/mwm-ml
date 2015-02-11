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
    global g_trajectories_session;
    global g_partitions;
    global g_animals_trajectories_map;
    global g_trajectories_latency;
    global g_trajectories_length;
    
    % classify trajectories
    cache_trajectories_classification; 
        
    % bins = [30, 60];    
    bins = repmat(6, 1, 15);
    
    classes = g_config.REDUCED_BEHAVIOURAL_CLASSES;
    
    % classes = g_segments_classification.classes; 
    strat_distr = g_segments_classification.mapping_ordered(-1, 'Classes', classes, 'DiscardUnknown', 0, 'MinSegments', 6);    
    % strat_distr = g_segments_classification.classes_mapping_time(bins, 'Classes', classes, 'DiscardUnknown', 1, 'MinSegments', 4, 'ClassesWeights', [1 1 2 5 5 5 1 5]);    
    
    % count animals
    nanimals = 20;
    % 27; % sum(g_trajectories_trial(g_long_trajectories_idx) == 1);    
    
    for c = 1:length(classes)            
       % for b = 1:length(bins)        
            % construct matrix for the Friedman test
            m = zeros(g_config.TRIALS*nanimals, 2);                        
            for t = 1:g_config.TRIALS      
                for g = 1:2                                        
                    sel = find( g_trajectories_trial == t & g_trajectories_group == g);
                    [~, sorting] = sort(g_trajectories_length(sel), 'Descend');
                    
                    for i = 1:nanimals
                        %if g_long_trajectories_map(sel(i)) > 0 && g_trajectories_latency(sel(i)) > 10
                             nseg = g_partitions(sel(sorting(i)));
                             seg0 = 1;
                             if sel(sorting(i)) > 1
                                 s = cumsum(g_partitions);        
                                 seg0 = s(sel(sorting(i)) - 1);
                             end
                             lasti = 1;
%                              for k = seg0:(seg0 + nseg)
%                                  if g_segments.items(k).start_time > 12
%                                      nseg = k - seg0 + 1;
%                                      break;
%                                  end
%                              end
%                             
                            tmp = g_segments_classification.class_map(seg0:seg0 + nseg); % g_long_trajectories_map(sel(i)), :);                                                        
                            %m((t - 1)*n + i, g) = sum(find(tmp(1:lasti) == c)) / sum(find(tmp(1:lasti) > 0));         
                          %  if sum(find(tmp > 0))
                           %     m((t - 1)*n + i, g) = sum(find(tmp  == c)) / sum(find(tmp > 0));                                                     
                            %end
                            if sum(find(tmp > 0))
                                 m((t - 1)*nanimals + i, g) = sum(tmp  == c) / sum(tmp > 0);                                                     
                            end                            
                        end
                   % end
                end                
            end

            % run friedman test            
            p = friedman(m, nanimals);
            pa = anova2(m, nanimals);
            str = sprintf('Class: %s\tSection: %d\tp_frdm: %g\tp_anova: %g', classes(c).description, 1, p, pa);
            disp(str);
            % export_fig(fullfile(g_config.OUTPUT_DIR, sprintf('control_stress_evol_s%d_b%d.eps', s, b)));
        end
  %  end   
  
 %   g_animals_trajectories_map
  
   for c = 1:length(classes)            
       % for b = 1:length(bins)        
            % construct matrix for the Friedman test
            m = zeros(g_config.SESSIONS*nanimals, 2);                        
            for ses = 1:g_config.SESSIONS
                for g = 1:2                                                            
                    map = g_animals_trajectories_map{g};
                                        
                    for i = 1:nanimals 
                        tot = 0;
                        n = 0;
                        for j = (ses - 1)*4 + 1:4*ses                        
                            if g_long_trajectories_map(map(j, i)) > 0 && g_trajectories_length(map(j, i)) > 1000
                                nseg = g_partitions(map(j, i));
                                seg0 = 1;
                                if map(j, i) > 1
                                    s = cumsum(g_partitions);        
                                    seg0 = s(map(j, i) - 1);
                                end
                            
                                tmp = g_segments_classification.class_map(seg0:seg0 + nseg); % g_long_trajectories_map(sel(i)), :);                                                        
                            
                                tot = tot + sum(tmp  == c);
                                n = n + sum(tmp > 0);
                            end                            
                        end
                        if n > 0
                            m((ses - 1)*nanimals + i, g) = tot / n;
                        end
                    end
                end                
            end

            % run friedman test            
            p = friedman(m, nanimals);
            pa = anova2(m, nanimals);
            str = sprintf('Class: %s\tSection: %d\tp_frdm: %g\tp_anova: %g', classes(c).description, 1, p, pa);
            disp(str);
            % export_fig(fullfile(g_config.OUTPUT_DIR, sprintf('control_stress_evol_s%d_b%d.eps', s, b)));
        end
end

