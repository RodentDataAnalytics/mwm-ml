function browse_set(set_num, set_comp, varargin)
    global g_config;
    global g_trajectories;
    cache_trajectories;

    param = g_config.TAGS_CONFIG{set_num};    
    if param{3} > 0
        segments = g_trajectories.partition(param{3}, param{4}, param{5:end});        
    else
        segments = g_trajectories;
    end
    ref_res = [];
    if set_comp > 0
        % comparision set
        param_comp = g_config.TAGS_CONFIG{set_comp};
        if param_comp{3} > 0
            segments_comp = g_trajectories.partition(param_comp{3}, param_comp{4}, param_comp{5:end});
        end
        % get classifier object
        classif = segments_comp.classifier(param_comp{1}, g_config.DEFAULT_FEATURE_SET, g_config.TAG_TYPE_BEHAVIOUR_CLASS);        
        % classify'em
        ref_res = classif.cluster(param_comp{4}, 0);            
    end
    
    browse_trajectories(param{1}, segments, 'ReferenceClassification', ref_res, varargin{:});    
end    