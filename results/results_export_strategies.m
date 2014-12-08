function results_export_strategies    
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/legendflex'));
    
    % global data initialized elsewhere
    global g_trajectories;    
    % initialize data
    cache_trajectories; 
          
    % select stress-control group
    groups = arrayfun( @(t) t.group, g_trajectories.items);        
    traj = trajectories(g_trajectories.items(groups == 1 | groups == 2));
    
    % segment trajectories - ones with less than 2 segments will be discarded
    [seg, partitions] = traj.divide_into_segments(constants.DEFAULT_SEGMENT_LENGTH, constants.DEFAULT_SEGMENT_OVERLAP, 2);
 
    % classify them
    [segment_classes, tags] = seg.classify(constants.SEGMENTS_TAGS250_PATH, constants.DEFAULT_FEATURE_SET, 100, 0);    
    
    fi = fopen('/tmp/tags.txt', 'w');
    for i = 1:length(tags)
        fprintf(fi, '%d %s %s\n', i, tags(i).abbreviation, tags(i).description);
    end
    fclose(fi);
    
     % compute the prefered strategy for a small time window for each
    % trajectory
    N = 9;
    tw = constants.TRIAL_TIMEOUT / N;
    class_distr = [];            
    
    id = [-1, -1, -1];
    class_distr_traj = [];
    ident = [];
    for i = 1:seg.count    
        if ~isequal(id, seg.items(i).data_identification)
            id = seg.items(i).data_identification;
            % different trajectory
            if ~isempty(class_distr_traj)
                traj_distr = zeros(1, N);
                % for each window select the most common class
                for j = 1:N
                    [val, pos] = max(class_distr_traj(j, :));                
                    if val > 0
                        traj_distr(j) = pos;
                    else
                        if seg.items(i - 1).end_time < (j - 1 + .5)*tw
                            traj_distr(j) = -1;
                        else
                            traj_distr(j) = 0;
                        end
                    end
                end
                class_distr = [class_distr; traj_distr];
            end  
            class_distr_traj = zeros(N, length(tags));
        end
        
        if segment_classes(i) > 0
            % first and last time window that this segment crosses        
            wi = floor(seg.items(i).start_time / tw) + 1;
            wf = floor(seg.items(i).end_time / tw) + 1;
            % for each one of them increment class count        
            for j = wi:wf
                class_distr_traj(j, segment_classes(i)) =  class_distr_traj(j, segment_classes(i)) + 1;
            end
        end
    end
 
    class_distr = [class_distr; traj_distr];
     
  %  assert(size(class_distr, 1) == traj.count);
    
    % export data -> sick of matlab
    off = 1;
    data = -1 + zeros(traj.count, N + 7);    
    for i = 1:traj.count
        data(i, 1:7) = [traj.items(i).group, traj.items(i).id, traj.items(i).session, traj.items(i).trial, partitions(i), traj.items(i).compute_feature(features.LATENCY), traj.items(i).compute_feature(features.AVERAGE_SPEED)]; 
        if partitions(i) > 0
            data(i, 8:7 + N) = class_distr(off, :);
            off = off + 1;
        end
    end     
        
    csvwrite('/tmp/data.csv', data);       
end