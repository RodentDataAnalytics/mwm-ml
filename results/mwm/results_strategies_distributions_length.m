% Complutes the average segment lengths for each strategy adopted by 
% stress and control group for a set of 12 trials divided in 3 sessions 
% (days). The generated plots show the average length in meters that 
% animals spent in one strategy during each trial (8 total strategies). 

% Publication:
% Main Paper
% page 8 Figure 5 (A-H)

function results_strategies_distributions_length

    % global data
    global g_config; % configurations
    global g_segments_classification; % classification of segments (splited trajectories).
    global g_animals_trajectories_map; % matrix of trajectory indices for each trial and group of animals.
    global g_long_trajectories_map; % % keeps only the trajectory with length > 0       
    
    % classify trajectories
    cache_animals;
    cache_trajectories_classification; 
                                  
    strat_distr = g_segments_classification.mapping_ordered();
    lim = [90, 60, 13, 25, 25, 13, 25, 18]*25;
    %% plot distributions
    b = 1;
    for c = 1:g_segments_classification.nclasses
        data = [];
        groups = [];
        pos = [];
        d = 0.05;
        grp = 1;
                        
        if c == g_segments_classification.nclasses                        
            last = 1;
        else
            last = 0;
        end
                
        nanimals = size(g_animals_trajectories_map{1}, 2);
        mfried = zeros(nanimals*g_config.TRIALS, 2);                
        
        for t = 1:g_config.TRIALS
            for g = 1:2            
                tot = 0;
                pts_session = [];
                map = g_animals_trajectories_map{g};
        
                pts = [];
                for i = 1:nanimals
                    if g_long_trajectories_map(map(t, i)) ~= 0                        
                        val = 25*sum(strat_distr(g_long_trajectories_map(map(t, i)), :) == c);
                        pts = [pts, val];
                        mfried((t - 1)*nanimals + i, g) = val;
                    end                                           
                end

                if isempty(pts)
                    data = [data, 0];
                    groups = [groups, grp];
                else
                    data = [data, pts];
                    groups = [groups, ones(1, length(pts))*grp];
                end
                grp = grp + 1;
                
                pts_session = [pts_session, pts];

                pos = [pos, d];
                d = d + 0.05;                 
            end     
            
            if rem(t, 4) == 0
                d = d + 0.07;                
            end                
            d = d + 0.02;                
        end
       
        figure;
        boxplot(data./1000, groups, 'positions', pos, 'colors', [0 0 0]);     
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
        
        lbls = {};
        lbls = arrayfun( @(i) sprintf('%d', i), 1:g_config.TRIALS, 'UniformOutput', 0);     
        
        set(gca, 'DataAspectRatio', [1, lim(c)*1.25/1000, 1], 'XTick', (pos(1:2:2*g_config.TRIALS - 1) + pos(2:2:2*g_config.TRIALS)) / 2, 'XTickLabel', lbls, 'Ylim', [0, lim(c)/1000], 'FontSize', 0.75*g_config.FONT_SIZE);
        set(gca, 'LineWidth', g_config.AXIS_LINE_WIDTH);   
                 
        ylabel(g_segments_classification.classes(c).description, 'FontSize', 0.75*g_config.FONT_SIZE);
        xlabel('trial', 'FontSize', g_config.FONT_SIZE);        
        
        set(gcf, 'Color', 'w');
        box off;  
        set(gcf,'papersize',[8,8], 'paperposition',[0,0,8,8]);

        export_figure(1, gcf, g_config.OUTPUT_DIR, sprintf('control_stress_lenght_c%d', c));
    
        p = friedman(mfried, nanimals);
        str = sprintf('Class: %s\tp_frdm: %g', g_segments_classification.classes(c).description, p);            
        disp(str);        
    end     
end

