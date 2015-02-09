function browse_trajectories(labels_fn, traj, tags, feat, selection)
%BROWSE_TRAJECTORIES Summary of this function goes here                
    % no filter at first
    filter = 1:traj.count;
    sorting = 1:traj.count;           
            
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern'));
        
    % create main window
    f = figure('Visible','off', 'name', 'Trajectories tagging', ...
               'Position', [200, 200, 900, 800], 'Menubar', 'none', 'Toolbar', 'none');
    
    %%
    %% Create controls
    %%%
    
    % trajectories navigation
    uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'String', '<- prev',...
        'Position', [0.25, 0.02, 0.07, 0.06], ...
        'Callback',{@previous_callback});
    uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'String', '-> next',...
        'Position', [0.68, 0.02, 0.07, 0.06], ...
        'Callback',{@next_callback});    
    uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'String', '<<-',...
        'Position', [0.20, 0.02, 0.05, 0.06], ...
        'Callback',{@previous2_callback});
    uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'String', '->>',...
        'Position', [0.75, 0.02, 0.05, 0.06], ...
        'Callback',{@next2_callback});        
    % status text (middle)
    hpos = uicontrol('Style', 'text', 'Units', 'normalized', 'String', '', ...
        'Position', [0.32, 0.01, 0.36, 0.08]);
    align([hpos], 'Center','Bottom');    
    % clustering controls
    uicontrol('Style', 'text', 'Units', 'normalized', ...
        'String', '# of clusters:', ...
        'Position', [0.82, 0.06, 0.05, 0.02]);   
    vals = arrayfun( @(x) sprintf('%d', x), 1:500, 'UniformOutput', 0);
    hclusters = uicontrol('Style', 'popupmenu', 'Units', 'normalized', ...
        'String', vals, ...
        'Position', [0.82, 0.04, 0.06, 0.02]);   
    hcv = uicontrol('Style', 'checkbox', 'Units', 'normalized', 'String', 'Enable CV', ...
        'Position', [0.82, 0.01, 0.06, 0.02]);    
    uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'String', 'Cluster', ...
        'Position', [0.9, 0.02, 0.08, 0.06], 'Callback', {@cluster_callback});
    % feature sorting control
    hfilter = [];
    sortstr = {'** none **', '** distance to centre (max) **', '** distance to centre (euclidean) **', '** combined **', '** random **' };
    sortstr = [sortstr, arrayfun( @(f) features.feature_name(f), feat, 'UniformOutput', 0)];
    hsort = uicontrol('Style', 'popupmenu', 'Units', 'normalized', 'String', sortstr, ...
        'Position', [0.02, 0.02, 0.10, 0.02], 'Callback', {@sorting_callback});
    hsort_reverse = uicontrol('Style', 'checkbox', 'Units', 'normalized', 'String', 'Rev', ...
        'Position', [0.12, 0.02, 0.05, 0.02], 'Callback', {@sorting_callback});    
    % cluster navigation and control (note: combo-box is created elsewhere
    % since it is dynamic
    hfilter_prev = uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'String', '<-', ...
        'Position', [0.02, 0.04, 0.075, 0.03], 'Callback', {@filter_prev_callback});    
    hfilter_next = uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'String', '->', ...
        'Position', [0.095, 0.04, 0.075, 0.03], 'Callback', {@filter_next_callback});        
    nitems_filter = 0;
    % trajectories display
    ha = { axes('Parent', f, 'Units', 'normalized', 'Position', [0.02, 0.60, 0.4, 0.38]), ...
           axes('Parent', f, 'Units', 'normalized', 'Position', [0.02, 0.15, 0.4, 0.38]), ...
           axes('Parent', f, 'Units', 'normalized', 'Position', [0.5, 0.60, 0.4, 0.38]), ...
           axes('Parent', f, 'Units', 'normalized', 'Position', [0.5, 0.15, 0.4, 0.38])};
    % status for each trajectory (feature values)
    hs = { uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [0.02, 0.55, 0.4, 0.04]), ...
           uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [0.02, 0.1, 0.4, 0.04]), ...
           uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [0.5, 0.55, 0.4, 0.04]), ...
           uicontrol('Style', 'text', 'Units', 'normalized', 'Position', [0.5, 0.1, 0.4, 0.04])}; 
           
    ntags = length(tags); 
    
    % create check-boxes     
    hcb = {[], [], [], []};
    for i = 1:ntags
        txt = tags(i).abbreviation;
        hcb{1} = [hcb{1}, ...
                  uicontrol('Style','checkbox', 'Units', 'normalized', 'String', txt, ...
                    'Position',[0.43, 1. - 0.03*i, 0.07, 0.03], ...
                    'Callback', {@checkbox_callback})];
        hcb{2} = [hcb{2}, ...
                  uicontrol('Style','checkbox', 'Units', 'normalized', 'String', txt, ...
                    'Position',[0.43, 0.55 - 0.03*i, 0.07, 0.03], ...
                    'Callback', {@checkbox_callback})];
        hcb{3} = [hcb{3}, ...
                  uicontrol('Style','checkbox', 'Units', 'normalized', 'String', txt, ...
                    'Position',[0.93, 1. - 0.03*i, 0.07, 0.03], ...
                    'Callback', {@checkbox_callback})];
        hcb{4} = [hcb{4}, ...
                  uicontrol('Style','checkbox', 'Units', 'normalized', 'String', txt, ...
                    'Position',[0.93, 0.55 - 0.03*i, 0.07, 0.03], ...
                    'Callback', {@checkbox_callback})];        
    end        
           
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
           
    % styles for plotting clusters
    pointtypes = {'+r', 'xg', 'db', '.c', 'om', 'xy', '+b', 'ok'};

    classif_res = [];
    draw_boundary = 0;
    distr_status = '';
    covering = [];
    feat_values = traj.compute_features(feat);
    segments_map = [];
    
    update_filter_combo;
    show_trajectories;
    set(f,'Visible','on');            
    
    %%
    %% nested functions
    %%
    
    function update_filter_combo
        if ~isempty(hfilter)
            delete(hfilter);
            hfilter = [];
        end
        strings = {'** all **', '** tagged only **', '** isolated **', '** suspicious **', '** selection **', '** errors **'};
        if ~isempty(classif_res)
            strings = [strings, arrayfun( @(t) t.description, classif_res.classes, 'UniformOutput', 0)];
        end     
            
        if ~isempty(classif_res)
            % isolated/lonely segments            
            isol = ~covering;
            for i = 1:max(classif_res.cluster_idx)
                if classif_res.cluster_class_map(i) == 0
                    lbl = g_config.UNDEFINED_TAG_ABBREVIATION;
                else
                    lbl = classif_res.classes(classif_res.cluster_class_map(i)).abbreviation;
                end
                nclus = sum(classif_res.cluster_idx == i);
                strings = [strings, sprintf('Cluster #%d (''%s'', N=%d, L=%d, I=%d)', ... 
                                            i, lbl, nclus, ...
                                            length(find(sum(labels_traj(classif_res.cluster_idx == i, :), 2) > 0)), ...
                                            sum(isol(classif_res.cluster_idx == i)))];
            end
        end
        
        hfilter = uicontrol('Style', 'popupmenu', 'Units', 'normalized', 'String', strings, ...
        'Position', [0.02, 0.07, 0.15, 0.02], 'Callback', {@combobox_filter_callback});
        nitems_filter = length(strings);
    
        combobox_filter_callback(0, 0);
    end
        
    function show_trajectories                
        for i = 1:4
            if cur + i < length(filter)
                traj_idx = filter(sorting(cur + i - 1));
                % plot the trajectory/segment
                set(f, 'currentaxes', ha{i});                                
                traj.items(traj_idx).plot;                
                hold on;                
                if ~isempty(covering)
                    if covering(traj_idx)
                        rectangle('Position', [80, 80, 10, 10], 'FaceColor', [0.5, 1, 0.5]);                    
                    else
                        rectangle('Position', [80, 80, 10, 10], 'FaceColor', [1, 0.5, 0.5]);
                    end
                end                                    
                % draw surrounding ellipse?
                if draw_boundary
                    hold on;                    
                    vals = traj.items(traj_idx).compute_features([ ...
                        features.BOUNDARY_CENTRE_RADIUS, ...
                        features.BOUNDARY_CENTRE_ANGLE, ...
                        features.BOUNDARY_MAJOR_RADIUS, ...
                        features.BOUNDARY_MINOR_RADIUS, ...
                        features.BOUNDARY_INCLINATION ]);                    
                    r = vals(1); ang = vals(2); a = vals(3); b = vals(4); inc = vals(5);
                    draw_ellipse(r*cos(ang), r*sin(ang), b, a, inc, ':r');
                    axis equal;
                    hold off;
                end
                
                % update the status text with feature values
                str = '';
                for j = 1:length(feat)
                    if j > 1
                        str = strcat(str, ' | ');
                    end
                    str = strcat(str, sprintf('%s: %.4f', features.feature_abbreviation(feat(j)), feat_values(traj_idx, j)));                    
                end
                % put also segment identification
                str = sprintf('%s  ||  %d/%d/%d+%dcm', str, traj.items(traj_idx).set, traj.items(traj_idx).track, traj.items(traj_idx).trial, round(traj.items(traj_idx).offset));
                if ~isempty(classif_res)
                    str = sprintf('  ||  %s cluster #%d', str, classif_res.cluster_idx(traj_idx));
                end
                set(hs{i}, 'String', str);
                                
                % update checkboxes
                handles = hcb{i};
                arrayfun(@(h,j) set(h, 'Value', labels_traj(traj_idx, j)), handles(1:(length(handles) - 1)), 1:(length(handles) - 1));  
    
                for j = 1:(length(handles) - 1)
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
                        if idx ~= -1 && classif_res.class_map(traj_idx) == idx                            
                            if labels_traj(traj_idx, j)                                
                                set(handles(j), 'BackgroundCol', [0.2, 1., 0.2]);                            
                            else
                                if ~isempty(find(labels_traj(traj_idx, :)))                              
                                    set(handles(j), 'BackgroundCol', [1., 0.2, 0.2]);                            
                                else
                                    set(handles(j), 'BackgroundCol', [.5, 0.5, 0.9]);
                                end
                            end
                        else
                            set(handles(j), 'BackgroundCol', get(gcf,'DefaultUicontrolBackgroundCol'));                            
                        end                                                
                    else
                        set(handles(j), 'BackgroundCol', get(gcf,'DefaultUicontrolBackgroundCol'));                            
                    end
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
        for i = 0:3            
            if length(filter) >= cur + i
                vals = arrayfun(@(h) get(h, 'Value'), hcb{i + 1});                
                labels_traj(filter(sorting(cur + i)), :) = vals;
            end
        end
        
        traj.save_tags(labels_fn, tags, labels_traj, []);
    end

    function update_status
        str = sprintf('%d to %d from %d\n\n', cur, cur + 3, length(filter));
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
            str = strcat(str, sprintf('\nErrors: %d (%.1f%%) | Unknown: %.1f%% | Covering: %.1f%%', ...
                classif_res.nerrors, classif_res.perrors*100, classif_res.punknown*100, pcov*100)); 
        end
        str = sprintf('%s\n%s', str, distr_status);        
        set(hpos, 'String', str);
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
                % everyone labelled
                filter = find(sum(labels_traj, 2) > 0);                            
            case 3
                filter = find(covering == 0);
            case 4
                % "suspicious" guys 
                if ~isempty(classif_res)
                    if isempty(segments_map)
                        [~, ~, segments_map] = traj.classes_mapping_ordered(classif_res, -1, 'MinSegments', 4);
                    end
                    
                    filter = find(segments_map ~= classif_res.class_map & segments_map > 0 & classif_res.class_map > 0);                    
                end
            case 5
                % user selection
                filter = selection;
            case 6                     
                % mis-matched classifications      
                if ~isempty(classif_res)
                    filter = classif_res.non_empty_labels_idx(classif_res.errors == 1);            
                else
                    filter = 1:traj.count;
                end
            otherwise
                % classes
                if val <= classif_res.nclasses + 6
                    if classif_res.classes(val - 6).abbreviation == g_config.UNDEFINED_TAG_ABBREVIATION                                    
                        filter = find(classif_res.class_map == 0);
                    else
                        filter = find(classif_res.class_map == (val - 6));                                    
                    end
                else
                   % clusters
                   filter = find(classif_res.cluster_idx == (val - classif_res.nclasses - 6));
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
        
        if ~isempty(classif_res)
            % plot clusters in a separate window with pairwise features
            n = length(feat)*(length(feat) -1)/2 + 1;
            if n == 1
                l = 1;
                m = 1;
            elseif n <= 4
                l = 2;
                m = 2;
            elseif n <= 6
                l = 3;
                m = 2;
            elseif n <= 9
                l = 3;
                m = 3;
            elseif n <= 12
                l = 4;
                m = 3;
            elseif n <= 16
                l = 4;
                m = 4;
            elseif n <= 25
                l =5;
                m = 5;
            else
                % too many possible pairings
                return;
            end
%             figure(27);        
%             clf;
%             n = 1;        
%             for i = 1:(length(feat) - 1)
%                 for j = (i + 1):length(feat)               
%                     subplot(m, l, n);
%                     n = n + 1;
%                     % the "unknown" guys
%                     pos = find(classif_res.class_map(filter) == 0);
%                     plot(feat_values(filter(pos), i), feat_values(filter(pos), j), 'dk');
%                     hold on;                
%                     p = 1;
%                     for k = 1:classif_res.nclasses
%                         if ~strcmp(classif_res.classes(k).abbreviation, g_config.UNDEFINED_TAG_ABBREVIATION)
%                             pos = find(classif_res.class_map(filter) == k);      
%                             if ~isempty(pos)
%                                 plot(feat_values(filter(pos), i), feat_values(filter(pos), j), pointtypes{p});
%                                 p = p + 1;
%                             end
%                         end
%                     end         
%                     xlabel(features.feature_name(feat(i)));
%                     ylabel(features.feature_name(feat(j)));                                                     
%                     hold off;                                                
%                 end
%             end
% 
%             % plot legend in a separate sub-window
%             subplot(m, l, n);                
%             p = 1;
%             for k = 1:classif_res.nclasses
%                 if strcmp(classif_res.classes(k).abbreviation, g_config.UNDEFINED_TAG_ABBREVIATION)
%                     plot(0, 0, 'dk');
%                 else
%                     plot(0, 0, pointtypes{p});
%                     p = p + 1;
%                 end
%                 hold on;            
%             end
%             names = arrayfun( @(t) t.description, classif_res.classes, 'UniformOutput', 0);
%             hold off;
%             legend(names);                                    
        end
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
                dist = ((feat_values(filter, :) - classif_res.centroids(:, classif_res.cluster_idx(filter), :)') / repmat(feat_norm, size(feat_values, 1), 1)).^2;
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

    function sorting_callback(source, eventdata)
        update_sorting;
        cur = 1;
        show_trajectories;
    end

    function previous_callback(source, eventdata)
        if cur >= 5
            cur = cur - 4;
            show_trajectories;
        end        
    end
   
    function next_callback(source, eventdata)        
        cur = cur + 4;
        if cur > (length(filter) - 3)
            cur = length(filter) - 3;                               
        end     
        show_trajectories;        
    end

    function previous2_callback(source, eventdata)
        cur = cur - floor(0.04*length(filter));
        if cur < 1
            cur = 1;
        end
        show_trajectories;        
    end
   
    function next2_callback(source, eventdata)        
        cur = cur + floor(0.04*length(filter));
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
        classif = traj.classifier(labels_fn, feat, g_config.TAG_TYPE_BEHAVIOUR_CLASS);
        classif_res = classif.cluster(nclusters, test_p);                
        segments_map = [];
        [~, covering] = traj.segments_covering(classif_res);
        update_filter_combo;        
        set(gcf,'Pointer','arrow');                
        
        %% show correlation matrix
%         figure(29);
%         lbls = {};
%         % sort the labels, otherwise the result will look meaningless
%         [~, idx] = sort(cluster_map);
%         for i = 1:nclusters        
%             if cluster_map(idx(i)) == 0
%                 lbl = '**';
%             else
%                 lbl = cluster_tags(cluster_map(idx(i))).abbreviation;
%             end        
%             lbls = [lbls, sprintf('%d: %s', idx(i), lbl)];
%         end
%         
%         %%
%         %% show labelled trajectories in another window
%         %%
%         
%         n = length(feat)*(length(feat) -1)/2 + 1;
%         if n == 1
%             l = 1;
%             m = 1;
%         elseif n <= 4
%             l = 2;
%             m = 2;
%         elseif n <= 6
%             l = 3;
%             m = 2;
%         elseif n <= 9
%             l = 3;
%             m = 3;
%         elseif n <= 12
%             l = 4;
%             m = 3;
%         elseif n <= 16
%             l = 4;
%             m = 4;
%         elseif n <= 25
%             l =5;
%             m = 5;
%         else
%             % too many possible pairings
%             return;
%         end
%         
%         figure(28);    
%         % tagged segments        
%         n = 1;
%         % tags given as input
%         abrev = arrayfun( @(t) t.abbreviation, tags, 'UniformOutput', 0);
%         for i = 1:(length(feat) - 1)
%             for j = (i + 1):length(feat)               
%                 subplot(m, l, n);                
%                 n = n + 1;
%                 p = 1;
%                 for k = 1:length(cluster_tags)                                                                                  
%                     % match input tag
%                     match = cellfun( @(t) strcmp(t, cluster_tags(k).abbreviation), abrev);
%                     idx = find(match == 1);
%                     if ~isempty(idx )                        
%                         pos = find(labels_traj(:, idx));      
%                         if ~strcmp(cluster_tags(k).abbreviation, g_config.UNDEFINED_TAG_ABBREVIATION)
%                             pt = pointtypes{p};
%                             p = p + 1;
%                         else
%                             pt = 'dk';
%                         end
%                         plot(feat_values(pos, i), feat_values(pos, j), pt);
%                         hold on;                    
%                     end
%                 end
%                 xlabel(features.feature_name(feat(i)));
%                 ylabel(features.feature_name(feat(j)));                    
%                         
%                 hold off;                                                
%             end
%         end
% 
%         % plot only legend
%         subplot(m, l, n);                
%         p = 1;
%         for k = 1:length(cluster_tags)                   
%             if strcmp(cluster_tags(k).abbreviation, g_config.UNDEFINED_TAG_ABBREVIATION)
%                 plot(0, 0, 'dk');
%             else
%                 plot(0, 0, pointtypes{p});
%                 p = p + 1;
%             end
%             hold on;            
%         end
%         names = arrayfun( @(t) t.description, cluster_tags, 'UniformOutput', 0);
%         hold off;
%         legend(names);  
% 
%         centroids = cluster_centroids(:, idx);
%         imagesc(corr(centroids));            %# Create a colored plot of the matrix values
%         colormap('Jet');          
%         % colorbar;
% 
%         set(gca,'XTick', 1:nclusters,...                         %# Change the axes tick marks
%                 'XTickLabel', lbls,...  %#   and tick labels
%                 'YTick', 1:nclusters,...
%                 'YTickLabel', lbls,...
%                 'TickLength',[0 0]);        
%         rotateXLabels(gca, 90);                           
%         axis square;
%         daspect([1 1 1]);
    end
end     
                 
