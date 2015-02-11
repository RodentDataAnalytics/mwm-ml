function results_trajectory_classification
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/cm_and_cb_utilities'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));  
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/legendflex'));
      
    %%  load all trajectories and compute feature values if necessary (data is then cached)
    global g_trajectories;    
    global g_segments;
    global g_segments_classification;
    global g_segments_base_classification;
    global g_long_trajectories_map;
    global g_partitions;
    
    cache_trajectories_classification;
       
    fprintf('\nCOVERAGE: %.2f | UNKNOWN: %.2f', g_segments_base_classification.coverage()*100, g_segments_base_classification.punknown*100);
    strat_distr = g_segments_base_classification.mapping_ordered(-1, 'DiscardUnknown', 1, 'MinSegments', 4);
    ids = [2, 2, 19; 1, 1, 57; 1, 1, 6; 3, 1, 4; 1, 2, 48; 1, 1, 55; 1, 3, 41; 2, 3, 17; 2, 2, 4; 1, 3, 78; 2, 1, 27; 2, 1, 26];
    ls = {'-','--',':',':', '--','-',':','-'};
    lclr = [ ...
        .2 .2 .2; ...
        .2 .2 .2; ...
        .2 .2 .2; ...
        .0 .6 .0; ...
        .0 .6 .0; ...
        .0 .6 .0; ...
        .9 .0 .0; ...
        .9 .0 .0 ];
    lvl = [0, 0, 0.3, 0.5, 0.5, 0.5, 0, 0.2];
    lw = [1, 1, 1, 1, 1, 1, 1, 1];
    
    for i = 1:g_segments_classification.nclasses
        fprintf('\nClass %d = %s', i, g_segments_classification.classes(i).description);
    end
    
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
                        
%         for j = 1:g_segments_classification.nclasses
%             p = (sum(strat_distr(idx, :) == j) / nbins);
%             if p > 0
%                 fprintf('%s: %f%% ', g_segments_classification.classes(j).abbreviation, p*100);
%             end
%         end    
        
        % fprintf('UNK: %f%%', g_trajectories_punknown(idx));
                
        % segments
        nseg = g_partitions(idx);
        seg0 = 1;
        if idx > 1
            s = cumsum(g_partitions);        
            seg0 = s(idx - 1);
        end
        
        fprintf('\nTrajectory %d / %d / %d, first segment %d: ', ids(i,1), ids(i,2), ids(i,3), seg0);        
      
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

        lastc = distr(1);
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
               % if j == nseg
                %    endi = g_segments.items(seg0 + j).start_index + size(g_segments.items(seg0 + j).points, 1) - 1;                
                %else
                    endi = g_segments.items(seg0 + j).start_index;
                % end
                if distr(j - 1) > 0                    
                    clr = lclr(distr(j - 1), :);
                    lspec = ls{distr(j - 1)};
                    w = 2.2 * lw(distr(j - 1));
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
        
    hdummy = figure;
    handles = [];
    for i = 1:g_segments_base_classification.nclasses
        handles(i) = plot([0, 1], [0, 1], ls{i}, 'Color', lclr(i, :));
        hold on;
    end
                    
    leg = arrayfun(@(t) t.description, g_segments_base_classification.classes, 'UniformOutput', 0);
    hleg = figure;
    set(gcf, 'Color', 'w');
    legendflex(handles, leg, 'box', 'off', 'nrow', 3, 'ncol', 3, 'ref', hleg, 'fontsize', 8, 'anchor', {'n','n'});
    export_fig(fullfile(g_config.OUTPUT_DIR, 'strategies_line_legend.eps'));
    
    close(hleg);
    close(hdummy);      
end

