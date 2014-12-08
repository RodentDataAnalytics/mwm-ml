function results_strategies_individual_evolution
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
    global g_long_trajectories_idx;
    
    % classify trajectories
    cache_trajectories_classification; 
    
    figure;
    
    % bins = [10, 15, 25, 40];        
    bins = [20, 25, 45];    
    
    classes = constants.REDUCED_BEHAVIOURAL_CLASSES;
    
    cm = cmapping(length(classes), constants.CLASSES_COLORMAP);
    % custom color map
    % cm = [0, 0, 0; ...
     %%     1, 1, 1];          
%     cm = cm ./ repmat(255, size(cm, 1), size(cm, 2));
%     
    [strat_distr, full_strat_distr] = g_segments.classes_mapping_time(g_segments_classification, bins, 'Classes', classes, 'DiscardUnknown', 0);

    % plot the distribution of strategies for each session and group of
    % animals
    for g = 1:2        
        for s = 1:constants.SESSIONS % for each session
            clf;
            distr = {};
            row_labels = {};
            col_labels = {};
            markers = {};

            for t = 1:constants.TRIALS_PER_SESSION
                trial = (s - 1)*constants.TRIALS_PER_SESSION + t;
                sel = find(g_trajectories_trial(g_long_trajectories_idx) == trial & g_trajectories_group(g_long_trajectories_idx) == g);
                
                % convert array of values to a single integer
                vals = cellfun( @(x) sum(arrayfun( @(idx) iff(x(idx) > 0, x(idx)*10^(idx - 1), 0), 1:length(x))), num2cell(strat_distr(sel, :), 2));
                un = unique(vals);
                prot = [];
                counts = [];
                for i = 1:length(un)
                    idx = find(vals == un(i));
                    if sum(strat_distr(sel(idx(1)), :) > 0) > 0
                        prot = [prot; strat_distr(sel(idx(1)), :)];                
                        counts = [counts, length(idx)];
                    end
                end
                % sort them by count
                [counts, ord] = sort(counts, 'descend');
                prot = prot(ord, :);
                lbls = arrayfun( @num2str, counts, 'UniformOutput', 0);
                distr = [distr, prot];
                row_labels = [row_labels, {lbls}];
                col_labels = [col_labels, sprintf('Trial %d', trial)];
            end
                        
            % 'RowLabels', row_labels, 
            plot_distribution_strategies(distr, 'Ordered', 1, 'Widths', bins, ...
                            'ColumnLabels', col_labels, 'RowLabels', row_labels, ...
                            'Ticks', [10, 50, 90], 'TicksLabels', {'10s', '50s', '90s'}, 'AspectRatio', 0.2, 'ColorMap', cm);

            export_fig(fullfile(constants.OUTPUT_DIR, sprintf('individual_strategies_evol_g%d_s%d.eps', g, s)));
        end
    end 
    
    % two reduced additional plots
    sel_trials = [1, 4, 9, 10, 11];
    for g = 1:2        
        clf;
        distr = {};
        row_labels = {};
        col_labels = {};
        markers = {};

        for t = 1:length(sel_trials)
            sel = find(g_trajectories_trial(g_long_trajectories_idx) == sel_trials(t) & g_trajectories_group(g_long_trajectories_idx) == g);
             % convert array of values to a single integer
            vals = cellfun( @(x) sum(arrayfun( @(idx) iff(x(idx) > 0, x(idx)*10^(idx - 1), 0), 1:length(x))), num2cell(strat_distr(sel, :), 2));
            un = unique(vals);
            prot = [];
            counts = [];
            for i = 1:length(un)
                idx = find(vals == un(i));
                if sum(strat_distr(sel(idx(1)), :) > 0) > 0
                    prot = [prot; strat_distr(sel(idx(1)), :)];                
                    counts = [counts, length(idx)];
                end
            end
            % sort them by count
            [counts, ord] = sort(counts, 'descend');
            prot = prot(ord, :);
            lbls = arrayfun( @num2str, counts, 'UniformOutput', 0);
            distr = [distr, prot];
            row_labels = [row_labels, {lbls}];
            col_labels = [col_labels, sprintf('Trial %d', sel_trials(t))];
        end

        plot_distribution_strategies(distr, 'Ordered', 1, 'Widths', bins, ...
                         'ColumnLabels', col_labels, 'RowLabels', row_labels, ...
                         'Ticks', [10, 50, 90], 'TicksLabels', {'10s', '50s', '90s'});                             

        export_fig(fullfile(constants.OUTPUT_DIR, sprintf('individual_strategies_evol_g%d_red.eps', g)));
    end     
         
    %% plot distributions now 
    bin_lbls = {'start', 'middle', 'end'};
    for b = 1:length(bins)    
    %    trials = [2, 4, 6, 8, 10, 12];
     %   trials = [1, 3, 5, 7, 9, 11];
    %     trials = 1:12;
        
        for s = 1:constants.SESSIONS
            % trials = 1:6;
            ti = (s - 1)*constants.TRIALS_PER_SESSION + 1;
            tf = s*constants.TRIALS_PER_SESSION;             
            data = [];
            groups = [];
            tpos = [];
            pos = [];
            sig = [];
            d = 0.5;
            grp = 1;
            for t = ti:tf
                sig_test_data = {};
                for g = 1:2
                    timei = d;

                    sel = find( g_trajectories_trial(g_long_trajectories_idx) == t & g_trajectories_group(g_long_trajectories_idx) == g);                
                    %sel = find( (g_trajectories_trial(g_long_trajectories_idx) == t*2 | g_trajectories_trial(g_long_trajectories_idx) == t*2 - 1) & g_trajectories_group(g_long_trajectories_idx) == g);                


                    for c = 1:length(classes)            
                        %sel = find( (g_trajectories_trial(g_long_trajectories_idx) == 2*t | g_trajectories_trial(g_long_trajectories_idx) == 2*t-1) & g_trajectories_group(g_long_trajectories_idx) == g);
                        pts = [];
                        for i = 1:length(sel)
                            tmp = full_strat_distr{sel(i)};
                            if tmp(b, c) ~= -1
                                pts = [pts, tmp(b, c)];
                            end
                        end

                        if g == 1
                            sig_test_data{c} = pts';
                            sig_test_data{c} = [sig_test_data{c}, ones(length(pts), 1)];                        
                        else
                            sig_test_data{c} = [sig_test_data{c}; pts' 2*ones(length(pts), 1)];                                                
                        end

                        if isempty(pts)
                            data = [data, 0];
                            groups = [groups, grp];
                        else
                            data = [data, pts];
                            groups = [groups, ones(1, length(pts))*grp];
                        end
                        grp = grp + 1;

                        pos = [pos, d];
                        d = d + 1;
                    end

                    tpos = [tpos, (d + timei)/2];
                    d = d + 1;
                end
                d = d + 1;
                for i = 1:length(sig_test_data)
                    hip = AnDarksamtest(sig_test_data{i});
                    if hip
                        val = 0.05;
                        hip = AnDarksamtest(sig_test_data{i}, 0.01);
                        if hip
                            val = 0.01;
                        end
                        sig = [sig; pos(length(pos) - 2*length(classes) + i) pos(length(pos) - length(classes) + i) val];                    
                    end
                end    

            end

            figure;
            boxplot(data, groups, 'positions', pos, 'colors', [0 0 0]);     

            lbls = {};
            for i = ti:tf
                lbls = [lbls, sprintf('C%d', i)];
                lbls = [lbls, sprintf('S%d', i)];
            end
            set(gca, 'Xtick', tpos, 'XTIckLabel', lbls, 'DataAspectRatio', [1, 0.06, 1], 'Ylim', [0, 1.2], 'YTick', [0.2, 0.4, 0.6, 0.8, 1]);
            ylabel(sprintf('session %d %s', s, bin_lbls{b}), 'FontSize', 0.6*constants.FONT_SIZE);

%             lbl = '';
%             for i = 1:length(trials)
%                 lbl = [lbl, 'T ' num2str(trials(i)) '             '];
%             end
%             xlabel(lbl, 'FontSize', 0.6*constants.FONT_SIZE);

    %        lbls = arrayfun( @(i) sprintf('trial %d', i), 6:constants.TRIALS, 'UniformOutput', 0);         
     %       set(gca, 'XTick', (pos(1:2:2*constants.TRIALS - 1) + pos(2:2:2*constants.TRIALS)) / 2, 'XTickLabel', lbls, 'FontSize', 0.6*constants.FONT_SIZE);                 
            h = findobj(gca,'Tag','Box');               
            for j=1:length(h)
                idx = mod(j, length(classes));
                switch idx
                    case 0
                        patch(get(h(j),'XData'), get(h(j), 'YData'), [0 0 0]);
                        median_color = [.9 .9 .9];
                    case 2  
                        patch(get(h(j),'XData'), get(h(j), 'YData'), [.8 .8 .8]);
                        median_color = [0 0 0];
                    otherwise
                        median_color = [0 0 0];
                end                                        
            end
            set([h], 'LineWidth', 0.8);

            h = findobj(gca, 'Tag', 'Median');
            for j=1:length(h)
                idx = mod(j, length(classes));
                switch idx
                    case 0
                        line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [1 1 1], 'LineWidth', 2);
                    case 2  
                        line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [.2 .2 .2], 'LineWidth', 2);
                    otherwise
                        line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [0 0 0], 'LineWidth', 2);                        
                end                                        
            end
            
            % check significances
            for i = 1:size(sig, 1)                        
                h = sigstar( {sig(i, 1:2)}, [sig(i, 3)]);
                set(h(:, 1), 'LineWidth', 1.2);
                set(h(:, 2), 'FontSize', 0.6*constants.FONT_SIZE);            
            end

            set(gcf, 'Color', 'w');
            set(gca, 'LineWidth', constants.AXIS_LINE_WIDTH);
            box off; 

            export_fig(fullfile(constants.OUTPUT_DIR, sprintf('control_stress_evol_s%d_b%d.eps', s, b)));
        end
    end   
end

