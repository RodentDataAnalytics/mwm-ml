function results_confusion_matrix
%RESULTS_CLUSTERING_CONFUSION_MATRIX Computes the confusion matrix of the
%classification
    fn = fullfile(constants.OUTPUT_DIR, 'confusion_matrix.mat');
    
    % if output file already exists do nothing
    if exist(fn, 'file')
        load(fn);
    else    
        global g_segments;    
        % initialize data
        cache_trajectory_segments;                    

        folds = 10;

        % get classifier object
        classif = g_segments.classifier(constants.DEFAULT_TAGS_PATH, constants.DEFAULT_FEATURE_SET, constants.TAG_TYPE_BEHAVIOUR_CLASS);

        % perform a 10-fold cross-validation
        res = classif.cluster_cross_validation(constants.DEFAULT_NUMBER_OF_CLUSTERS, 'Folds', folds);

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