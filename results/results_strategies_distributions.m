function results_strategies_distributions
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/AnDarksamtest'));

    % global data initialized elsewhere
    global g_trajectories_trial;    
    global g_trajectories_session;
    global g_trajectories_group;        
    global g_trajectories_speed;        
    global g_segments_classification;
    global g_long_trajectories_idx;
    global g_animals_trajectories_map;
        
    % classify trajectories
    cache_trajectories_classification; 
    
    bins = [90]; % [20, 25, 45];    
    % bins = [90];
    
    classes = constants.REDUCED_BEHAVIOURAL_CLASSES;
    % classes = g_segments_classification.classes; 
    [~, full_strat_distr] = g_segments.classes_mapping_time(g_segments_classification, bins, ...
                                                           'Classes', classes, ...
                                                           'DiscardUnknown', 0);
    
    % count animals
    n = sum(g_trajectories_trial(g_long_trajectories_idx) == 1);
    
    % plot distributions for each session (first bin only if there is more
    % than 1)
    data = [];        
    for c = 1:length(classes)
        figure;        
        for s = 1:constants.SESSIONS                        
            for g = 1:2                
                sel = distr(g_trajectories_session(g_long_trajectories_idx) == s & g_trajectories_group(g_long_trajectories_idx) == g);
                
                % for each guy
                for i = 1:length(sel)
                    tmp = full_strat_distr{sel(i)};
                    if tmp(1, c) ~= -1
                        pts = [pts, tmp(b, c)];
                    end
                end
                
                
                data = sort(data);
                n = length(data);
                p = zeros(1, n);
                p(1) = 1/n;
                for i = 2:n
                    p(i) = p(i - 1) + 1/n;
                end
                if g == 1
                    plot(smooth(data), p, 'k-');
                else
                    plot(smooth(data), p, 'k:');
                end
                hold on;
            end            
            
%             hip = kstest2(data1, data2);
            test_data = zeros(length(data1) + length(data2), 2);
            test_data(1:length(data1), 1) = data1;
            test_data(1:length(data1), 2) = 1;
            test_data(length(data1) + 1:length(test_data), 1) = data2;
            test_data(length(data1) + 1:length(test_data), 2) = 2;
%            AnDarksamtest(test_data);
%              if hip
%                 disp('aha');
%             end
        end
        hold off;
        xlabel(sprintf('%% %s', g_segments_classification.classes(c).description), 'FontSize', constants.FONT_SIZE);
        ylabel('percentage', 'FontSize', constants.FONT_SIZE);
        

    end         
    
    % export_fig(fullfile(constants.OUTPUT_DIR, 'distribution_strat_trials.eps'));
    
    
end