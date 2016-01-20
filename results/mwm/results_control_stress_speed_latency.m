function results_control_stress_speed_latency    
    addpath(fullfile(fileparts(mfilename('fullpath')), '../../extern/sigstar'));
    
    % global data initialized elsewhere
    global g_trajectories_speed;        
    global g_trajectories_length;        
    global g_animals_trajectories_map;
    global g_trajectories;
    global g_config;
    
    cache_animals;

    trajectories_latency = arrayfun( @(t) t.compute_feature(g_config.FEATURE_LATENCY), g_trajectories.items);      
    
    cache_animals;
     vars = [trajectories_latency; g_trajectories_speed; g_trajectories_length/100];
    names = {'latency', 'speed', 'length'};
    ylabels = {'latency [s]', 'speed [cm/s]', 'path length [m]'};
    log_y = [0, 0, 0];
        
    for i = 1:size(vars, 1)
        figure;
        values = vars(i, :);
        data = [];
        groups = [];
        xpos = [];
        pos = [0, 0.4, 1.2, 1.6, 2.4, 2.8];
        for s = 1:g_config.SESSIONS
            for g = 1:2            
                map = g_animals_trajectories_map{g};
                ti = (s - 1)*g_config.TRIALS_PER_SESSION + 1;
                tf = s*g_config.TRIALS_PER_SESSION;
                tmp = mean(values(map(ti:tf, :)));                 
                data = [data, tmp(:)'];
                xpos = [xpos, repmat(pos(s*2 - 1 + g - 1), 1, length(tmp(:)))];             
                groups = [groups, repmat(s*2 - 1 + g - 1, 1, length(tmp(:)))];                         
            end
        end
        boxplot(data, groups, 'positions', pos, 'colors', [0 0 0; .7 .7 .7]);     
        set(gca, 'XTick', [0.2, 1.4, 2.6], 'XTickLabel', {'Session 1', 'Session 2', 'Session 3'}, 'FontSize', g_config.FONT_SIZE);         
        h = findobj(gca,'Tag','Box');
        for j=1:2:length(h)
             patch(get(h(j),'XData'), get(h(j), 'YData'), [.9 .9 .9], 'FaceAlpha', .3);
        end
        set([h], 'LineWidth', 1.5);        
   
        h = findobj(gca, 'Tag', 'Outliers');
        for j=1:length(h)
            set(h(j), 'MarkerEdgeColor', [0 0 0]);
        end

        h = findobj(gca, 'Tag', 'Median');
        for j=1:2:length(h)
             line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [0 0 0]);
        end
                
        % check significances
        for s = 1:g_config.SESSIONS
            hip = ttest2(data(groups == 2*s - 1), data(groups == 2*s));
            if hip
                h = sigstar( {[pos(2*s - 1), pos(s*2)]}, [0.05]);
                set(h(:, 1), 'LineWidth', 2);
                set(h(:, 2), 'FontSize', g_config.FONT_SIZE);
            end
        end
                
        set(gcf, 'Color', 'w');
        set(gca, 'LineWidth', g_config.AXIS_LINE_WIDTH);
        box off;        
        ylabel(ylabels{i}, 'FontSize', g_config.FONT_SIZE);
        
        export_fig(fullfile(g_config.OUTPUT_DIR, sprintf('control_stress_%s.eps', names{i}))); 
        
        %%
        %% Do the same for each trial
        clf;
        data = [];
        groups = [];
        xpos = [];
        d = .1;
        idx = 1;
        pos = zeros(1, 2*g_config.TRIALS);
        for s = 1:g_config.SESSIONS
            for t = 1:g_config.TRIALS_PER_SESSION
                for g = 1:2                    
                    pos(idx) = d;
                    d = d + 0.1;
                    idx = idx + 1;
                end
                d = d + 0.07;
            end
            d = d + 0.15;
        end
        
        % matrix for friedman's multifactor tests
        n = 27;
        fried = zeros(g_config.TRIALS*n, 2);                        
        for t = 1:g_config.TRIALS
            for g = 1:2            
                map = g_animals_trajectories_map{g};
                tmp = values(map(t, :));                 
                data = [data, tmp(:)'];
                xpos = [xpos, repmat(pos(t*2 - 1 + g - 1), 1, length(tmp(:)))];             
                groups = [groups, repmat(t*2 - 1 + g - 1, 1, length(tmp(:)))];             
                for j = 1:n
                    fried((t - 1)*n + j, g) = tmp(j);
                end
            end            
        end
                                                   
        boxplot(data, groups, 'positions', pos, 'colors', [0 0 0; .7 .7 .7]);
        set(gca, 'LineWidth', g_config.AXIS_LINE_WIDTH, 'FontSize', g_config.FONT_SIZE);
        
        lbls = {};
        lbls = arrayfun( @(i) sprintf('%d', i), 1:g_config.TRIALS, 'UniformOutput', 0);     
        
        set(gca, 'XLim', [0, max(pos) + 0.1], 'XTick', (pos(1:2:2*g_config.TRIALS - 1) + pos(2:2:2*g_config.TRIALS)) / 2, 'XTickLabel', lbls, 'FontSize', 0.75*g_config.FONT_SIZE);                 
                
        if log_y(i)
            set (gca, 'Yscale', 'log');
        else
            set (gca, 'Yscale', 'linear');
        end
        
        ylabel(ylabels{i}, 'FontSize', g_config.FONT_SIZE);
        xlabel('trial', 'FontSize', g_config.FONT_SIZE);

        h = findobj(gca,'Tag','Box');
        for j=1:2:length(h)
             patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
        end
        set([h], 'LineWidth', 0.8);
   
        h = findobj(gca, 'Tag', 'Median');
        for j=1:2:length(h)
             line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.9 .9 .9], 'LineWidth', 2);
        end
        
        h = findobj(gca, 'Tag', 'Outliers');
        for j=1:length(h)
            set(h(j), 'MarkerEdgeColor', [0 0 0]);
        end
        
        % check significances
        for t = 1:g_config.TRIALS
            p = ranksum(data(groups == 2*t - 1), data(groups == 2*t));                                
            if p < 0.05
                if p < 0.01
                    if p < 0.001
                        alpha = 0.001;
                    else
                        alpha = 0.01;
                    end
                else
                  alpha = 0.05;
                end
                 
               % add significance stars
               % h = sigstar( {[pos(2*t - 1), pos(t*2)]}, [alpha]);
               % set(h(:, 1), 'LineWidth', 1.5);
               % set(h(:, 2), 'FontSize', 0.7*g_config.FONT_SIZE);
            end
        end
                
        set(gcf, 'Color', 'w');
        box off;        
        
        set(gcf,'papersize',[8,8], 'paperposition',[0,0,8,8]);
      
        export_fig(fullfile(g_config.OUTPUT_DIR, sprintf('control_stress_trial_%s.eps', names{i})));
        
        % run friedman test            
        p = friedman(fried, n);
        str = sprintf('Friedman p-value (%s): %g', ylabels{i}, p);
        disp(str);          
    end
    
    close;
end

