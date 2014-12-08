function plot_distribution_strategies(distributions, varargin)
%PLOT_DISTRIBUTION_STRATEGIES Summary of this function goes here
%   Detailed explanation goes here    
    addpath(fullfile(fileparts(mfilename('fullpath')), './extern/cm_and_cb_utilities'));
    addpath(fullfile(fileparts(mfilename('fullpath')), './extern/'));
    
    [mean_row, mean_col, row_labels, col_labels, ticks, ticks_labels, markers, ordered, widths, cm, bh] = ...
        process_options(varargin, ...
            'MeanRow', 0, 'MeanColumn', 0, 'RowLabels', {}, 'ColumnLabels', {}, ...
            'Ticks', [], 'TicksLabels', {}, 'Markers', {}, 'Ordered', 0, ...
            'Widths', [], 'ColorMap', constants.CLASSES_COLORMAP, 'BarHeight', 0.8);
    
    ncol = length(distributions) + mean_col;    
    % sanity checks
    assert(~(mean_col && ordered) && ~(mean_row && ordered));
    
    % we need the length of the longest distribution to make sure that all
    % columns are of the same width
    max_len = 0;    
    if ordered
        % we have a fixed number of bins
        max_len = size(distributions{1}, 2);
        if ~isempty(widths)
            assert(length(widths) == max_len);
            max_len = sum(widths);
        end            
    else
        % variable length, look for the maximum
        for i = 1:length(distributions)
            max_len = max(max_len, max(sum(distributions{i}, 2)));
        end
    end
        
    % maximum number of bars
    nbars = 0;
    for i = 1:length(distributions)
        nbars = max(nbars, size(distributions{i}, 1));        
    end
    if mean_row
        nbars = nbars + 1;
    end
    % number of classes
    if ~ordered
        nclasses = size(distributions{i}, 2);
    else
        un = [];
        for i = 1:length(distributions)
            tmp = distributions{i};
            un = [un, tmp(:)'];
        end
        nclasses = max(un);
    end
        
    l = 0.92;
    b = 0.05;
    if ~isempty(row_labels) && length(row_labels{1}) > 1
        ib = 0.05;
    else
        ib = 0.02;
    end    
    w = (l - 2*b - (ncol - 1)*ib)/ncol;
    h = l - 2*b; 
    
    % need to compute the "total" distribution for the mean column
    tot = [];   
       
    set(gcf, 'PaperUnits', 'centimeters');
    set(gcf, 'visible','on','Color','w', 'PaperPosition', [0.1 0 12 8],...
        'PaperSize', [12 8],'PaperUnits', 'centimeters'); %Position plot at left hand corner with width 14cm and height 7cm.
    axes('Position',[b b l l]);  % "parent" axes            
    axis off;            
    for i = 1:ncol               
        is_mean_col = i == ncol && mean_col;
        if is_mean_col                     
            distr = tot / (ncol - 1);
        else
            distr = distributions{i};        
            if mean_col
                if i == 1
                    tot = distr;
                else
                    tot = tot + distr;                                    
                end
            end
        end
        
        % create an axes inside the parent axes for the ii-the barh           
        sa = axes('Position', [b + w*(i - 1) + ib*(i - 1), b + 0.05, w, h]); % position the ii-th barh
        
        if mean_row
            % one additional row for the mean
            vals = zeros(size(distr, 1) + 1, size(distr, 2));
            m = mean(distr);
            vals(1, :) = m;
            vals(2:size(vals, 1), :) = distr;               
        else
            vals = distr;
        end
        
        n = size(vals, 1);
        
        vals(size(vals, 1) + 1:nbars, :) = zeros(nbars - size(vals, 1), size(distr, 2));
                
        if ordered
            % rescale colormap
            if size(cm, 1) > nclasses
                cm = cmapping(nclasses, cm);
            end
            wbin = widths;            
            if isempty(wbin)
                wbin = ones(1, size(distr, 2)); 
            end
            nbins = length(wbin);
                        
            for k = 1:nbars   
                tmp = nan(1, nbins);
                tmp(vals(k, :) >= 0) = wbin(vals(k, :) >= 0);
                barh([k, k + 1], [tmp; zeros(1, nbins)], 'Stacked');
                % color the patches
                P = findobj(gca, 'type', 'patch');
                for l = 1:nbins                    
                    if vals(k, l) > 0                     
                        set(P(nbins - l + 1), 'facecolor', cm(vals(k, l), :));
                    elseif vals(k, l) == 0                     
                        set(P(nbins - l + 1), 'facecolor', [1, 1, 1]);
                    end
                end
                hold on;
            end   
        else
            vals(vals(:) <= 0) = nan; 
            barh(1:n, vals, bh, 'Stack', 'Parent', sa);               
            colormap(cm);
        end
        
        set(gca,'box','off');
        set(gca,'XLim', [0, max_len]);
        if ~isempty(ticks)
            set(gca, 'XTick', ticks);
        end
        if ~isempty(ticks_labels)
            set(gca, 'XTickLabel', ticks_labels, 'FontSize', 8);
        end
        if ~isempty(row_labels)                            
            if i == 1 || iscell(row_labels{1})
                % set labels
                if mean_row
                    lbls = {'AVG'};
                else
                    lbls = {};
                end
                if iscell(row_labels{1})
                    nl = length(row_labels{i});
                    lbls = [lbls, row_labels{i}];
                else
                    lbls = [lbls, row_labels];
                    nl = length(row_labels);
                end
                set(gca,'YTick', 1:nl, 'YTickLabel', lbls, 'FontSize', 8 );
            else                        
                set(gca,'YTick', []);
            end
        else                        
            set(gca,'YTick', []);
        end
        hold on;
        if ~isempty(col_labels)                
            if mean_col && i == ncol
                text(max_len / 2, nbars + 2, 'Average', 'FontSize', 6, 'HorizontalAlignment','center');
            else    
                text(max_len / 2, nbars + 2, col_labels{i}, 'FontSize', 6, 'HorizontalAlignment','center');
            end
        end
        
        if ~isempty(markers) && ~is_mean_col
             % mark cases where animal found the platform
            m = markers{i};
            for j = 1:length(m)
                if m(j) 
                    if mean_row
                        off = 1;
                    else
                        off = 0;
                    end
                    hold on;               
                    if ordered                        
                        text(sum( (distr(j, :) >= 0).*widths) + sum(widths)/50, j + off, 'x', 'FontSize', 6, 'FontWeight', 'bold');                     
                    else    
                        text(sum(distr(j, :)) + max_len/100, j + off, 'x', 'FontSize', 6, 'FontWeight', 'bold'); 
                    end
                end
            end
        end
        % set(gca, 'FontSize', 6, 'LineWidth', 0.8);                                    
    end        
end        