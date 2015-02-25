function copy_tags(set1, set2, p, tag_type)
    global g_trajectories;
    cache_trajectories;

    param1 = g_config.TAGS_CONFIG{set1};
    param2 = g_config.TAGS_CONFIG{set2};
    
    % compute both segmentations
    segments1 = g_trajectories.divide_into_segments(param1{2}, param1{3}, 2);
    segments2 = g_trajectories.divide_into_segments(param2{2}, param2{3}, 2);
    
    len_diff = param2{2} - param1{2};        
    
    % read labels of the source group
    [labels_data, tags] = segments1.read_tags(param1{1}, tag_type);
    mapping = segments1.match_tags(labels_data, tags);        
    
    % compute the mapping of the segments1 -> segments2    
    seg_map = segments1.match_segments(segments2, 'SegmentDistance', len_diff/2, 'Tolerance', 25, 'LengthTolerance', len_diff + 25);
    
    % set of mapped segments that could also be mapped to the second set
    sel_idx = find(sum(mapping, 2) > 0 & seg_map' > 0);
    nl = sum(sum(mapping > 0, 2));
    % select at most p*N_labels labels
    sel_idx = sel_idx(randperm(length(sel_idx), min(floor(p*nl), length(sel_idx))));
    
    % create second tags set
    mapping2 = zeros(segments2.count, length(tags));
    for i = 1:length(sel_idx)
        mapping2(seg_map(sel_idx(i)), :) = mapping(sel_idx(i), :);
    end
    segments2.save_tags(param2{1}, tags, mapping2, []);
end