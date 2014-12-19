function results_distribution_segments
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));  
    addpath(fullfile(fileparts(mfilename('fullpath')), '../'));

    % global data initialized elsewhere
    global g_segments_classification;
    global g_partitions;
    global g_trajectories_length;
    global g_long_trajectories_idx;
    
    % classify trajectories
    cache_trajectories_classification; 
        
    labels_map = g_segments_classification.input_labels;    
    class_map = g_segments_classification.class_map;    
    unk_idx = tag.tag_position(g_segments_classification.classes, g_config.UNDEFINED_TAG_ABBREVIATION);
                
    % maximum number of segments for one trajectory
    max_seg = max(g_partitions);
    
    data = ones(max_seg, length(g_long_trajectories_idx));
    
    traj = 1;
    nseg = 0;
    part = g_partitions(g_long_trajectories_idx);
    for i = 1:length(class_map)
        if nseg == part(traj)
            % move to next trajectory
            if traj == 553
                disp('break');
            end
            traj = traj + 1;            
            nseg = 0;                        
        end        
        nseg = nseg + 1;
        
        % ith segment, was it manually labelled?
        x = labels_map{i};
        if x(1) ~= -1
            data(nseg, traj) = 2; % labelled
        elseif class_map(i) > 0
            data(nseg, traj) = 3; % classified
        else
            data(nseg, traj) = 4; % could not be classified
        end
    end         
    
    % sort data by trajectory length
    [~, ord] = sort(g_trajectories_length(g_long_trajectories_idx), 'descend');
    data = data(:, ord);
    % data = data(size(data, 1):-1:1, :);
    % data = data(:, g_trajectories_group(g_long_trajectories_idx) == 1); 
    data = data(:, 1:250);   
    % plot bars
    figure;
    cm = [1 1 1; .1 .45 .1; .7 .7 .7; .85 .85 .85];    
    colormap(cm);
    caxis([1 4]);
    daspect([1 1 1]);
    ph = pcolor(data);                       
    set(ph, 'edgecolor', 'none');
    set(gcf, 'Color', 'w');
    box off;        
    axis off;
    
    export_fig(fullfile(g_config.OUTPUT_DIR, 'distribution_segments.png'), '-m3');
end
