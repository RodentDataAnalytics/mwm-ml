% Comparison between classification of trajectories and a manual 
% classification 

% Publication:
% Supplementary Material
% page 8 Figure 4

function results_full_trajectories_classification2

    % global data initialized elsewhere
    global g_trajectories; % total trajectories
    global g_long_trajectories_map; % keeps only the trajectory with length > 0
    global g_animals_trajectories_map; % matrix of trajectory indices for each trial and group of animals.
    global g_config; % configurations
    cache_animals;
    cache_trajectory_segments;
       
    % load trajectory tags -> these are the tags assigned to the full
    % trajectories
    param = g_config.TAGS_CONFIG{ g_config.TAGS_FULL };    

    [full_labels_data, full_tags] = g_trajectories.read_tags(param{1}, g_config.TAG_TYPE_BEHAVIOUR_CLASS);
    full_map = g_trajectories.match_tags(full_labels_data, full_tags);        
    % select only tagged trajectories
    tagged = sum(full_map, 2) > 0;
           
    pts = [];    
    
    for c = 1:length(full_tags)
        data = [];
        groups = [];
        pos = [];
        d = 0.05;
        grp = 1;
                                       
        nanimals = size(g_animals_trajectories_map{1}, 2);
        n = zeros(1, g_config.TRIALS*2);
        tot = zeros(1, g_config.TRIALS*2);
        mfried = zeros(nanimals*g_config.TRIALS, 2);
        
        for t = 1:g_config.TRIALS
            for g = 1:2            
                b = 0;
                pts_session = [];
                map = g_animals_trajectories_map{g};
        
                idx = 2*(t - 1) + g;
                
                for i = 1:nanimals
                    if g_long_trajectories_map(map(t, i)) ~= 0                                                
                        if full_map(map(t, i), c) > 0
                            val = full_map(map(t, i), c)/sum(full_map(map(t, i), :));
                        else
                            val = 0;
                        end
                        tot(idx) = tot(idx) + val;
                        n(idx) = n(idx) + 1;
                        mfried((t - 1)*nanimals + i, g) = val;
                    end                                           
                end
                                
                pos = [pos, d];
                d = d + 0.05;                 
            end     
            
            if rem(t, 4) == 0
                d = d + 0.07;                
            end                
            d = d + 0.02;                
        end
       
        figure;
        
        lim = max(tot ./ n);
        if lim == 0
            continue;
        end
        for j = 1:(g_config.TRIALS*2)                
            h = bar(pos(j), tot(j) / n(j), 0.04);
            if mod(j, 2) == 0
                set(h, 'facecolor', [0 0 0]);
            else
                set(h, 'facecolor', [1 1 1]);
            end           
            hold on;
        end
        lbls = {};
        lbls = arrayfun( @(i) sprintf('%d', i), 1:g_config.TRIALS, 'UniformOutput', 0);     
        
        set(gca, 'DataAspectRatio', [1, lim*1.25, 1], 'XTick', (pos(1:2:2*g_config.TRIALS - 1) + pos(2:2:2*g_config.TRIALS)) / 2, 'XTickLabel', lbls, 'FontSize', 0.75*g_config.FONT_SIZE);
        set(gca, 'LineWidth', g_config.AXIS_LINE_WIDTH);   
                 
        ylabel(full_tags(c).description, 'FontSize', 0.75*g_config.FONT_SIZE);
        xlabel('trial', 'FontSize', g_config.FONT_SIZE);        
        
        set(gcf, 'Color', 'w');
        box off;  
        set(gcf,'papersize',[8,8], 'paperposition',[0,0,8,8]);
        export_figure(1, gcf, g_config.OUTPUT_DIR, sprintf('full_traj_class_c%d', c));
        
        p = friedman(mfried, nanimals);
        str = sprintf('Class: %s\tp_frdm: %g', full_tags(c).description, p);            
        disp(str);
    end    
end
