function results_classes_legend
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/legendflex'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/cm_and_cb_utilities'));

    global g_trajectories_strat_distr;
    global g_trajectories_strat;
    global g_segments_classification;
    
    cache_trajectories_classification;
        
    hdummy = figure;
    cm = cmapping(g_segments_classification.nclasses + 1, g_config.CLASSES_COLORMAP);             
    dummyplot = barh(repmat(1:g_segments_classification.nclasses + 1, 4, 1), 'Stack');
    leg = arrayfun(@(t) t.description, g_segments_classification.classes, 'UniformOutput', 0);
    leg = [leg, 'direct finding'];
    colormap(cm);    
    hleg = figure;
    set(gcf, 'Color', 'w');
    legendflex(dummyplot, leg, 'box', 'off', 'nrow', 3, 'ncol', 3, 'ref', hleg, 'fontsize', 6, 'anchor', {'n','n'}, 'xScale', 0.5);
    export_fig(fullfile(g_config.OUTPUT_DIR, 'strategies_legend.eps'));
    
    close(hleg);
    close(hdummy);      
    
    cm =  cmapping(length(g_trajectories_strat), g_config.CLASSES_COLORMAP);  
    cm = cm(1:size(cm, 1) - 1, :);
    
    % vertical legend
    hdummy = figure;
    dummyplot = barh(repmat(1:length(g_trajectories_strat) - 1, 2, 1), 'Stack');
    leg = arrayfun(@(t) t.description, g_trajectories_strat(1:length(g_trajectories_strat) - 1), 'UniformOutput', 0);
    hleg = figure;
    colormap(cm);    
    set(gcf, 'Color', 'w');
    legendflex(dummyplot, leg, 'box', 'off', 'nrow', length(g_trajectories_strat) - 1, 'ncol', 1, 'ref', hleg, 'fontsize', 8, 'anchor', {'n','n'});
    export_fig(fullfile(g_config.OUTPUT_DIR, 'strategies_legend_vert.eps'));
    
    close(hleg);
    close(hdummy);      
    
    % reduced legend
    hdummy = figure;
    dummyplot = barh(repmat(1:length(g_config.REDUCED_BEHAVIOURAL_CLASSES), 2, 1), 'Stack');
    leg = arrayfun(@(t) t.description, g_config.REDUCED_BEHAVIOURAL_CLASSES, 'UniformOutput', 0);
    colormap(g_config.CLASSES_COLORMAP);
    hleg = figure;
    set(gcf, 'Color', 'w');
    legendflex(dummyplot, leg, 'box', 'off', 'nrow', 2, 'ncol', 2, 'ref', hleg, 'fontsize', 8, 'anchor', {'n','n'});
    export_fig(fullfile(g_config.OUTPUT_DIR, 'strategies_legend_reduced.eps'));
    
     % reduced legend BW
    hdummy = figure;
    dummyplot = barh(repmat(1:length(g_config.REDUCED_BEHAVIOURAL_CLASSES), 2, 1), 'Stack');
    leg = arrayfun(@(t) t.description, g_config.REDUCED_BEHAVIOURAL_CLASSES, 'UniformOutput', 0);
    cm = [0 0 0; ...
          0.8 0.8 0.8; ...
          1 1 1];
    hleg = figure;
    set(gcf, 'Color', 'w');    
    colormap(cm);
    legendflex(dummyplot, leg, 'box', 'off', 'nrow', 2, 'ncol', 2, 'ref', hleg, 'fontsize', 8, 'anchor', {'n','n'});
    export_fig(fullfile(g_config.OUTPUT_DIR, 'strategies_legend_reduced_bw.eps'));
    
    close(hleg);
    close(hdummy); 
end

