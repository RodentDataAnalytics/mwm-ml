function results_strategies_individual_distributions
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../'));

    % global data initialized elsewhere
    global g_trajectories_trial;    
    global g_trajectories_group;      
    global g_trajectories_length;          
    global g_trajectories;
    global g_trajectories_strat_distr_norm;
    global g_trajectories_latency;
  
    % classify trajectories
    cache_trajectories_classification; 
    
    figure;
   
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
                sel = find(g_trajectories_trial == trial & g_trajectories_group == g);
                distr = [distr, g_trajectories_strat_distr_norm(sel, :).*repmat(g_trajectories_length(sel)', 1, size(g_trajectories_strat_distr_norm, 2))];
                if t == 1
                    row_labels = arrayfun( @(x) num2str(x.id), g_trajectories.items(sel), 'UniformOutput', 0); 
                end                
                markers = [markers, arrayfun( @(idx) g_trajectories_latency(idx) == constants.TRIAL_TIMEOUT, sel)]; 
                col_labels = [col_labels, sprintf('Trial %d', trial)];
            end
                        
            plot_distribution_strategies(distr, 'Markers', markers, 'MeanRow', 1, 'MeanColumn', 1, ...
                                        'RowLabels', row_labels, 'ColumnLabels', col_labels, ...
                                        'Ticks', [1000 3000], 'TicksLabels', {'10m', '30m'});
            
            export_fig(fullfile(constants.OUTPUT_DIR, sprintf('detailed_strategies_g%d_s%d.eps', g, s)));
        end
    end 
    
    % two reduced additional plots
    sel_trials = [1, 3, 5, 7, 9];
    for g = 1:2        
        clf;
        distr = {};
        row_labels = {};
        col_labels = {};
        markers = {};

        for t = 1:length(sel_trials)
            sel = find(g_trajectories_trial == sel_trials(t) & g_trajectories_group == g);
            distr = [distr, g_trajectories_strat_distr_norm(sel, :).*repmat(g_trajectories_length(sel)', 1, size(g_trajectories_strat_distr_norm, 2))];
            if t == 1
                row_labels = arrayfun( @(x) num2str(x.id), g_trajectories.items(sel), 'UniformOutput', 0); 
            end                
            markers = [markers, arrayfun( @(idx) g_trajectories_latency(idx) == constants.TRIAL_TIMEOUT, sel)]; 
            col_labels = [col_labels, sprintf('Trial %d', sel_trials(t))];
        end

        plot_distribution_strategies(distr, 'Markers', markers, 'MeanRow', 1, ...
                                    'RowLabels', row_labels, 'ColumnLabels', col_labels, ...
                                    'Ticks', [1000 3000], 'TicksLabels', {'10m', '30m'});

        export_fig(fullfile(constants.OUTPUT_DIR, sprintf('detailed_strategies_g%d_red.eps', g)));
    end     
end

