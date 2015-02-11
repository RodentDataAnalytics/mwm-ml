function browse_set(set_num, set_comp)
    global g_trajectories;
    cache_trajectories;

    param = g_config.TAGS_CONFIG{set_num};    
    if param{2} > 0 && param{3} > 0
        segments = g_trajectories.divide_into_segments(param{2}, param{3}, 2);
    else
        segments = g_trajectories;
    end
    ref_res = [];
    if set_comp > 0
        % comparision set
        param_comp = g_config.TAGS_CONFIG{set_comp};
        segments_comp = g_trajectories.divide_into_segments(param_comp{2}, param_comp{3}, 2);
        % get classifier object
        classif = segments_comp.classifier(param_comp{1}, g_config.DEFAULT_FEATURE_SET, g_config.TAG_TYPE_BEHAVIOUR_CLASS);        
        % classify'em
        ref_res = classif.cluster(param_comp{4}, 0);            
    end
       
%     off = 0;
%     sel = zeros(1, length(g_partitions));
%     for i = 1:length(g_partitions)
%         off = off + g_partitions(i);
%         sel(i) = off;  
%     end
%     sel = sel(g_trajectories_latency < g_config.TRIAL_TIMEOUT);
    
    browse_trajectories(param{1}, segments, 'ReferenceClassification', ref_res);    