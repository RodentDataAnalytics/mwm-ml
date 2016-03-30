classdef results_full_trajectories < handle
    
    properties(GetAccess = 'protected', SetAccess = 'protected')
        window = [];
        parent = [];              
        grid = [];
        grid_box = [];
        panels = [];
        controls_box = [];
        axis = [];        
        sel_combos  = [];
        nx_combo = [];
        ny_combo = [];
        
        measures_list = {};        
    end
    
    methods
        function inst = results_full_trajectories(par, par_wnd)
            global g_config;
            inst.parent = par;
            inst.window = uiextras.VBox('Parent', par_wnd);
            
            for i = 1:length(g_config.DATA_REPRESENTATION)
                par = g_config.DATA_REPRESENTATION{i};
                switch par{2}
                    case base_config.DATA_TYPE_SCALAR_FIELD
                        inst.measures_list = [inst.measures_list, ...
                            {{ par{1}, i, []}, ...
                            { [par{1} ' (mean)'], i, @(vals) mean(vals(:, 4)) }, ...
                            { [par{1} ' (max)'], i, @(vals) max(vals(:, 4)) }, ...
                            { [par{1} ' (min)'], i, @(vals) min(vals(:, 4)) }} ...
                        ];
                    case base_config.DATA_TYPE_EVENTS
                        inst.measures_list = [inst.measures_list, ...
                            {{ par{1}, i, []}, ...
                            { [par{1} ' (count)'], i, @(vals) sum(vals(:, 4) > 0) }} ...                                  
                        ];
                end
            end
        end
        
        function update(inst)                           
            if isempty(inst.grid)                                
                inst.grid_box = uiextras.VBox('Parent', inst.window);                  
                inst.controls_box = uiextras.HBox('Parent', inst.window);  
                set(inst.window, 'Sizes', [-1, 40]);                
                                
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'NX:');
                inst.nx_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', 'String', {'1', '2', '3', '4', '5', '6'}, 'Callback', {@inst.update_layout});
                set(inst.nx_combo, 'value', 2);
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'NY:');
                inst.ny_combo = uicontrol('Parent', inst.controls_box, 'Style', 'popupmenu', 'String', {'1', '2', '3', '4', '5', '6'}, 'Callback', {@inst.update_layout});    
                set(inst.ny_combo, 'value', 2);                   
                
                inst.update_layout;                                    
            else
                inst.update_plots;
            end            
        end
        
        function update_layout(inst, source, event_data)
            if ~isempty(inst.grid)                
                delete(inst.grid);
            end
                        
            inst.grid = uiextras.Grid('Parent', inst.grid_box);
            nx = get(inst.nx_combo, 'value');
            ny = get(inst.ny_combo, 'value');
            if ~isempty(inst.axis)
                arrayfun( @(x) delete(x), inst.axis);
            end            
            inst.axis = [];
            inst.panels = [];
            inst.sel_combos = [];
            
            for i = 1:nx*ny                              
                vbox = uiextras.VBox('Parent', inst.grid);
                % create one box for the axis (created later)
                inst.axis = [inst.axis, axes('Parent', vbox, 'Visible', 'off')];
                box = uiextras.HBox('Parent', vbox);
                
                uicontrol('Parent', box, 'Style', 'text', 'String', 'Measure:');
                strs = {'None'};
                for j = 1:length(inst.measures_list)                    
                    par = inst.measures_list{j};
                    strs = [strs, par{1}];
                end
                inst.sel_combos = [inst.sel_combos, uicontrol('Parent', box, 'Style', 'popupmenu', 'String', strs, 'Callback', @inst.update_plots)];
                set(vbox, 'Sizes', [-1, 40]);              
                set(box, 'Sizes', [50, 200]);
            end                                
                            
            set(inst.grid, 'RowSizes', ones(1, nx)*-1, 'ColumnSizes', ones(1, nx)*-1); 
            inst.update_plots;
        end
        
        function update_plots(inst, source, event_data)
            global g_config;
            nx = get(inst.nx_combo, 'value');
            ny = get(inst.ny_combo, 'value');            
            grp = inst.parent.group;
            ti = inst.parent.first_trial;
            tf = inst.parent.last_trial;
            clr = [ [0, 0, 1]; [1, 0, 0]; [0, 1, 0]];
            hold off;
            for i = 1:nx*ny                              
                sel = get(inst.sel_combos(i), 'value');
                if sel > 1
                    % create an axis
                    % stupid_box = uiextras.HBox('Parent', inst.traj_measures_panels(i));
                    % inst.traj_measures_axis = [inst.traj_measures_axis , axes('Parent', stupid_box)];
                    set(inst.axis(i), 'Visible', 'on');
                    set(inst.parent.window, 'currentaxes', inst.axis(i));
                    meas_param = inst.measures_list{sel - 1};
                    f = meas_param{3};
                    dr = meas_param{2};
                    dr_param = g_config.DATA_REPRESENTATION{meas_param{2}};
                    % data type
                    dt = dr_param{2}; 
                    % plot something
                    data = {};
                    for g = 1:g_config.GROUPS
                        for t = 1:inst.parent.traj.parent.count
                            tg = inst.parent.traj.parent.items(t).group;
                            if grp == 1 || (grp == 2 && g == tg) || (grp - 2) == tg
                                % see if trial matches                                                               
                                if inst.parent.traj.parent.items(t).trial >= ti && inst.parent.traj.parent.items(t).trial <= tf
                                    tmp = inst.parent.traj.parent.items(t).data_representation(dr);
                                    % see if we have continuous values or
                                    % one squashing function                                     
                                    if isempty(f)                                        
                                        switch dt
                                            case base_config.DATA_TYPE_SCALAR_FIELD                                                                                                
                                                data = [data, tmp(:, [1, 4])];
                                            case base_config.DATA_TYPE_EVENT
                                                data = [data, tmp(find(tmp(:, 4) > 0), 1)];
                                            otherwise
                                                error('ops')
                                        end
                                    else
                                        % single values
                                        data = [data, f(tmp)];
                                    end
                                end
                            end
                        end
                        % see what to plot
                        if ~isempty(f)
                           % scalar values -> plot histogram
                           bar(hist(data{:}, 15) ./ sum(hist(data{:}, 15)), 'FaceColor', clr(g, :));
                        else                            
                            switch dt
                                case base_config.DATA_TYPE_SCALAR_FIELD
                                    % plot individual lines
                                    for t = 1:length(data)                                        
                                        tmp = data{t};
                                        plot(tmp(:, 1), tmp(:, 2), '-', 'Color', clr(g, :));
                                        hold on;
                                    end
                                case base_config.DATA_TYPE_EVENT
                                    
                            end                                
                        end
                      
                        if grp == 1
                            break;
                        end                                                                                                
                        
                    end                                        
                end
            end
        end
    end    
end

