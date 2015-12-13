function browse_trajectories(labels_fn, traj, varargin)
%BROWSE_TRAJECTORIES Summary of this function goes here                
    % no filter at first
    global g_config;
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern'));    
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/cm_and_cb_utilities'));
    
    filter = 1:traj.count;
    sorting = 1:traj.count;           
            
    [tags, disp_feat, cluster_feat, selection, ref_set, n_hor, n_ver, name] = process_options(varargin, ...
                'Tags', g_config.TAGS, 'Features', g_config.DEFAULT_FEATURE_SET, ...
                'ClusteringFeatures', g_config.CLUSTERING_FEATURE_SET, ...
                'UserSelection', [], 'ReferenceClassification', [], ...
                'ItemsHor', 2, 'ItemsVer', 2, 'Name', 'Trajectories tagging' ...
    );
    
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern'));
        
    % create main window
    f = figure('Visible','off', 'name', name, ...
        'Position', [200, 200, 1280, 800], 'Menubar', 'none', 'Toolbar', 'none', 'resize', 'on');
    
    % base layout
    bg_box = uiextras.VBox('Parent', f);           
                  
    % combine display + clustering features
    feat = [cluster_feat setdiff(disp_feat, cluster_feat)];
 
    %%
    %% Create controls
    %%%
    % control buttons box
    views_box = uiextras.VBox('Parent', bg_box);
    ctrl_box = uiextras.HBox('Parent', bg_box);
    set(bg_box, 'Sizes', [-1 100] );
    % box with additional controls on the left    
    filter_panel = uiextras.BoxPanel('Parent', ctrl_box, 'Title', 'Filter/Sort');
    filter_box = uiextras.VBox('Parent', filter_panel);
    % box with left navigation controls
    lnav_box = uiextras.VBox('Parent', ctrl_box);
    % middle status box
    stat_box = uiextras.VBox('Parent', ctrl_box);
    % box with right navigation controls
    rnav_box = uiextras.VBox('Parent', ctrl_box);
    % box with additional controls on the right       
    clus_panel = uiextras.BoxPanel('Parent', ctrl_box, 'Title', 'Clustering');
    clus_box = uiextras.VBox('Parent', clus_panel);
    % and another one
    layout_panel = uiextras.BoxPanel('Parent', ctrl_box, 'Title', 'Layout');
    layout_box = uiextras.VBox('Parent', layout_panel);
    
    set(ctrl_box, 'Sizes', [200 75 -1 75 200 350]);
    % trajectories navigation
    uicontrol('Parent', lnav_box, 'Style', 'pushbutton', 'String', '<-', 'Callback', {@previous_callback});
    uicontrol('Parent', rnav_box, 'Style', 'pushbutton', 'String', '->', 'Callback',{@next_callback});    
    uicontrol('Parent', lnav_box, 'Style', 'pushbutton', 'String', '<<-', 'Callback',{@previous2_callback});
    uicontrol('Parent', rnav_box, 'Style', 'pushbutton', 'String', '->>', 'Callback',{@next2_callback});
    uicontrol('Parent', lnav_box, 'Style', 'pushbutton', 'String', '<<<-', 'Callback',{@previous3_callback});
    uicontrol('Parent', rnav_box, 'Style', 'pushbutton', 'String', '->>>', 'Callback',{@next3_callback});
    
    % status text (middle)
    status_handle = uicontrol('Parent', stat_box, 'Style', 'text', 'String', '');
    % clustering controls        
    uicontrol('Parent', clus_box, 'Style', 'text', 'String', '# of clusters:');        
    vals = arrayfun( @(x) sprintf('%d', x), 1:500, 'UniformOutput', 0);
    hclusters = uicontrol('Parent', clus_box, 'Style', 'popupmenu', 'String', vals);         
    hbox = uiextras.HBox('Parent', clus_box);
    hcv = uicontrol('Parent', hbox, 'Style', 'checkbox', 'String', 'Enable CV');    
    hshow_results = uicontrol('Parent', hbox, 'Style', 'checkbox', 'String', 'Pop-out Res.', 'Callback', {@popout_results_callback});    
    uicontrol('Parent', clus_box, 'Style', 'pushbutton', 'String', 'Cluster', 'Callback', {@cluster_callback});
    % feature sorting control
    hfilter = [];
    sortstr = {'** none **', '** distance to centre (max) **', '** distance to centre (euclidean) **', '** combined **', '** random **' };
    for i = 1:length(feat) % have to do this way because of stupid matlab        
        tmp = g_config.FEATURES{feat(i)};
        sortstr = [sortstr, tmp{2}];
    end
    sort_box = uiextras.HBox('Parent', filter_box);
    uicontrol('Parent', sort_box, 'Style', 'text', 'String', 'Sort:');        
    hsort = uicontrol('Parent', sort_box, 'Style', 'popupmenu', 'String', sortstr, 'Callback', {@sorting_callback});
    hsort_reverse = uicontrol('Parent', filter_box, 'Style', 'checkbox', 'String', 'Reverse', 'Callback', {@sorting_callback});       
    set(sort_box, 'Sizes', [40, -1]);
    % cluster navigation and control (note: combo-box is created elsewhere
    % since it is dynamic
    filter_combo_box = uiextras.HBox('Parent', filter_box);
    filter_nav_box = uiextras.HButtonBox('Parent', filter_box);
    hfilter_prev = uicontrol('Parent', filter_nav_box, 'Style', 'pushbutton', 'String', '<-', 'Callback', {@filter_prev_callback});    
    hfilter_next = uicontrol('Parent', filter_nav_box, 'Style', 'pushbutton', 'String', '->', 'Callback', {@filter_next_callback});
    nitems_filter = 0;
    % layout controls
    box = uiextras.HBox('Parent', layout_box);
    uicontrol('Parent', box, 'Style', 'text', 'String', 'NX:');
    xviews_handle = uicontrol('Parent', box, 'Style', 'popupmenu', 'String', {'1', '2', '3', '4', '5', '6'}, 'Callback', {@layout_change_callback});
    set(xviews_handle, 'value', n_ver);
    uicontrol('Parent', box, 'Style', 'text', 'String', 'NY:');
    yviews_handle = uicontrol('Parent', box, 'Style', 'popupmenu', 'String', {'1', '2', '3', '4', '5', '6'}, 'Callback', {@layout_change_callback});      
    set(yviews_handle, 'value', n_hor);
    uicontrol('Parent', box, 'Style', 'text', 'String', 'Tol:');
    tol_str = arrayfun( @(x) num2str(x), 1:25, 'UniformOutput', 0);
    simplify_tol_handle = uicontrol('Parent', box, 'Style', 'popupmenu', 'String', tol_str, 'Callback', {@layout_change_callback});
    set(simplify_tol_handle, 'value', 5);
   
    % build a list with all the possible data representations
    strs = {};
    for i = 1:length(g_config.DATA_REPRESENTATION)
        tmp = g_config.DATA_REPRESENTATION{i};
        strs = [strs, tmp{1}];
    end
    if ~isempty(traj.parent)
        full_status = 'on';
    else
        full_status = 'off';
    end
    strs = ['None', strs];
    % 1st combo: main view
    box = uiextras.HBox('Parent', layout_box);    
    uicontrol('Parent', box, 'Style', 'text', 'String', 'Main:');
    main_view_combo = uicontrol('Parent', box, 'Style', 'popupmenu', 'String', strs, 'Callback', {@layout_change_callback}, 'Value', 2);        
    main_view_dir_check = uicontrol('Parent', box, 'Style', 'checkbox', 'String', 'Vec.', 'Callback', {@layout_change_callback});    
    main_view_full_combo = uicontrol('Parent', box, 'Style', 'popupmenu', 'String', strs, 'Callback', {@layout_change_callback}, 'Enable', full_status);
    set(box, 'Sizes', [50, -1, 50, -1]);
    % 2nd combo: secondary view 1    
    box = uiextras.HBox('Parent', layout_box);    
    uicontrol('Parent', box, 'Style', 'text', 'String', 'Sec. 1:');
    sec_view_combos = [uicontrol('Parent', box, 'Style', 'popupmenu', 'String', strs, 'Callback', {@layout_change_callback})];      
    sec_view_dir_check = uicontrol('Parent', box, 'Style', 'checkbox', 'String', 'Vec.', 'Callback', {@layout_change_callback});    
    sec_view_full_combos = [uicontrol('Parent', box, 'Style', 'popupmenu', 'String', strs, 'Callback', {@layout_change_callback}, 'Enable', full_status)];
    set(box, 'Sizes', [50, -1, 50, -1]);
    % 3rd combo: secondary view 2
    box = uiextras.HBox('Parent', layout_box);    
    uicontrol('Parent', box, 'Style', 'text', 'String', 'Sec. 2:');
    sec_view_combos = [ sec_view_combos, ...
                        uicontrol('Parent', box, 'Style', 'popupmenu', 'String', strs, 'Callback', {@layout_change_callback}) ...
                      ];     
    sec_view_dir_check = [sec_view_dir_check, uicontrol('Parent', box, 'Style', 'checkbox', 'String', 'Vec.', 'Callback', {@layout_change_callback})];
    sec_view_full_combos = [sec_view_full_combos, uicontrol('Parent', box, 'Style', 'popupmenu', 'String', strs, 'Callback', {@layout_change_callback}, 'Enable', full_status)];
    set(box, 'Sizes', [50, -1, 50, -1]);
    
    sec_view_handles = [];
    
    views_grid = [];    
    views_panels = [];
    axis_handles = [];initialize
    desc_handles = [];
    view_panels = [];
    cb_handles = [];
    simplify_level_prev = 0;
    
    ntags = length(tags);  
    % normalization values for speed and other scalar values
    data_repr_norm = zeros(1, length(g_config.DATA_REPRESENTATION));
    data_repr_off  = zeros(1, length(g_config.DATA_REPRESENTATION));
    
    create_views();
                
    cur = 1; %current index
    % read labels if we already have something
    labels_traj = zeros(traj.count, length(tags));
    if exist(labels_fn, 'file')
        [labels_data, label_tags] = traj.read_tags(labels_fn, g_config.TAG_TYPE_ALL);
        [labels_map, labels_idx] = traj.match_tags(labels_data, label_tags);
        non_matched = sum(labels_idx == -1);
        if non_matched > 0
            fprintf('Warning: %d unmatched trajectories/segments found!\n', non_matched);
        end
        
        % match tags with complete list of tags
        for i = 1:length(label_tags)
            for j = 1:length(tags)
               if strcmp(label_tags(i).abbreviation, tags(j).abbreviation)
                   labels_traj(:, j) = labels_map(:, i);
                   break;
               end
            end
        end
    end
    
    classif_res = [];
    distr_status = '';
    covering = [];
    
    feat_values = traj.compute_features(feat);
    segments_map = [];
    diff_set = [];
     
    update_filter_combo;
    show_trajectories;
    results_window = [];
    set(f, 'Visible', 'on');            
    
    
    %%
    %% nested functions
    %%
    function [nx, ny] = number_of_views()
        nx = get(xviews_handle, 'value');
        ny = get(yviews_handle, 'value');
    end

    function create_views()
        % create base grid
        if ~isempty(views_grid)
            delete(views_grid);
        end
        views_grid = uiextras.Grid('Parent', views_box);
        views_panels = [];
        axis_handles = [];
        view_panels = [];
        desc_handles = [];
        cb_handles = [];
        sec_view_handles = [];        
        
        [nx, ny] = number_of_views();
        main1 = get(main_view_combo, 'value');
        main2 = get(main_view_full_combo, 'value');
        main = (main1 > 1 || main2 > 1);
        sec1 = get(sec_view_combos(1), 'value');
        sec1main = get(sec_view_full_combos(1), 'value');        
        sec2 = get(sec_view_combos(2), 'value');
        sec2main = get(sec_view_full_combos(2), 'value');
        sec = (sec1 > 1 || sec2 > 1 || sec1main > 1 || sec2main > 1);
        
        for j =1:nx
            for i = 1:ny
                view_panels = [view_panels, uiextras.BoxPanel('Parent', views_grid)];
                % boxes for the view (a vertical one for the checkboxes)
                view_hbox = uiextras.HBox('Parent', view_panels(end));
                                                
                % trajectory display
                view_vbox = uiextras.VBox('Parent', view_hbox);
                % do we have any secondary views ?
                if (sec)                                
                    hbox = uiextras.HBox('Parent', view_vbox);                    
                    if main
                        axis_handles = [axis_handles, axes('Parent', hbox)];
                    else
                        uicontrol('Parent', hbox, 'Style', 'text', 'String', 'None');
                    end
                    % create another box for the secondary views
                    vbox = uiextras.VBox('Parent', hbox);
                    if (sec1 > 1)
                        sec_view_handles = [sec_view_handles , axes('Parent', vbox)];
                    else
                        sec_view_handles = [sec_view_handles, uicontrol('Parent', vbox, 'Style', 'text', 'String', 'None')];
                    end
                    if (sec2 > 1)
                        sec_view_handles = [sec_view_handles, axes('Parent', vbox)];
                    else
                        sec_view_handles = [sec_view_handles, uicontrol('Parent', vbox, 'Style', 'text', 'String', 'None')];        
                    end
                else                    
                    if main
                        axis_handles = [axis_handles, axes('Parent', view_vbox)];
                    else
                        uicontrol('Parent', view_vbox, 'Style', 'text', 'String', 'None');
                    end
                end
                % trajectory description            
                desc_handles = [desc_handles, uicontrol('Parent', view_vbox, 'Style', 'text')];
                set(view_vbox, 'Sizes', [-1, 35]);
                
                % check boxes with tags
                % yet another box
                cb_box = uiextras.VButtonBox('Parent', view_hbox);
                set(view_hbox, 'Sizes', [-1, 50]);       
                hcb_new = [];
                for k = 1:ntags
                    txt = tags(k).abbreviation;
                    hcb_new = [ hcb_new, ...
                                  uicontrol('Parent', cb_box, 'Style', 'checkbox', 'String', txt, 'Callback', {@checkbox_callback}) ...
                              ];
                end
                cb_handles = [cb_handles; hcb_new];
            end
        end
        
        set(views_grid, 'RowSizes', -1*ones(1, ny), 'ColumnSizes', -1*ones(1, nx));
    end  
    
    function update_filter_combo
        if ~isempty(hfilter)
            delete(hfilter);
            hfilter = [];
        end
        strings = {'** all **', '** tagged **', '** untagged **', '** isolated **', '** suspicious **', '** selection **', '** compare **', '** errors **'};
        if ~isempty(classif_res)
            strings = [strings, arrayfun( @(t) t.description, classif_res.classes, 'UniformOutput', 0)];
        end     
            
        if ~isempty(classif_res)
            % isolated/lonely segments            
            isol = ~covering;
            for i = 1:max(classif_res.nclusters)
                if classif_res.cluster_class_map(i) == 0
                    lbl = g_config.UNDEFINED_TAG_ABBREVIATION;
                else
                    lbl = classif_res.classes(classif_res.cluster_class_map(i)).abbreviation;
                end
                nclus = sum(classif_res.cluster_index == i);
                strings = [strings, sprintf('Cluster #%d (''%s'', N=%d, L=%d, I=%d)', ... 
                                            i, lbl, nclus, ...
                                            length(find(sum(labels_traj(classif_res.cluster_index == i, :), 2) > 0)), ...
                                            sum(isol(classif_res.cluster_index == i)))];  
            end
        end
        
        hfilter = uicontrol('Parent', filter_combo_box, 'Style', 'popupmenu', 'String', strings, 'Callback', {@combobox_filter_callback});
        nitems_filter = length(strings);
    
        combobox_filter_callback(0, 0);
    end
        
    function plot_trajectory(tr, repr, vec, tol, hl)
        lw = 1.2;
        lc = [0 0 0];
        if hl
            hold on;
            lw = 2;
            lc = [0 1 0];
        else        
            axis off;
            daspect([1 1 1]);                      
            rectangle('Position',[g_config.CENTRE_X - g_config.ARENA_R, g_config.CENTRE_X - g_config.ARENA_R, g_config.ARENA_R*2, g_config.ARENA_R*2],...
                'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3);
            hold on;
            axis square;
            % see if we have a platform to draw
            if isprop(g_config, 'PLATFORM_X')
                rectangle('Position',[g_config.PLATFORM_X - g_config.PLATFORM_R, g_config.PLATFORM_Y - g_config.PLATFORM_R, 2*g_config.PLATFORM_R, 2*g_config.PLATFORM_R],...
                    'Curvature',[1,1], 'FaceColor',[1, 1, 1], 'edgecolor', [0.2, 0.2, 0.2], 'LineWidth', 3);             
            end
        end
        
        dr_param = g_config.DATA_REPRESENTATION{repr};
        dt = dr_param{2};
        
        pts = tr.data_representation(repr, 'SimplificationTolerance', tol);
        
        % if the tolerance changed re-scale everything
        if tol ~= simplify_level_prev
            data_repr_norm = zeros(1, length(data_repr_norm));
            simplify_level_prev = tol;
        end    
                               
        if dt == base_config.DATA_TYPE_COORDINATES
            if vec
                % simplify trajectory
                sz = getpixelposition(gca);
                
                for ii = 2:size(pts, 1)                    
                    arrow(pts(ii - 1, 2:3), pts(ii, 2:3), 'LineWidth', lw, 'Length', min(sz(3), sz(4))*0.04, 'FaceColor', lc, 'EdgeColor', lc);
                end
            else
                plot(pts(:,2), pts(:,3), '-', 'LineWidth', lw, 'Color', lc);
            end
        elseif dt == base_config.DATA_TYPE_SCALAR_FIELD            
            % normalize values
            if data_repr_norm(repr) == 0
               val_min = []; 
               val_max = [];
               for ii = 1:length(traj.items)
                   tmp = traj.items(ii).data_representation(repr, 'SimplificationTolerance', tol);
                   if isempty(val_min)
                       val_min = min(tmp(:, 4));
                       val_max = max(tmp(:, 4));
                   else
                       val_min = min(val_min, min(tmp(:, 4)));
                       val_max = max(val_max, max(tmp(:, 4)));
                   end
               end
               data_repr_norm(repr) = 1/(val_max - val_min);
               data_repr_off(repr) = val_min;
            end
            pts(:, 4) = (pts(:, 4) - data_repr_off(repr))*data_repr_norm(repr); 
                                                                 
            cm = jet;
            n = 20;
            cm = cmapping(n + 1, cm);
            fac = 1/n;
            np = size(pts, 1);
                        
            if vec
                clr = cm(floor(pts(:, 4) ./ repmat(fac, np, 1)) + 1, :);
                sz = getpixelposition(gca);
                for ii = 2:size(pts, 1)
                    arrow(pts(ii - 1, 2:3), pts(ii, 2:3), 'FaceColor', clr(ii, :), 'EdgeColor', clr(ii, :), 'LineWidth', lw, 'Length', min(sz(3), sz(4))*0.04);
                end 
            else
                clr = floor(pts(:, 4) ./ repmat(fac, np, 1) + 1);
                z = zeros(1,np);
                surface( [pts(:,2)'; pts(:,2)'], [pts(:,3)'; pts(:,3)'], [z;z], [clr'; clr'], ...
                     'facecol','no', 'edgecol', 'interp', 'linew', 2);            
                colormap(cm);
            end
        elseif dt == base_config.DATA_TYPE_EVENTS
            % plot coordinates            
            plot(pts(:,2), pts(:,3), '-', 'LineWidth', lw, 'Color', [0 0 0]);
            % and plot points for the events
            pos = find(pts(:,4) > 0);
            sz = getpixelposition(gca);
               
            r = sz(3)*0.005;
            for kk = 1:length(pos)
                rectangle('Position', [pts(pos(kk), 2) - r, pts(pos(kk), 3) - r, 2*r, 2*r], 'Curvature', [1,1], 'FaceColor', [1 0 0]);                
            end
        end
                
        set(gca, 'LooseInset', [0,0,0,0]);
    end

    function show_trajectories                
        [nx, ny] = number_of_views();
        for i = 1:nx*ny
            if cur + i < length(filter)
                traj_idx = filter(sorting(cur + i - 1));
                
                % plot views
                for k = 1:3                                        
                    if k == 1                        
                        idx = get(main_view_combo, 'value') - 1;
                        idxfull = get(main_view_full_combo, 'value') - 1;
                        if idx == 0 && idxfull == 0
                            continue;
                        end
                        vec = get(main_view_dir_check, 'value');
                        set(f, 'currentaxes', axis_handles(i));
                    else
                        if isempty(sec_view_handles)
                            break;
                        end                        
                        idx = get(sec_view_combos(k - 1), 'value') - 1; % second -1 because of the "none"
                        idxfull = get(sec_view_full_combos(k - 1), 'value') - 1; % second -1 because of the "none"
                        vec = get(sec_view_dir_check(k - 1), 'value');
                        if idx == 0 && idxfull == 0
                            continue; % "none"
                        end
                        set(f, 'currentaxes', sec_view_handles((i - 1)*2 + k - 1));
                    end
                       
                    hasfull = idxfull > 0 && idxfull <= length(g_config.DATA_REPRESENTATION);
                    if hasfull
                        % look for parent trajectory
                        id = traj.items(traj_idx).identification;
                        for l = 1:traj.parent.count
                            id2 = traj.parent.items(l).identification;
                            len = length(id) - 1;
                            if isequal(id(1:len), id2(1:len))                               
                                plot_trajectory(traj.parent.items(l), idxfull, 0, 0, 0);                                
                                break;
                            end
                        end                                                
                    end
                    
                    if idx > 0 && idx <= length(g_config.DATA_REPRESENTATION)
                        if vec
                            tol = get(simplify_tol_handle, 'value')*0.01*g_config.ARENA_R;
                        else
                            tol = 0;
                        end
                                                                                                                                                
                        plot_trajectory(traj.items(traj_idx), idx, vec, tol, hasfull);
                    end                                        
                end
                                
                hold on;                
                if ~isempty(covering)
                    if covering(traj_idx)
                        rectangle('Position', [80, 80, 10, 10], 'FaceColor', [0.5, 1, 0.5]);                    
                    else
                        rectangle('Position', [80, 80, 10, 10], 'FaceColor', [1, 0.5, 0.5]);
                    end
                end                                    
                
                % update the status text with feature values
                str = '';
                for j = 1:length(feat)
                    if j > 1
                        str = strcat(str, ' | ');
                    end
                    tmp = g_config.FEATURES{feat(j)};
                    str = strcat(str, sprintf('%s: %.4f', tmp{1}, feat_values(traj_idx, j)));                    
                end
                set(desc_handles(i), 'String', str);
                
                % put segment identification in the title
                str = sprintf('id: %d | set: %d | track: %d | session: %d | trial:%d +%dcm', traj.items(traj_idx).id, traj.items(traj_idx).set, traj.items(traj_idx).track, traj.items(traj_idx).session, traj.items(traj_idx).trial, round(traj.items(traj_idx).offset));
                if ~isempty(classif_res)
                    str = sprintf('%s || cluster #%d', str, classif_res.cluster_index(traj_idx));
                end               
                set(view_panels(i), 'Title', str);
                
                % update checkboxes
                handles = cb_handles(i, :);
                arrayfun(@(h,j) set(h, 'Value', labels_traj(traj_idx, j)), handles(1:(length(handles) - 1)), 1:(length(handles) - 1));  
    
                for j = 1:(length(handles) - 1)
                    % by default no color
                    c = get(gcf,'DefaultUicontrolBackgroundCol');
                                                                              
                    if ~isempty(classif_res) 
                        idx = -1;
                        if strcmp(tags(j).abbreviation, g_config.UNDEFINED_TAG_ABBREVIATION)                                                            
                            idx = 0;
                        else
                            for k = 1:length(classif_res.classes)                            
                                if strcmp(tags(j).abbreviation, classif_res.classes(k).abbreviation)                                
                                    idx = k;
                                    break;
                                end
                            end                        
                        end
  
                         % see if we have a segment for comparison
                        if ~isempty(ref_set) && diff_set(traj_idx) == idx
                            c = [0.6 0.0 0.0];                            
                        end
                    
                        if idx ~= -1 && classif_res.class_map(traj_idx) == idx                            
                            if labels_traj(traj_idx, j)                                
                                c = [0.2, 1., 0.2];                            
                            else
                                if ~isempty(find(labels_traj(traj_idx, :)))                              
                                    c = [1., 0.2, 0.2];                            
                                else
                                    c = [.5, 0.5, 0.9];
                                end
                            end                                                                               
                        end                                                
                    end
                    set(handles(j), 'BackgroundCol', c); 
                end
                
                % "unknown" is treated separatedly
                if ~isempty(classif_res) && (classif_res.class_map(traj_idx) == -1)
                    set(handles(end), 'BackgroundCol', [1., 1., 0.3]);                            
                else
                    set(handles(end), 'BackgroundCol', get(gcf,'DefaultUicontrolBackgroundCol'));                            
                end
            end
        end
        update_status;
    end   
        
    function save_data        
        % save values from screen
        [nx, ny] = number_of_views;
        for i = 0:nx*ny - 1
            if length(filter) >= cur + i
                vals = arrayfun(@(h) get(h, 'Value'), cb_handles(i + 1, :));                
                labels_traj(filter(sorting(cur + i)), :) = vals;
            end
        end
        
        traj.save_tags(labels_fn, tags, labels_traj, []);
    end

    function update_status
        [nx, ny] = number_of_views;
        str = sprintf('%d to %d from %d\n\n', cur, cur + nx*ny - 1, length(filter));
        first = 1;
        for i = 1:length(tags)
            n = sum(labels_traj(filter, i));            
            if n > 0
                if first
                    first = 0;
                    str = strcat(str, sprintf('\n%s: %d  ', tags(i).abbreviation, n));
                else
                    str = strcat(str, sprintf(' | %s: %d', tags(i).abbreviation, n));
                end
            end
        end
        if ~isempty(classif_res)
            pcov = sum(covering) / traj.count;
            str = strcat(str, sprintf('\nErrors: %d (%.3f%%) | Unknown: %.1f%% | Coverage: %.1f%%', ...
                classif_res.nerrors, classif_res.perrors*100, classif_res.punknown*100, pcov*100)); 
        end
        if ~isempty(diff_set)            
            str = strcat(str, sprintf(' | Agreement: %.1f%%', 100.* ...
                sum(diff_set == 0) / sum(diff_set > -1) ...
            ));
        end
        
        str = sprintf('%s\n%s', str, distr_status);        
        set(status_handle, 'String', str);
    end
    
    function checkbox_callback(source, eventdata)
        save_data;   
        update_status;
    end

    function combobox_filter_callback(source, eventdata)
        val = get(hfilter, 'value');
        switch val
            case 1
                % everyone
                filter = 1:traj.count;
            case 2                        
                % everyone labelled                filter = find(sum(labels_traj, 2) > 0);                            

                filter = find(sum(labels_traj, 2) > 0);                            
            case 3                        
                % everyone not labelled
                filter = find(sum(labels_traj, 2) == 0);                                        
            case 4
                filter = find(covering == 0);
            case 5
                % "suspicious" guys 
                if ~isempty(classif_res)
                    if isempty(segments_map)
                        [~, ~, segments_map] = classif_res.mapping_ordered(-1, 'MinSegments', 4);
                    end
                    
                    filter = find(segments_map ~= classif_res.class_map & segments_map > 0 & classif_res.class_map > 0);                    
                end
            case 6
                % user selection
                filter = selection;
            case 7
                % reference classification
                if ~isempty(diff_set)                    
                    filter = find(diff_set > 0);
                end
            case 7                     
                % mis-matched classifications      
                if ~isempty(classif_res)
                    filter = classif_res.non_empty_labels_idx(classif_res.errors == 1);            
                else
                    filter = 1:traj.count;
                end
            otherwise
                % classes
                if val <= classif_res.nclasses + 8
                    if classif_res.classes(val - 8).abbreviation == g_config.UNDEFINED_TAG_ABBREVIATION                                    
                        filter = find(classif_res.class_map == 0);
                    else
                        filter = find(classif_res.class_map == (val - 8));                                    
                    end
                else
                   % clusters
                   filter = find(classif_res.cluster_index == (val - classif_res.nclasses - 8));
                end
        end
        % status text string
        if ~isempty(classif_res)
           vals = unique(classif_res.class_map(filter));
           pc = arrayfun( @(v) sum(classif_res.class_map(filter) == v)*100. / length(filter), vals);
           [pc, idx] = sort(pc, 'descend');
           vals = vals(idx);
           distr_status = '';
           for i = 1:length(vals)
                if vals(i) == 0
                    lbl = g_config.UNDEFINED_TAG_ABBREVIATION;
                else
                    lbl = classif_res.classes(vals(i)).abbreviation;
                end
                if i == 1
                    distr_status = strcat(distr_status, sprintf('%s: %.1f%% ', lbl, pc(i)));
                else
                    distr_status = strcat(distr_status, sprintf(' | %s: %.1f%% ', lbl, pc(i)));
                end        
           end
        end
        update_sorting;
        cur = 1;
        show_trajectories;
        
        
        update_filter_navigation();
    end

    function update_sorting
        val = get(hsort, 'value');
        rev = get(hsort_reverse, 'value');
        switch val
            case 1
                sorting = 1:length(filter);              
            case 2                
                % distance to centre of clusters
                middle = (min(feat_values(filter, :)) + max(feat_values(filter, :))) / 2;                
                nz = all(feat_values(filter, :) ~= 0);
                vals = (feat_values(filter, nz) - repmat( middle(nz), length(filter), 1)) ./ repmat( max(feat_values(filter, nz)) - min(feat_values(filter, nz)), length(filter), 1);                                
                dist = max(abs(vals), [], 2);
                % dist = (norm_feat_values(filter, :) - classif_res.centroids(:, classif_res.cluster_idx(filter), :)').^2;
                [~, sorting] = sort(dist);                
            case 3                
                % distance to centre of clusters                
                feat_norm = max(feat_values) - min(feat_values);
                dist = ((feat_values(filter, :) - classif_res.centroids(:, classif_res.cluster_index(filter), :)') / repmat(feat_norm, size(feat_values, 1), 1)).^2;
                [~, sorting] = sort(dist);                            
            case 4
                % distance function
                dist = sum((feat_values(filter, :) ./ repmat( max(feat_values(filter, :)) - min(feat_values(filter, :)), length(filter), 1)).^2, 2);                
                [~, sorting] = sort(dist);                            
            case 5
                % random
                sorting = randperm(length(filter));
            otherwise                        
                % sort by a single feature
                featval = feat_values;
                featval = featval(filter, :);
                [~, sorting] = sort(featval(:, val - 5));                                        
        end
        if rev
            sorting = sorting(end:-1:1);
        end
    end

    function update_filter_navigation()        
        if get(hfilter, 'value') == nitems_filter
            set(hfilter_next, 'Enable', 'off');
        else
            set(hfilter_next, 'Enable', 'on');
        end
        if get(hfilter, 'value') == 1
            set(hfilter_prev, 'Enable', 'off');
        else
            set(hfilter_prev, 'Enable', 'on');
        end
    end
        
    function filter_next_callback(source, eventdata)
        val = get(hfilter, 'value');        
        set(hfilter, 'value', val + 1);
        combobox_filter_callback(0, 0);
    end

    function filter_prev_callback(source, eventdata)
        val = get(hfilter, 'value');        
        set(hfilter, 'value', val - 1);
        combobox_filter_callback(0, 0);
    end    

    function layout_change_callback(source, eventdata)
        create_views;
        show_trajectories;
    end

    function sorting_callback(source, eventdata)
        update_sorting;
        cur = 1;
        show_trajectories;
    end

    function previous_callback(source, eventdata)
        [nx, ny] = number_of_views();
        if cur >= nx*ny + 1
            cur = cur - nx*ny;
            show_trajectories;
        end        
    end
   
    function next_callback(source, eventdata)        
        [nx, ny] = number_of_views();
        cur = cur + nx*ny;
        if cur > (length(filter) - nx*ny + 1)
            cur = length(filter) - nx*ny + 1;                               
        end     
        show_trajectories;        
    end

    function previous2_callback(source, eventdata)
        cur = cur - floor(0.01*length(filter));
        if cur < 1
            cur = 1;
        end
        show_trajectories;        
    end
   
    function next2_callback(source, eventdata)        
        cur = cur + floor(0.01*length(filter));
        if cur > (length(filter) - 3)
            cur = length(filter) - 3;                        
        end        
        show_trajectories;
    end

    function previous3_callback(source, eventdata)
        cur = cur - floor(0.05*length(filter));
        if cur < 1
            cur = 1;
        end
        show_trajectories;        
    end
   
    function next3_callback(source, eventdata)        
        cur = cur + floor(0.05*length(filter));
        if cur > (length(filter) - 3)
            cur = length(filter) - 3;                        
        end        
        show_trajectories;
    end

    function cluster_callback(source, eventdata) 
        set(gcf,'Pointer','watch');         
        nclusters = get(hclusters, 'value');        
        cv = get(hcv, 'value');
        if cv
            test_p = 0.1;
        else
            test_p = 0.;
        end
        classif = traj.classifier(labels_fn, cluster_feat, g_config.TAG_TYPE_BEHAVIOUR_CLASS);
        classif_res = classif.cluster(nclusters, test_p);          
        if ~isempty(ref_set)
            diff_set = classif_res.difference(ref_set);
        end
        segments_map = [];
        [~, covering] = classif_res.coverage();              
        
        update_filter_combo;        
        set(gcf,'Pointer','arrow');                    
        
        if ~isempty(results_window) && ishandle(results_window.window)
            results_window.set_results(classif_res);
        end
    end

    function popout_results_callback(source, eventdata) 
        if get(hshow_results, 'value') && ( isempty(results_window) || ~ishandle(results_window.window) )
            results_window = classification_results(traj);
            if ~isempty(classif_res)
                results_window.set_results(classif_res);
            end
        end
        if ~isempty(results_window) && ishandle(results_window.window)
            results_window.show(get(hshow_results, 'value'));
        end
    end
end     
                 
