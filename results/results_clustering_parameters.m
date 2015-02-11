function results_clustering_parameters
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));    
    % load trajectory segments
    global g_segments;    
    % initialize data
    cache_trajectory_segments;                    
    
    ptest = 0;
    
    % run multiple clusterings with different target number of clusters
    res1 = [];
    res2 = []; 
    res3 = [];
    nc = [];
    test_set = [];      
    covering = [];
    param = g_config.TAGS_CONFIG{2};    
        
    for i = 1:12
        n = 10 + i*10;
        nc = [nc, n];
               
        % get classifier object
        classif = g_segments.classifier(param{1}, g_config.DEFAULT_FEATURE_SET, g_config.TAG_TYPE_BEHAVIOUR_CLASS);
                
        if isempty(test_set)
            if ptest > 0          
                fn = fullfile(g_config.OUTPUT_DIR, sprintf('test_set.mat', n));
                if exist(fn ,'file')
                    load(fn);
                else                
                    test_set = zeros(1, classif.nlabels);
                    idx = 1:classif.nlabels;
                    test_set(idx(randsample(length(idx), floor(length(idx)*ptest)))) = 1;
                    save(fn, 'test_set');
                end
            else
                test_set = [];
            end
        end
        
        % i) two-phase clustering (default)        
        % see if we already have the data
        fn = fullfile(g_config.OUTPUT_DIR, sprintf('clustering_n%d.mat', n));
        if exist(fn ,'file')
            load(fn);
        else            
            [res, res1st] = classif.cluster_cross_validation(n, 'Folds', 10, 'TestSet', test_set);
            save(fn, 'res', 'res1st');
        end               
        res1 = [res1, res];
        res2 = [res2, res1st];
                
        % ii) clustering using all the constraints
        % see if we already have the data
        classif.two_stage = 1;        
        fn = fullfile(g_config.OUTPUT_DIR, sprintf('clustering_all_constr_%d.mat', n));
        if exist(fn ,'file')
            load(fn);
        else            
            res = classif.cluster(n);
            save(fn, 'res');
        end               
        res3 = [res3, res];
        covering = [covering, res.coverage];        
    end        
    
    % export data
    save(fullfile(g_config.OUTPUT_DIR, 'clustering_parameters.mat'), 'res1', 'res2', 'res3');
    
    % remap the classes as to not invalidate mixed clusters
    % we want to compare clustering errors after all
    res1bare = [];
    res2bare = [];    
    for i = 1:length(res1)
        res1bare = [res1bare, res1(i).remap_clusters('DiscardMixed', 0)];
    end
    for i = 1:length(res2)
        res2bare = [res2bare, res2(i).remap_clusters('DiscardMixed', 0)];
    end
 
    % classification errors (cross-validation)    
    figure(77);
    ci_fac = 1.96/sqrt(length(nc));
    errorbar( nc, arrayfun( @(x) 100*x.mean_perrors, res1bare),  arrayfun( @(x) 100*x.sd_perrors*ci_fac, res1bare), 'k-', 'LineWidth', g_config.LINE_WIDTH);                       
    hold on;
    errorbar( nc, arrayfun( @(x) 100*x.mean_perrors, res2bare),  arrayfun( @(x) 100*x.sd_perrors*ci_fac, res2bare), 'k:', 'LineWidth', g_config.LINE_WIDTH);                           
    xlabel('N_{clus}', 'FontSize', g_config.FONT_SIZE);
    ylabel('% errors', 'FontSize', g_config.FONT_SIZE);            
    set(gcf, 'Color', 'w');
    set(gca, 'FontSize', g_config.FONT_SIZE, 'LineWidth', g_config.AXIS_LINE_WIDTH);
    h1 = gca;
    box off;
    export_fig(fullfile(g_config.OUTPUT_DIR, 'clusters_dep_err.eps'));

    % percentage of unknown segments
    figure(78);
    errorbar( nc, arrayfun( @(x) 100*x.mean_punknown, res1),  arrayfun( @(x) 100*x.sd_punknown*ci_fac, res1), 'k-', 'LineWidth', g_config.LINE_WIDTH);                       
    hold on;
    errorbar( nc, arrayfun( @(x) 100*x.mean_punknown, res2),  arrayfun( @(x) 100*x.sd_punknown*ci_fac, res2), 'k:', 'LineWidth', g_config.LINE_WIDTH);                           
    plot(nc, arrayfun( @(x) 100*x.punknown, res3), 'k*');   
    xlabel('N_{clus}', 'FontSize', g_config.FONT_SIZE);
    ylabel('% undefined', 'FontSize', g_config.FONT_SIZE);            
    set(gcf, 'Color', 'w');
    set(gca, 'FontSize', g_config.FONT_SIZE, 'LineWidth', g_config.AXIS_LINE_WIDTH);
    h2 = gca;
    box off;
    export_fig(fullfile(g_config.OUTPUT_DIR, 'clusters_dep_undef.eps'));
    
    % final number of clusters
    figure(79);
    errorbar( nc, arrayfun( @(i) res1(i).mean_nclusters - nc(i), 1:length(res1)),  arrayfun( @(x) x.sd_nclusters*ci_fac, res1), 'k-', 'LineWidth', g_config.LINE_WIDTH);                       
    hold on;
    errorbar( nc, arrayfun( @(i) res2(i).mean_nclusters - nc(i), 1:length(res2)),  arrayfun( @(x) x.sd_nclusters*ci_fac, res2), 'k:', 'LineWidth', g_config.LINE_WIDTH);                           
    set(gca, 'Xtick', [50, 100, 150, 200]);  
    xlabel('N_{clus}', 'FontSize', g_config.FONT_SIZE);
    ylabel('\DeltaN_{clus}', 'FontSize', g_config.FONT_SIZE);            
    set(gcf, 'Color', 'w');
    set(gca, 'FontSize', g_config.FONT_SIZE, 'LineWidth', g_config.AXIS_LINE_WIDTH);
    h3 = gca;
    box off;
    export_fig(fullfile(g_config.OUTPUT_DIR, 'clusters_dep_deltan.eps'));        

    % covering
    figure(80);
    ci_fac = 1.96/sqrt(length(nc));
    plot( nc, covering*100,  'k-', 'LineWidth', g_config.LINE_WIDTH);                       
    xlabel('N_{clus}', 'FontSize', g_config.FONT_SIZE);
    ylabel('% coverage', 'FontSize', g_config.FONT_SIZE);            
    set(gcf, 'Color', 'w');
    set(gca, 'FontSize', g_config.FONT_SIZE, 'LineWidth', g_config.AXIS_LINE_WIDTH);
    h1 = gca;
    box off;
    export_fig(fullfile(g_config.OUTPUT_DIR, 'clusters_dep_coverage.eps'));
end
