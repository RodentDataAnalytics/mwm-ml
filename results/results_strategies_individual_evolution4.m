function results_strategies_individual_evolution4
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
    
    figure;
    
    % bins = [10, 15, 25, 40];        
    bins = [90];    
    
    classes = constants.REDUCED_BEHAVIOURAL_CLASSES;
    
    cm = cmapping(length(classes), constants.CLASSES_COLORMAP);
    % custom color map
    % cm = [0, 0, 0; ...
     %%     1, 1, 1];          
%     cm = cm ./ repmat(255, size(cm, 1), size(cm, 2));
%     
    [~, full_strat_distr] = g_segments.classes_mapping_time(g_segments_classification, bins, 'Classes', classes, 'DiscardUnknown', 0);
         
    %% plot distributions
    b = 1;
    for c = 1:length(classes)            
        for g = 1:2            
            data = [];
            groups = [];
            tpos = [];
            pos = [];
            sig = [];
            d = 1;
            grp = 1;
            pts_session = [];
            for t = 1:12         
                sel = find( g_trajectories_trial == t & g_trajectories_group == g);                
                                
                pts = [];
                for i = 1:length(sel)
                    if g_long_trajectories_map(sel(i)) ~= 0
                        tmp = full_strat_distr{g_long_trajectories_map(sel(i))};
                        if tmp(b, c) ~= -1
                            pts = [pts, tmp(b, c)];
                        end                           
                    else
                        pts = [pts, 0];
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
                if mod(t, 4) == 0                    
                    % plot distribution
                    hfig = figure;
                    hist(pts_session, 20);
                    pts_session = [];
                    fn = fullfile(constants.OUTPUT_DIR, sprintf('control_stress_histogram_s%d_g%d_c%d.eps', floor(t / 4), g, c));
                    export_fig(fn);
                    close(hfig);
                end

                pos = [pos, d];
                d = d + 1;    
                
                if rem(t, 4) == 0
                    d = d + 1;
                end
                                
            end           
       
            figure;
            boxplot(data, groups, 'positions', pos, 'colors', [0 0 0]);     

            lbls = {};
            for i = 1:12
                lbls = [lbls, sprintf('T%d', i)];
            end
        
            
            set(gca, 'Xtick', pos, 'XTIckLabel', lbls, 'DataAspectRatio', [.8, 0.2, 1], 'Ylim', [0, 1.1], 'YTick', [0.2, 0.4, 0.6, 0.8, 1]);
            ylabel(classes(c).description, 'FontSize', 0.6*constants.FONT_SIZE);

            h = findobj(gca,'Tag','Box');               
            for j=1:length(h)
                switch g
                    case 1
                      % patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
                    case 2  
                        patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
                end                                        
            end
            set([h], 'LineWidth', 0.8);
            
            h = findobj(gca,'Tag','Box');               
            for j=1:length(h)
                switch g
                    case 1
                       % patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
                    case 2  
                        patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
                end                                        
            end
            
            h = findobj(gca, 'Tag', 'Outliers');
            for j=1:length(h)
                set(h(j), 'MarkerEdgeColor', [0 0 0]);
            end

            h = findobj(gca, 'Tag', 'Median');
            for j=1:length(h)
                switch g
                    case 1
                        % line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [1 1 1], 'LineWidth', 2);
                    case 2  
                        line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.9 .9 .9], 'LineWidth', 2);
                end                                        
            end

            set(gcf, 'Color', 'w');
            box off;  

            export_fig(fullfile(constants.OUTPUT_DIR, sprintf('control_stress_friedman_g%d_c%d.eps', g, c)));
        end
    end     
end

