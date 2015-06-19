function results_transition_counts()    
    addpath(fullfile(fileparts(mfilename('fullpath')), '../../extern/export_fig'));  
    
    global g_config;
    global g_trajectories;    
    global g_segments;        
    global g_segments_classification;    
            
    cache_trajectories_classification;
          
    vals = [];
    vals_grps = [];           
    d = 0.05;
    pos = [];            
    ngrp = 0;  
    % for the friedman test
    mfried = [];
    ids = {};
    nanimals = -1;
    
    trans = g_segments_classification.transition_counts_trial;
    
    all_trials = arrayfun( @(t) t.trial, g_trajectories.items);                   
    all_groups = arrayfun( @(t) t.group, g_trajectories.items);                       
    all_groups = all_groups(g_trajectories.segmented_index);
    all_trials = all_trials(g_trajectories.segmented_index);
            
    par = g_segments.partitions;
    
    ngrp = 0;
    for t = 1:g_config.TRIALS
        for g = 1:2                                    
            ngrp = ngrp + 1;
            if t > 1
                ids_grp = ids{g};
            else
                ids_grp = [];
            end

            sel = find(all_trials == t & all_groups == g);
            
            for i = 1:length(sel)       
                if sel(i) == 0
                    continue; % a weird/too short trajectory
                end

                if par(sel(i)) == 0
                    continue;
                end
                
                val = trans(sel(i));
                
                vals = [vals, val];
                vals_grps = [vals_grps, ngrp];                        

                % put it in the matrix for the friedman test
                id = g_trajectories.items(sel(i)).id;        
                id_pos = find(ids_grp == id);
                if length(ids) < g
                    ids = [ids, g];
                end

                if isempty(id_pos)
                    if g == 1                            
                        if t == 1
                            ids_grp = [ids_grp, id];
                            id_pos = length(ids_grp);
                        end
                    else
                        % add only as many as animals as in the
                        % first group as?
                        if length(ids_grp) < nanimals
                            ids_grp = [ids_grp, id];
                            id_pos = length(ids_grp);
                        end
                    end
                end                        
                if ~isempty(id_pos)
                    assert((nanimals == -1 && t == 1) || id_pos <= nanimals);
                    mfried( (t - 1)*nanimals + id_pos, g) = val;
                end
            end
            ids{g} = ids_grp;
            if t == 1 && g == 1
                nanimals = length(ids_grp);
                % now we know the size of the end matrix
                tmp = zeros(nanimals*g_config.TRIALS, 2);
                tmp(1:nanimals, 1) = mfried;
                mfried = tmp;
            end
            pos = [pos, d];
            d = d + 0.05;
        end
        d = d + 0.05;
    end

    figure;
    hold off;
    % average each value                        
    boxplot(vals, vals_grps, 'positions', pos, 'colors', [0 0 0]);     
    h = findobj(gca,'Tag','Box');
    
    for j=1:2:length(h)
         patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
    end
    set([h], 'LineWidth', 0.8);

    h = findobj(gca, 'Tag', 'Median');
    for j=1:2:length(h)
         line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.9 .9 .9], 'LineWidth', 2);
    end

    h = findobj(gca, 'Tag', 'Outliers');
    for j=1:length(h)
        set(h(j), 'MarkerEdgeColor', [0 0 0]);
    end        

    lbls = {};
    lbls = arrayfun( @(i) sprintf('%d', i), 1:g_config.TRIALS, 'UniformOutput', 0);     

    set(gca, 'DataAspectRatio', [1, 25*1.25, 1], 'XTick', (pos(1:2:2*g_config.TRIALS - 1) + pos(2:2:2*g_config.TRIALS)) / 2, 'XTickLabel', lbls, 'Ylim', [0, 25], 'FontSize', 0.75*g_config.FONT_SIZE);
    set(gca, 'LineWidth', g_config.AXIS_LINE_WIDTH);   

    ylabel('transitions', 'FontSize', 0.75*g_config.FONT_SIZE);
    xlabel('trial', 'FontSize', g_config.FONT_SIZE);        

    set(gcf, 'Color', 'w');
    box off;  
    set(gcf,'papersize',[8,8], 'paperposition',[0,0,8,8]);

    export_fig(fullfile(g_config.OUTPUT_DIR, 'transision_counts.eps'));

    p = friedman(mfried, nanimals, 'off');
    % pa = anova2(m, nanimals);
    str = sprintf('p_frdm: %g', p);            
    disp(str);
    
    p = anova2(mfried, nanimals, 'off');
    % pa = anova2(m, nanimals);
    str = sprintf('p_anova: %g', p);            
    disp(str);