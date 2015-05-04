function results_trajectory_classification_nencki
    addpath(fullfile(fileparts(mfilename('fullpath')), '../../extern/cm_and_cb_utilities'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../../extern/export_fig'));  
    addpath(fullfile(fileparts(mfilename('fullpath')), '../../extern/legendflex'));
      
    %%  load all trajectories and compute feature values if necessary (data is then cached)
    global g_config;
    global g_trajectories;    
    global g_segments;
    global g_segments_classification;        
    global g_partitions;
    
    cache_trajectories_classification;
       
    fprintf('\nCOVERAGE: %.2f | UNKNOWN: %.2f', g_segments_classification.coverage()*100, g_segments_classification.punknown*100);
    
    % load the full trajectories
    strat_distr = g_segments_classification.mapping_ordered('DiscardUnknown', 1, 'MinSegments', 4);
        
    for i = 1:g_segments_classification.nclasses
        fprintf('\nClass %d = %s', i, g_segments_classification.classes(i).description);
    end

    cm = g_config.CLASSES_COLORMAP;
    % rescale colormap    
    if size(cm, 1) > g_segments_classification.nclasses
        cm = cmapping(g_segments_classification.nclasses + 1, cm);
    end
    
    ls = {'-','--',':',':','--','-'};
    lclr = [ ...
        .2 .2 .2; ...
        .2 .2 .2; ...
        .2 .2 .2; ...
        .0 .6 .0; ...
        .0 .6 .0; ...
        .9 .0 .0 ];
    lvl = [0, 0, 0.3, 0.5, 0.5, 0.5, 0, 0.2];
    lw = [1, 1, 1, 1, 1, 1, 1, 1];

    nx = 6;
    ny = 4;
    
    seg_off = 1;    
    idx = 1;
    % plot trajectory        
    figure('Position', [0, 0, 1500, 2200]);                    
    n = 1;
    for i = 1:g_trajectories.count        
        % segments
        nseg = g_partitions(i);
        if nseg == 0
            continue;
        end
        seg0 = seg_off;
                
        distr = strat_distr(idx, :);
        vals = g_segments_classification.class_map(seg0:seg0 + nseg - 1);

        subaxis(nx, ny, mod(idx - 1, nx*ny) + 1, 'SV', 0, 'SH', 0);        
        
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
        for j = 2:nseg
            p = 0;

            if distr(j) ~= lastc || j == nseg
                lastc = distr(j);
                p = 1;
            end

            if p
                starti = g_segments.items(seg0 + lasti - 1).start_index;
                if j == nseg
                    endi = g_segments.items(seg0 + j - 1).start_index + size(g_segments.items(seg0 + j - 1).points, 1) - 1;                
                else
                    endi = g_segments.items(seg0 + j - 1).start_index;
                end
                if distr(j - 1) > 0                    
                    clr = lclr(distr(j - 1), :);
                    lspec = ls{distr(j - 1)};
                    w = 2.2 * lw(distr(j - 1));
                else
                    clr = [0.7 0.7 0.7];
                    lspec = ':';
                    w = 1.5;
                end
                plot(g_trajectories.items(i).points(starti:endi, 2), g_trajectories.items(i).points(starti:endi, 3), lspec, 'LineWidth', w, 'Color', clr);
                lasti = j;                
            end 
            id = g_trajectories.items(i).identification;
            text(-g_config.ARENA_R, g_config.ARENA_R, sprintf('rat: %d trial: %d', id(2), id(3)));  
        end   
        set(gca, 'LooseInset', [0,0,0,0]);
        set(gcf, 'Color', 'w');
        
        seg_off = seg_off + nseg;
        idx = idx + 1;
        
        % last in this window?
        if mod(idx, nx*ny) == 0
            set(gcf,'papersize',[8, 12], 'paperposition',[0,0,8,12]);        
            export_fig(fullfile(g_config.OUTPUT_DIR, sprintf('training_swimming_paths_%d.pdf', n)));
            clf;
            n = n + 1;
        end
    end    
    
    % legend
    hdummy = figure;
    handles = [];
    for i = 1:g_segments_classification.nclasses
        handles(i) = plot([0, 1], [0, 1], ls{i}, 'Color', lclr(i, :));
        hold on;
    end

    leg = arrayfun(@(t) t.description, g_segments_classification.classes, 'UniformOutput', 0);
    hleg = figure;
    set(gcf, 'Color', 'w');
    legendflex(handles, leg, 'box', 'off', 'nrow', 8, 'ncol', 1, 'ref', hleg, 'fontsize', 8, 'anchor', {'n','n'});
    export_fig(fullfile(g_config.OUTPUT_DIR, 'strategies_legend.pdf'));

    close(hleg);
    close(hdummy);      
end