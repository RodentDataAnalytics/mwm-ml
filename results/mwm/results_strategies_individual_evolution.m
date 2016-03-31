% Classification results for each trial and 27 animals from the 
% control and stress group. Each bar represents a full trial 
% (up to 90 seconds) and shows changes in exploration strategies over 
% the trial.

% Publication:
% Main Paper
% page 7 Figure 4

function results_strategies_individual_evolution
    
    v = version();
    if str2num(v(1:3)) <= 8.3 % <= Matlab 2014a

        % global data initialized elsewhere
        global g_segments_classification; % classification of segments (splited trajectories)
        global g_partitions; % number of instances of the same trajectory class
        global g_animals_ids; % animal ids (controlled and streessed groups)
        global g_animals_trajectories_map; % matrix of trajectory indices for each trial and group of animals
        global g_config; % configurations

        % classify trajectories
        cache_animals; 
        cache_trajectories_classification;

        figure;
    
        bins = repmat(2, 1, 45);
        nbins = length(bins);

        strat_distr = g_segments_classification.mapping_time(bins, 'DiscardUnknown', 1);

        tmp = zeros(length(g_partitions), nbins);
        tmp(g_partitions > 0, 1:nbins) = strat_distr;
        tmp(g_partitions == 0, 1) = g_segments_classification.nclasses + 1;    
        tmp(g_partitions == 0, 2:nbins) = -1;
        strat_distr = tmp;

        % reduced plots            
        for s = 1:2
            if s == 1
                sel_trials = 1:6;            
            else
                sel_trials = 7:12;
            end
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
                           'ColumnLabels', col_labels, ... %'RowLabels', row_labels, ...
                           'Ticks', [10, 50, 90], 'TicksLabels', {'10s', '50s', '90s'}, 'BarHeight', 0.25, 'AverageBarsHeight', 0);
               %% To export the generated figures uncomment the line below. Note that the exporting process is very slow for these figures. 
               %export_figure(1, gcf, g_config.OUTPUT_DIR, sprintf('individual_strategies_g%d_s%d.eps', g, s));  
            end
        end    
        %% Generate legend
        hdummy = figure;
        cm = cmapping(g_segments_classification.nclasses, g_config.CLASSES_COLORMAP);             
        dummyplot = barh(repmat(1:g_segments_classification.nclasses+1, 4, 1), 'Stack');
        leg = arrayfun(@(t) t.description, g_segments_classification.classes, 'UniformOutput', 0);
        leg = [leg, 'Direct Finding'];
        colormap(cm);    
        hleg = figure;
        set(gcf, 'Color', 'w');
        legendflex(dummyplot, leg, 'box', 'off', 'nrow', 3, 'ncol', 3, 'ref', hleg, 'fontsize', 6, 'anchor', {'n','n'}, 'xScale', 0.5);
        export_figure(1, gcf, g_config.OUTPUT_DIR, 'individual_strategies_legend');
        close(hdummy);
    else
        disp('This function (results_strategies_individual_evolution) may only be run with MATLAB version 2014a or earlier.');
    end
end
