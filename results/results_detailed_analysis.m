function results_detailed_analysis
%RESULTS_CONTROL_STRESS_ANALYSIS Summary of this function goes here
%   Detailed explanation goes here
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/legendflex'));

    % global data initialized elsewhere
    global g_trajectories_trial;    
    global g_segments_classification;
    global g_long_trajectories_idx;
    global g_long_trajectories_classes_distr;
    global g_trajectories_latency;
    
    % classify trajectories
    cache_trajectories_classification; 
       
    % compute some feature sets for all segments that will be used to
    % select groups of segments
    % seg_lat = arrayfun( @(t) t.compute_feature(features.LATENCY), seg.items );        
    % seg_ti = arrayfun( @(t) t.start_time, seg.items );
    % seg_tf = arrayfun( @(t) t.end_time, seg.items );
    % seg_trial = arrayfun( @(t) t.trial, seg.items );
    % seg_group = arrayfun( @(t) t.group, seg.items);
                                   
    nplots = 6;
    plots = cell(nplots, 13);
    for g = 1:2 % groups 1 and 2
        for d = 1:3 % for each day
            r = (g - 1)*3 + d;
            plots{r, 1} = sprintf('/tmp/detailed_strategies_g%d_s%d', g, d);
            for i = 1:4 % for each trial
                plots{r, i*2} = find(trials == ((d - 1)*4 + i) & groups == g);
                plots{r, i*2 + 1} = sprintf('Trial %d', (d - 1)*4 + i);
            end
            plots{r, 10} = 'M';
            plots{r, 11} = 'Average';
        end
    end 
    % two reduced additional plots
    sel_trials = [1, 3, 6, 9, 12];
    % sel_trials = [12, 5];
%     for g = 1:2
%         sel = {};            
%         plots{6 + g, 1} = sprintf('/tmp/detailed_strategies_g%d_red', g);       
%         for i = 1:length(sel_trials)            
%             % sel(i, :) = find(trials == sel_trials(i) & groups == g);
%             if g == 1
%                 sel{i} = find(trials == sel_trials(i) & session_speed < 30);
%             else
%                 sel{i} = find(trials == sel_trials(i) & session_speed >= 30);
%             end
%         end
%         % sort by total length
%         %[~, ord] = sort( sum(reshape(traj_speed(sel(:)), length(sel_trials), length(sel))) );
%         %sel = sel(:, ord);
%         for i = 1:length(sel_trials)
%             plots{6 + g, 2*i} = sel{i};
%             plots{6 + g, 2*i + 1} = sprintf('Trial %d', sel_trials(i));
%         end        
%     end
%     
     % and two more mixed plots
    sel_trials = [3, 6, 7, 9];
    % sel_trials = [12, 5];
%     for g = 1:2
%         sel = {};                    
%         plots{8 + g, 1} = sprintf('/tmp/detailed_strategies_g%d_red2', g);       
%         for i = 1:length(sel_trials)
%             % sel(i, :) = find(trials == sel_trials(i) & groups == g);
%             if g == 1
%                 sel{i} = find(trials == sel_trials(i) & session_speed < 30);
%             else
%                 sel{i} = find(trials == sel_trials(i) & session_speed >= 30);
%             end
%         end
%         % sort by total length
%         %[~, ord] = sort( sum(reshape(traj_speed(sel(:)), length(sel_trials), size(sel, 2))) );
%         %sel = sel(:, ord);
%         for i = 1:length(sel_trials)
%             plots{8 + g, 2*i} = sel{i};
%             plots{8 + g, 2*i + 1} = sprintf('Trial %d', sel_trials(i));
%         end        
%     end
       
    %%%
    %% distribution of strategies over a set of trials
    %%%
    alw = 1;    % AxesLineWidth
    fsz = 6;      % Fontsize
    for iplot = 1:nplots
        cur = plots(iplot, :);
        ncol = 0;
        for i = 2:length(cur)
            if isempty(cur{i})
                break;
            end
            ncol = i - 1;
        end        
        
        l = 0.92;
        b = 0.05;
        w = (l - 2*b)/(ncol/2);
        h = l - 2*b;        
        tot = zeros(length(cur{2}), size(full_distr, 2));
        fig = figure('PaperUnits', 'centimeters');
        set(fig,'visible','on','Color','w', 'PaperPosition', [0.1 0 12 9],...
            'PaperSize', [12 8],'PaperUnits', 'centimeters'); %Position plot at left hand corner with width 14cm and height 7cm.
        ma = axes('Position',[b b l l] );  % "parent" axes            
        axis off;            
        for i=1:(ncol/2)             
            sel = cur{i*2};  
            if length(sel) == 1 && sel == 'M'
                mean_col = 1;
            else
                mean_col = 0;
            end
            if i == 1
                ids = arrayfun( @(idx) traj.items(idx).id, sel);
                n = length(sel);
            else
                if ~mean_col
                    assert(isequal(ids, arrayfun( @(idx) traj.items(idx).id, sel)));
                end    
            end

            % create an axes inside the parent axes for the ii-the barh            
            sa = axes('Position', [b + w*(i - 1), b + 0.05, w, h]); % position the ii-th barh

            if ~mean_col
                tot = tot + full_distr(sel, :);                    
                v = full_distr(sel, :);
            else
                % last column - mean
                v = tot / (ncol/2 - 1);                                        
            end

            vals = zeros(n + 1, size(full_distr, 2));
            m = mean(v);
            if ~mean_col
                m = mean(full_distr(sel, :));
            end
            vals(1, :) = m;
            vals(2:size(vals, 1), :) = v;   
            vals(vals(:) == 0) = nan;                

            barh(1:length(vals), vals, 'Stack', 'Parent', sa); 
            colormap jet;
            set(gca,'box','off');
            set(gca,'XLim', [0, max_len], 'XTick', [1000, 3000], 'XTickLabel', {'10m', '30m'});
            if i == 1
                lbls = {'AVG'};
                lbls = [lbls, arrayfun( @(idx) sprintf('%d', traj.items(idx).id), sel, 'UniformOutput', 0)];
                set(gca,'YTick', 1:(n + 1), 'YTickLabel', lbls);
            else
                set(gca,'YTick', []);
            end           
            hold on;
            if mean_col
                text(max_len / 2, n + 4, 'Average', 'FontSize', 1.1*fsz, 'HorizontalAlignment','center');
            else    
                text(max_len / 2, n + 4, cur{i*2 + 1}, 'FontSize', 1.1*fsz, 'HorizontalAlignment','center');
                 % mark cases where animal found the platform
                for j = 1:length(sel)
                    if traj_lat(sel(j)) == g_config.TRIAL_TIMEOUT
                        hold on;                     
                       % text( traj_length(sel(j)) + 100, j + 1, sprintf('* (%d)', found_counter(j)), 'FontSize', fsz, 'FontWeight', 'bold'); 
                        text( traj_length(sel(j)) + 100, j + 1, 'x', 'FontSize', fsz, 'FontWeight', 'bold'); 
                    end
                end
            end
            set(gca, 'FontSize', fsz, 'LineWidth', alw);                               
         %   plot([0, w, w, 0], [0, 0, h, h], 'k', 'linewidth', 2);

        end
        %print(gcf, '-dpdf', '-loose', sprintf('/tmp/detailed_strategies_g%d_s%d.pdf', g, d));
        export_fig(strcat(cur{1}, '.eps'));                                            
    end           
    
    % legend
    figure;
    dummyplot = barh(full_distr(1:2, :), 'Stack');
    leg = arrayfun(@(t) t.description, tags(strat_ordering), 'UniformOutput', 0);
    leg = [leg, 'direct finding'];
    hleg = figure;
    set(gcf, 'Color', 'w');
    legendflex(dummyplot, leg, 'box', 'off', 'nrow', 3, 'ncol', 3, 'ref', hleg, 'fontsize', 8, 'anchor', {'n','n'});
    % print(gcf, '-dpdf', '/tmp/detailed_strategies_legend');
    export_fig('/tmp/detailed_strategies_legend.eps');
    
    combined = { {'TT', 'IC'}, {'AT'}, {'SO', 'SC'}, {'CR'}, {'ST'}, {'DF'} };
    combined_titles = {'thigmotaxis/incursion', 'approaching target', 'scanning', 'chaining-reaction', 'target scanning', 'direct finding'};
    alw = 1.6;    % AxesLineWidth
    fsz = 8;      % Fontsize  
    lw = 1.6;      % LineWidth    
    
    %%%%
    %% second plot -> change of strategies over time
    %%%%
    
    % use a reduced set of classes
    tag_groups = [  tag.combine_tags( [g_config.TAGS(2), g_config.TAGS(3)] ), ... % TT + IC
                    g_config.TAGS(11), ...                         %AT
                    tag.combine_tags( [g_config.TAGS(7), g_config.TAGS(10)]), ... % SC + SO
                    g_config.TAGS(5), ... % CR                                                 
                    g_config.TAGS(6) ]; % ST                               
    
    [segment_classes, tags] = seg.classify(g_config.SEGMENTS_TAGS250_PATH, g_config.DEFAULT_FEATURE_SET, 100, 0, tag_groups);                         
                 
    % we compute the distribution of strategies by number of segments and
    % time as well
    classes_distr = seg.trajectory_classes_distribution(segment_classes, length(tag_groups), seg_lat);
    nclasses = length(tag_groups);    
    % normalize it
    classes_distr = classes_distr ./ repmat(sum(classes_distr , 2) + (sum(classes_distr, 2) == 0)*1e-5, 1, nclasses);
                
    max_seg = max(partitions);                 
                 
    class_colors = jet(5);    
    nmax_bars = 0;
    for iplot = 1:nplots
        cur = plots(iplot, :);
        ncol = 0;
        for i = 2:length(cur)
            if isempty(cur{i})
                break;
            end
            ncol = i - 1;
        end        
        
        l = 1;
        b = 0.05;        
        w = (l - 2*b)/(ncol/2);
        h = 0.8 - 2*b;                
        
        fig = figure('PaperUnits', 'centimeters');
        set(fig,'visible','on','Color','w', 'PaperPosition', [0.1 0 12 4.5],...
            'PaperSize', [12 4.5],'PaperUnits', 'centimeters'); %Position plot at left hand corner with width 14cm and height 7cm.
        axis off;                
        
        for i=1:(ncol/2)
            sel = cur{i*2};  
            if length(sel) == 1 && sel == 'M'
                continue;            
            end
            % take only the long enough trajectories
            sel = sel(traj_length(sel) > 2*g_config.DEFAULT_SEGMENT_LENGTH);
            % also, remove any trajectories withtout class information
            sel = sel(sum(full_distr(sel, 1:length(tag_groups)), 2) > 0);
            [~, idx] = sort(traj_length(sel), 'descend');
            sel = sel(idx);
            pref_strat = zeros(1, length(tag_groups));
            
            axes('Position', [w*(i - 1) + 0.05, b + 0.17, w - 0.05, h - 0.17]); % position the ii-th barh          
            
            all_vals = {};
            all_classes = {};

            nbars = min(length(sel), 11);
            if i == 1
                nmax_bars = nbars;
            end

            for j = 1:nbars            
                % create an axes inside the parent axes for the ii-the barh                        
                classes = [];
                vals = [];
                for k = 1:partitions(sel(j));
                    pos = cum_partitions(sel(j)) + k;       
                    if segment_classes(pos) ~= 0
                        new_strat = segment_classes(pos);
                    else
                        new_strat = 0;
                    end
                    if k == 1
                        % initialization
                        strat = new_strat;        
                        num = 1;
                    else
                        % strategy changed ?                   
                        if new_strat ~= strat                    
                            if strat ~= 0
                                % collect previous segment
                                if ~isempty(classes) && classes(end) == strat
                                    vals(end) = vals(end) + num;
                                else
                                    classes = [classes, strat];
                                    vals = [vals, num];
                                end
                                num = 0;        
                            else
                                % treat unknown segments differently
                                if ~isempty(classes)
                                    if mod(num, 2)
                                        vals(end) = vals(end) + (num - 1)/2;
                                        num = (num - 1)/2 + 1;
                                    else                                    
                                        vals(end) = vals(end) + num/2;
                                        num = num/2;
                                    end
                                end                                
                            end      
                            strat = new_strat;                        
                        end
                        num = num + 1;
                    end
                end
                % add tail
                if strat ~= 0                
                    classes = [classes, strat];
                    vals = [vals, num];
                else
                    vals(end) = vals(end) + num;
                end
                % add trajectory to the preferred strategies list
                off = 0;
                for k = 1:length(classes)                    
                    for l = 1:vals(k)
                        if size(pref_strat, 1) < off + l
                            pref_strat = [pref_strat; zeros(1, length(tag_groups))];
                        end
                        pref_strat(off + l, classes(k)) = pref_strat(off + l, classes(k)) + 1; 
                    end
                    off = off + vals(k);
                end
                
                all_vals = [all_vals, vals]; 
                all_classes = [all_classes, classes];
            end                       
            for j = (nbars + 1):nmax_bars
                all_vals = [all_vals, [0] ];
                all_classes = [all_classes, [1]];
            end
            
            % add preferred strategy bar
%             classes = [];
%             vals = [];
%             strat = 0;
%             num = 0;
%             for k = 1:max_seg
%                 [val, new_strat] = max(pref_strat(k, :));
%                 if val == 0 
%                     break;
%                 end
%                 if new_strat ~= strat
%                     if k ~= 1
%                         classes = [classes, strat];                       
%                         vals = [vals, num];
%                     end
%                     strat = new_strat;
%                     num = 0;
%                 end
%                 num = num + 1;
%             end
%             if num ~= 0
%                 classes = [classes, strat];
%                 vals = [vals, num];
%             end
%             all_vals = [vals, all_vals];            
%             all_classes = [classes, all_classes];
            
            % plot the bars
            len_max = 0;
            for k = 1:length(all_vals)            
                vals = all_vals{k};
                classes = all_classes{k};
                barh([k, k + 1], [vals; zeros(1, length(vals))], 'Stacked');
                % color the patches
                P = findobj(gca, 'type', 'patch');
                for l = 1:length(vals)
                    set(P(length(vals) - l + 1), 'facecolor', class_colors(classes(l), :));
                end
                hold on;                
            end           
                
            tick1 = 1000 / ((1. - g_config.DEFAULT_SEGMENT_OVERLAP)*g_config.DEFAULT_SEGMENT_LENGTH);
            tick2 = 3000 / ((1. - g_config.DEFAULT_SEGMENT_OVERLAP)*g_config.DEFAULT_SEGMENT_LENGTH);
            set(gca,'XLim', [0, max_seg], 'XTick', [tick1, tick2], 'XTickLabel', {'10m', '30m'});
            set(gca,'box','off');           

            % lbls = {'AVG'};
            lbls = arrayfun( @(idx) sprintf('%d', traj.items(idx).id), sel, 'UniformOutput', 0);
            set(gca,'YTick', 1:nbars, 'YTickLabel', lbls(1:nbars));
            
            text(max_seg / 2 + 10, nmax_bars + 2, cur{i*2 + 1}, 'FontSize', 1.1*fsz, 'HorizontalAlignment','center');
             % mark cases where animal has not found the platform
            for j = 1:nbars
                if traj_lat(sel(j)) == g_config.TRIAL_TIMEOUT
                    hold on;                     
                   % text( traj_length(sel(j)) + 100, j + 1, sprintf('* (%d)', found_counter(j)), 'FontSize', fsz, 'FontWeight', 'bold'); 
                    text( partitions(sel(j)) + 2, j + 0.2, 'x', 'FontSize', fsz, 'FontWeight', 'bold'); 
                end
            end
           
            set(gca, 'FontSize', 0.75*fsz, 'LineWidth', alw);
            axis tight;
    
            % plot distribution
            axes('Position', [w*(i - 1) + 0.05, b, (w - 0.05)*size(pref_strat,1)/max_seg, 0.12]); % position the ii-th barh          
            % smooth things a bit
            vals = pref_strat(1, :);
            for j = 2:size(pref_strat, 1)
                vals(j, :) = vals(j - 1, :)*0.75 + 0.25*pref_strat(j, :);                 
            end                        
            % normalize each column
            vals = vals ./ repmat( sum(vals, 2), 1, size(vals, 2));
            ha = area(vals);
            for j = 1:size(vals, 2)
                set(ha(j),'FaceColor', class_colors(j, :));
            end
            set(gca, 'FontSize', fsz*.8, 'LineWidth', alw);    
            set(gca,'YTick', [50], 'YTickLabel', {'50%'});            
            axis tight;
            set(gca,'XTick', []);            
            set(gca,'box','off');            
        end 
        export_fig(strcat(cur{1}, '_ordered.eps'));
    end
        
    % legend
    figure;
    dummyplot = barh(1:2, [1:length(class_colors); 1:length(class_colors)], 'Stack');
    P = findobj(gca, 'type', 'patch');
    for k = 1:length(P) 
        set(P(length(P) - k + 1), 'facecolor', class_colors(k, :));
    end
                
    leg = arrayfun(@(i) combined_titles{i}, 1:5, 'UniformOutput', 0);
    hleg = figure;
    set(gcf, 'Color', 'w');
    legendflex(dummyplot, leg, 'box', 'off', 'nrow', 3, 'ncol', 2, 'ref', hleg, 'fontsize', 8, 'anchor', {'n','n'});
    P = findobj(gca, 'type', 'patch');
    for k = 1:length(P) 
        set(P(length(P) - k + 1), 'facecolor', class_colors(k, :));
    end
    % print(gcf, '-dpdf', '/tmp/detailed_strategies_legend');
    export_fig('/tmp/detailed_strategies_legend_ordered.eps');
    
    for d = 1:3 % for each day
        for g = 1:2
            fig = figure('PaperUnits', 'centimeters');
            set(fig,'visible','on','Color','w', 'PaperPosition', [0 0 12 2],...
                'PaperSize', [12 2],'PaperUnits', 'centimeters'); %Position plot at left hand corner with width 14cm and height 7cm.
            axis off;                
        
            for t = 1:4
                axes('Position', [0.06 + (t - 1)*0.24, 0.1, 0.21, 0.85]);  
                % sel = find(groups == g & traj_length > 3*g_config.DEFAULT_SEGMENT_LENGTH & (trials == ((d-1)*4 + t)));
                
                if g == 1
                    sel = find(groups == 1 & session_speed < non_stress_max_speed & traj_length > 3*g_config.DEFAULT_SEGMENT_LENGTH & (trials == ((d-1)*4 + t)));
                else
                    sel = find(groups == 2 & session_speed >= stress_min_speed(d) & traj_length > 3*g_config.DEFAULT_SEGMENT_LENGTH & (trials == ((d-1)*4 + t)));
                end
                accum_strat = zeros(50, length(tag_groups));

                for s = 1:100
                    if s > 1
                        accum_strat(s, :) = accum_strat(s - 1, :);
                    end
                    for i = 1:length(sel)
                        if partitions(sel(i)) >= s
                            strat = segment_classes(cum_partitions(sel(i)) + s);
                            if strat ~= 0
                                accum_strat(s, strat) = accum_strat(s, strat) + 1;
                            end
                        end                    
                    end                  
                end

                % normalize the values
                accum_strat = accum_strat ./ repmat(sum(accum_strat, 2), 1, length(tag_groups));

                ha = area(accum_strat);
                for j = 1:length(tag_groups)
                    set(ha(j),'FaceColor', class_colors(j, :));
                end
                set(gca, 'FontSize', 2*fsz);    
                axis tight;
                set(gca,'box','off');       
                tick1 = 1000 / ((1. - g_config.DEFAULT_SEGMENT_OVERLAP)*g_config.DEFAULT_SEGMENT_LENGTH);
                tick2 = 3000 / ((1. - g_config.DEFAULT_SEGMENT_OVERLAP)*g_config.DEFAULT_SEGMENT_LENGTH);
                set(gca,'XTick', [tick1, tick2], 'XTickLabel', {'10m', '30m'});           
                xlabel(sprintf('Trial %d', (d - 1)*4 + t), 'FontSize', 2*fsz);            
                if t == 1
                    set(gca,'YTick', [0.25, 0.5, 0.75]);
                else
                    set(gca,'YTick', []);
                end
            end
            set(gcf, 'Position', [0,15,1200,180]);
        %    export_fig(sprintf('/tmp/cumulative_distr_g%d_d%i.eps', g, d));
        end    
    end
    for i = 1:length(combined)
        cur = combined{i};
        % look for class indices
        ind = zeros(1, length(cur));
        for j = 1:length(cur)
            if strcmp(cur{j}, 'DF')
                pos = length(strat_order) + 1;
            else                
                matches = arrayfun( @(t) strcmp(t, cur{j}), strat_order);
                pos = find(matches == 1);
                if length(pos) ~= 1
                    error('????');
                end
            end           
            ind(j) = pos;
        end
        
        data = [];
        grp = [];
        means = [];
        for j = 1:3
            t0 = (j - 1)*4;            
            for g = 1:2
                % sel = find(groups == g & traj_length > 2*g_config.DEFAULT_SEGMENT_LENGTH & (trials == (t0 + 1) | trials == (t0 + 2) | trials == (t0 + 3) | trials == (t0 + 4)));
                if g == 1
                    sel = find(groups == 1 & session_speed < non_stress_max_speed & traj_length > 2*g_config.DEFAULT_SEGMENT_LENGTH & (trials == (t0 + 1) | trials == (t0 + 2) | trials == (t0 + 3) | trials == (t0 + 4)));
                else
                    sel = find(groups == 2 & session_speed >= stress_min_speed(j) & traj_length > 2*g_config.DEFAULT_SEGMENT_LENGTH & (trials == (t0 + 1) | trials == (t0 + 2) | trials == (t0 + 3) | trials == (t0 + 4)));
                end
                
                tmp = sum(full_distr(sel, ind), 2);   
                tmp = tmp ./ sum(full_distr(sel, :), 2);                 
                                
                data = [data, tmp(:)'];
                means = [means, mean(tmp)];
                grp = [grp, repmat((j - 1)*2 + g, 1, length(tmp(:)))];
            end                   
        end
        
        figure('name', combined_titles{i});         
         boxplot(data, grp, 'positions', [1, 1.25, 1.75, 2, 2.5, 2.75], 'colors', [[0 0 0]; [.5 .5 .5]], 'symbol', '+', 'labels', {'        session 1','','        session 2', '', '        session 3', ''});        
         
         hold on;
         plot([1 1.75 2.5], means([1,2,3]), 'Color', [0 0 0], 'Marker', 'd', 'Linestyle', 'none');
         plot([1.25 2 2.75], means([2,4,6]), 'Color', [.5 .5 .5], 'Marker', 'd', 'Linestyle', 'none');        
        % xlabel('session', 'FontSize', fsz);
        ylabel(sprintf('%s', combined_titles{i}), 'FontSize', 2*fsz);
        box off;
        set(gca,'XTick',[]);
        set(gcf, 'Color', 'w');
        P = findobj(gca, 'type', 'line');
        for l = 1:length(P)
            set(P(l), 'LineWidth', 1.3*alw);
        end
        P = findobj(gca, 'type', 'text');
        for l = 1:length(P)
            set(P(l), 'FontSize', 2*fsz);
        end
                
     %   export_fig(sprintf('/tmp/combined_results_%d.eps', i));        
    end        
end

