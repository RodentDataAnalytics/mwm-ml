function results_hormone_correlation
    addpath(fullfile(fileparts(mfilename('fullpath')), '../../extern/my_corrplot'));
    
    global g_config;
    global g_segments_classification;    
    global g_animals_trajectories_map;
    global g_animals_ids;
    global g_trajectories_speed;   
    global g_trajectories_group;
    global g_trajectories;
    
    cache_trajectories_classification;
    cache_animals;
    
    all_ids = [87 , 91 , 93 , 95 , 99 , 101 , 103 , 114 , 115 , 121 , 88 , 90 , 98 , 100 , 104 , 106 , 108 , 113 , 118 , 122, ...
               43 , 49 , 52 , 57 , 59 , 65 , 75 , 82 , 44 , 50 , 53 , 58 , 60 , 67 , 71 , 76 , 78 , 83, ...
               50 , 61 , 67 , 71 , 75 , 83 , 90 , 94 , 100 , 111 , 52 , 57 , 63 , 69 , 73 , 81 , 92 , 96 , 102 , 107];

    cc_basal = [ 0 , 1.5 , 7.8 , 4.7 , 2.6 , 1.6 , 7.4 , 2.4 , 1.5 , 3.7 , 18 , 15.4 , 1.3 , 2.3 , 4.6 , 0.9 , 3.1 , 0.9 , 0 , 6.9, ...
                 19.2 , 2.8 , 15.8 , 1.4 , 3.5 , 1.3 , 8.3 , 6.2 , 0.2 , 23.7 , 3.6 , 1.4 , 20.6 , 11.2 , 7.9 , 11.5 , 3.1 , 6.9, ...
                 16.5 , 20.1 , 1.7 , 11.2 , 38.7 , 43.2 , 35.2 , 2.4 , 21.9 , 47.6 , 12.2 , 58.7 , 5.9 , 18.6 , 72 , 0.4 , 4.5 , 4.1 , 11 , 39 ];

    cc_stress = [ 40.3 , 17.3 , 199.2 , 44.9 , 243.7 , 113.7 , 178.8 , 247 , 33.4 , 132.5 , 4.8 , 3.3 , 56.6 , 50.5 , 59.9 , 103.1 , 17.4 , 97.2 , 129 , 111.6,  ...
                  70.9 , 79.7 , 29.1 , 104.9 , 96.2 , 87.9 , 123 , 66.9 , 29.6 , 70.2 , 36.2 , 100.5 , 60.1 , 142.1 , 70.5 , 68.3 , 74.7 , 85.8, ... 
                  183.1 , 63.5 , 63.9 , 209.8 , 26.4 , 67.5 , 115 , 83.9 , 95.3 , 64.5 , 68.9 , 100.4 , 78.3 , 47.5 , 52.3 , 28.5 , 78.9 , 66.5 , 54 , 56.1];

    cc_rec30 = [ 37.7 , 10.1 , 86.1 , 105 , 113.4 , 52.6 , 14 , 31.8 , 194.9 , 18.3 , 61.4 , 14.7 , 309 , 69.9 , 77.4 , 15.6 , 7.1 , 21.4 , 9.4 , 49, ...
                 70.6 , 225.3 , 7.1 , 361.9 , 14.7 , 15.7 , 35.8 , 16.6 , 66.2 , 20.4 , 13.9 , 24.5 , 19.7 , 57.9 , 15.4 , 55.3 , 46.6 , 13.8, ...
                 42.2 , 260.6 , 42.2 , 312 , 99.8 , 43.4 , 34.9 , 24.2 , 185 , 33.3 , 30.8 , 236.8 , 211.3 , 149.9 , 27.5 , 10.9 , 39.1 , 65.6 , 23.1 , 66.1];

    cc_rec60 = [ 9.4 , 4.3 , 3.5 , 20.5 , 3 , 24.7 , 2.1 , 50.5 , 79.9 , 3.7 , 14.5 , 1.8 , 26.8 , 11.7 , 24.4 , 13.5 , 0.5 , 0.9 , 0.4 , 38.4, ...
                 22.9 , 130.1 , 8.5 , 33.4 , 24.2 , 47.3 , 20.3 , 23.1 , 5.8 , 57.6 , 3.8 , 4.7 , 9.9 , 36.7 , 7.3 , 10.7 , 89.1 , 4.6, ... 
                 13.4 , 25.7 , 6.7 , 90.1 , 7 , 69.5 , 4.8 , 55.1 , 122.8 , 4.8 , 27.1 , 97 , 57.3 , 108.7 , 4.7 , 20.5 , 19.5 , 12 , 4.8 , 12.6 ];

    w27 = [ 69.9 , 67.5 , 71.4 , 57.4 , 66.1 , 60.5 , 73.1 , 64.2 , 62.4 , 66.5 , 64.2 , 68.6 , 52.3 , 53.5 , 68 , 75 , 76.6 , 62.4 , 69.1 , 70.7, ...
            84   , 83.9    , 84.8    , 66.8, 56.5, 52, 66, 77.4    , 77.6    , 84.1    , 72.1, 72.2, 55, 51.1    , 68, 68.1, 62.6    , 77.6, ...    
            66.5 , 61.1    , 58.9    , 78.9    , 62.4    , 59.7    , 63.5    , 68.6    , 64      , 62.6    , 69.2    , 59      , 59.4    , 57.1    , 65.1    , 60.3    , 64.5    , 62.2    , 67.3    , 59.6];

    traj_ids = arrayfun( @(idx) g_trajectories.items(idx).id, 1:g_trajectories.count);
    
    stress_flag = zeros(1, length(all_ids));
    for i = 1:length(all_ids)
        pos = find(traj_ids == all_ids(i));
        if g_trajectories_group(pos(1)) == 2
            stress_flag(i) = 1;
        end
    end
    
    fprintf('\nBASAL control: %g (%g)', mean(cc_basal(stress_flag == 0)), std(cc_basal(stress_flag == 0)));
    fprintf('\nBASAL stress: %g (%g)', mean(cc_basal(stress_flag == 1)), std(cc_basal(stress_flag == 1)));
    
    fprintf('\nSTRESS control: %g (%g)', mean(cc_stress(stress_flag == 0)), std(cc_stress(stress_flag == 0)));
    fprintf('\nSTRESS stress: %g (%g)', mean(cc_stress(stress_flag == 1)), std(cc_stress(stress_flag == 1)));
    
    
    w43 = [ 164 , 177.5 , 181.2 , 139.8 , 162.2 , 143.1 , 184.3 , 163.5 , 152.3 , 164.9 , 164 , 170.9 , 121.6 , 121.6 , 178.6 , 170.4 , 195.6 , 153.4 , 167.6 , 166.6, ...
           185.9 , 182.7 , 196.1 , 175.2 , 147.3 , 137.7 , 164.6 , 179.7 , 158.9 , 185.4 , 174.1 , 167.7 , 130.9 , 128.9 , 170.7 , 176 , 163.1 , 171.5, ... 
          171.6 , 151.9 , 151 , 187.9 , 156.4 , 155.3 , 165.4 , 176.8 , 181.1 , 164.8 , 180.1 , 151.2 , 151.8 , 145 , 164.9 , 158.1 , 159.3 , 168.4 , 172.9 , 155];

    of_time_centre = [ 5.33 , 3.1 , 4.77 , 5.37 , 4.13 , 3.73 , 6.07 , 5.33 , 3.4 , 1.73 , 5.93 , 1.2 , 8.2 , 11.97 , 5.6 , 5.37 , 4.3 , 2.9 , 3.17 , 7.57, ...
                       4.7 , 4.27 , 4.43 , 6.07 , 4.13 , 4.1 , 7.17 , 5.03 , 5.3 , 2.87 , 10.53 , 5.3 , 5.2 , 3.97 , 4.2 , 5.1 , 3.73 , 3.93 , 5.97 , 9.03, ...
                       2.67 , 2.53 , 9.27 , 6.3 , 3.97 , 9.17 , 7.77 , 0.83 , 5.4 , 5.23 , 4.3 , 6.83 , 3.47 , 10.73 , 4.83 , 6.83 , 5.97 , 4.9 ]; 

    p42_ids = [88, 90, 100, 104, 106, 108, 113, 118, 122, ...
               44, 50, 53, 58, 60, 67, 71, 76, 78, 83, ...
               52, 57, 63, 69, 73, 81, 92, 96, 102, 107];
           
    p42_stress = [313.3, 215.2, 66.2, 128.5, 189.8, 147.3, 86.7, 133.8, 300.4, ...
                  29.6, 70.2, 36.2, 100.5, 60.1, 142.1, 70.5, 68.3, 74.7, 85.8, ...
                  68.9, 100.4, 78.3, 47.5, 52.3, 28.5, 78.9, 66.5, 54, 56.1];
    
    p42_rec = [80.8, 188.7, 62.3, 86.1, 195.3, 59.6, 19.7, 40.5, 55.2, ...
               66.2, 20.4, 13.9, 24.5, 19.7, 57.9, 15.4, 55.3, 46.6, 13.8, ...
               30.8, 236.8, 211.3, 149.9, 27.5, 10.9, 39.1, 65.6, 23.1, 66.1];

    p42_AUC = [11354, 11728, 3762, 6369, 11271, 5910, 3161, 4959, 9985, ...
               2964, 3938, 1614, 3842, 2852, 6719, 2805, 4041, 5022, 3161, ...
               3581, 12452, 9636, 7832, 3545, 1496, 3900, 4205, 2550, 4440];
   
    w27_p42 = [64.2, 68.6, 53.5, 68, 75, 76.6, 62.4, 69.1, 70.7, ... 
        77.6, 84.1, 72.1, 72.2, 55, 51.1, 68, 68.1, 62.6, 77.6, ...
        69.2, 59, 59.4, 57.1, 65.1, 60.3, 64.5, 62.2, 67.3, 59.6];
                      
    w43_p42 = [164, 170.9, 121.6, 178.6, 170.4, 195.6, 153.4, 167.6, 166.6, ...
           158.9, 185.4, 174.1, 167.7, 130.9, 128.9, 170.7, 176, 163.1, 171.5, ...
           180.1, 151.2, 151.8, 145, 164.9, 158.1, 159.3, 168.4, 172.9, 155];        


        
    %% behavioural classes correlations
    
%     exp_measures = [p42_stress; p42_rec; p42_AUC; w43_p42 - w27_p42];
%     exp_ids = p42_ids; 

    exp_measures = [cc_basal; cc_stress; cc_rec30; cc_rec60; w43 - w27; of_time_centre];
    exp_ids = all_ids;

    
    % only stressed animals
    map = g_animals_trajectories_map{2};    
    ids = g_animals_ids{2};
    
    classes = [ ...
            tag.combine_tags( [g_config.TAGS(tag.tag_position(g_config.TAGS, 'TT')), g_config.TAGS(tag.tag_position(g_config.TAGS, 'IC'))]), ...
            tag.combine_tags( [g_config.TAGS(tag.tag_position(g_config.TAGS, 'SS')), g_config.TAGS(tag.tag_position(g_config.TAGS, 'FS')), g_config.TAGS(tag.tag_position(g_config.TAGS, 'SC'))]), ...
            tag.combine_tags( [g_config.TAGS(tag.tag_position(g_config.TAGS, 'CR')), g_config.TAGS(tag.tag_position(g_config.TAGS, 'SO')), g_config.TAGS(tag.tag_position(g_config.TAGS, 'ST'))])  ...                          
        ];

    % full_strat_distr = g_segments_classification.classes_distribution(g_segments_classification.segments.partitions, 'Normalize', 1, 'Classes', classes);
    full_strat_distr = g_segments_classification.classes_distribution(g_segments_classification.segments.partitions, 'Normalize', 1);
    valid_idx = [];
    comp_vals = [];
    for c = 1:g_segments_classification.nclasses                            
        vals = [];
        
        for iid = 1:length(exp_ids)
%             if stress_flag(iid)
%                 continue;
%             end
%             
            idx_animal = find(ids == exp_ids(iid));
            if isempty(idx_animal)
                continue;
            end
            
            tot = 0;
            for t = 1:g_config.TRIALS                                                
                tot = tot + full_strat_distr(map(t, idx_animal), c);                                                                  
            end
            vals = [vals, tot/g_config.TRIALS];            
            if c == 1
                valid_idx = [valid_idx, iid];
            end
        end
        if c == 1
            comp_vals = zeros(1, length(vals));
        end
        comp_vals(c, :) = vals;
    end      
    
    last = size(comp_vals, 1);    
    vals = [];
        
    for iid = 1:length(exp_ids)
        idx_animal = find(ids == exp_ids(iid));
        if isempty(idx_animal)
            continue;
        end
%         if stress_flag(iid)
%             continue;
%         end
        
        tot = 0;
        for t = 1:g_config.TRIALS                                                
            tot = tot + g_trajectories_speed(map(t, idx_animal));                                                                  
        end
        vals = [vals, tot/g_config.TRIALS];               
    end
    last = last + 1;    
    comp_vals(last, :) = vals;

    trans = g_segments_classification.transition_counts_trial;
    vals = [];
    for iid = 1:length(exp_ids)
        idx_animal = find(ids == exp_ids(iid));
        if isempty(idx_animal)
            continue;
        end
%         if stress_flag(iid)
%             continue;
%         end
        
        tot = 0;
        for t = 1:g_config.TRIALS
            tot = tot + trans(map(t, idx_animal));                                                                              
        end
        vals = [vals, tot];               
    end
    last = last + 1;    
    comp_vals(last, :) = vals;
    
    
    correlations = zeros(last, size(exp_measures, 1)); 
    pvalues = zeros(last, size(exp_measures, 1));            

    % compute correlations
    for i = 1:size(exp_measures, 1)
        for j = 1:size(comp_vals, 1)
            [rho, p] = corr(exp_measures(i, valid_idx)', comp_vals(j, :)', 'Type', 'Pearson');
            correlations(j, i) = rho;
            pvalues(j, i) = p;                        
        end
    end
    
    for i = 1:size(exp_measures, 1)
        for j = 1:size(comp_vals, 1)
            [rho, p] = corr(exp_measures(i, valid_idx)', comp_vals(j, :)', 'Type', 'Pearson');
            correlations(j, i) = rho;
            pvalues(j, i) = p;                        
        end
    end
    
    % correlation with speed and number of transitions
    correlations
    pvalues
    
    X = zeros(size(exp_measures, 1) + size(comp_vals, 1), length(valid_idx));
    
    for i = 1:size(exp_measures, 1)
        X(i, :) = exp_measures(i, valid_idx);        
    end
    xnames = {'CC basal', 'CC stress', 'CC rec30', 'CC rec60', 'weight' 'OF time centre'};
        
    for i = 1:g_segments_classification.nclasses
        xnames = [xnames, g_segments_classification.classes(i).description];
    end
    xnamees = [xnames, 'Speed', 'Transitions'];
    
    for i = 1:size(comp_vals, 1)
        X(i + size(exp_measures, 1), :) = comp_vals(i, :);        
    end        
    
    figure;
    mycorrplot_1(X', xnames);  

end

