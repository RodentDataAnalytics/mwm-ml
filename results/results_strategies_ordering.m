function results_strategies_ordering
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));    
    addpath(fullfile(fileparts(mfilename('fullpath')), '../'));
    
    % global data initialized elsewhere
    global g_segments_classification;
    global g_long_trajectories_idx;
    global g_segments;
        
    % classify trajectories
    cache_trajectories_classification; 

    bins = repmat(1, 1, 90);
    nbins = length(bins);

    %[strat_distr, full_strat_distr] = g_segments.classes_mapping_time(g_segments_classification, bins, 'Classes', classes);
    strat_distr = g_segments.classes_mapping_time(g_segments_classification, bins);

    nbins_count = 3;
    
    counts = zeros(1, g_segments_classification.nclasses);
    for i = 1:size(strat_distr, 1)
        for j = 1:size(strat_distr, 2)
            if strat_distr(i, j) == -1
                for k = 1:min((j - 1), nbins_count)
                    if strat_distr(i, j - k) > 0
                        counts(strat_distr(i, j - k)) = counts(strat_distr(i, j - k)) + 1;
                    end
                end    
                break;
            end
        end
    end
          
    msg = 'COUNTS: \n';
    for i = 1:g_segments_classification.nclasses
        msg = [msg g_segments_classification.classes(i).description ': ' num2str(counts(i)) '\n'];
    end    
    fprintf(msg);    
end