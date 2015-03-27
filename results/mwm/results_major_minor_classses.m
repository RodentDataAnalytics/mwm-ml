function results_major_minor_classes
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));      
    
    %%  load all trajectories and compute feature values if necessary (data is then cached)
    global g_segments_base_classification;
    global g_config;
    
    cache_trajectories_classification;
    
    for iter = 1:2
        fprintf('\n*****************');
        % 1: results giving all classes the same weight
        w = ones(1, g_segments_base_classification.nclasses);
        if iter == 1
            strat_distr = g_segments_base_classification.mapping_ordered('DiscardUnknown', 1, 'MinSegments', 1, 'ClassesWeights', w);
        else
            strat_distr = g_segments_base_classification.mapping_ordered('DiscardUnknown', 1, 'MinSegments', 1);
        end
        
        vals = arrayfun( @(x) [], 1:g_segments_base_classification.nclasses, 'UniformOutput', 0);
        % do now the other classifications
        for i = 1:size(strat_distr, 1)
            c = strat_distr(i, 1);
            ci = 1;
            for j = 2:size(strat_distr, 2)
                cc = strat_distr(i, j);
                if cc ~= c                
                    if c <= 0
                        c = cc;
                        ci = j;
                    elseif cc == -1
                        % last probably
                        if j - ci > 1                            
                            vals{c} = [vals{c}, j - ci - 1];                            
                        end
                        break;
                    elseif cc > 0 && c > 0
                        % real change
                        if j - ci > 1                                                    
                            vals{c} = [vals{c}, j - ci - 1];
                        end
                        c = cc;
                        ci = j;
                    end
                end
            end
        end

        fac = g_config.DEFAULT_SEGMENT_LENGTH*(1 - g_config.DEFAULT_SEGMENT_OVERLAP);
        % show'em, will ya?
        for i = 1:g_segments_base_classification.nclasses
            fprintf('\n%s: %.2f (max: %d)', g_segments_base_classification.classes(i).description, fac*mean(vals{i}), fac*max(vals{i}));        
        end
    end
end