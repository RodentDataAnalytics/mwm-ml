classdef classification_results < handle   
    
    properties(GetAccess = 'public', SetAccess = 'protected')        
        window = [];
        traj = [];
        % selected groups and trials
        groups = [];
        trials = [];
        % selected cluster
        cluster = 0;                
        groups_colors = [];
        % results of the clustering
        results = [];                        
        trajectories_group = [];
        trajectories_trial = [];
        feat = [];
    end
    
    properties(GetAccess = 'protected', SetAccess = 'protected')
        tab_panel = [];
        common_controls_box = [];        
        % tabs        
        single_features = [];
        clusters = [];
        features_evolution = [];
        full_trajectories = [];
        correlations = [];
        classes = [];
        % common controls
        group_checkboxes = [];
        trial_type_combo = [];
        first_trial_combo = [];
        last_trial_combo = [];
        cluster_combo = [];        
    end
    
    methods
        function inst = classification_results(traj)
            global g_config;            
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/GUILayout'));
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/GUILayout/Patch'));
            addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/cm_and_cb_utilities'));
            
            inst.groups_colors = cmapping(g_config.GROUPS + 1, jet);
            inst.traj = traj;           
            inst.feat = [g_config.CLUSTERING_FEATURE_SET setdiff(g_config.DEFAULT_FEATURE_SET, g_config.CLUSTERING_FEATURE_SET)];
            
            inst.window = figure('Visible','off', 'name', 'Classification results', ...
                'Position', [200, 200, 900, 800], 'Menubar', 'none', 'Toolbar', 'none', 'resize', 'on');
            
            % create the tabs
            vbox = uiextras.VBox( 'Parent', inst.window, 'Padding', 5);
            inst.tab_panel = uiextras.TabPanel( 'Parent', vbox, 'Padding', 5, 'Callback', @inst.update_tab_callback, 'TabSize', 150);
            
            inst.single_features = results_single_features(inst, inst.tab_panel);            
            inst.clusters = results_clusters(inst, inst.tab_panel);
            inst.features_evolution = results_features_evolution(inst, inst.tab_panel);
            % inst.full_trajectories = results_full_trajectories(inst, inst.tab_panel);
            inst.correlations = results_correlation(inst, inst.tab_panel);
            inst.classes = results_classes_evolution(inst, inst.tab_panel);
            inst.tab_panel.TabNames = {'Segment features', 'Features clusters', 'Features evolution', 'Correlations', 'Classes'};
            inst.tab_panel.SelectedChild = 1;       
            
            %%
            %% common control area
            %%
            inst.common_controls_box = uiextras.HBox( 'Parent', vbox);
            set(vbox, 'Sizes', [-1, 50]);
            
            % trials combos
            pan = uiextras.BoxPanel('Parent', inst.common_controls_box, 'Title', 'Filter');      
            box = uiextras.HBox('Parent', pan);                                    
            
            uicontrol('Parent', box, 'Style', 'text', 'String', 'Trial type:');                        
            types = {'All'};
            types = [types, g_config.TRIAL_TYPES_DESCRIPTION];
            inst.trial_type_combo = uicontrol('Parent', box, 'Style', 'popupmenu', 'String', types, 'Callback', @inst.update_callback);
            trials = arrayfun( @(t) num2str(t), 1:g_config.TRIALS, 'UniformOutput', 0);  
            uicontrol('Parent', box, 'Style', 'text', 'String', 'First trial:');            
            inst.first_trial_combo = uicontrol('Parent', box, 'Style', 'popupmenu', 'String', trials, 'Callback', @inst.update_callback);
            set(inst.first_trial_combo, 'value', 1);            
            uicontrol('Parent', box, 'Style', 'text', 'String', 'Last trial:');            
            inst.last_trial_combo = uicontrol('Parent', box, 'Style', 'popupmenu', 'String', trials, 'Callback', @inst.update_callback);
            set(inst.last_trial_combo, 'value', g_config.TRIALS);
            uicontrol('Parent', box, 'Style', 'text', 'String', 'Cluster:');        
            inst.cluster_combo = uicontrol('Parent', box, 'Style', 'popupmenu', 'String', '** all **', 'Enable', 'off');
            
            % groups
            pan = uiextras.BoxPanel('Parent', inst.common_controls_box, 'Title', 'Groups');      
            box = uiextras.HBox('Parent', pan);                                    
            inst.group_checkboxes = uicontrol('Parent', box, 'Style', 'checkbox', 'String', '', 'Callback', @inst.update_callback, 'BackgroundCol', inst.groups_colors(1, :), 'Value', 1);          
            uicontrol('Parent', box, 'Style', 'text', 'String', 'Combined');
            sz = [25, -1];
            for g = 1:g_config.GROUPS
                if ~isempty(g_config.GROUPS_DESCRIPTION)
                    str = g_config.GROUPS_DESCRIPTION{g};
                else
                    str = sprinttf('Group %d', g);
                end
                inst.group_checkboxes = [ inst.group_checkboxes, ...
                                           uicontrol('Parent', box, 'Style', 'checkbox', 'String', '', 'Callback', @inst.update_callback, 'BackgroundCol', inst.groups_colors(g + 1, :)) ...
                                         ];                
                uicontrol('Parent', box, 'Style', 'text', 'String', str);
                sz = [sz, 25, -1];
            end                                    
            set(box, 'Sizes', sz);
            set(inst.common_controls_box, 'Sizes', [500, -1]);
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
                        
            strings = {'** all **'};            
            for i = 1:inst.results.nclusters
                if inst.results.cluster_class_map(i) == 0
                    lbl = g_config.UNDEFINED_TAG_ABBREVIATION;
                else
                    lbl = inst.results.classes(inst.results.cluster_class_map(i)).abbreviation;
                end
                nclus = sum(inst.results.cluster_index == i);
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
            global g_config;
            f = gcf;
            figure(inst.window);
            vis = get(inst.window, 'Visible');            
                        
            inst.groups = arrayfun( @(h) get(h, 'value'), inst.group_checkboxes);
            
            trial_type = get(inst.trial_type_combo, 'value');
            first_trial = get(inst.first_trial_combo, 'value');            
            last_trial = get(inst.last_trial_combo, 'value');
            inst.trials = zeros(1, g_config.TRIALS);
            sig = sign(last_trial - first_trial);
            if sig == 0
                sig = 1;
            end
            inst.trials(first_trial:sig:last_trial) = 1;
            if trial_type > 1
                inst.trials = inst.trials & (g_config.TRIAL_TYPE == trial_type - 1);
            end                
            
            inst.cluster = get(inst.cluster_combo, 'value') - 1;            
            
            if strcmp(vis, 'on')                
                switch tabnr
                    case 1 % show features
                        inst.single_features.update;
                    case 2
                        inst.clusters.update;
                    case 3
                        inst.features_evolution.update;                       
                    case 4
                        inst.correlations.update;                        
                    case 5
                        inst.classes.update;
                    otherwise
                        error('Ehm, seriously?');
                end
            end
            figure(f);
        end                                                   
    end        
end