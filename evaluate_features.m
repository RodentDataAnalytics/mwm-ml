function [ comb, res ] = evaluate_features( n, nclusters )
%RESULTS_FEATURE_SELECTION Summary of this function goes here
%   Detailed explanation goes here
    feat = g_config.FULL_FEATURE_SET;
    
    global g_trajectories; % loaded thru the function bellow that caches trajectories
    cache_trajectories;
    
    % select only trajectories from groups 1 & 2
    x = arrayfun( @(t) any([1,2] == t.group), g_trajectories.items);
    traj = trajectories(g_trajectories.items(find(x == 1)));
    
    % generate all possible combinations of features (take, say, 6
    % features)
    comb = combnk(feat, n);
    
    fprintf('Number of feature combinations to be tested: %d\n', size(comb, 1));
           
    % segment trajectories - ones with less than 2 segments will be discarded
    seg = traj.divide_into_segments(g_config.DEFAULT_SEGMENT_LENGTH, g_config.DEFAULT_SEGMENT_OVERLAP, 2);
        
    res = [];    
    for i = 1:size(comb, 1)
        [class_idx, cluster_tags, cluster_idx, cluster_map, cluster_centroids, cluster_miss] = seg.classify(g_config.SEGMENTS_TAGS320_PATH, comb(i, :), nclusters);
        % map tags from the classification to the list of trajectory
        % tags
        res = [res; length(cluster_map), sum(cluster_miss == 1 & cluster_idx ~= 0), sum(class_idx == 0)*100./seg.count];               
    end
   
    % show some information
    disp('\n*** Best feature combinations sorted by # or classificaiton errors ***');
    [~, idx] = sort(res(:, 2));
    for i = 1:size(comb, 1)        
        for j = 1:(n - 1)            
            fprintf('%s, ', features.feature_abbreviation(comb(idx(i), j)));            
        end
        fprintf('%s: %d clusters / %d errors / %.1f unknown\n', features.feature_abbreviation(comb(idx(i), n)), res(idx(i), 1), res(idx(i), 2), res(idx(i), 3));
    end
    
    disp('\n*** Best feature combinations sorted by % of undefined segments ***');
    [~, idx] = sort(res(:, 3));
    for i = 1:size(comb, 1)        
        for j = 1:(n - 1)            
            fprintf('%s, ', features.feature_abbreviation(comb(idx(i), j)));            
        end
        fprintf('%s: %d clusters / %d errors / %.1f unknown\n', features.feature_abbreviation(comb(idx(i), n)), res(idx(i), 1), res(idx(i), 2), res(idx(i), 3));
    end
end

