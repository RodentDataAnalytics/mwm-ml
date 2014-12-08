function results_control_stress_speed_latency    
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/notBoxPlot'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/sigstar'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/AnDarksamtest'));
    
    
    % global data initialized elsewhere
    global g_trajectories_speed;        
    global g_trajectories_length;        
    global g_trajectories_latency;
    global g_trajectories_efficiency;
    global g_animals_trajectories_map;
    
    cache_trajectories;
    eff = g_trajectories_efficiency;
    eff = eff + ones(1, length(eff))*3e-3;
    vars = [g_trajectories_latency; eff; g_trajectories_speed; g_trajectories_length/100];
    names = {'latency', 'efficiency', 'speed', 'length'};
    ylabels = {'latency [s]', 'efficiency', 'speed [cm/s]', 'path length [m]'};
    log_y = [0, 1, 0, 0];
    
    figure(872);
    for i = 1:size(vars, 1)
        clf;
        values = vars(i, :);
        data = [];
        groups = [];
        xpos = [];
        pos = [0, 0.4, 1.2, 1.6, 2.4, 2.8];
        for s = 1:constants.SESSIONS
            for g = 1:2            
                map = g_animals_trajectories_map{g};
                ti = (s - 1)*constants.TRIALS_PER_SESSION + 1;
                tf = s*constants.TRIALS_PER_SESSION;
                tmp = mean(values(map(ti:tf, :)));                 
                data = [data, tmp(:)'];
                xpos = [xpos, repmat(pos(s*2 - 1 + g - 1), 1, length(tmp(:)))];             
                groups = [groups, repmat(s*2 - 1 + g - 1, 1, length(tmp(:)))];             
            
            end
        end
        boxplot(data, groups, 'positions', pos, 'colors', [0 0 0; .7 .7 .7]);     
        set(gca, 'XTick', [0.2, 1.4, 2.6], 'XTickLabel', {'Session 1', 'Session 2', 'Session 3'}, 'FontSize', constants.FONT_SIZE);         
        h = findobj(gca,'Tag','Box');
        for j=1:2:length(h)
             patch(get(h(j),'XData'), get(h(j), 'YData'), [.9 .9 .9], 'FaceAlpha', .3);
        end
        set([h], 'LineWidth', 1.5);
   
        h = findobj(gca, 'Tag', 'Median');
        for j=1:2:length(h)
             line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [0 0 0]);
        end
                
        % check significances
        for s = 1:constants.SESSIONS
            hip = ttest2(data(groups == 2*s - 1), data(groups == 2*s));
            if hip
                h = sigstar( {[pos(2*s - 1), pos(s*2)]}, [0.05]);
                set(h(:, 1), 'LineWidth', 2);
                set(h(:, 2), 'FontSize', constants.FONT_SIZE);
            end
        end
                
        set(gcf, 'Color', 'w');
        set(gca, 'LineWidth', constants.AXIS_LINE_WIDTH);
        box off;        
        ylabel(ylabels{i}, 'FontSize', constants.FONT_SIZE);
        
        export_fig(fullfile(constants.OUTPUT_DIR, sprintf('control_stress_%s.eps', names{i}))); 
        
        %%
        %% Do the same for each trial
        clf;
        data = [];
        groups = [];
        xpos = [];
        d = 0.1;
        idx = 1;
        pos = zeros(1, 2*constants.TRIALS);
        for s = 1:constants.SESSIONS
            for t = 1:constants.TRIALS_PER_SESSION
                for g = 1:2                    
                    pos(idx) = d;
                    d = d + 0.1;
                    idx = idx + 1;
                end
                d = d + 0.07;
            end
            d = d + 0.15;
        end
             
%        pos = 0:0.3:(0.3*(2*constants.TRIALS - 1));
%        pos(2:2:(2*constants.TRIALS)) = pos(2:2:(2*constants.TRIALS)) - repmat(0.1, 1, constants.TRIALS);
        for t = 1:constants.TRIALS
            for g = 1:2            
                map = g_animals_trajectories_map{g};
                tmp = values(map(t, :));                 
                data = [data, tmp(:)'];
                xpos = [xpos, repmat(pos(t*2 - 1 + g - 1), 1, length(tmp(:)))];             
                groups = [groups, repmat(t*2 - 1 + g - 1, 1, length(tmp(:)))];             
            
            end
            
        end
        boxplot(data, groups, 'positions', pos, 'colors', [0 0 0; .7 .7 .7]);
        set(gca, 'LineWidth', constants.AXIS_LINE_WIDTH, 'FontSize', constants.FONT_SIZE);
        
        lbls = {};
        lbls = arrayfun( @(i) sprintf('%d', i), 1:constants.TRIALS, 'UniformOutput', 0);     
        
        set(gca, 'XTick', (pos(1:2:2*constants.TRIALS - 1) + pos(2:2:2*constants.TRIALS)) / 2, 'XTickLabel', lbls, 'FontSize', 0.75*constants.FONT_SIZE);                 
        
        
        if log_y(i)
            set (gca, 'Yscale', 'log');
        else
            set (gca, 'Yscale', 'linear');
        end
        
        ylabel(ylabels{i}, 'FontSize', constants.FONT_SIZE);
        xlabel('trial', 'FontSize', constants.FONT_SIZE);

        h = findobj(gca,'Tag','Box');
        for j=1:2:length(h)
             patch(get(h(j),'XData'), get(h(j), 'YData'), [.9 .9 .9], 'FaceAlpha', .3);
        end
        set([h], 'LineWidth', 0.8);
   
        h = findobj(gca, 'Tag', 'Median');
        for j=1:2:length(h)
             line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [0 0 0]);
        end
                
        % check significances
        for t = 1:constants.TRIALS
            data_test = [data(groups == 2*t - 1)' ones(sum(groups == 2*t - 1), 1); ...
                         data(groups == 2*t)' 2*ones(sum(groups == 2*t), 1)];

                   
                % hip = kstest2(data(groups == 2*t - 1), data(groups == 2*t));
            hip = AnDarksamtest(data_test, 0.05);                    
            if hip
                alpha = 0.05;
                hip = AnDarksamtest(data_test, 0.01);                    
            
                if hip
                   alpha = 0.01;
                end
                                                                    
                h = sigstar( {[pos(2*t - 1), pos(t*2)]}, [alpha]);
                set(h(:, 1), 'LineWidth', 1.5);
                set(h(:, 2), 'FontSize', 0.7*constants.FONT_SIZE);
            end
        end
                
        set(gcf, 'Color', 'w');
        box off;        
        
        export_fig(fullfile(constants.OUTPUT_DIR, sprintf('control_stress_trial_%s.eps', names{i})));
    end
    
    close;
end

