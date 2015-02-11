function results_strategies_individual_evolution5
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));  
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
    bins = repmat(2, 1, 45);
    nbins = length(bins);

    strat_distr = g_segments_classification.mapping_ordered(bins);

    tmp = zeros(length(g_partitions), nbins);
    tmp(g_partitions > 0, 1:nbins) = strat_distr;
    tmp(g_partitions == 0, 1) = g_segments_classification.nclasses + 1;    
    tmp(g_partitions == 0, 2:nbins) = -1;
    strat_distr = tmp;
  
    % reduced plots             
    sel_trials = [1, 4, 8, 12];
    for g = 1:2
        ids = g_animals_ids{g};
        map = g_animals_trajectories_map{g};
                                                                
        clf;
        distr = {[], [], [], []};            
        row_labels = {};
        col_labels = {};                                

        for t = 1:length(sel_trials)
            trial = sel_trials(t);

            col_labels = [col_labels, sprintf('trial %d', trial)];                        
            distr{t} = strat_distr(map(trial, :), :);                                      
        end
        row_labels = [row_labels, arrayfun( @num2str, ids, 'UniformOutput', 0)];            

        % reverse everything
        for t = 1:length(sel_trials)
            tmp = distr{t};
            distr{t} = tmp(end:-1:1, :);                                
        end   
        row_labels = row_labels(end:-1:1);

        plot_distribution_strategies(distr, 'Ordered', 1, 'Widths', bins, ...
                   'ColumnLabels', col_labels, 'RowLabels', row_labels, ...
                   'Ticks', [10, 50, 90], 'TicksLabels', {'10s', '50s', '90s'}, 'BarHeight', 1.2, 'AverageBarsHeight', 0.2);
        export_fig(fullfile(g_config.OUTPUT_DIR, sprintf('individual_strategies_red_g%d.eps', g)));        
    end                      
end