function results_strategies_individual_evolution3
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));  
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/sigstar'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/AnDarksamtest'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/cm_and_cb_utilities'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../'));

    % global data initialized elsewhere
    global g_segments_classification;
    global g_trajectories_length;
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
    strat_distr = tmp;
    
    row_labels = arrayfun( @(t) sprintf('T %d', t), 12:-1:1, 'UniformOutput', 0);
            
    % plot the distribution of strategies for each session and group of
    % animals
    for g = 1:2
        % sort animals by total length
        ids = g_animals_ids{g};
        map = g_animals_trajectories_map{g};
        % reverse the map
        map = map(12:-1:1, :);
        total_len = sum(g_trajectories_length(map));
        [~, ord] = sort(total_len, 'descend');
        for off = 1:4:length(ord)                    
            clf;
            distr = {};
            col_labels = {};
            
            for i = off:min(off + 3, length(ord))
                distr = [distr, strat_distr(map(:, ord(i)), :)];                
                col_labels = [col_labels, num2str(ids(ord(i)))];
            end
                        
            % 'RowLabels', row_labels, 
            plot_distribution_strategies(distr, 'Ordered', 1, 'Widths', bins, ...
                            'ColumnLabels', col_labels, 'RowLabels', row_labels, ...
                            'Ticks', [10, 50, 90], 'TicksLabels', {'10s', '50s', '90s'}, 'AspectRatio', 0.2);

            export_fig(fullfile(constants.OUTPUT_DIR, sprintf('individual_strategies_evol_g%d_%d.eps', g, off)));
        end
    end                           
end

