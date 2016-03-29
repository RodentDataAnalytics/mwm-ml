% Produces the Calibration functions (x and y position correction) and the
% Calibration error as a function of the number of calibration points.

% Publication:
% Supplementary Material
% page 13 Figure 8 & page 14 Figure 10

function results_calibration

    global g_config;    
                
    [traj, cal_data] = load_trajectories(1:3, 1);
    origtraj = load_trajectories(1:3, 0);  
        
    % show calibration data
    for i = 1:length(cal_data) 
        temp = cal_data{i};
        if isempty(temp)
            continue;
        end        
        Fx = scatteredInterpolant(temp(:,1), temp(:,2), temp(:,3), 'linear', 'linear');
        Fy = scatteredInterpolant(temp(:,1), temp(:,2), temp(:,4), 'linear', 'linear');                       
        [xq, yq] = meshgrid(0:5:200,0:5:200);
        figure('name', sprintf('Calibration function X (set %d)', i));
        mesh(xq, yq, Fx(xq, yq));
        xlabel('X [cm]');
        ylabel('Y [cm]');
        zlabel('correction [cm]');
        set(gcf, 'Color', 'w');
        set(gca, 'FontSize', g_config.FONT_SIZE, 'LineWidth', g_config.AXIS_LINE_WIDTH);
        export_figure(1, gcf, g_config.OUTPUT_DIR, sprintf('calibration_set%d_x', i));
        
        figure('name', sprintf('Calibration function Y (set %d)', i));
        mesh(xq, yq, Fy(xq, yq));
        xlabel('X [cm]');
        ylabel('Y [cm]');
        zlabel('correction [cm]');
        set(gcf, 'Color', 'w');
        set(gca, 'FontSize', g_config.FONT_SIZE, 'LineWidth', g_config.AXIS_LINE_WIDTH);
        export_figure(1, gcf, g_config.OUTPUT_DIR, sprintf('calibration_set%d_y', i));
        
        % cross validation        
        n = length(cal_data{i});
        data = cal_data{i};        
        pts = [];
        for s = 0.1:0.1:1            
            err = [];
            for rep = 1:10                                   
                cv = cvpartition(randsample(1:n, floor(s*n)), 'k', 10);
                % 1 - run the standard k-means clustering algorithm
                for j = 1:cv.NumTestSets % perforn a 10-fold stratified cross-validation                                        
                    training = data(cv.training(j), :);
                    test = data(cv.test(j), :);                    
                    % compute interpolation functions
                    Fx = scatteredInterpolant(training(:,1), training(:,2), training(:,3), 'linear', 'linear');
                    Fy = scatteredInterpolant(training(:,1), training(:,2), training(:,4), 'linear', 'linear');                       

                    % compute error
                    err = [err; (Fx(test(:, 1), test(:,2)) - test(:,3))];
                    err = [err; (Fy(test(:, 1), test(:,2)) - test(:,4))];                    
                end
            end
            
            pts = [pts; floor(s*n*0.9), mean(abs(err)), 1.96*std(abs(err))/sqrt(length(err) - 1)];
        end
        
        figure('name', sprintf('Calibration error (set %d)', i));
        set(gcf, 'Color', 'w');
        set(gca, 'FontSize', g_config.FONT_SIZE, 'LineWidth', g_config.AXIS_LINE_WIDTH);
        errorbar(pts(:,1), pts(:,2), pts(:,3), 'k:', 'LineWidth', g_config.LINE_WIDTH);
        xlabel('number of calibration points');
        ylabel('error [cm]');        
        export_figure(1, gcf, g_config.OUTPUT_DIR, sprintf('calibration_error%d', i));
    end
end
