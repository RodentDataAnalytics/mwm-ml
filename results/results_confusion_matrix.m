function results_confusion_matrix
%RESULTS_CLUSTERING_CONFUSION_MATRIX Computes the confusion matrix of the
%classification
    fn = fullfile(g_config.OUTPUT_DIR, 'confusion_matrix.mat');
    
    % if output file already exists do nothing
    if exist(fn, 'file')
        load(fn);
    else    
        global g_segments;    
        % initialize data
        cache_trajectory_segments;                    


        % get classifier object
        classif = g_segments.classifier(g_config.DEFAULT_TAGS_PATH, g_config.DEFAULT_FEATURE_SET, g_config.TAG_TYPE_BEHAVIOUR_CLASS);

        % perform a N-fold cross-validation
        folds = 10;
        res = classif.cluster_cross_validation(g_config.DEFAULT_NUMBER_OF_CLUSTERS, 'Folds', folds);

        % take the "total confusion matrix"    
        cm = res.results(1).confusion_matrix;
        for i = 2:folds
            cm = cm + res.results(i).confusion_matrix;
        end
        tags = res.results(1).classes;
      
        % save data
        save(fn, 'tags', 'cm');   
    end
    
    disp('Tags:');
    for i = 1:length(tags)
        fprintf('%s\n', tags(i).description);
    end
        
    fprintf('\nConfusion matrix:\n');    
    cm        
end
