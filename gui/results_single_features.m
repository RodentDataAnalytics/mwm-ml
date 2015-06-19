classdef results_single_features < handle
    %RESULTS_SINGLE_FEATURES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(GetAccess = 'protected', SetAccess = 'protected')
        window = [];    
        parent = [];
        grid = [];
        panels = [];
        axis = [];
        controls_box = [];
        plot_combo = []; 
        full_check = [];        
    end
    
    methods
        function inst = results_single_features(par, par_wnd)                        
            inst.window = uiextras.VBox('Parent', par_wnd);
            inst.parent = par;            
        end
        
        function update(inst)
            global g_config;
            
            n = length(inst.parent.feat);
            if isempty(inst.grid)                
                inst.grid = uiextras.Grid('Parent', inst.window);
                inst.controls_box = uiextras.HBox('Parent', inst.window);
                set(inst.window, 'Sizes', [-1, 40]);
                inst.panels = [];
                inst.axis = [];

                if n == 1
                    nr = 1;
                    nc = 1;
                elseif n == 2
                    nr = 1;
                    nc = 2;
                elseif n <= 4
                    nr = 2;
                    nc = 2;
                elseif n <= 6
                    nr = 2;
                    nc = 3;
                elseif n <= 9;
                    nr = 3;
                    nc = 3;
                elseif n <= 12;
                    nr = 3;
                    nc = 4;
                elseif n <= 15;
                    nr = 3;
                    nc = 5;
                else
                    error('need to update the list above');
                end
                for i = 1:nr*nc
                    if i <= n
                        feat = g_config.FEATURES{inst.parent.feat(i)};
                        inst.panels = [inst.panels, uiextras.BoxPanel('Parent', inst.grid, 'Title', feat{2})];
                        hbox = uiextras.VBox('Parent', inst.panels(end));
                        inst.axis = [inst.axis, axes('Parent', hbox)];
                    else
                        uicontrol('Parent', inst.grid, 'Style', 'text', 'String', '+++++');        
                    end
                end                                

                set(inst.grid, 'RowSizes', -1*ones(1, nr), 'ColumnSizes', -1*ones(1, nc));

                % create other controls            
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'Plot:');            
                inst.plot_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', 'String', {'Histogram', 'Histogram (fine)', 'Log-Histogram', 'Log-Histogram (fine)', 'CDF'}, 'Callback', @inst.update_plots);
                set(inst.controls_box, 'Sizes', [100, 200]);
                state = 'on';
                if isempty(inst.parent.traj.parent)
                    state = 'off';
                end
                inst.full_check = uicontrol('Parent', inst.controls_box, 'Style', 'checkbox', 'String', 'Full trajectories', 'Enable', state, 'Callback', @inst.update_plots);
            end

            inst.update_plots;
        end        

        function update_plots(inst, source, event_data)
            global g_config;
            
            plt = get(inst.plot_combo, 'value');
            grps = inst.parent.groups;            
            full = get(inst.full_check, 'value');            
            
            if full
                traj = inst.parent.traj.parent;                
            else
                traj = inst.parent.traj;                
            end
            
            feat_val = traj.compute_features(inst.parent.feat);                
            groups = arrayfun( @(t) t.group, traj.items);       
            trials = arrayfun( @(t) t.trial, traj.items);                       
            types = arrayfun( @(t) t.trial_type, traj.items);
            
            for i = 1:length(inst.parent.feat)                  
                % store values for possible later significance test            
                vals = {};
                set(inst.parent.window, 'currentaxes', inst.axis(i));                
                hold off;
                for g = 1:length(grps)
                    if ~grps(g) 
                        continue;
                    end
                    if g == 1
                        sel = (inst.parent.trials(trials) == 1);                        
                    else
                        sel = (groups == g - 1 & inst.parent.trials(trials) == 1);                        
                    end
                    if inst.parent.trial_type
                        sel = (sel & types == inst.parent.trial_type);                        
                    end
                    sel = find(sel);
                    
                    switch(plt)
                        case 1             
                            [Y, X] = hist(feat_val(sel, i), 15);
                            bar(X, Y ./ sum(hist(feat_val(sel, i), 15)), 'FaceColor', inst.parent.groups_colors(g, :));                                                        
                        case 2
                            [Y, X] = hist(feat_val(sel, i), 40);
                            bar(X, Y ./ sum(hist(feat_val(sel, i), 40)), 'FaceColor', inst.parent.groups_colors(g, :));                            
                        case 3
                            [Y, X] = hist(log(feat_val(sel, i)), 15);
                            bar(X, Y ./ sum(hist(log(feat_val(sel, i)), 15)), 'FaceColor', inst.parent.groups_colors(g, :));                            
                        case 4
                            [Y, X] = hist(log(feat_val(sel, i)), 40);
                            bar(X, Y ./ sum(hist(log(feat_val(sel, i)), 40)), 'FaceColor', inst.parent.groups_colors(g, :));
                        case 5
                            X = feat_val(sel, i);
                            if isempty(X(~isnan(X)))
                                X = [1 1 1];
                            end    
                            h = cdfplot(X);
                            set(h, 'Color', inst.parent.groups_colors(g, :), 'LineWidth', 2.5);
                    end
                    vals = [vals, feat_val(sel, i)];

                    hold on;
                end

                % significance tests                
                if sum(groups == 2) && length(vals) == 2
                    x1 = vals{1};
                    x2 = vals{2};                    
                    if length(x1) > 1 && length(x2) > 1 && ~isempty(x1(~isnan(x1))) && ~isempty(x2(~isnan(x2)))
                        [~, p] = kstest2(x1, x2, 'Tail', 'larger');
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
                end
            end
        end
    end        
end