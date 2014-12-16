function trajectory_detailed_classification( traj_labels_fn, labels_fn, seg_len, ovlp, feat, clusters, grps )
%CLASSIFY_TRAJECTORIES Summary of this function goes here
%   Detailed explanation goes here
    global g_trajectories;
    cache_trajectories;
    
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern'));
    
    if isempty(grps)
        traj = g_trajectories;
    else
        % filter trajectories
        x = arrayfun( @(t) any(grps == t.group), g_trajectories.items);
        traj = trajectories(g_trajectories.items(x == 1));
    end
    
    % select trajectories with at least length >= seg_len
    len = arrayfun( @(t) t.compute_feature(features.LENGTH), traj.items);
    traj = trajectories( traj.items(len >= seg_len));
    
    % read tags for full trajectories
    [labels_data, full_tags] = traj.read_tags(traj_labels_fn);
    traj_map = traj.match_tags(labels_data, full_tags);    
    beh_idx = find( arrayfun( @(t) t.type == g_config.TAG_TYPE_BEHAVIOUR_CLASS, full_tags) );    
    full_tags = full_tags(beh_idx);
    traj_map = traj_map(:, beh_idx);        
    
    [segments, partitions] = traj.divide_into_segments(seg_len, ovlp, 2);
    % remove trajectories with only 1 partition
    
    cumpart = zeros(1, length(partitions));
    for i = 2:length(partitions)
        cumpart(i) = cumpart(i - 1) + partitions(i - 1);
    end
    
    % classifiy
    [class_idx, tags, ~, ~, ~, cluster_miss] = segments.classify(labels_fn, feat, clusters);
    
    tag_map = repmat({}, 1, length(full_tags));
    for k = 1:length(full_tags)
        % look for tags matching the current one and ones that have it as parent as well    
        tmp = find( arrayfun( @(t) strcmp(t.abbreviation, full_tags(k).abbreviation), tags) | ... 
                    arrayfun( @(t) strcmp(t.parent, full_tags(k).abbreviation), tags) );
        if ~isempty(tmp)
            tag_map{k} = tmp; 
        else
            tag_map{k} = -1;
            fprintf('class not present in classification: %s\n', full_tags(k).description);                  
        end
    end
    
    % create main window
    f = figure('Visible','off', 'name', 'Trajectories classification', ...
               'Position', [200, 200, 900, 800], 'Menubar', 'none', 'Toolbar', 'none');
    
    % create controls
    uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'String', '<- prev',...
        'Position', [0.25, 0.02, 0.08, 0.06], ...
        'Callback',{@previous_callback});
    uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'String', '-> next',...
        'Position', [0.67, 0.02, 0.08, 0.06], ...
        'Callback',{@next_callback});    
    uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'String', '<<-',...
        'Position', [0.20, 0.02, 0.05, 0.06], ...
        'Callback',{@previous2_callback});
    uicontrol('Style', 'pushbutton', 'Units', 'normalized', 'String', '->>',...
        'Position', [0.75, 0.02, 0.05, 0.06], ...
        'Callback',{@next2_callback});        
    hpos = uicontrol('Style', 'text', 'Units', 'normalized', 'String', '', ...
        'Position', [0.33, 0.02, 0.34, 0.06]);
    align([hpos], 'Center','Bottom'); 
    
    m = 8;
    n = 5;
    ha = zeros(1, m*n);
    hs = zeros(1, m*n);
    for i = 1:n
        for j = 1:m
            x = 0.01 + (j - 1.)/m;
            y = 1. - i*0.9/n + 0.01;
            w = 1./m - 0.01;
            ha((i - 1)*m + j) = axes('Parent', f, 'Units', 'normalized', 'Position', [x, y + 0.08, w, 0.9/n - 0.07]);
            hs((i - 1)*m + j) = uicontrol('Style', 'text', 'Units', 'normalized', 'String', '----', ...
                                'Position', [x, y, w, 0.06]);
        end
    end
    
    cur = 1;
    show_segments;
    set(f,'Visible','on');

    function show_segments
        % for all segments of current trajectory
        set(f, 'currentaxes', ha(1));
        traj.items(cur).plot;
        for i = 1:(m*n - 1)
            set(f, 'currentaxes', ha(i + 1));
            if i <= partitions(cur) 
                pos = cumpart(cur) + i;
                segments.items(pos).plot;
                if class_idx(pos) == 0
                    set(hs(i + 1), 'String', '** undefined **');
                else
                    set(hs(i + 1), 'String', tags(class_idx(pos)).description);
                end
            else
                axis off;
                set(hs(i + 1), 'String', '');
                cla;
            end 
        end
        
        % update full trajectory
        str = '';
        mapped = [];
        for i = 1:length(full_tags)
            if traj_map(cur, i) ~= 0
                % do we have a corresponding class in the segments?
                t = tag_map{i};
                if t(1) == -1
                    % nop
                    sign = 'NA';
                else
                    pos = cumpart(cur) + 1;                    
                    tot = 0;
                    for j = 1:length(t)
                        tot = tot + sum(class_idx(pos:(pos + partitions(cur))) == t(j));
                        mapped = [mapped, t(j)];
                    end
                    if tot > 0        
                        sign = sprintf('OK, %.1f%%', tot/(sum(class_idx(pos:(pos + partitions(cur))) ~= 0))*100.);
                    else
                        sign = 'EE';
                    end
                end
                str = strcat(str, sprintf(' %s (%s)', full_tags(i).abbreviation, sign));
            end
        end                
        % look for unmapped classes
        first = 1;
        for i = 1:length(tags)
            if isempty(find(mapped == i))
                tot = sum(class_idx(pos:(pos + partitions(cur))) == i);
                if tot > 0
                    tmp = sprintf(' %s (%.1f%%)', tags(i).abbreviation, tot/(sum(class_idx(pos:(pos + partitions(cur))) ~= 0))*100.);                
                    if first
                        first = 0;
                        str = sprintf('%s\nOthers:%s', str, tmp);
                    else    
                        str = strcat(str, tmp);
                    end                
                end
            end
        end
        set(hs(1), 'String', str);
        update_status;
    end

    function update_status
        str = sprintf('Set %d / day %d / track %d [%d/%d]', traj.items(cur).set, ...
            traj.items(cur).session, traj.items(cur).track, cur, traj.count);
        set(hpos, 'String', str);
    end

    function previous_callback(source, eventdata)
        if cur > 1
            cur = cur - 1;
            show_segments;
        end        
    end
   
    function next_callback(source, eventdata)        
        if cur < traj.count
            cur = cur + 1;
            show_segments;
        end        
    end

    function previous2_callback(source, eventdata)
        cur = cur - floor(0.04*traj.count);
        if cur < 1
            cur = 1;
        end
        show_segments;        
    end
   
    function next2_callback(source, eventdata)        
        cur = cur + floor(0.04*traj.count);
        if cur > traj.count
            cur = traj.count;                        
        end        
        show_segments;
    end

end

