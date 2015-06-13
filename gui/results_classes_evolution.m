classdef results_classes_evolution < handle
    %RESULTS_SINGLE_FEATURES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(GetAccess = 'protected', SetAccess = 'protected')
        window = [];        
        parent = [];                
        axis = [];       
        panels = [];
        grid_panel = [];
        grid = [];
        controls_box = [];
        class_combo = [];
        plot_combo = []; 
        full_check = [];        
        results_hash = -1;
        class_map = [];
        all_trials = [];
        all_groups = [];
    end
    
    methods
        function inst = results_classes_evolution(par, par_wnd)                        
            inst.window = uiextras.VBox('Parent', par_wnd);
            inst.parent = par;            
            
            inst.all_groups = arrayfun( @(t) t.group, inst.parent.traj.parent.items);       
            inst.all_trials = arrayfun( @(t) t.trial, inst.parent.traj.parent.items);                   
            inst.all_groups = inst.all_groups(inst.parent.traj.segmented_index);
            inst.all_trials = inst.all_trials(inst.parent.traj.segmented_index);
        end
        
        function update(inst)    
            global g_config;
            naxis = 1;
            if ishandle(inst.plot_combo)
                val = get(inst.plot_combo, 'value');
                if val == 2 || val == 4 || val == 5 
                    naxis = sum(inst.parent.groups);
                end
            end
                        
            if naxis ~= length(inst.axis)
                sel_plot = 1;
                if ~isempty(inst.grid_panel)
                    if ishandle(inst.plot_combo)
                        sel_plot = get(inst.plot_combo, 'value');
                    end
                    delete(inst.grid_panel);
                end
                inst.grid_panel = uiextras.VBox('Parent', inst.window);
                inst.grid = uiextras.Grid('Parent', inst.grid_panel);
                inst.controls_box = uiextras.HBox('Parent', inst.grid_panel);
                set(inst.grid_panel, 'Sizes', [-1, 40]);
                inst.panels = [];
                inst.axis = [];
                
                if naxis == 1
                    nr = 1;
                    nc = 1;
                elseif naxis == 2
                    nr = 1;
                    nc = 2;
                elseif naxis <= 4
                    nr = 2;
                    nc = 2;
                elseif naxis <= 6
                    nr = 2;
                    nc = 3;
                elseif naxis <= 9;
                    nr = 3;
                    nc = 3;
                elseif naxis <= 12;
                    nr = 3;
                    nc = 4;
                elseif naxis <= 15;
                    nr = 3;
                    nc = 5;
                else
                    error('too many groups');
                end
                                
                for i = 1:nc*nr
                    if i <= naxis                        
                        inst.panels = [inst.panels, uiextras.BoxPanel('Parent', inst.grid)];
                        hbox = uiextras.VBox('Parent', inst.panels(end));
                        inst.axis = [inst.axis, axes('Parent', hbox)];
                    else
                        uicontrol('Parent', inst.grid, 'Style', 'text', 'String', '+++++');        
                    end
                end                                
                set(inst.grid, 'RowSizes', -1*ones(1, nr), 'ColumnSizes', -1*ones(1, nc));
                                                
                % create other controls            
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'Class:');                            
                classes = {'None'};
                if ~isempty(inst.parent.results)
                    classes = arrayfun( @(idx) inst.parent.results.classes(idx).description, 1:inst.parent.results.nclasses, 'UniformOutput', 0);
                end
                inst.class_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', 'String', classes, 'Callback', @inst.update_plots);               
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'Plot:');            
                inst.plot_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', 'String', {'Box-plot', 'Distributions', 'Lines', 'Transition probabilities', 'Transition counts'}, 'Callback', @inst.update_plots, 'value', sel_plot);
                set(inst.controls_box, 'Sizes', [100, 200, 100, 200]);                                
            end

            if isempty(inst.class_map) && ~isempty(inst.parent.results) && (inst.results_hash ~= inst.parent.results.hash_value)
                tmp = inst.parent.results.mapping_ordered;
                inst.class_map = zeros(size(tmp, 1), inst.parent.results.nclasses);
                for i = 1:inst.parent.results.nclasses                    
                    inst.class_map(:, i) = sum(tmp == i, 2);
                end                    
                inst.class_map = inst.class_map ./ repmat(sum(inst.class_map >= 0, 2), 1, size(inst.class_map, 2));
                inst.results_hash = inst.parent.results.hash_value;
                classes = arrayfun( @(idx) inst.parent.results.classes(idx).description, 1:inst.parent.results.nclasses, 'UniformOutput', 0);
                set(inst.class_combo, 'String', classes, 'Value', 1);
            end
                                   
            if ~isempty(inst.class_map)                
                switch(get(inst.plot_combo, 'value'))
                    case 1
                        inst.box_plots;
                    case 2
                        inst.area_plots;
                    case 3
                        inst.line_plots;
                    case 4
                        inst.transitions_plot(1);
                    case 5
                        inst.transitions_plot(0);
                end                        
            end
        end        
        
        function update_plots(inst, source, event_data)            
            inst.update;
        end
        
        function box_plots(inst)            
            global g_config;
            
            grps = inst.parent.groups;              
            class = get(inst.class_combo, 'value');
                                                            
            vals = [];
            vals_grps = [];           
            d = 0.05;
            pos = [];            
            ngrp = 0;  
            % for the friedman test
            mfried = [];
            ids = {};
            nanimals = -1;
            set(inst.panels(1), 'Title', 'Box plots');
            
            for t = 1:g_config.TRIALS
                grp_idx = 0;                
                for g = 1:length(grps)                                    
                    ngrp = ngrp + 1;
                    if ~grps(g) 
                        continue;
                    end
                    grp_idx = grp_idx + 1;
                    if t > 1
                        ids_grp = ids{grp_idx};
                    else
                        ids_grp = [];
                    end
                    
                    if g == 1
                        sel = find(inst.all_trials == t);
                    else
                        sel = find(inst.all_trials == t & inst.all_groups == g - 1);
                    end                                        
                                                            
                    for i = 1:length(sel)       
                        if sel(i) == 0
                            continue; % a weird/too short trajectory
                        end
                        
                        val = inst.class_map(sel(i), class);
                        
                        vals = [vals, val];
                        vals_grps = [vals_grps, ngrp];                        
                        
                        % put it in the matrix for the friedman test
                        id = inst.parent.traj.parent.items(sel(i)).id;        
                        id_pos = find(ids_grp == id);
                        if length(ids) < grp_idx
                            ids = [ids, grp_idx];
                        end

                        if isempty(id_pos)
                            if grp_idx == 1                            
                                if t == 1
                                    ids_grp = [ids_grp, id];
                                    id_pos = length(ids_grp);
                                end
                            else
                                % add only as many as animals as in the
                                % first group as?
                                if length(ids_grp) <= nanimals
                                    ids_grp = [ids_grp, id];
                                    id_pos = length(ids_grp);
                                end
                            end
                        end                        
                        if ~isempty(id_pos)
                            assert((nanimals == -1 && t == 1) || id_pos <= nanimals);
                            mfried( (t - 1)*nanimals + id_pos, grp_idx) = val;
                        end
                    end
                    ids{grp_idx} = ids_grp;
                    if t == 1 && grp_idx == 1
                        nanimals = length(ids_grp);
                        % now we know the size of the end matrix
                        tmp = zeros(nanimals*g_config.TRIALS, sum(grps));
                        tmp(1:nanimals, 1) = mfried;
                        mfried = tmp;
                    end
                    pos = [pos, d];
                    d = d + 0.05;
                end
                d = d + 0.05;
            end
            
            set(inst.parent.window, 'currentaxes', inst.axis(1));
            hold off;
            % average each value                        
            boxplot(vals, vals_grps, 'positions', pos, 'colors', [0 0 0]);     
            h = findobj(gca,'Tag','Box');

            sel_grp = find(grps > 0);                    
            rev_map = length(sel_grp):-1:1;
            for j = 1:length(h)                        
                clr = mod(j - 1, length(sel_grp)) + 1;
                clr = sel_grp(rev_map(clr));
                patch(get(h(j),'XData'), get(h(j), 'YData'), inst.parent.groups_colors(clr, :));
            end
            set([h], 'LineWidth', 0.8);

            if length(sel_grp) > 1
                p = friedman(mfried, nanimals, 'off');
                sig = 'ns';
                if p < 0.05                        
                    sig = '*';
                    if p < 0.01
                        sig = '**';
                        if p < '0.001' 
                            sig = '***';
                        end
                    end
                end
                title(sprintf('p = %.3e (%s)', p, sig), 'FontWeight', 'bold', 'FontSize', 14);
            end

            h = findobj(gca, 'Tag', 'Median');
            for j = 1:length(h)
                line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.9 .9 .9], 'LineWidth', 2);
            end

            lbls = {};
            sel = 1:g_config.TRIALS;
            sel = sel(inst.parent.trials == 1);
            lbls = arrayfun( @(i) sprintf('%d', i), sel, 'UniformOutput', 0);     

            set(gca, 'XTick', 1:length(sel), 'XTickLabel', lbls);                                               
        end
       
        function area_plots(inst)            
            global g_config;
            if isempty(inst.class_map)
                return;
            end
                                                
            sel_grp = 1:g_config.GROUPS + 1;
            sel_grp = sel_grp(inst.parent.groups == 1);
            
            sel_trial = 1:g_config.TRIALS;
            sel_trial = sel_trial(inst.parent.trials == 1);
                        
            leg = {};
            for i = 1:inst.parent.results.nclasses
                att = inst.parent.results.classes(i);
                leg = [leg, att.description];                
            end
                        
            for ig = 1:length(sel_grp)                
                set(inst.parent.window, 'currentaxes', inst.axis(ig));
                data = zeros(length(sel_trial), size(inst.class_map, 2));
                if sel_grp(ig) == 1
                    % everyone
                    sel = ones(1, length(inst.all_trials));
                else
                    sel = (inst.all_groups == sel_grp(ig) - 1);
                end                
                
                for it = 1:length(sel_trial)
                    data(it, :) = mean(inst.class_map(sel & inst.all_trials == sel_trial(it), :));
                end
                
                % normalize the data
                data = 100*data ./ repmat(sum(data, 2), 1, size(data, 2));
                area(1:length(sel_trial), data);
                set(gca, 'Ylim', [0 100]);
                
                if sel_grp(ig) == 1
                    gn = 'Combined';
                else
                    gn = g_config.GROUPS_DESCRIPTION{sel_grp(ig) - 1};
                end
                set(inst.panels(ig), 'Title', gn);
                legend(leg, 'Location', 'eastoutside');
                colormap jet;
            end
        end
        
        function line_plots(inst)            
            global g_config;
            if isempty(inst.class_map)
                return;
            end
                                                
            class = get(inst.class_combo, 'value');
            sel_grp = 1:g_config.GROUPS + 1;
            sel_grp = sel_grp(inst.parent.groups == 1);
            
            sel_trial = 1:g_config.TRIALS;
            sel_trial = sel_trial(inst.parent.trials == 1);
                                    
            set(inst.parent.window, 'currentaxes', inst.axis(1));
            hold off;
            for ig = 1:length(sel_grp)               
                data = zeros(length(sel_trial), size(inst.class_map, 2));
                if sel_grp(ig) == 1
                    % everyone
                    sel = ones(1, length(inst.all_trials));
                else
                    sel = (inst.all_groups == sel_grp(ig) - 1);
                end                
                
                data = zeros(1, length(sel_trial));
                err_bar = zeros(1, length(sel_trial));
                for it = 1:length(sel_trial)
                    tmp = inst.class_map(sel & inst.all_trials == sel_trial(it), class);
                    data(it) = mean(tmp);                    
                    err_bar(it) = 1.96*std(tmp)/sqrt(length(tmp));
                end
                               
                shadedErrorBar( 1:length(sel_trial) ....
                            , data ...
                            , err_bar ...
                            , {'Color', inst.parent.groups_colors(sel_grp(ig), :), 'LineWidth', 2}, 1);                                                        
                
                hold on;                
            end
            set(gca, 'XTick', 1:length(sel_trial));
        end
        
        function transitions_plot(inst, prob)            
            global g_config;
            if isempty(inst.class_map)
                return;
            end
                                                
            sel_grp = 1:g_config.GROUPS + 1;
            sel_grp = sel_grp(inst.parent.groups == 1);
            
            sel_trial = 1:g_config.TRIALS;
            sel_trial = sel_trial(inst.parent.trials == 1);
                        
            leg = {};
            for i = 1:inst.parent.results.nclasses
                att = inst.parent.results.classes(i);
                leg = [leg, att.description];                
            end
            
            strings = {};
            for ci = 1:inst.parent.results.nclasses
                % normalize feature                        
                att = inst.parent.results.classes(ci);
                strings = [strings, att.description];                
            end                    
            
            for ig = 1:length(sel_grp)                
                set(inst.parent.window, 'currentaxes', inst.axis(ig));
                                
                if prob                   
                    vals = inst.parent.results.transition_probabilities('Group', sel_grp(ig) - 1);
                    tot = -1;
                else                           
                    vals = inst.parent.results.transition_counts('Group', sel_grp(ig) - 1);
                    tot = sum(sum(vals));
                    vals = vals ./ repmat(sum(inst.all_groups == sel_grp(ig) - 1), size(vals, 1), size(vals, 2));
                end
                hold off;
                imagesc(abs(vals));            %# Create a colored plot of the matrix values
                colormap(flipud(gray));  %# Change the colormap to gray (so higher values are
                         %#   black and lower values are white)

                textStrings = num2str(vals(:),'%0.2f');  %# Create strings from the matrix values
                textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
                [x, y] = meshgrid(1:size(vals, 2), 1:size(vals, 1));   %# Create x and y coordinates for the strings
                hStrings = text(x(:), y(:), textStrings(:), ...      %# Plot the strings
                                'HorizontalAlignment', 'center' );
                midValue = mean(get(gca, 'CLim'));  %# Get the middle value of the color range
                textColors = repmat(vals(:) > midValue, 1, 3);  %# Choose white or black for the
                                             %#   text color of the strings so
                                             %#   they can be easily seen over
                                             %#   the background color
                set(hStrings,{'Color'}, num2cell(textColors, 2));  %# Change the text colors

                set(gca,'XTick', 1:size(vals, 2), ...                         %# Change the axes tick marks
                        'XTickLabel', strings,...  %#   and tick labels
                        'YTick', 1:size(vals, 1), ...
                        'YTickLabel', strings, ...
                        'TickLength', [0 0]);                                                    
                    
                  
                if sel_grp(ig) == 1
                    gn = 'Combined';
                else
                    gn = g_config.GROUPS_DESCRIPTION{sel_grp(ig) - 1};
                end
                if tot > -1
                    gn = sprintf('%s (N = %d)', gn, tot);
                end
                set(inst.panels(ig), 'Title', gn);                
            end
        end
    end         
end