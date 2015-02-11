function results_strategies_distributions_length
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));  
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/sigstar'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/AnDarksamtest'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/cm_and_cb_utilities'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../'));

    % global data initialized elsewhere
    global g_segments_classification;
    global g_trajectories_trial;    
    global g_trajectories_group;          
    global g_segments;    
    global g_long_trajectories_map;        
    
    % classify trajectories
    cache_trajectories_classification; 
       
    % bins = [10, 15, 25, 40];        
    bins = [90];    
                            
    [~, full_strat_distr] = g_segments_classification.mapping_ordered(-1);
    
    classes = [classes, tag('DF', 'direct finding', g_config.TAG_TYPE_BEHAVIOUR_CLASS)];
    
    %% plot distributions
    b = 1;
    for c = 1:length(classes)            
        data = [];
        groups = [];
        pos = [];
        d = 0.1;
        grp = 1;
                        
        if c == length(classes)                        
            last = 1;
        else
            last = 0;
        end
        
        for t = 1:g_config.TRIALS                            
            for g = 1:2            
                pts_session = [];
                sel = find( g_trajectories_trial == t & g_trajectories_group == g);                
                                
                pts = [];
                for i = 1:length(sel)                        
                    if g_long_trajectories_map(sel(i)) ~= 0
                        if c == length(classes)
                            % 'direct finding' group
                            pts = [pts, 0];
                        else                            
                            tmp = full_strat_distr{g_long_trajectories_map(sel(i))};
                            if tmp(b, c) ~= -1
                                pts = [pts, tmp(b, c)];
                            end
                        end
                    else
                        if c == length(classes)
                            % 'direct finding' ...
                            pts = [pts, 1];
                        else
                            pts = [pts, 0];
                        end
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
%                 if mod(t, 4) == 0                    
%                     % plot distribution
%                     hfig = figure;
%                     hist(pts_session, 20);
%                     pts_session = [];
%                     fn = fullfile(g_config.OUTPUT_DIR, sprintf('control_stress_histogram_s%d_g%d_c%d.eps', floor(t / 4), g, c));
%                     export_fig(fn);
%                     close(hfig);
%                 end

                pos = [pos, d];
                d = d + 0.1; 
                if last
                    d = d + 0.04;
                end
            end     
            
            if rem(t, 4) == 0
                d = d + 0.15;
                if last
                    d = d + 0.07;
                end
            end                
            d = d + 0.07;    
            if last
                d = d + 0.03;
            end
        end
       
        figure;
        if c == length(classes)
            % last plot (direct finding) -> use a standard bar plot since
            % we have only 1/0 values
            
            % why can't matlab be consistent between different funcitons?
            % parameters for 'bar' and 'boxplot' should be the same, but
            % for the former we don't have the 'group' option
            for j = 1:(g_config.TRIALS*2)                
                h = bar(pos(j), sum(data(groups == j) / length(data(groups == j))), 0.08);
                if mod(j, 2) == 0
                    set(h, 'facecolor', [0 0 0]);
                else
                    set(h, 'facecolor', [1 1 1]);
                end           
                hold on;
            end            
        else
            boxplot(data, groups, 'positions', pos, 'colors', [0 0 0]);     
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
        end
        
        lbls = {};
        lbls = arrayfun( @(i) sprintf('%d', i), 1:g_config.TRIALS, 'UniformOutput', 0);     
        
        set(gca, 'XTick', (pos(1:2:2*g_config.TRIALS - 1) + pos(2:2:2*g_config.TRIALS)) / 2, 'YLim', [-0.02, 1], 'XTickLabel', lbls, 'FontSize', 0.75*g_config.FONT_SIZE);                      
        set(gca, 'LineWidth', g_config.AXIS_LINE_WIDTH);   
        
        % 'DataAspectRatio', [1, 0.08, 1], 
        ylabel(classes(c).description, 'FontSize', 0.75*g_config.FONT_SIZE);
        xlabel('trial', 'FontSize', g_config.FONT_SIZE);
        
        
        set(gcf, 'Color', 'w');
        box off;  
        set(gcf,'papersize',[8,8], 'paperposition',[0,0,8,8]);
        
        export_fig(fullfile(g_config.OUTPUT_DIR, sprintf('control_stress_friedman_c%d.eps', c)));
    end     
end

