function [ nbest, res ] = results_number_clusters( set_num, ni, inc, nf, varargin)
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern'));
    [max_error, testp] = process_options(varargin, ...
        'MaximumError', 0.015, 'TestingGroup', 0.0);
    
    global g_trajectories;
    cache_trajectories;

    param = g_config.TAGS_CONFIG{set_num};
    segments = g_trajectories.divide_into_segments(param{2}, param{3}, 2);    
    classif = segments.classifier(param{1}, g_config.DEFAULT_FEATURE_SET, g_config.TAG_TYPE_BEHAVIOUR_CLASS);        
    
    nbest = 0;
    res = [];
    best_cov = 0;
    for n = ni:inc:nf
        new_res = classif.cluster(n, testp);
        if new_res.coverage > best_cov && new_res.perrors <= max_error
            best_cov = new_res.coverage;
            nbest = n;
        end
        fprintf('\nN = %d clusters, coverage: %.3f, error: %.3f', n, new_res.coverage, new_res.perrors);
        res = [res, new_res];
    end
end