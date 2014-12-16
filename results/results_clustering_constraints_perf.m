function results_clustering_constraints_perf
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));    
    % load trajectory segments
    global g_segments;    
    % initialize data
    cache_trajectory_segments;                    
    
    p = [0.05; 0.1; 0.2; 0.4; 0.6; 0.8; 1.0];
    
    fn = fullfile(g_config.OUTPUT_DIR, 'clustering_constrains_perf.mat');
    
    if exist(fn, 'file')
        load(fn);
    else
        % run multiple clusterings with different target number of clusters
        results = cell(1, length(p));

        % get classifier object
        classif = g_segments.classifier(g_config.DEFAULT_TAGS_PATH, g_config.DEFAULT_FEATURE_SET, g_config.TAG_TYPE_BEHAVIOUR_CLASS);        

        folds = 10;
        cv = cvpartition(1:classif.nlabels, 'k', folds);

        for j = 1:cv.NumTestSets            
            for i = 1:length(p)
                % perform classifcation using only a subset of the
                % constraints
                classif.pconstraints = p(i);
                classif.two_stage = 0;
                new_results = classif.cluster_cross_validation(g_config.DEFAULT_NUMBER_OF_CLUSTERS, ...
                    'TrainingPercentage', 1., ...
                    'Runs', 1, ...
                    'TestSet', cv.test(j) ...
                );
            
                if j == 1
                    results{i} = new_results;
                else
                    results{i}.append(new_results);
                end
            end
        end          
        save(fn, 'results');
    end
        
    % classification errors (cross-validation)    
    
    % for all the results, remap the clusters allowing for mixed clusters
    % and relaxing other constraints such as minum number of samples
    tmp = [];
    for i = 1:length(results)
        tmp = [tmp, results{i}.remap_clusters('DiscardMixed', 0, 'MinSamplesPercentage', 0.001, 'MinSamplesExponent', 3)];
    end
    results = tmp;
     
    figure(99);
    ci_fac = 1.96/sqrt(results(1).count);
    errorbar( arrayfun( @(x) x.mean_nconstraints, results), arrayfun( @(x) 100*x.mean_perrors, results),  arrayfun( @(x) 100*x.sd_perrors*ci_fac, results), 'k-', 'LineWidth', g_config.LINE_WIDTH);                       
    
    xlabel('N_{contraints}', 'FontSize', g_config.FONT_SIZE);
    set (gca, 'Xscale', 'log')
    ylabel('% errors', 'FontSize', g_config.FONT_SIZE);            
    set(gcf, 'Color', 'w');
    set(gca, 'FontSize', g_config.FONT_SIZE, 'LineWidth', g_config.AXIS_LINE_WIDTH);
    export_fig(fullfile(g_config.OUTPUT_DIR, 'clustering_constraints_errors.eps'));               
end
