function results_export_selected_trajectories
%RESULTS_EXPORT_SELECTED Export some trajectories/segments of interest
    
    global g_segments; %total segments produced from the splitting of trajectories    
    global g_trajectories; %total trajectories   
    global g_config; %configurations
    global g_long_trajectories_map; %keeps only the trajectory with length > 0
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
           export_figure(1, gcf, g_config.OUTPUT_DIR, sprintf('/trajectory_s%d_d%d_t%d', g_trajectories.items(pos(i)).set, g_trajectories.items(pos(i)).session, g_trajectories.items(pos(i)).track));
        end       
    end

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
        
        export_figure(1, gcf, g_config.OUTPUT_DIR,...
                sprintf('/traj_s%d_d%d_t%d', g_trajectories.items(idx).set, g_trajectories.items(idx).session,g_trajectories.items(idx).track));
    end
end
