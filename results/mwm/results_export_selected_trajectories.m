function results_export_selected_trajectories
%RESULTS_EXPORT_SELECTED Export some trajectories/segments of interest
    global g_segments;    
    global g_trajectories;    
    
    % initialize data
    cache_trajectory_segments;                    

    % load trajectory tags
    [labels_data, full_tags] = g_trajectories.read_tags(g_config.FULL_TRAJECTORIES_TAGS_PATH);
    map = g_trajectories.match_tags(labels_data, full_tags);    
    
    figure(213);           
           
    % look for trajectories of interest
    idx = find( arrayfun( @(t) strcmp(t.abbreviation, 'S1'), full_tags) );
    if ~isempty(idx)
        pos = find(map(:, idx));

        % export them
        for i = 1:length(pos)
           g_trajectories.items(pos(i)).plot;
           set(gcf, 'Color', 'w');
           fn = fullfile(g_config.OUTPUT_DIR, sprintf('/trajectory_s%d_d%d_t%d.eps', g_trajectories.items(pos(i)).set, g_trajectories.items(pos(i)).session, g_trajectories.items(pos(i)).track));
           export_fig(fn);           
        end       
    end
    
        
    % now export segments of interest..
    [labels_data, segment_tags] = g_segments.read_tags(g_config.DEFAULT_TAGS_PATH);
    map = g_segments.match_tags(labels_data, segment_tags);    
    
    % look for trajectories of interest
    idx = find( arrayfun( @(t) strcmp(t.abbreviation, 'S1'), segment_tags) );
    if ~isempty(idx)
        pos = find(map(:, idx));

        % export them
        for i = 1:length(pos)
           g_segments.items(pos(i)).plot;
           set(gcf, 'Color', 'w');
           export_fig(fullfile(g_config.OUTPUT_DIR, ...
               sprintf('/segment_s%d_d%d_t%d_o%d.eps', g_segments.items(pos(i)).set, g_segments.items(pos(i)).session, ...
               g_segments.items(pos(i)).track, round(g_segments.items(pos(i)).offset)...
           )));
        end
    end 
    
    close;
end
