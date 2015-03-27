function results_agreement
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));          
    global g_config;
    
    %%  load all trajectories and compute feature values if necessary (data is then cached)
    global g_trajectories;    
    cache_trajectory_segments;
                           
    mapping = {};
    segments = {};
    l = [];
    tags = [];

    % do now the other classifications
    for i = 2:length(g_config.TAGS_CONFIG)
        param = g_config.TAGS_CONFIG{i};
        l = [l, param{2}];
        seg = g_trajectories.divide_into_segments(param{2}, param{3}, 2);
        segments = [segments, seg];
        % get classifier object
        classif = seg.classifier(param{1}, g_config.DEFAULT_FEATURE_SET, g_config.TAG_TYPE_BEHAVIOUR_CLASS);        
        % classify'em
        res = classif.cluster(param{4}, 0);
        tags = [tags; res.classes];
        %[~, ~, map] = res.mapping_ordered(-1, 'DiscardUnknown', 1, 'MinSegments', 1);
        % mapping = [mapping, map];
        mapping = [mapping, res.class_map];
    end
    
    for r1 = 1:length(mapping)
        for r2 = (r1 + 1):length(mapping)            
            % map segments
            seg1 = segments(r1);            
            seg2 = segments(r2);
            tag1 = tags(r1, :);
            tag2 = tags(r2, :);
            
            len_diff = l(r2) - l(r1);        
   
            % compute the mapping of the segments1 -> segments2    
            seg_map = seg1.match_segments(seg2, 'SegmentDistance', len_diff/2, 'Tolerance', 25, 'LengthTolerance', len_diff + 25);
            tag_map = tag.mapping(tag1, tag2);
                            
            % compare all pairs of results now
            tot = 0;
            match = 0;
            m1 = mapping{r1};
            m2 = mapping{r2};
            for i = 1:length(m1)
                j = seg_map(i);
                if j > 0                    
                    if m1(i) > 0 && m2(j) > 0                      
                        if tag_map(m1(i)) == m2(j)
                            match = match + 1;                        
                        elseif i > 1 && m1(i - 1) > 0 && tag_map(m1(i - 1)) == m2(j)
                            match = match + 1;
                        elseif i < length(m1) - 1 && m1(i + 1) > 0 && tag_map(m1(i + 1)) == m2(j)
                            match = match + 1;
                        end
                        tot = tot + 1;                    
                    end
                end                
            end
            fprintf('\nAGREEMENT %d x %d: %.3f', r1, r2, match/tot);
        end
    end               
end