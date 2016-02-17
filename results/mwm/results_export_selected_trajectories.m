function results_export_selected_trajectories
%RESULTS_EXPORT_SELECTED Export some trajectories/segments of interest
    global g_segments;    
    global g_trajectories;    
    global g_config;
    global g_long_trajectories_map;
    % initialize data
    cache_trajectory_segments;                    

    % load trajectory tags
    tag_conf = g_config.TAGS_CONFIG{1};
    [labels_data, full_tags] = g_trajectories.read_tags(tag_conf{1});
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
           %%%%fn = fullfile(g_config.OUTPUT_DIR, sprintf('/trajectory_s%d_d%d_t%d.eps', g_trajectories.items(pos(i)).set, g_trajectories.items(pos(i)).session, g_trajectories.items(pos(i)).track));
           %%%%%export_fig(fn);  
           export_figure(1, gcf, g_config.OUTPUT_DIR, sprintf('/trajectory_s%d_d%d_t%d', g_trajectories.items(pos(i)).set, g_trajectories.items(pos(i)).session, g_trajectories.items(pos(i)).track));           
        end       
    end
    
        
    % now export segments of interest..
%     [labels_data, segment_tags] = g_segments.read_tags(g_config.DEFAULT_TAGS_PATH);
%     map = g_segments.match_tags(labels_data, segment_tags);    
%     
%     % look for trajectories of interest
%     idx = find( arrayfun( @(t) strcmp(t.abbreviation, 'S1'), segment_tags) );
%     if ~isempty(idx)
%         pos = find(map(:, idx));
% 
%         % export them
%         for i = 1:length(pos)
%            g_segments.items(pos(i)).plot;
%            set(gcf, 'Color', 'w');
%            export_fig(fullfile(g_config.OUTPUT_DIR, ...
%                sprintf('/segment_s%d_d%d_t%d_o%d.eps', g_segments.items(pos(i)).set, g_segments.items(pos(i)).session, ...
%                g_segments.items(pos(i)).track, round(g_segments.items(pos(i)).offset)...
%            )));
%         end
%     end 
    
    close;
    
     ids = [1, 1, 103; ... 
            1, 2, 99; ...
            2, 3, 81; ...
            2, 2, 44; ...
            1, 2, 50; ...
            2, 3, 96; ...
            1, 2, 90; ...
            1, 3, 65; ...
           ];
       
    figure;
    for i = 1:size(ids, 1)
        idx = 0;
        for j = 1:g_trajectories.count
            if g_long_trajectories_map(j) == 0
                continue;
            end
            if g_trajectories.items(j).set == ids(i, 1) && ... 
               g_trajectories.items(j).session == ids(i, 2) && ...
               g_trajectories.items(j).track == ids(i, 3)           
                    idx = j;
                    break;
            end            
        end
        
        if idx == 0
            continue;
        end
        
        clf;
        g_trajectories.items(idx).plot;
        set(gcf, 'Color', 'w');
        %export_fig(fullfile(g_config.OUTPUT_DIR, ...
        %   sprintf('/traj_s%d_d%d_t%d.eps', g_trajectories.items(idx).set, g_trajectories.items(idx).session, ...
        %        g_trajectories.items(idx).track)...                
        %   ));
        export_figure(1, gcf, g_config.OUTPUT_DIR,...
                sprintf('/traj_s%d_d%d_t%d', g_trajectories.items(idx).set, g_trajectories.items(idx).session,g_trajectories.items(idx).track));
    end
end
