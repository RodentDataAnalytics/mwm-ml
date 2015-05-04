function results_trajectory_classification_nencki
    addpath(fullfile(fileparts(mfilename('fullpath')), '../../extern/cm_and_cb_utilities'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../../extern/export_fig'));  
    addpath(fullfile(fileparts(mfilename('fullpath')), '../../extern/legendflex'));
      
    %%  load all trajectories and compute feature values if necessary (data is then cached)
    global g_config;
    global g_trajectories;    
    global g_segments;
    global g_segments_classification;        
    global g_partitions;
    
    cache_trajectories_classification;
       
    fprintf('\nCOVERAGE: %.2f | UNKNOWN: %.2f', g_segments_classification.coverage()*100, g_segments_classification.punknown*100);
    
    % load the full trajectories
    % strat_distr = g_segments_classification.classes_distribution(g_segments.partitions, 'DiscardUnknown', 1, 'Normalize', 1);
    
    strat_distr = g_segments_classification.mapping_ordered('DiscardUnknown', 1, 'MinSegments', 4);
    
    
    for i = 1:g_segments_classification.nclasses
        fprintf('\nClass %d = %s', i, g_segments_classification.classes(i).description);
    end

    param_short = config_mwm_nencki_short.TAGS_CONFIG{2};
    
    [full_labels_data, full_tags] = g_trajectories.read_tags(param_short{1}, config_mwm_nencki_short.TAG_TYPE_BEHAVIOUR_CLASS);
    full_map = g_trajectories.match_tags(full_labels_data, full_tags);            
    
    f = fopen('/tmp/class.csv', 'w');

    for i = 1:length(full_tags)
        fprintf(f, '\nColumn %d = %s', i + 2, full_tags(i).description);
    end

    for i = 1:g_segments_classification.nclasses
        fprintf(f, '\nColumn %d = %s', i + 2 + length(full_tags), g_segments_classification.classes(i).description);
    end
    
    idx = 1;

    part = g_segments.partitions;
    for i = 1:g_trajectories.count        
        id = g_trajectories.items(i).identification;
        fprintf(f, '\n%d,%d', id(2), id(3));
        for j = 1:size(full_map, 2)
            fprintf(f, ',');
            fprintf(f, '%d', full_map(i, j));
        end
        if part(i) > 0                       
            tot = [];
            for j = 1:6
                tot = [tot, sum(strat_distr(idx, :) == j)];
            end
            ntot = sum(tot);
            for j = 1:6
                fprintf(f, ',');
                fprintf(f, '%.2f', tot(j)/ntot);
            end
            idx = idx+1;
        else
            fprintf(f, ',0,0,0,0,0,0');
        end
    end
    fclose(f);
end