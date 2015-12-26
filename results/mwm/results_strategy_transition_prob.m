function results_strategy_transition_prob
%RESULTS_STRATEGY_TRANSITION_PROB Summary of this function goes here
%   Detailed explanation goes here
    addpath(fullfile(fileparts(mfilename('fullpath')), '../../extern/cm_and_cb_utilities'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../../extern/legendflex'));
      
    %%  load all trajectories and compute feature values if necessary (data is then cached)
    global g_trajectories;    
    global g_segments_classification;
    global g_partitions;
    global g_long_trajectories_map;
    global g_trajectories_group;
    
    cache_trajectories_classification;
        
    strat_distr = g_segments_classification.mapping_ordered(-1, 'DiscardUnknown', 1, 'MinSegments', 4);

    % create 2 matrices
    nc = g_segments_classification.nclasses;
    trans_prob1 = zeros(nc, nc);
    trans_prob2 = zeros(nc, nc);
    
    traj_idx = 1;
    nseg = 0;
    prev_class = -1;
    while traj_idx <= g_trajectories.count
        if nseg >= g_partitions(traj_idx)
            traj_idx = traj_idx + 1;
            nseg = 0;
            prev_class = -1;
            continue;
        end       
        nseg = nseg + 1;

        new_class = strat_distr(g_long_trajectories_map(traj_idx), nseg);
        if prev_class == -1
            prev_class = new_class;
        elseif prev_class ~= new_class
            % we have a transition
            if new_class > 0 && prev_class > 0
                if g_trajectories_group(traj_idx) == 1                    
                    trans_prob1(prev_class, new_class) = trans_prob1(prev_class, new_class) + 1; 
                else
                    trans_prob2(prev_class, new_class) = trans_prob2(prev_class, new_class) + 1; 
                end
            end
            new_class = prev_class;
        end                                
    end
    % normalize matrices
    trans_prob1 = trans_prob1 ./ repmat(sum(trans_prob1, 2), 1, nc);
    trans_prob2 = trans_prob2 ./ repmat(sum(trans_prob2, 2), 1, nc);
    
    for i = 1:g_segments_classification.nclasses
        fprintf('\nClass %d: %s', i, g_segments_classification.classes(i).description);
    end
    figure;    
    trans_prob1
    imagesc(trans_prob1);
    figure;
    imagesc(trans_prob2);    
    trans_prob2
    
end

