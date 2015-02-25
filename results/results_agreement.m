function results_agreement
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));      
    
    %%  load all trajectories and compute feature values if necessary (data is then cached)
    global g_trajectories;    
                           
    mapping = {};
    dl = [];

    % do now the other classifications
    for i = 2:length(g_config.TAGS_CONFIG)
        param = g_config.TAGS_CONFIG{i};
        dl = [dl, param{2} * (1. - param{3})];
        segments = g_trajectories.divide_into_segments(param{2}, param{3}, 2);
        % get classifier object
        classif = segments.classifier(param{1}, g_config.DEFAULT_FEATURE_SET, g_config.TAG_TYPE_BEHAVIOUR_CLASS);        
        % classify'em
        res = classif.cluster(param{4}, 0);
        mapping = [mapping, res.mapping_ordered(-1, 'DiscardUnknown', 1, 'MinSegments', 4)];
    end
    
    % compare all pairs of results now
    for r1 = 1:length(mapping)
        for r2 = (r1 + 1):length(mapping)            
            tot = 0;
            match = 0;
            m1 = mapping{r1};
            m2 = mapping{r2};
            for i = 1:size(m1, 1)
                for j = 1:size(m1, 2)
                    j2 = floor((j - 0.5)*dl(r1) / dl(r2)) + 1;
                    if m1(i, j) > 0 && m2(i, j2) > 0
                        if m1(i, j) == m2(i, j2)
                            match = match + 1;
                        end
                        tot = tot + 1;
                    end
                end                
            end
            fprintf('\nAGREEMENT %d x %d: %.2f', r1, r2, match/tot);
        end
    end               
end