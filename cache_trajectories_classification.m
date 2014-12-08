function cache_trajectories_classification
% CACHE_TRAJECTORIES_CLASSIFICATION
%   Loads trajectories, parititions and then classify them using the
%   default parameters

    % load trajectories and segments
    global g_segments;        
    global g_partitions;    
    cache_trajectory_segments;
    
    % segment classification
    global g_segments_classification;
    
    % classification of all trajectories (including short - single segment
    % - ones);
    global g_trajectories_strat;    
    global g_trajectories_strat_distr;
    global g_trajectories_strat_distr_norm;
    global g_trajectories_punknown;
    
    if isempty(g_segments_classification)
        % get classifier object
        classif = g_segments.classifier(constants.DEFAULT_TAGS_PATH, constants.DEFAULT_FEATURE_SET, constants.TAG_TYPE_BEHAVIOUR_CLASS);
        
        % classify segments
        g_segments_classification = classif.cluster(constants.DEFAULT_NUMBER_OF_CLUSTERS, 0);    
        
        % trajectory classes - segment classes + "direct finding" class        
        df_pos = tag.tag_position(g_segments_classification.classes, 'DF'); 
        if ~df_pos
            g_trajectories_strat = [g_segments_classification.classes, constants.TAGS(tag.tag_position(constants.TAGS, 'DF'))];
            df_pos = length(g_segments_classification.classes) + 1;
        else
            g_trajectories_strat = g_segments_classification.classes;
        end
                
        % define the distribution of classes for the complete trajectories  
        g_trajectories_strat_distr = g_segments_classification.classes_distribution(g_partitions, 'EmptyClass', df_pos);
        % normalized version
        g_trajectories_strat_distr_norm = g_trajectories_strat_distr;
        g_trajectories_strat_distr_norm(g_partitions > 0, :) = g_trajectories_strat_distr(g_partitions > 0, :) ./ ...
            repmat(g_partitions(g_partitions > 0)', 1, size(g_trajectories_strat_distr, 2));
        % repmat(sum(g_trajectories_strat_distr, 2) + (sum(g_trajectories_strat_distr, 2) == 0)*1e-5, 1, length(g_trajectories_strat));                    
        
        g_trajectories_punknown = zeros(length(g_partitions));
        g_trajectories_punknown(g_partitions > 0) = sum(g_trajectories_strat_distr(g_partitions > 0, :) == 0, 2)' ./ g_partitions(g_partitions > 0);
    end   
end