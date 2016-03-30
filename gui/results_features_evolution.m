classdef results_features_evolution < handle

    properties(GetAccess = 'protected', SetAccess = 'protected')
        window = [];    
        parent = [];
        axis = [];
        controls_box = [];
        feature_combo = [];
        plot_combo = []; 
        full_check = [];        
    end
    
    methods
        function inst = results_features_evolution(par, par_wnd)                        
            inst.window = uiextras.VBox('Parent', par_wnd);
            inst.parent = par;            
        end
        
        function update(inst)
            global g_config;
            
            if isempty(inst.axis)                
                inst.axis = [inst.axis, axes('Parent', inst.window)];                
                inst.controls_box = uiextras.HBox('Parent', inst.window);
                set(inst.window, 'Sizes', [-1, 40]);
                
                feat = {};
                for i = 1:length(inst.parent.feat)
                    att = g_config.FEATURES{inst.parent.feat(i)};
                    feat = [feat, att{2}];
                end
                
                % create other controls            
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'Feature:');            
                inst.feature_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', 'String', feat, 'Callback', @inst.update_plots);
                
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'Plot:');            
                inst.plot_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', 'String', {'Lines + 95% CI', 'Lines', 'Box-plot'}, 'Callback', @inst.update_plots);
                set(inst.controls_box, 'Sizes', [100, 200, 100, 200]);
                
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
            feat = get(inst.feature_combo, 'value');
            
            if full
                traj = inst.parent.traj.parent;                
            else
                traj = inst.parent.traj;                
            end
            
            feat_val = traj.compute_features(inst.parent.feat(feat));                
            groups = arrayfun( @(t) t.group, traj.items);       
            trials = arrayfun( @(t) t.trial, traj.items);         
            if inst.parent.trial_type > 0
                types = arrayfun( @(t) t.trial_type, traj.items);    
            else
                types = zeros(1, traj.count);
            end
            
            vals = {};
            set(inst.parent.window, 'currentaxes', inst.axis);
            hold off;
            for g = 1:length(grps)
                if ~grps(g) 
                    continue;
                end
                if g == 1
                    sel = ones(1, traj.count);
                else
                    sel = groups == g - 1;                        
                end
                % collect all the values for each trial
                vals_trial = {};
                for t = 1:g_config.TRIALS
                    if inst.parent.trials(t) == 1
                        vals_trial = [vals_trial, feat_val(sel & trials == t & types == inst.parent.trial_type)];
                    end
                end
                
                switch(plt)
                    case 1
                        % average each value                        
                        shadedErrorBar( 1:length(vals_trial) ....
                            , arrayfun( @(idx) mean(vals_trial{idx}), 1:length(vals_trial)) ...
                            , arrayfun( @(idx) 1.95*std(vals_trial{idx})/sqrt(length(vals_trial{idx})), 1:length(vals_trial)) ...
                            , {'Color', inst.parent.groups_colors(g, :), 'LineWidth', 2}, 1);                                                        
                    case 2    
                        % average each value                        
                        plot( 1:length(vals_trial) ....
                            , arrayfun( @(idx) mean(vals_trial{idx}), 1:length(vals_trial)) ...
                            , '-', 'Color', inst.parent.groups_colors(g, :), 'LineWidth', 2);                                                        
                    case 3                        
                end
                
                hold on;
            end                
        end
    end        
end
