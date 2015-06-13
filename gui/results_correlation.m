classdef results_correlation < handle
%RESULTS_CORRELATION Summary of this function goes here
%   Detailed explanation goes here
   
    properties(GetAccess = 'protected', SetAccess = 'protected')
        window = [];    
        parent = [];
        axis = [];
        controls_box = [];
        feature_combo = [];
        plot_combo = []; 
        full_check = [];        
    end
    
    methods
        function inst = results_correlation(par, par_wnd)                        
            inst.window = uiextras.VBox('Parent', par_wnd);
            inst.parent = par;            
        end
        
        function update(inst)
            global g_config;
            
            if isempty(inst.axis)                
                inst.axis = [inst.axis, axes('Parent', inst.window)];                
                inst.controls_box = uiextras.HBox('Parent', inst.window);
                set(inst.window, 'Sizes', [-1, 40]);
                
                feat = {};
                for i = 1:length(inst.parent.feat)
                    att = g_config.FEATURES{inst.parent.feat(i)};
                    feat = [feat, att{2}];
                end
                
                % create other controls                            
                uicontrol('Parent', inst.controls_box, 'Style', 'text', 'String', 'Plot:');            
                inst.plot_combo = uicontrol('Parent', inst.controls_box, ...
                                            'Style', 'popupmenu', ...
                                            'String', {'Features-Features', 'Features-Clusters', 'Groups-Clusters'}, ...                                            
                                            'Callback', @inst.update_plots);
                
               
                state = 'on';
                if isempty(inst.parent.traj.parent)
                    state = 'off';
                end
                inst.full_check = uicontrol('Parent', inst.controls_box, 'Style', 'checkbox', 'String', 'Full trajectories', 'Enable', state, 'Callback', @inst.update_plots);
                set(inst.controls_box, 'Sizes', [100, 200, 100]);
            end

            inst.update_plots;
        end        

        function update_plots(inst, source, event_data)            
            global g_config;
            plt = get(inst.plot_combo, 'value');
            if plt == 2
                set(inst.full_check, 'value', 0);
            end
            
            % grps = inst.parent.groups;
            full = get(inst.full_check, 'value');                                    
            
            if full
                traj = inst.parent.traj.parent;                
            else
                traj = inst.parent.traj;                
            end
            trials = arrayfun( @(t) t.trial, traj.items);       
            groups = arrayfun( @(t) t.group, traj.items);    
            
            vals = [];
            hor_str = {};
            ver_str = {};
            
            switch plt
                case 1
                    % feature-feature                    
                    feat_val = traj.compute_features(inst.parent.feat);  
                    vals = corrcoef(feat_val(inst.parent.trials(trials) == 1, :));
                        
                    for fi = 1:length(inst.parent.feat)
                        % normalize feature                        
                        att = g_config.FEATURES{inst.parent.feat(fi)};
                        ver_str = [ver_str, att{2}];
                        hor_str = [hor_str, att{2}];
                    end                    
                case 2            
                    % features-clusters                    
                    if ~isempty(inst.parent.results)
                        vals = zeros(length(inst.parent.feat), inst.parent.results.nclusters);
                        for fi = 1:length(inst.parent.feat)
                            feat_val = traj.compute_features(inst.parent.feat(fi));                            
                            for ic = 1:inst.parent.results.nclusters                                               
                                vals(fi, ic) = mean(feat_val(inst.parent.results.cluster_index == ic & inst.parent.trials(trials) == 1));
                            end
                            % normalize feature
                            vals(fi, :) = vals(fi, :) ./ repmat(norm(vals(fi, :)), 1, size(vals, 2));                      
                            att = g_config.FEATURES{inst.parent.feat(fi)};
                            ver_str = [ver_str, att{2}];
                        end
                       hor_str = arrayfun( @(idx) sprintf('Cluster %d', idx), 1:inst.parent.results.nclusters, 'UniformOutput', 0);                       
                    end           
                case 3
                    % groups-clusters
                    if ~isempty(inst.parent.results)
                        vals = zeros(g_config.GROUPS, inst.parent.results.nclusters);
                        for gi = 1:g_config.GROUPS                           
                            for ic = 1:inst.parent.results.nclusters                                               
                                vals(gi, ic) = sum(inst.parent.results.cluster_index == ic & groups == gi & inst.parent.trials(trials) == 1);
                            end                                                        
                            % vals(gi, :) = vals(gi, :) ./ repmat(norm(vals(gi, :)), 1, size(vals, 2));                      
                        end
                        
                        % normalize feature
                        for ic = 1:inst.parent.results.nclusters                                               
                            vals(:, ic) = vals(:, ic) ./ repmat(norm(vals(:, ic)), size(vals, 1), 1);                                                                   
                        end
                        hor_str = arrayfun( @(idx) sprintf('Cluster %d', idx), 1:inst.parent.results.nclusters, 'UniformOutput', 0);                       
                        if isempty(g_config.GROUPS_DESCRIPTION)
                            ver_str = arrayfun( @(idx) sprintf('Group %d', idx), 1:g_config.GROUPS, 'UniformOutput', 0);                                          
                        else
                            ver_str = arrayfun( @(idx) sprintf('Group %s', g_config.GROUPS_DESCRIPTION{idx}), 1:g_config.GROUPS, 'UniformOutput', 0);                             
                        end
                    end
            end
            
            if ~isempty(vals)
                set(inst.parent.window, 'currentaxes', inst.axis);
                hold off;
                imagesc(abs(vals));            %# Create a colored plot of the matrix values
                colormap(flipud(gray));  %# Change the colormap to gray (so higher values are
                         %#   black and lower values are white)

                textStrings = num2str(vals(:),'%0.2f');  %# Create strings from the matrix values
                textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
                [x, y] = meshgrid(1:size(vals, 2), 1:size(vals, 1));   %# Create x and y coordinates for the strings
                hStrings = text(x(:), y(:), textStrings(:), ...      %# Plot the strings
                                'HorizontalAlignment', 'center' );
                midValue = mean(get(gca, 'CLim'));  %# Get the middle value of the color range
                textColors = repmat(vals(:) > midValue, 1, 3);  %# Choose white or black for the
                                             %#   text color of the strings so
                                             %#   they can be easily seen over
                                             %#   the background color
                set(hStrings,{'Color'}, num2cell(textColors, 2));  %# Change the text colors

                set(gca,'XTick', 1:size(vals, 2), ...                         %# Change the axes tick marks
                        'XTickLabel', hor_str,...  %#   and tick labels
                        'YTick', 1:size(vals, 1), ...
                        'YTickLabel', ver_str, ...
                        'TickLength', [0 0]);
            end
        end
    end        
end