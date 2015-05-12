function cache_trajectories_classification
% CACHE_TRAJECTORIES_CLASSIFICATION
%   Loads trajectories, parititions and then classify them using the
%   default parameters

    % load trajectories and segments
    global g_segments;        
    global g_config;
    global g_partitions;    
    global g_trajectories;
    cache_trajectory_segments;
    
    % segment classification
    global g_segments_classification;
    global g_segments_base_classification;
    
    % classification of all trajectories (including short - single segment
    % - ones);
    global g_trajectories_strat;    
    global g_trajectories_strat_distr;
    global g_trajectories_strat_distr_norm;
    global g_trajectories_punknown;
    
    if isempty(g_segments_classification)
        % parameters of the most detailed set
        param = g_config.TAGS_CONFIG{2};    
               
        % get classifier object
        classif = g_segments.classifier(param{1}, g_config.DEFAULT_FEATURE_SET, g_config.TAG_TYPE_BEHAVIOUR_CLASS);
        
        % classify segments
        g_segments_classification = classif.cluster(param{5}, 0);    
        g_segments_base_classification = g_segments_classification;
        
        % do now the other classifications
        for i = 3:length(g_config.TAGS_CONFIG)
            param = g_config.TAGS_CONFIG{i};
            segments = g_trajectories.divide_into_segments(param{2}, param{3}, abs(param{4}));
            % get classifier object
            classif = segments.classifier(param{1}, g_config.DEFAULT_FEATURE_SET, g_config.TAG_TYPE_BEHAVIOUR_CLASS);        
            % classify'em
            res = classif.cluster(param{4}, 0);
            % combine results
            g_segments_classification = g_segments_classification.combine(res); 
        end
        
        % trajectory classes - segment classes + "direct finding" class        
        df_pos = tag.tag_position(g_segments_classification.classes, 'DF'); 
        if ~df_pos
            g_trajectories_strat = [g_segments_classification.classes, g_config.TAGS(tag.tag_position(g_config.TAGS, 'DF'))];
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
        idx = find(g_partitions > 0);
        g_trajectories_punknown(idx) = ( ...
            g_partitions(idx) - sum(g_trajectories_strat_distr(idx, :) > 0, 2)'  ...
        ) ./ g_partitions(idx);
    end   
end
