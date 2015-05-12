classdef classification_results < handle   
    properties(GetAccess = 'public', SetAccess = 'protected')
        window = [];
        traj = [];
    end
    
    properties(GetAccess = 'protected', SetAccess = 'protected')
        trajectories_group = [];
        trajectories_trial = [];
        tab_panel = [];
        common_controls_box = [];
        features_tab = [];
        features2_tab = [];
        clusters_tab = [];
        % features (individual)
        features_grid = [];
        features_panels = [];
        features_axis = [];
        features_controls_box = [];
        features_plot_combo = [];        
        % features (combined)
        features2_grid = [];
        features2_panels = [];
        features2_axis = [];
        features2_controls_box = [];
        features2_feat1_combo = [];        
        features2_feat2_combo = [];        
        features2_feat3_combo = [];
        % common controls
        group_combo = [];
        first_trial_combo = [];
        last_trial_combo = [];
        cluster_combo = [];
        % results of the clustering
        results = [];        
    end
    
    methods
        function inst = classification_results(traj)
            global g_config;
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/GUILayout'));
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/GUILayout/Patch'));
    
            inst.traj = traj;            
            inst.trajectories_group = arrayfun( @(t) t.group, inst.traj.items);       
            inst.trajectories_trial = arrayfun( @(t) t.trial, inst.traj.items);
            
            inst.window = figure('Visible','off', 'name', 'Classification results', ...
                'Position', [200, 200, 900, 800], 'Menubar', 'none', 'Toolbar', 'none', 'resize', 'on');
            
            % create the tabs
            vbox = uiextras.VBox( 'Parent', inst.window, 'Padding', 5);
            inst.tab_panel = uiextras.TabPanel( 'Parent', vbox, 'Padding', 5, 'Callback', @inst.update_tab_callback);
            inst.features_tab = uiextras.VBox( 'Parent', inst.tab_panel, 'Padding', 5);
            inst.features2_tab = uiextras.VBox( 'Parent', inst.tab_panel, 'Padding', 5);
            inst.clusters_tab = uiextras.VBox( 'Parent', inst.tab_panel, 'Padding', 5);
            inst.tab_panel.TabNames = {'Individual features', 'Combined features', 'Clusters'};
            inst.tab_panel.SelectedChild = 1;       
            
            %%
            %% common control area
            %%
            inst.common_controls_box = uiextras.HBox( 'Parent', vbox);
            set(vbox, 'Sizes', [-1, 40]);
            
            uicontrol('Parent', inst.common_controls_box, 'Style', 'text', 'String', 'Group:');            
            grps = {'Combined'};
            if g_config.GROUPS > 1
                grps = [grps, 'All'];
                for i = 1:g_config.GROUPS
                    grps = [grps, ['Group ' num2str(i)]];
                end
            end
            inst.group_combo = uicontrol('Parent', inst.common_controls_box, 'Style', 'popupmenu', 'String', grps, 'Callback', @inst.update_callback);            
            
            % trials combos
            trials = arrayfun( @(t) num2str(t), 1:g_config.TRIALS, 'UniformOutput', 0);  
            uicontrol('Parent', inst.common_controls_box, 'Style', 'text', 'String', 'First trial:');            
            inst.first_trial_combo = uicontrol('Parent', inst.common_controls_box, 'Style', 'popupmenu', 'String', trials, 'Callback', @inst.update_callback);            
            set(inst.first_trial_combo, 'value', 1);            
            uicontrol('Parent', inst.common_controls_box, 'Style', 'text', 'String', 'Last trial:');            
            inst.last_trial_combo = uicontrol('Parent', inst.common_controls_box, 'Style', 'popupmenu', 'String', trials, 'Callback', @inst.update_callback);
            set(inst.last_trial_combo, 'value', g_config.TRIALS);
            uicontrol('Parent', inst.common_controls_box, 'Style', 'text', 'String', 'Cluster:');        
            inst.cluster_combo = uicontrol('Parent', inst.common_controls_box, 'Style', 'popupmenu', 'String', '** all **', 'Enable', 'off');
            set(inst.common_controls_box, 'Sizes', [80, 150, 80, 150, 80, 150, 80, 150]);
        end
        
        function show(inst, show_flag)
            if show_flag
                set(inst.window, 'Visible', 'on');
            else
                set(inst.window, 'Visible', 'off');
            end
            inst.update(1);
        end
        
        function set_results(inst, res)
            global g_config;
            inst.results = res;            
            
            % delete(inst.cluster_combo);            
                    
            strings = {'** all **'};            
            for i = 1:inst.results.nclusters
                if inst.results.cluster_class_map(i) == 0
                    lbl = g_config.UNDEFINED_TAG_ABBREVIATION;
                else
                    lbl = inst.results.classes(inst.results.cluster_class_map(i)).abbreviation;
                end
                nclus = sum(inst.results.cluster_idx == i);
                strings = [strings, sprintf('#%d (''%s'', N=%d)', i, lbl, nclus)];  
            end        
            
            % inst.cluster_combo = uicontrol('Parent', inst.common_controls_box, 'Style', 'popupmenu', 'String', strings, 'Callback', @inst.update_callback, 'Enable', 'on');            
            set(inst.cluster_combo, 'String', strings, 'Callback', @inst.update_callback, 'Enable', 'on', 'Value', 1);            
            inst.update(inst.tab_panel.SelectedChild);
        end
        
        function update_tab_callback(inst, source, eventdata)
            inst.update(eventdata.SelectedChild);
        end
        
        function update_callback(inst, source, eventdata)
            inst.update(inst.tab_panel.SelectedChild);
        end
        
        function update(inst, tabnr)
            f = gcf;
            figure(inst.window);
            vis = get(inst.window, 'Visible');            
            if strcmp(vis, 'on')                
                switch tabnr
                    case 1 % show features
                        inst.update_features;
                    case 2
                        inst.update_features2;
                    case 3
                        
                    otherwise
                        error('Ehm, seriously?');
                end
            end
            figure(f);
        end
                               
        function update_features(inst)
            global g_config;
            n = length(g_config.DEFAULT_FEATURE_SET);
            if isempty(inst.features_grid)                
                inst.features_grid = uiextras.Grid('Parent', inst.features_tab);
                inst.features_controls_box = uiextras.HBox('Parent', inst.features_tab);
                set(inst.features_tab, 'Sizes', [-1, 40]);
                inst.features_panels = [];
                inst.features_axis = [];
                
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
                        feat = g_config.FEATURES{g_config.DEFAULT_FEATURE_SET(i)};
                        inst.features_panels = [inst.features_panels, uiextras.BoxPanel('Parent', inst.features_grid, 'Title', feat{2})];
                        hbox = uiextras.VBox('Parent', inst.features_panels(end));
                        inst.features_axis = [inst.features_axis, axes('Parent', hbox)];
                    else
                        uicontrol('Parent', inst.features_grid, 'Style', 'text', 'String', '+++++');        
                    end
                end                                
                
                set(inst.features_grid, 'RowSizes', -1*ones(1, nr), 'ColumnSizes', -1*ones(1, nc));
                
                % create other controls            
                uicontrol('Parent', inst.features_controls_box, 'Style', 'text', 'String', 'Plot:');            
                inst.features_plot_combo = uicontrol('Parent', inst.features_controls_box, 'Style', 'popupmenu', 'String', {'Histogram', 'Histogram (fine)', 'Log-Histogram', 'Log-Histogram (fine)', 'CDF'}, 'Callback', @inst.update_features_plots);
                set(inst.features_controls_box, 'Sizes', [100, 200]);
            end
                        
            inst.update_features_plots;
        end        
            
        function update_features_plots(inst, source, event_data)
            global g_config;
            feat_val = inst.traj.compute_features(g_config.DEFAULT_FEATURE_SET);

            plt = get(inst.features_plot_combo, 'value');
            grp = get(inst.group_combo, 'value');
            ti = get(inst.first_trial_combo, 'value');
            tf = get(inst.last_trial_combo, 'value');
            
            clr = [ [0, 0, 1]; [1, 0, 0]; [0, 1, 0]];
                        
            for i = 1:length(g_config.DEFAULT_FEATURE_SET)                  
                % store values for possible later significance test            
                vals = {};
                set(inst.window, 'currentaxes', inst.features_axis(i));
                hold off;
                for g = 1:g_config.GROUPS                   
                    if grp == 1
                        sel = find(inst.trajectories_trial >= ti & inst.trajectories_trial <= tf);
                        clr_idx = 1;
                    elseif grp == 2
                        sel = find(inst.trajectories_group == g & inst.trajectories_trial >= ti & inst.trajectories_trial <= tf);  
                        clr_idx = g + 1;
                    else
                        sel = find(inst.trajectories_group == grp - 2 & inst.trajectories_trial >= ti & inst.trajectories_trial <= tf);                    
                        clr_idx = grp - 1;
                    end
                    switch(plt)
                        case 1                                            
                            bar(hist(feat_val(sel, i), 15) ./ sum(hist(feat_val(sel, i), 15)), 'FaceColor', clr(clr_idx, :));                                                        
                        case 2
                            bar(hist(feat_val(sel, i), 40) ./ sum(hist(feat_val(sel, i), 40)), 'FaceColor', clr(clr_idx, :));                            
                        case 3
                            bar(hist(log(feat_val(sel, i)), 15) ./ sum(hist(log(feat_val(sel, i)), 15)), 'FaceColor', clr(clr_idx, :));                            
                        case 4
                            bar(hist(log(feat_val(sel, i)), 40) ./ sum(hist(log(feat_val(sel, i)), 40)), 'FaceColor', clr(clr_idx, :));
                        case 5
                            h = cdfplot(feat_val(sel, i));        
                            set(h, 'Color', clr(clr_idx, :), 'LineWidth', 2.5);                            
                    end
                    vals = [vals, feat_val(sel, i)];
                                        
                    if grp ~= 2
                        break;
                    end
                    hold on;
                end
                
                % significance tests
                if (grp == 2) && (g_config.GROUPS == 2)
                    [~, p] = kstest2( vals{1}, vals{2});
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
        
        function update_features2(inst)
            global g_config;            
            if isempty(inst.features2_grid)                
                inst.features2_grid = uiextras.Grid('Parent', inst.features2_tab);
                inst.features2_controls_box = uiextras.HBox('Parent', inst.features2_tab);
                set(inst.features2_tab, 'Sizes', [-1, 40]);                
                inst.features2_axis = [];
                
                for i = 1:9
                    if i == 1 || i == 5 || i == 9
                        uicontrol('Parent', inst.features2_grid, 'Style', 'text', 'String', '-');        
                    else
                        hbox = uiextras.VBox('Parent', inst.features2_grid);
                        inst.features2_axis = [inst.features2_axis, axes('Parent', hbox)];                    
                    end
                end                                
                
                set(inst.features2_grid, 'RowSizes', [-1 -1 -1], 'ColumnSizes', [-1 -1 -1]);
                
                % create other controls            
                feat = {};
                for i = 1:length(g_config.DEFAULT_FEATURE_SET)
                    att = g_config.FEATURES{g_config.DEFAULT_FEATURE_SET(i)};
                    feat = [feat, att{2}];
                end
                
                uicontrol('Parent', inst.features2_controls_box, 'Style', 'text', 'String', 'Feature 1:');            
                inst.features2_feat1_combo = uicontrol('Parent', inst.features2_controls_box, 'Style', 'popupmenu', 'String', feat, 'Callback', @inst.update_features2_plots);
                set(inst.features2_feat1_combo, 'value', 1);
                uicontrol('Parent', inst.features2_controls_box, 'Style', 'text', 'String', 'Feature 2:');            
                inst.features2_feat2_combo = uicontrol('Parent', inst.features2_controls_box, 'Style', 'popupmenu', 'String', feat, 'Callback', @inst.update_features2_plots);
                set(inst.features2_feat2_combo, 'value', 2);
                uicontrol('Parent', inst.features2_controls_box, 'Style', 'text', 'String', 'Feature 3:');            
                inst.features2_feat3_combo = uicontrol('Parent', inst.features2_controls_box, 'Style', 'popupmenu', 'String', feat, 'Callback', @inst.update_features2_plots);
                set(inst.features2_feat3_combo, 'value', 3);
                
                set(inst.features2_controls_box, 'Sizes', [80, 150, 80, 150, 80, 150]);
            end
                        
            inst.update_features2_plots;
        end       
        
        function update_features2_plots(inst, source, event_data)
            global g_config;
            feat_val = inst.traj.compute_features(g_config.DEFAULT_FEATURE_SET);
            
            grp = get(inst.group_combo, 'value');
            ti = get(inst.first_trial_combo, 'value');
            tf = get(inst.last_trial_combo, 'value');
            feat1 = get(inst.features2_feat1_combo, 'value');
            feat2 = get(inst.features2_feat2_combo, 'value');
            feat3 = get(inst.features2_feat3_combo, 'value');
            
            clus = get(inst.cluster_combo, 'value');           
            if clus > 1
                % filter by cluster
                cluster_mask = (inst.results.cluster_idx == clus - 1);
            else
                cluster_mask = ones(1, inst.traj.count);
            end
                        
            clr = [ [0, 0, 1]; [1, 0, 0]; [0, 1, 0]];
                
            comb = [ feat1 feat2; feat1 feat3; feat2 feat1; feat2 feat3; feat3 feat1; feat3 feat2];
            idx = 1;
            for i = 2:9
                if i == 5 || i == 9
                    continue;
                end
                
                % store values for possible later significance test                            
                vals = {};
                
                set(inst.window, 'currentaxes', inst.features2_axis(idx));
                hold off;
                if clus > 1
                    % plot all values in light gray first
                    plot(feat_val(:, comb(idx, 1)), feat_val(:, comb(idx, 2)), 'o', 'Color', [.6 .6 .6]);
                    hold on;
                end
                
                for g = 1:g_config.GROUPS
                    if grp == 1
                        sel = inst.trajectories_trial >= ti & inst.trajectories_trial <= tf;
                        clr_idx = 1;
                    elseif grp == 2
                        sel = inst.trajectories_group == g & inst.trajectories_trial >= ti & inst.trajectories_trial <= tf;  
                        clr_idx = g + 1;
                    else
                        sel = inst.trajectories_group == grp - 2 & inst.trajectories_trial >= ti & inst.trajectories_trial <= tf;  
                        clr_idx = grp - 1;
                    end
                    
                    sel = sel & cluster_mask;
                    
                    sel_pos = find(sel);
                    
                    % plot cluster
                    plot(feat_val(sel_pos, comb(idx, 1)), feat_val(sel_pos, comb(idx, 2)), 'o', 'Color', clr(clr_idx, :));
                    att = g_config.FEATURES{g_config.DEFAULT_FEATURE_SET(comb(idx, 1))};
                    xlabel(att{2});
                    att = g_config.FEATURES{g_config.DEFAULT_FEATURE_SET(comb(idx, 2))};
                    ylabel(att{2});                    
                    vals = [vals, [feat_val(sel_pos, comb(idx, 1)), feat_val(sel_pos, comb(idx, 2))]];
                                        
                    if grp ~= 2
                        break;
                    end
                    hold on;
                end
                idx = idx + 1;
                % significance tests
%                 if (grp == 2) && (g_config.GROUPS == 2)
%                     [~, p] = kstest2( vals{1}, vals{2});
%                     sig = 'ns';
%                     if p < 0.05                        
%                         sig = '*';
%                         if p < 0.01
%                             sig = '**';
%                             if p < '0.001' 
%                                 sig = '***';
%                             end
%                         end
%                     end
%                             
%                     title(sprintf('p = %.3e (%s)', p, sig), 'FontWeight', 'bold', 'FontSize', 14);
%                 end
            end
        end
    end        
end