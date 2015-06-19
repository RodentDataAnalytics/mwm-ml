classdef results_clusters < handle
    %RESULTS_SINGLE_FEATURES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(GetAccess = 'protected', SetAccess = 'protected')
        window = [];    
        parent = [];
        grid = [];
        panels = [];
        axis = [];
        controls_box = [];                
        feat1_combo = [];        
        feat2_combo = [];        
        feat3_combo = [];        
    end
    
    methods
        function inst = results_clusters(par, par_wnd)            
            inst.window = uiextras.VBox('Parent', par_wnd);
            inst.parent = par;
        end
               
        function update(inst)
            global g_config;            
            if isempty(inst.grid)                
                inst.grid = uiextras.Grid('Parent', inst.window);
                inst.controls_box = uiextras.HBox('Parent', inst.window);
                set(inst.window, 'Sizes', [-1, 40]);                
                inst.axis = [];
                
                for i = 1:9
                    if i == 1 || i == 5 || i == 9
                        uicontrol('Parent', inst.grid, 'Style', 'text', 'String', '-');        
                    else
                        hbox = uiextras.VBox('Parent', inst.grid);
                        inst.axis = [inst.axis, axes('Parent', hbox)];                    
                    end
                end                                
                
                set(inst.grid, 'RowSizes', [-1 -1 -1], 'ColumnSizes', [-1 -1 -1]);
                
                % create other controls            
                feat = {};
                for i = 1:length(inst.parent.feat)
                    att = g_config.FEATURES{inst.parent.feat(i)};
                    feat = [feat, att{2}];
                end
                
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'Feature 1:');            
                inst.feat1_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', 'String', feat, 'Callback', @inst.update_plots);
                set(inst.feat1_combo, 'value', 1);
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'Feature 2:');            
                inst.feat2_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', 'String', feat, 'Callback', @inst.update_plots);
                set(inst.feat2_combo, 'value', 2);
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'Feature 3:');            
                inst.feat3_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', 'String', feat, 'Callback', @inst.update_plots);
                set(inst.feat3_combo, 'value', 3);
                
                set(inst.controls_box, 'Sizes', [80, 150, 80, 150, 80, 150]);
            end
                        
            inst.update_plots;
        end       
        
        function update_plots(inst, source, event_data)
            global g_config;
            feat_val = inst.parent.traj.compute_features(inst.parent.feat);
            
            grps = inst.parent.groups;
            feat1 = get(inst.feat1_combo, 'value');
            feat2 = get(inst.feat2_combo, 'value');
            feat3 = get(inst.feat3_combo, 'value');
            
            clus = inst.parent.cluster;           
            if clus > 0
                % filter by cluster
                cluster_mask = (inst.parent.results.cluster_index == clus);
            else
                cluster_mask = ones(1, inst.parent.traj.count);
            end            
            groups = arrayfun( @(t) t.group, inst.parent.traj.items);       
            trials = arrayfun( @(t) t.trial, inst.parent.traj.items);                       
                                        
            comb = [ feat1 feat2; feat1 feat3; feat2 feat1; feat2 feat3; feat3 feat1; feat3 feat2];
            idx = 1;
            for i = 2:9
                if i == 5 || i == 9
                    continue;
                end
                
                % store values for possible later significance test                            
                vals = {};
                
                set(inst.parent.window, 'currentaxes', inst.axis(idx));                
                hold off;                
                % plot all values in light gray first
                leg = {'Undefined'};
                h = plot(feat_val(:, comb(idx, 1)), feat_val(:, comb(idx, 2)), 'o', 'Color', [.6 .6 .6]);
                set(h,'MarkerEdgeColor','none','MarkerFaceColor', [.6 .6 .6]);
                hold on;                
                
                if grps(1) == 1 && clus == 0 && ~isempty(inst.parent.results) && sum(grps) == 1
                    % plot each cluster individually with different colors
                    
                    clrs = cmapping(inst.parent.results.nclusters, jet);
                    for c = 1:inst.parent.results.nclusters
                        sel = find(inst.parent.results.cluster_index == c);                        
                        h = plot(feat_val(sel, comb(idx, 1)), feat_val(sel, comb(idx, 2)), 'o', 'Color', clrs(c, :));
                        set(h,'MarkerEdgeColor','none','MarkerFaceColor', clrs(c, :));
                        hold on;
                        leg = [leg, inst.parent.results.classes(c).description];
                    end                    
                    legend(leg, 'Location', 'eastoutside');
                else                            
                    for g = 1:g_config.GROUPS
                        if ~grps(g) 
                            continue;
                        end
                        if g == 1
                            sel = (inst.parent.trials(trials) == 1); 
                        else
                            sel = (groups == g - 1 & inst.parent.trials(trials) == 1);
                        end

                        sel = sel & cluster_mask;                    
                        sel_pos = find(sel);

                        % plot cluster
                        h = plot(feat_val(sel_pos, comb(idx, 1)), feat_val(sel_pos, comb(idx, 2)), 'o', 'Color', inst.parent.groups_colors(g, :));                    
                        set(h,'MarkerEdgeColor','none','MarkerFaceColor', inst.parent.groups_colors(g, :));
                        vals = [vals, [feat_val(sel_pos, comb(idx, 1)), feat_val(sel_pos, comb(idx, 2))]];                        
                        
                        hold on;
                    end                    
                end
                att = g_config.FEATURES{inst.parent.feat(comb(idx, 1))};
                xlabel(att{2});
                att = g_config.FEATURES{inst.parent.feat(comb(idx, 2))};
                ylabel(att{2});                    
                idx = idx + 1;             
            end
        end               
    end       
end