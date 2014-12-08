function results_strategies_cumulative_session
%RESULTS_CONTROL_STRESS_ANALYSIS Plot distribution of strategies for each
%trial
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/export_fig'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../'));
    addpath(fullfile(fileparts(mfilename('fullpath')), '../extern/legendflex'));

    % plot cumulative distributions for each trial
    nbins = 250;
    
    global g_trajectories_trial;    
    global g_trajectories_group;        
    global g_segments_classification;
    global g_long_trajectories_idx;
    global g_segments;
    global g_partitions;
    
    % classify trajectories
    cache_trajectories_classification; 
                   
    distr = g_segments.classes_distribution(g_partitions, nbins);   
    
    for c = 1:g_segments_classification.nclasses
        figure;        
        for s = 1:constants.SESSIONS
            ti = (s - 1)*constants.TRIALS_PER_SESSION + 1;
            tf = s*constants.TRIALS_PER_SESSION;
            
            for g = 1:2
                distr_sel = distr(g_trajectories_trial(g_long_trajectories_idx) >= ti & g_trajectories_trial(g_long_trajectories_idx) < tf & g_trajectories_group(g_long_trajectories_idx) == g, :);
                % count total number of bins of this class
                ntot = sum(reshape(distr_sel, 1, size(distr_sel, 1)*size(distr_sel, 2)) == c);

                % now let's go bin by bin and build the cumulative
                % distribution
                p = zeros(1, nbins);                
                for i = 1:nbins
                    if i > 1
                        p(i) = p(i - 1);
                    end                    
                    p(i) = p(i) + sum(distr_sel(:, i) == c)/ntot;
                    if abs(p(i) - 1.) < 1e-4
                        last = i;
                        break
                    end
                end

                if g == 1
                    plot(1:last, p(1:last), 'k-');
                else
                    plot(1:last, p(1:last), 'k:');
                end
                hold on;
            end
        
        end
        hold off;
        xlabel(sprintf('%% %s', g_segments_classification.classes(c).description), 'FontSize', constants.FONT_SIZE);
        ylabel('percentage', 'FontSize', constants.FONT_SIZE);        
    end     

    % export_fig(fullfile(constants.OUTPUT_DIR, 'distribution_strat_trials_80.eps'));
end

