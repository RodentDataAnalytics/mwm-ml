function results_strategies_individual_evolution2
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));  
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/sigstar'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/AnDarksamtest'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/cm_and_cb_utilities'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../'));

    % global data initialized elsewhere
    global g_segments_classification;
    global g_segments;
    global g_partitions;
    global g_animals_ids;
    global g_animals_trajectories_map;
    
    % classify trajectories
    cache_trajectories_classification; 
    
    figure;
    
    % bins = [10, 15, 25, 40];        
    bins = repmat(6, 1, 15);
    nbins = length(bins);

    %[strat_distr, full_strat_distr] = g_segments.classes_mapping_time(g_segments_classification, bins, 'Classes', classes);
    strat_distr = g_segments.classes_mapping_time(g_segments_classification, bins);

    tmp = zeros(length(g_partitions), nbins);
    tmp(g_partitions > 0, 1:nbins) = strat_distr;
    tmp(g_partitions == 0, 1) = g_segments_classification.nclasses + 1;    
    tmp(g_partitions == 0, 2:nbins) = -1;
    strat_distr = tmp;

    N = 9;
    % plot the distribution of strategies for each session and group of
    % animals
    for g = 1:2
        ids = g_animals_ids{g};
        map = g_animals_trajectories_map{g};
        
        %total_len = sum(g_trajectories_length(map));        
        %[~, ord] = sort(total_len, 'descend');
        % ord = 1:length(ids);
        num_blank = zeros(1, length(ids));
        for i = 1:size(map, 2)                        
            num_blank(i) = sum(sum(strat_distr(map(:, i), :) == 0));
        end            
        [~, ord] = sort(num_blank);
        
        for off = 1:N:length(ord)                                        
            clf;
            distr = {[], [], [], []};            
            row_labels = {};
            col_labels = {};                                
            idx = ord(off:min(off + N - 1, length(ord)));
            
            for s = 1:constants.SESSIONS % for each session                
                for t = 1:constants.TRIALS_PER_SESSION
                    trial = (s - 1)*constants.TRIALS_PER_SESSION + t;

                    if s == 1
                        col_labels = [col_labels, sprintf('trial %d', trial)];                        
                        distr{t} = strat_distr(map(trial, idx), :);  
                    else
                        distr{t} = [distr{t}; -1*ones(3, nbins)];                        
                        distr{t} = [distr{t}; strat_distr(map(trial, idx), :)];
                    end                    
                end
                if s > 1
                    row_labels = [row_labels, repmat({''}, 1, 3)];
                end
                row_labels = [row_labels, arrayfun( @num2str, ids(idx), 'UniformOutput', 0)];                
            end
            
            % reverse everything
            for t = 1:constants.TRIALS_PER_SESSION
                tmp = distr{t};
                distr{t} = tmp(end:-1:1, :);                                
            end   
            row_labels = row_labels(end:-1:1);
            
            plot_distribution_strategies(distr, 'Ordered', 1, 'Widths', bins, ...
                       'ColumnLabels', col_labels, 'RowLabels', row_labels, ...
                       'Ticks', [10, 50, 90], 'TicksLabels', {'10s', '50s', '90s'}, 'BarHeight', 1.2);
            export_fig(fullfile(constants.OUTPUT_DIR, sprintf('individual_strategies_evol_g%d_%d.eps', g, off)));
        end
    end 
    
    % two reduced additional plots
%     sel_trials = [1, 4, 9, 10, 11];
%     for g = 1:2        
%         clf;
%         distr = {};
%         row_labels = {};
%         col_labels = {};
%         markers = {};
% 
%         for t = 1:length(sel_trials)
%             sel = find(g_trajectories_trial == sel_trials(t) & g_trajectories_group == g);
%             if t == 1
%                 row_labels = arrayfun( @(x) num2str(x.id), g_trajectories.items(sel), 'UniformOutput', 0); 
%             end                
% 
%             distr = [distr, strat_distr(sel, :)];
%             col_labels = [col_labels, sprintf('Trial %d', sel_trials(t))];
%         end
% 
%         plot_distribution_strategies(distr, 'Ordered', 1, 'Widths', bins, ...
%                          'ColumnLabels', col_labels, 'RowLabels', row_labels, ...
%                          'Ticks', [10, 50, 90], 'TicksLabels', {'10s', '50s', '90s'});                             
% 
%         export_fig(fullfile(constants.OUTPUT_DIR, sprintf('individual_strategies_evol_g%d_red.eps', g)));
%     end                  
end

