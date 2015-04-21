function results_strategies_total_length_correlation
    addpath(fullfile(fileparts(mfilename('fullpath')), '../../extern/export_fig'));        
    addpath(fullfile(fileparts(mfilename('fullpath')), '../../'));
    
    % global data initialized elsewhere
    global g_segments_classification;
    global g_config;
    global g_partitions;
    global g_trajectories_length;    
    global g_animals_trajectories_map;    
    
    % classify trajectories
    cache_animals;
    cache_trajectories_classification; 

    %%
    %% Plot strategies x total length - area plot
    %%        
    distr = g_segments_classification.classes_distribution(g_partitions, 'Normalize', 0);
    
    % group per animal
    distr_animal = [];
    total_lenght = [];
    for g = 1:1
        map = g_animals_trajectories_map{g};
        for idx = 1:size(map, 2);
            % add the distributions of all the trials together
            distr_animal = [distr_animal; sum(distr(map(:, idx), :))];
            total_lenght = [total_lenght, sum(g_trajectories_length(map(:, idx)))];
        end
    end
    distr_animal = distr_animal ./ repmat(sum(distr_animal, 2) + (sum(distr_animal, 2) == 0)*1e-5, 1, g_segments_classification.nclasses);
    
    nbins = 5;
    min_len = min(total_lenght);%log(0.01); log(min(g_trajectories_efficiency(g_long_trajectories_idx)));
    max_len = max(total_lenght); %log(0.25); % log(max(g_trajectories_efficiency(g_long_trajectories_idx)));
    dt = (max_len - min_len) / nbins;
    
    % bin the data according to strategy x efficiency
    xvals = [];
    data = [];        
    for i = 1:nbins
        ei = (i - 1)*dt + min_len;
        ef = i*dt + min_len + 1e-5;
        idx = find(total_lenght >= ei & total_lenght < ef);
        if length(idx) > 3
            xvals = [xvals, (ei + ef) / 2];          
            data = [data; sum(distr(idx, :))];        
        end
    end     
    
    % normalize the data
    data = [data, 1e-3*ones(size(data, 1), 1)];
    data = data ./ repmat(sum(data, 2) + 1e-6, 1, size(data, 2));   
   
    figure(321);
    area(xvals, data); 
    set (gca, 'Xscale', 'log')
    set(gca,'XDir','reverse');
    set(gca, 'XTick', [0.01, 0.05, 0.1, 0.2, 0.3]);
    colormap(g_config.CLASSES_COLORMAP());
    
    xlabel('path efficiency', 'FontSize', 0.8*g_config.FONT_SIZE);
    ylabel('normalized distribution', 'FontSize', 0.8*g_config.FONT_SIZE);    
    set(gcf, 'Color', 'w');

    %box off;
    %export_fig(fullfile(g_config.OUTPUT_DIR, 'strategy_score_efficiency.eps')); 
    
    
    %%
    %% Compute the Spearman correlation coefficient for each strategy x efficiency
    %%
    msg = 'SPEARMAN CORRELATION COEFFICIENTS: \n';
    for i = 1:g_segments_classification.nclasses
        [rho, pval] = corr(log(xvals)', data(:, i), 'Type', 'Spearman');   
        msg = [msg g_segments_classification.classes(i).description]; 
        msg = [msg ' = ' num2str(rho) ' p = ' num2str(pval) '\n'];
    end
    fprintf(msg);
       
    if 0 % remove this to compute scores for different groups of animals
         global g_trajectories_session;
         global g_trajectories_group;
        global g_animals_trajectories_map;   
   
        scores_sel = sum(distr .* repmat(w, size(distr, 1), 1), 2);

        % it is easier to expand the scores to the full set of trajectories
        temp = zeros(1, length(g_partitions));
        temp(g_long_trajectories_idx) = scores_sel;
        scores = temp;

        temp = zeros(1, length(g_partitions));
        temp(g_long_trajectories_idx) = scores_sel;

        full_scores = temp;   

        figure(323);

        base_score = {};
        data = [];
        xpos = [];
        groups = [];
        pos = [0, 0.6, 1.8, 2.4, 3.6, 4.2];
        for s = 1:g_config.SESSIONS
            for g = 1:2
                idx = g_animals_trajectories_map{g};

                if s == 1
                    % get base score for each animal
                    base_score{g} = scores(idx(1, :));

                    tmp = scores(idx(2:4, :));
                    tmp = cellfun( @(v) mean(v(v ~= 0)), num2cell(tmp, 1));
                    tmp = tmp - base_score{g};                               
                    tmp = tmp(base_score{g} ~= 0);
                else
                    tmp = scores(idx((s - 1)*4 + 1:s*4, :));
                    tmp = cellfun( @(v) mean(v(v ~= 0)), num2cell(tmp, 1));
                    tmp = tmp - base_score{g};
                    tmp = tmp(base_score{g} ~= 0);
                end                

                tmp = scores_sel(g_trajectories_session(g_long_trajectories_idx) == s & g_trajectories_group(g_long_trajectories_idx) == g); 
                data = [data, tmp(:)'];
                xpos = [xpos, repmat(pos(s*2 - 1 + g - 1), 1, length(tmp(:)))];             
                groups = [groups, repmat(s*2 - 1 + g - 1, 1, length(tmp(:)))];             
            end
        end    

        figure(424);
        pos = [1, 1.2, 2, 2.2, 3, 3.2]; 
        boxplot(data, groups, 'positions', pos, 'colors', [0 0 0; .7 .7 .7]);         
        lbls = arrayfun( @(i) sprintf('Session %d', i), 1:g_config.TRIALS, 'UniformOutput', 0);         
        set(gca, 'XTick', (pos(1:2:2*g_config.SESSIONS - 1) + pos(2:2:2*g_config.SESSIONS)) / 2, 'XTickLabel', lbls, 'FontSize', g_config.FONT_SIZE);                 
        h = findobj(gca,'Tag','Box');
        for j=1:2:length(h)
             patch(get(h(j),'XData'), get(h(j), 'YData'), [.9 .9 .9], 'FaceAlpha', .3);
        end
        set([h], 'LineWidth', 1.5);

        h = findobj(gca, 'Tag', 'Median');
        for j=1:2:length(h)
             line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [0 0 0]);
        end
        set([h], 'LineWidth', 1.8);

        ylabel('score', 'FontSize', g_config.FONT_SIZE);

      % check significances
        for s = 1:g_config.SESSIONS
            hip = kstest2(data(groups == 2*s - 1), data(groups == 2*s));
            if hip
                h = sigstar( {[pos(2*s - 1), pos(s*2)]}, [0.05]);
                set(h(:, 1), 'LineWidth', 2);
                set(h(:, 2), 'FontSize', g_config.FONT_SIZE);
            end
        end

        set(gcf, 'Color', 'w');
        set(gca, 'FontSize', g_config.FONT_SIZE, 'LineWidth', g_config.AXIS_LINE_WIDTH);
        box off;        
        export_fig(fullfile(g_config.OUTPUT_DIR, 'control_stress_score.eps')); 

        %% Do the same for the trials

        base_score = {};
        data = [];
        xpos = [];
        groups = [];
        pos = 0:0.3:(0.3*(2*g_config.TRIALS - 1));
        pos(2:2:(2*g_config.TRIALS)) = pos(2:2:(2*g_config.TRIALS)) - repmat(0.1, 1, g_config.TRIALS);

        for t = 1:g_config.TRIALS
            for g = 1:2
                idx = g_animals_trajectories_map{g};

                if t == 1
                    % get base score for each animal
                    base_score{g} = full_scores(idx(1, :));

                    tmp = full_scores(idx(1, :));
                   % tmp = tmp - base_score{g};                               
                   % tmp = tmp(base_score{g} ~= 0);
                else
                    tmp = full_scores(idx(t, :));                
                   % tmp = tmp - base_score{g};                   
                    %tmp = tmp(base_score{g} ~= 0);
                    % tmp = tmp(g_trajectories_length(idx(t, :)) > 60);
                end                

                %tmp = scores(idx(t, :));
                % tmp = scores_sel(g_trajectories_latency(g_long_trajectories_idx) > 20 & g_trajectories_trial(g_long_trajectories_idx) == t & g_trajectories_group(g_long_trajectories_idx) == g); 
                tmp = tmp(tmp ~= 0);

                data = [data, tmp(:)'];
                xpos = [xpos, repmat(pos(t*2 - 1 + g - 1), 1, length(tmp(:)))];             
                groups = [groups, repmat(t*2 - 1 + g - 1, 1, length(tmp(:)))];             
            end
        end    

        figure(424);
        boxplot(data, groups, 'positions', pos, 'colors', [0 0 0; .7 .7 .7]);     
        ylabel('score', 'FontSize', g_config.FONT_SIZE);
        xlabel('trial', 'FontSize', g_config.FONT_SIZE);

        lbls = arrayfun( @(i) sprintf('%d', i), 1:g_config.TRIALS, 'UniformOutput', 0);         
        set(gca, 'XTick', (pos(1:2:2*g_config.TRIALS - 1) + pos(2:2:2*g_config.TRIALS)) / 2, 'XTickLabel', lbls, 'FontSize', 0.6*g_config.FONT_SIZE);                 
        h = findobj(gca,'Tag','Box');
        for j=1:2:length(h)
             patch(get(h(j),'XData'), get(h(j), 'YData'), [.9 .9 .9], 'FaceAlpha', .3);
        end
        set([h], 'LineWidth', 0.8);
        h = findobj(gca,'Tag','Outliers');
        set([h], 'Color', [0.2 0.2 0.2]);

        h = findobj(gca, 'Tag', 'Median');
        for j=1:2:length(h)
             line('XData', get(h(j),'XData'), 'YData', get(h(j), 'YData'), 'Color', [0 0 0]);
        end
        set([h], 'LineWidth', 1.8);


      % check significances
        for t = 1:g_config.TRIALS   
            idx = find( (groups == 2*t - 1 ) | (groups == 2*t ));        
            l1 = sum(groups == 2*t - 1 );
            test_data = zeros(length(idx), 2);
            test_data(:, 1) = data(idx);
            test_data(1:l1, 2) = 1;
            test_data(l1 + 1:end, 2) = 2;

            hip = AnDarksamtest(test_data);
    %        
    %         hip = kstest2(data(groups == 2*t - 1), data(groups == 2*t));
             if hip 
                  h = sigstar( {[pos(2*t - 1), pos(t*2)]}, [0.05]);
                 set(h(:, 1), 'LineWidth', 2);
                 set(h(:, 2), 'FontSize', g_config.FONT_SIZE);
             end
        end

        set(gcf, 'Color', 'w');
        set(gca, 'LineWidth', g_config.AXIS_LINE_WIDTH);
        box off;        
        export_fig(fullfile(g_config.OUTPUT_DIR, 'control_stress_trial_score.eps'));
    end
end

