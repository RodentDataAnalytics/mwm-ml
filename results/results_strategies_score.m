function results_strategies_score
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/notBoxPlot'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/sigstar'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../'));
    
    % global data initialized elsewhere
    global g_segments_classification;
    global g_long_trajectories_idx;
    global g_partitions;
    global g_trajectories_latency;
    global g_trajectories_session;
    global g_trajectories_group;
    global g_animals_trajectories_map;   
        
    % classify trajectories
    cache_trajectories_classification; 

    distr = g_segments_classification.classes_distribution(g_partitions(g_long_trajectories_idx), 'Normalize', 1);
    % plot distribution for different trajectory lengths    
    nbins = 9;
    min_len = min(g_trajectories_latency(g_long_trajectories_idx));
    dt = (constants.TRIAL_TIMEOUT - min_len) / nbins;
    
    xvals = zeros(1, nbins);
    data = zeros(nbins, g_segments_classification.nclasses);        
    for i = 1:nbins
        ti = (i - 1)*dt + min_len;
        tf = i*dt + min_len;
        xvals(nbins - i + 1) = (ti + tf) / 2;          
        data(nbins - i + 1, :) = sum(distr(g_trajectories_latency(g_long_trajectories_idx) > ti & g_trajectories_latency(g_long_trajectories_idx) <= tf, :));        
    end     
    
    % normalize the data
    data = 100*data ./ repmat(sum(data, 2), 1, size(data, 2));
    
    figure(321);
    area(xvals, data); 
    set(gca,'XDir','reverse');
    colormap(constants.CLASSES_COLORMAP);
    
    xlabel('latency [s]', 'FontSize', constants.FONT_SIZE);
    ylabel('percentage', 'FontSize', constants.FONT_SIZE);    
    box off;
           
    export_fig(fullfile(constants.OUTPUT_DIR, 'strategy_distribution_latency.eps'));        
    
    % calculate weights based on first and last bins
    w = data(end, :) ./ data(1, :);
    
    log = 'COMPUTED STRATEGY SCORES: \n';
    for i = 1:g_segments_classification.nclasses
        log = [log g_segments_classification.classes(i).description ' = ' num2str(w(i)) '\n'];
    end    
    fprintf(log);
    f = fopen(fullfile(constants.OUTPUT_DIR, 'scores.txt'), 'w');        
    fprintf(f, log);
    fclose(f);
    
    scores_sel = sum(distr .* repmat(w, size(distr, 1), 1), 2);    
    
    %% look at strategies that led to the platform
    distr = g_segments_classification.classes_distribution(g_partitions(g_long_trajectories_idx), 'MaxSegments', 10, 'Reverse', 1);
    % plot distribution for different trajectory lengths        
    data = sum(distr(g_trajectories_latency(g_long_trajectories_idx) < constants.TRIAL_TIMEOUT, :));
    
    % normalize the data
    data = 100*data / sum(data);
    
    clf;;
    bar(data); 
    colormap(constants.CLASSES_COLORMAP);
    
    % xlabel('latency [s]', 'FontSize', constants.FONT_SIZE);
    ylabel('percentage', 'FontSize', constants.FONT_SIZE);    
    box off;
    
    
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
    for s = 1:constants.SESSIONS
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
    lbls = arrayfun( @(i) sprintf('Session %d', i), 1:constants.TRIALS, 'UniformOutput', 0);         
    set(gca, 'XTick', (pos(1:2:2*constants.SESSIONS - 1) + pos(2:2:2*constants.SESSIONS)) / 2, 'XTickLabel', lbls, 'FontSize', constants.FONT_SIZE);                 
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
   
    ylabel('score', 'FontSize', constants.FONT_SIZE);
    
  % check significances
    for s = 1:constants.SESSIONS
        hip = kstest2(data(groups == 2*s - 1), data(groups == 2*s));
        if hip
            h = sigstar( {[pos(2*s - 1), pos(s*2)]}, [0.05]);
            set(h(:, 1), 'LineWidth', 2);
            set(h(:, 2), 'FontSize', constants.FONT_SIZE);
        end
    end

    set(gcf, 'Color', 'w');
    set(gca, 'FontSize', constants.FONT_SIZE, 'LineWidth', constants.AXIS_LINE_WIDTH);
    box off;        
    export_fig(fullfile(constants.OUTPUT_DIR, 'control_stress_score.eps')); 

    %% Do the same for the trials
    
    base_score = {};
    data = [];
    xpos = [];
    groups = [];
    pos = 0:0.3:(0.3*(2*constants.TRIALS - 1));
    pos(2:2:(2*constants.TRIALS)) = pos(2:2:(2*constants.TRIALS)) - repmat(0.1, 1, constants.TRIALS);
        
    for t = 1:constants.TRIALS
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
    ylabel('score', 'FontSize', constants.FONT_SIZE);
    xlabel('trial', 'FontSize', constants.FONT_SIZE);

    lbls = arrayfun( @(i) sprintf('%d', i), 1:constants.TRIALS, 'UniformOutput', 0);         
    set(gca, 'XTick', (pos(1:2:2*constants.TRIALS - 1) + pos(2:2:2*constants.TRIALS)) / 2, 'XTickLabel', lbls, 'FontSize', 0.6*constants.FONT_SIZE);                 
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
    for t = 1:constants.TRIALS
        hip = kstest2(data(groups == 2*t - 1), data(groups == 2*t));
        if hip
            h = sigstar( {[pos(2*t - 1), pos(t*2)]}, [0.05]);
            set(h(:, 1), 'LineWidth', 2);
            set(h(:, 2), 'FontSize', constants.FONT_SIZE);
        end
    end

    set(gcf, 'Color', 'w');
    set(gca, 'LineWidth', constants.AXIS_LINE_WIDTH);
    box off;        
    export_fig(fullfile(constants.OUTPUT_DIR, 'control_stress_trial_score.eps'));
end

