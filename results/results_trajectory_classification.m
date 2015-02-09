function results_trajectory_classification
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/cm_and_cb_utilities'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));  
        
    %%  load all trajectories and compute feature values if necessary (data is then cached)
    global g_trajectories;    
    global g_segments;
    global g_segments_classification;
    global g_long_trajectories_map;
    global g_partitions;
    
    cache_trajectories_classification;
       
    w = 6;
    nbins = ceil(90/w);
    bins = repmat(w, 1, nbins);
    class_w = [1 1 1 10 10 10 1 10]; 
    strat_distr = g_segments.classes_mapping_ordered(g_segments_classification, -1, 'DiscardUnknown', 1, 'MinSegments', 4, 'ClassesWeights', class_w);
    ids = [2, 2, 19; 1, 1, 57; 1, 1, 6; 3, 1, 4; 1, 2, 48; 1, 1, 55; 1, 3, 41; 2, 3, 17; 2, 2, 4];
    ls = {'-','--',':','-', '-', '-',':', '-'};
    lvl = [0, 0, 0.3, 0.5, 0.5, 0.5, 0, 0.2];
    lw = [1, 1, 1, 1.5, 1.5, 1.5, 1, 2];
    
    cm = g_config.CLASSES_COLORMAP;
    % rescale colormap    
    if size(cm, 1) > g_segments_classification.nclasses
        cm = cmapping(g_segments_classification.nclasses + 1, cm);
    end
    
    for i = 1:size(ids, 1)
        idx = 0;
        for j = 1:g_trajectories.count
            if g_long_trajectories_map(j) == 0
                continue;
            end
            if g_trajectories.items(j).set == ids(i, 1) && ... 
               g_trajectories.items(j).session == ids(i, 2) && ...
               g_trajectories.items(j).track == ids(i, 3)           
                    idx = j;
                    break;
            end            
        end
        
        fprintf('\nTrajectory %d / %d / %d: ', ids(i,1), ids(i,2), ids(i,3));        
        
        for j = 1:g_segments_classification.nclasses
            p = (sum(strat_distr(idx, :) == j) / nbins);
            if p > 0
                fprintf('%s: %f%% ', g_segments_classification.classes(j).abbreviation, p*100);
            end
        end    
        
        % fprintf('UNK: %f%%', g_trajectories_punknown(idx));
                
        % segments
        nseg = g_partitions(idx);
        seg0 = 1;
        if idx > 1
            s = cumsum(g_partitions);        
            seg0 = s(idx - 1);
        end
        
        distr = strat_distr(g_long_trajectories_map(idx), :);
        
        vals = g_segments_classification.class_map(seg0:seg0 + nseg);
        
        % plot trajectory
        
        figure;            
        % draw arena
        axis off;
        daspect([1 1 1]);                      
        rectangle('Position',[g_config.CENTRE_X - g_config.ARENA_R, g_config.CENTRE_X - g_config.ARENA_R, g_config.ARENA_R*2, g_config.ARENA_R*2],...
            'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3);
        hold on;
        axis square;
        rectangle('Position',[g_config.PLATFORM_X - g_config.PLATFORM_R, g_config.PLATFORM_Y - g_config.PLATFORM_R, 2*g_config.PLATFORM_R, 2*g_config.PLATFORM_R],...
            'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3); 

        lastc = distr(j);
        lasti = 1;
        x = [];
        y = [];
        for j = 2:nseg
            p = 0;
            
            if distr(j) ~= lastc || j == nseg
                lastc = distr(j);
                p = 1;
            end
                    
            if p
                starti = g_segments.items(seg0 + lasti).start_index;
                endi = g_segments.items(seg0 + j).start_index;
                if distr(j - 1) > 0                    
                    clr = [1 1 1] * lvl(distr(j - 1));
                    lspec = ls{distr(j - 1)};
                    w = 2 * lw(distr(j - 1));
                else
                    clr = [0.7 0.7 0.7];
                    lspec = ':';
                    w = 1.5;
                end
                plot(g_trajectories.items(idx).points(starti:endi, 2), g_trajectories.items(idx).points(starti:endi, 3), lspec, 'LineWidth', w, 'Color', clr);
                lasti = j;                
            end            
        end   
        set(gca, 'LooseInset', [0,0,0,0]);
        set(gcf, 'Color', 'w');
            
        export_fig(fullfile(g_config.OUTPUT_DIR, sprintf('trajectory_detailed_%d.eps', i)));
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
    
