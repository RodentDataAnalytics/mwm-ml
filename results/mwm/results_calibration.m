function results_calibration
%RESULTS_CALIBRATION Summary of this function goes here
%   Detailed explanation goeshere
% show calibration results   
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
        %%export_fig(fullfile(g_config.OUTPUT_DIR, sprintf('calibration_set%d_x.eps', i)));
        export_figure(1, gcf, g_config.OUTPUT_DIR, sprintf('calibration_set%d_x', i));
        figure('name', sprintf('Calibration function Y (set %d)', i));
        mesh(xq, yq, Fy(xq, yq));
        xlabel('X [cm]');
        ylabel('Y [cm]');
        zlabel('correction [cm]');
        set(gcf, 'Color', 'w');
        set(gca, 'FontSize', g_config.FONT_SIZE, 'LineWidth', g_config.AXIS_LINE_WIDTH);
        %%export_fig(fullfile(g_config.OUTPUT_DIR, sprintf('calibration_set%d_y.eps', i)));
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
        %%export_fig(fullfile(g_config.OUTPUT_DIR, sprintf('calibration_error%d.eps', i)));
        export_figure(1, gcf, g_config.OUTPUT_DIR, sprintf('calibration_error%d', i));
    end
    
%     traj_cal = [];
%     traj_uncal = [];
%     traj_name = {};
%     for i = 1:length(g_config.TRAJECTORY_SNAPSHOTS_DIRS)
%         samples = dir(strcat(g_config.TRAJECTORY_SNAPSHOTS_DIRS{i}, '*.png')); 
%         if length(samples) > 1
%             figure('name', sprintf('Samples for set %d', i));
%         end                
%         for j = 1:length(samples)
%             temp = sscanf(samples(j).name, 'day%d_track%d.png');
%             day = temp(1);
%             track = temp(2);
%             
%             traj_name = [traj_name, sprintf('set%d_%s', i, samples(j).name)];
% 
%             % look for corresponding trajectory in the uncorrected data set
%             idxorig = -1;
%             for k = 1:length(origtraj)
%                 id1 = origtraj.items(k).data_identification();                            
%                 if i == id1(1) && day == id1(2) && track == id1(3)
%                    % found ya                
%                    idxorig = k;
%                    break;
%                 end
%             end    
%             % save index for later plotting as well
%             traj_uncal = [traj_uncal, idxorig];            
% 
%             idx = -1;
%             for k = 1:length(traj)
%                 id1 = traj.items(k).data_identification();                            
%                 if i == id1(1) && day == id1(2) && track == id1(3)                
%                    % found ya                
%                    idx = k;
%                    break;
%                 end
%             end    
%             % save index for later plotting as well
%             traj_cal = [traj_cal, idx];            
% 
%             if idx == -1 || idxorig == -1
%                 error('Did not find trajectory');
%             end
% 
%             subaxis(length(samples), 3, (j-1)*3 + 1, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0.05);        
%             imshow(strcat(g_config.TRAJECTORY_SNAPSHOTS_DIRS{i}, samples(i).name), 'Border', 'tight');            
%             subaxis(length(samples), 3, (j-1)*3 + 2, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0.05);     
%             origtraj(idxorig).plot;                        
%             subaxis(length(samples), 3, (j-1)*3 + 3, 'Spacing', 0.03, 'Padding', 0, 'Margin', 0.05);    
%             traj(idx).plot;            
%         end            
%     end
%     
%     % export individual figures
%     for i = 1:length(traj_uncal)
%         figure(111);        
%         clf;                        
%         origtraj(traj_uncal(i)).plot;
%         set(gcf, 'Color', 'w');
%         set(gca,'DataAspectRatio',[1 1 1], 'PlotBoxAspectRatio',[1 1 1]);
%         export_fig(fullfile(g_config.OUTPUT_DIR, sprintf('%s_uncalibrated.eps', traj_name{i})));       
%     end
%     
%     for i = 1:length(traj_cal)
%         figure(111);
%         clf;
%         traj(traj_cal(i)).plot;
%         set(gcf, 'Color', 'w');
%         set(gca,'DataAspectRatio',[1 1 1], 'PlotBoxAspectRatio',[1 1 1]);
%         export_fig(fullfile(g_config.OUTPUT_DIR, sprintf('%s_calibrated.eps', traj_name{i})));       
%     end
%     
%     for i = 1:length(cal_data) 
%         temp = cal_data{i};
%         fprintf('Total calibration points for set %d: %d', i, size(temp, 1));
%     end
end
