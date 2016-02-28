function cache_animals    
    global g_trajectories;    
    global g_trajectories_group;
    global g_trajectories_trial;
    global g_config;
    global g_trajectories_speed;
    cache_trajectories;
        
    global g_animals_count;
    % groups animals: for each group an array of animals ids
    global g_animals_ids;
    % matrix of trajectory indices for each trial and group of animals
    global g_animals_trajectories_map;
    
    if isempty(g_animals_count)
        g_animals_count = [sum(g_trajectories_group == 1 & g_trajectories_trial == 1), sum(g_trajectories_group == 2 & g_trajectories_trial == 1)];

        g_animals_ids = {};
        g_animals_trajectories_map = {};
        for g = 1:2
            % select ids based on first trial
            map = find(g_trajectories_group == g & g_trajectories_trial == 1);
            ids = arrayfun( @(x) x.id, g_trajectories.items(map));
            for t = 2:g_config.TRIALS
                trial_idx = find(g_trajectories_group == g & g_trajectories_trial == t);
                trial_ids = arrayfun( @(x) x.id, g_trajectories.items(trial_idx));
                map = [map; arrayfun( @(id) trial_idx(trial_ids == id), ids)];
            end
            avg_speed = mean(g_trajectories_speed(map));
            [~, ord] = sort(avg_speed);
            if g == 1
                nd = g_animals_count(1) - g_animals_count(2);
                if nd > 0
                    nd = max(nd, g_config.NDISCARD);
                else
                    nd = max(g_config.NDISCARD + nd, 0);
                end
                for s = 1:g_config.SESSIONS                    
                    ti = (s - 1)*g_config.TRIALS_PER_SESSION + 1;
                    tf = s*g_config.TRIALS_PER_SESSION;
                    avg_speed = mean(g_trajectories_speed(map(ti:tf, :)));
                    [~, ord] = sort(avg_speed);
                    
                    % discard N too stressed animals                
                    idx = map(ti:tf, ord(length(ord) - nd + 1:end));
                    g_trajectories_group(idx(:)) = -1;
                end
                ids = ids(ord(1:length(ord) - nd));
                map = map(:, ord(1:length(ord) - nd));
            else
                nd = g_animals_count(2) - g_animals_count(1);
                if nd > 0
                    nd = max(nd, g_config.NDISCARD);
                else
                    nd = max(g_config.NDISCARD + nd, 0);
                end
                
                for s = 1:g_config.SESSIONS                    
                    ti = (s - 1)*g_config.TRIALS_PER_SESSION + 1;
                    tf = s*g_config.TRIALS_PER_SESSION;
                    avg_speed = mean(g_trajectories_speed(map(ti:tf, :)));
                    [~, ord] = sort(avg_speed);
                    
                    % discard N too calm animals                
                    idx = map(ti:tf, ord(1:nd));                
                    g_trajectories_group(idx(:)) = -2;                
                end

                ids = ids(ord(nd + 1:length(ord)));
                map = map(:, ord(nd + 1:length(ord)));                    
            end
            
            g_animals_ids = [g_animals_ids, ids];
            g_animals_trajectories_map = [g_animals_trajectories_map, map];                                                                                     
        end
    end
end