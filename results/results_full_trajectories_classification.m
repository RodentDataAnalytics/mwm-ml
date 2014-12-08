function results_full_trajectories_classification
%RESULTS_FULL_TRAJECTORIES_CLASSIFICATION Compare classification of
%trajectories with a manual classification
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));

    % global data initialized elsewhere
    global g_trajectories; 
    cache_trajectories; 
       
    % load trajectory tags -> these are the tags assigned to the full
    % trajectories
    [full_labels_data, full_tags] = g_trajectories.read_tags(constants.FULL_TRAJECTORIES_TAGS_PATH, constants.TAG_TYPE_BEHAVIOUR_CLASS);
    full_map = g_trajectories.match_tags(full_labels_data, full_tags);        
    % select only tagged trajectories
    tagged = sum(full_map, 2) > 0;
       
%     tt = constants.TAGS(tag.tag_position(constants.TAGS, 'TT')); 
%     ic = constants.TAGS(tag.tag_position(constants.TAGS, 'IC'));
%     at = constants.TAGS(tag.tag_position(constants.TAGS, 'TS'));
%     sc = constants.TAGS(tag.tag_position(constants.TAGS, 'SC'));
%     so = constants.TAGS(tag.tag_position(constants.TAGS, 'SO'));
%     st = constants.TAGS(tag.tag_position(constants.TAGS, 'ST'));
%     
%     tag_groups = [ tt, ...                           
%                    tag.combine_tags( [ic, at]), ...
%                    tag.combine_tags( [sc, so]), ... 
%                    st];    
%                    
    % we classify them now using different segment lengths
    % len = [125, 150, 175, 200, 225, 250, 275, 300, 325, 350];
    ovlp = [0.6, 0.8, 0.9, 0.95];
    
    pts = [];
    log_file = fopen(fullfile(constants.OUTPUT_DIR, 'full_trajectories_classification_log.txt'), 'w');
    
    for i = 1:length(ovlp)
        mess = sprintf('**** SEGMENT OVERLAP = %f ****', ovlp(i));
        fprintf(log_file, '%s\n', mess);
        disp(mess);
        
        fn = fullfile(constants.OUTPUT_DIR, sprintf('full_traj_class_olvp%d.mat', ovlp(i)));
        if exist(fn, 'file')
           load(fn);
        else                    
            err_class = [];
            unk = [];
            nc = [];
            
            [segments, partitions] = g_trajectories.divide_into_segments(constants.DEFAULT_SEGMENT_LENGTH, ovlp(i), 2); 
            % build classifier
            classif = segments.classifier(constants.DEFAULT_TAGS_PATH, constants.DEFAULT_FEATURE_SET, constants.TAG_TYPE_BEHAVIOUR_CLASS);
                            
            % run the thing for 3 different number of clusters
            for j = 1:6
                nc = [nc, constants.DEFAULT_NUMBER_OF_CLUSTERS + (j - 1)*10];
                mess = sprintf('**** OVLP = %f, Clusters = %d ****', ovlp(i), nc(end));
                fprintf(log_file, '%s\n', mess);
                disp(mess);  
                                
                % run clusterer                
                results = classif.cluster(nc(end));
                
                % map segment to full trajectory tags
                tag_map = repmat({}, 1, length(full_tags));
                for k = 1:length(full_tags)
                    % look for tags matching the current one                
                    tag_map{k} = tag.tag_position(results.classes, full_tags(k).abbreviation);
                    if tag_map{k} == 0
                        mess = sprintf('class not present in classification: %s', full_tags(k).description);
                        fprintf(log_file, '%s\n', mess);
                        disp(mess);
                    end
                end

                % select only trajectories with at least 2 segments
                part_idx = find(partitions > 0);

                % convert from individual segment classes to full trajectories
                % distribution of classes
                seg_map = results.classes_distribution(partitions);
                err2 = 0;
                tot = 0;
                distr = zeros(1, length(full_tags));
                for k = 1:length(part_idx)
                    if ~tagged(part_idx(k))
                        continue;
                    end
                    % ntags = 0;
                    % count # of tags not present in the full trajectories                
                    for l = 1:length(full_tags)
                        t = tag_map{l};                      
                        if t(1) ~= 0
                            % ntags = ntags + results.class_map(k, l);
                            distr(l) = sum(seg_map(part_idx(k), t));
                        end
                    end

                 %   [~, sorting] = sort(distr, 'descend');
                    for l = 1:length(full_tags)
                        t = tag_map{l};                      
                        if t(1) ~= 0
                            if full_map(part_idx(k), l)
                                % test if tag present
                                tot = tot + 1;
                            
                                if distr(l) == 0
                                    mess = sprintf('trajectory (set %d, day %d, trk %d): tag %s not detected', ...
                                        g_trajectories.items(part_idx(k)).set, g_trajectories.items(part_idx(k)).session, ...
                                        g_trajectories.items(part_idx(k)).track, full_tags(l).description);                        
                                    fprintf(log_file, '%s\n', mess);
                                    disp(mess);
                                    err2 = err2 + 1;                                
                                else
                                    % test if the class is one of the main ones in the
                                    % distribution
    %                                 if sorting(l) > ntags
    %                                     fprintf('trajectory (set %d, day %d, trk %d): tag %s not a major one\n', ...
    %                                         sel_traj.items(traj_idx(k)).set, sel_traj.items(traj_idx(k)).session, sel_traj.items(traj_idx(k)).track, full_tags(l).description);                        
    %                                     err2 = err2 + 1;
    %                                 end
                                end
                            end
                        end
                    end
                end
                err_class = [err_class, err2/tot*100];               
                unk = [unk, results.punknown];
            end
            
            % run a cross validation with the number of clusters that gave
            % the best resuls           
%             [~, best_pos] = min(err_class);
%             cv_results = classif.cluster_cross_validation(nc(best_pos), 'Folds', 10);
%             cv_err = cv_results.mean_perrors;
%             cv_err_sd = cv_results.sd_perrors;           
            
            % save to a file to avoid doing it all over again
            % save(fn, 'err_class', 'unk', 'cv_err', 'cv_err_sd');
            save(fn, 'err_class', 'unk');
        end
        pts = [pts; ovlp(i), ...
            mean(err_class), 1.96*std(err_class)/sqrt(length(err_class) - 1), ...
            mean(unk), 1.96*std(unk)/sqrt(length(err_class)) ...
            %cv_err*100, 100*cv_err_sd ...
        ];       
    end
    fclose(log_file);
    
    % plot error count
    fig = figure('PaperUnits', 'centimeters');
            set(fig,'visible','on','Color','w', 'PaperPosition', [0 0 12 8],...
                'PaperSize', [12 8],'PaperUnits', 'centimeters'); %Position plot at left hand corner with width 14cm and height 7cm.
            axis off;  
    errorbar( pts(:, 1), pts(:, 2), pts(:, 3), 'k-', 'LineWidth', constants.LINE_WIDTH);
    hold on;
    xlabel('segment overlap', 'FontSize', constants.FONT_SIZE);
    ylabel('% classification errors', 'FontSize', constants.FONT_SIZE);     
    box off;         
    set(gcf, 'Color', 'w');
    set(gca, 'FontSize', constants.FONT_SIZE, 'LineWidth', constants.AXIS_LINE_WIDTH);
    export_fig(fullfile(constants.OUTPUT_DIR, 'segment_ovlp_dep.eps'));       
    close;
    
%     clf;
%     errorbar( pts(:, 1), pts(:, 6), pts(:, 7), 'k-', 'LineWidth', constants.LINE_WIDTH);
%     hold on;
%     xlabel('segment overlap', 'FontSize', constants.FONT_SIZE);
%     ylabel('% errors', 'FontSize', constants.FONT_SIZE);     
%     box off;         
%     set(gcf, 'Color', 'w');
%     set(gca, 'FontSize', constants.FONT_SIZE, 'LineWidth', constants.AXIS_LINE_WIDTH);
%    % export_fig(fullfile(constants.OUTPUT_DIR, 'segment_length_dep.eps'));       
%     close;
    
    clf;
    errorbar( pts(:, 1), pts(:, 4), pts(:, 5), 'k-', 'LineWidth', constants.LINE_WIDTH); 
    hold on;
    xlabel('segment overlap', 'FontSize', constants.FONT_SIZE);
    ylabel('% unknown', 'FontSize', constants.FONT_SIZE);            
    set(gcf, 'Color', 'w');
    box off;
    set(gca, 'FontSize', constants.FONT_SIZE, 'LineWidth', constants.AXIS_LINE_WIDTH);
    export_fig(fullfile(constants.OUTPUT_DIR, 'segment_ovlp_dep_unk.eps'));           
end