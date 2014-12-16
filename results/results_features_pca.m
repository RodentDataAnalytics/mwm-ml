function results_features_pca
    feat = g_config.FULL_FEATURE_SET;
    
    global g_trajectories; % loaded thru the function bellow that caches trajectories
    cache_trajectories;
   
    % segment trajectories - ones with less than 2 segments will be discarded
    [seg, partitions] = g_trajectories.divide_into_segments(g_config.DEFAULT_SEGMENT_LENGTH, g_config.DEFAULT_SEGMENT_OVERLAP, 2);
    feat_val = seg.compute_features(feat);

    n = seg.count;
    m = length(features);

    % subtract the mean
    means = repmat(mean(feat_val), n, 1);
    stddev = repmat(std(feat_val), n, 1);
    % feat_val = feat_val - means;
    
    % feat_val = (feat_val - means) ./ stddev;
    feat_val = feat_val ./ repmat( sqrt(sum(feat_val.^2)), n, 1);
    
    for i = 1:length(feat)
        fprintf('Feature %d: %s\n', i, features.feature_name(feat(i)));
    end
    
    % compute covariance matrix and eigenvalues/eigenvectors
    C = cov(feat_val);
    [V, lam] = eig(C);
    lam = diag(lam);
    [lam, idx] = sort(lam, 'descend');    
    V = V(:,idx)
    mean(abs(V), 2)
