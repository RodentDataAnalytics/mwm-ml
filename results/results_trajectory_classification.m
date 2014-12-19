function results_trajectory_classification
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/cm_and_cb_utilities'));
        
    %%  load all trajectories and compute feature values if necessary (data is then cached)
    global g_trajectories_strat_distr_norm;
    global g_trajectories_strat;
    global g_trajectories;
    global g_trajectories_punknown;
    global g_segments;
    global g_segments_classification;
    global g_long_trajectories_map;
    global g_partitions;
    
    cache_trajectories_classification;
       
    strat_distr = g_segments.classes_mapping_ordered(g_segments_classification, -1);

    ids = [1, 1, 57; 1, 1, 6; 3, 1, 4; 1, 2, 48; 1, 1, 55; 1, 3, 41; 2, 3, 17; 2, 2, 4];
    
    cm = g_config.CLASSES_COLORMAP;
    % rescale colormap    
    if size(cm, 1) > g_segments_classification.nclasses
        cm = cmapping(g_segments_classification.nclasses, cm);
    end
    
    for i = 1:size(ids, 1)
        idx = -1;
        for j = 1:g_trajectories.count
            if g_trajectories.items(j).set == ids(i, 1) && ... 
               g_trajectories.items(j).session == ids(i, 2) && ...
               g_trajectories.items(j).track == ids(i, 3)           
                idx = j;
                break;
            end
        end
        
        fprintf('\nTrajectory %d / %d / %d: ', ids(i,1), ids(i,2), ids(i,3));        
        
        for j = 1:length(g_trajectories_strat)
            if g_trajectories_strat_distr_norm(idx, j) > 0
                fprintf('%s: %f%% ', g_trajectories_strat(j).abbreviation, g_trajectories_strat_distr_norm(idx, j));
            end
        end    
        
        fprintf('UNK: %f%%', g_trajectories_punknown(idx));
                
        % segments
        nseg = g_partitions(idx);
        seg0 = 1;
        if idx > 1
            s = cumsum(g_partitions);        
            seg0 = s(idx - 1);
        end
        
        distr = strat_distr(g_long_trajectories_map(idx), :);
        
        % plot trajectory
        figure;            
        for j = 1:nseg
            clr = [0 0 0];
            if distr(j) > 0
                clr = cm(distr(j), :);
            end            
            if j == 1
                g_segments.items(seg0 + j - 1).plot('Color', clr);
            else
                g_segments.items(seg0 + j - 1).plot('Color', clr, 'DrawArena', 0);
            end
            hold on;
        end    
        close;
    end
    
%     % plot clusters    
%     featgrp = [ 1, 2, 3; 2, 3, 4 ];
%     for i = 1:length(featgrp)        
%         featidx = featgrp(i, :);
%         subplot(3, 3, 1);
%         plot_clusters(g_seg_features(:, featidx(3)), g_seg_features(:, featidx(1)), idx);
%         subplot(3, 3, 2);
%         plot_clusters(g_seg_features(:, featidx(3)), g_seg_features(:, featidx(2)), idx);
%         subplot(3, 3, 4);
%         plot_clusters(g_seg_features(:, featidx(2)), g_seg_features(:, featidx(1)), idx);
%         subplot(3, 3, 6);
%         plot_clusters(g_seg_features(:, featidx(2)), g_seg_features(:, featidx(3)), idx);
%         subplot(3, 3, 8);
%         plot_clusters(g_seg_features(:, featidx(1)), g_seg_features(:, featidx(2)), idx);
%         subplot(3, 3, 9);
%         plot_clusters(g_seg_features(:, featidx(1)), g_seg_features(:, featidx(3)), idx);
%     end    
end


function plot_clusters(X, Y, mapping)    
    pointtypes = {'+r', 'og', '*b', '.c', 'xm', 'sy', 'dk'};
    % classesname = {'thigmotaxis', 'incursion', 'circling', 'chained response', 'scanning-centre', 'scanning-target', 'focused-search'};
    for i = 1:7
        pos = find(mapping == i);        
        plot(X(pos), Y(pos), pointtypes{i});
        hold on;
    end
    legend('thigmotaxis', 'incursion', 'circling', 'chained response', 'scanning-centre', 'scanning-target', 'focused-search');
    hold off;
end    
    
