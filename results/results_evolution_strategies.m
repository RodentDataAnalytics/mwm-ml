function results_evolution_strategies
%RESULTS_CONTROL_STRESS_ANALYSIS Plot distribution of strategies for each
%trial
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../'));

    % global data initialized elsewhere
    global g_trajectories_trial;    
    global g_segments_classification;
    global g_long_trajectories_idx;
    global g_partitions;
    global g_trajectories_latency;
    
    % classify trajectories
    cache_trajectories_classification; 

    distr = g_segments_classification.classes_distribution(g_partitions(g_long_trajectories_idx));
    % plot distribution for each trial
    data = [];        
    for t = 1:constants.TRIALS
        data = [data, ...
            arrayfun( @(c) sum(distr(g_trajectories_trial(g_long_trajectories_idx) == t, c)), ...
                1:g_segments_classification.nclasses...
            )']; 
                         
    end     
    
    % normalize the data
    data = 100*data ./ repmat(sum(data), size(data, 1), 1);
    
    figure(321);
    bar(data', 'Stack'); 
    colormap(constants.CLASSES_COLORMAP);
    
    xlabel('trial', 'FontSize', constants.FONT_SIZE);
    ylabel('percentage', 'FontSize', constants.FONT_SIZE);    
    box off;
    
    export_fig(fullfile(constants.OUTPUT_DIR, 'distribution_strat_trials.eps'));
    
    % do the same for very long trajectories (latency >80 seconds)
    data = [];
    for t = 1:constants.TRIALS
        data = [data, ...
            arrayfun( @(c) sum(distr(g_trajectories_trial(g_long_trajectories_idx) == t ...
                             & g_trajectories_latency(g_long_trajectories_idx) > 80, c)), ...
                1:g_segments_classification.nclasses...
            )']; 
                         
    end     
    
    figure;
    data = 100*data ./ repmat(sum(data), size(data, 1), 1);
    
    bar(data', 'Stack'); 
    colormap(constants.CLASSES_COLORMAP);
    
    xlabel('trial', 'FontSize', constants.FONT_SIZE);
    ylabel('percentage', 'FontSize', constants.FONT_SIZE);    
    box off;
    
    export_fig(fullfile(constants.OUTPUT_DIR, 'distribution_strat_trials_80.eps'));
end

