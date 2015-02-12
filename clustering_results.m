classdef clustering_results < handle
    % CLUSTERING_RESULTS Stores results of the clustering
    
    properties(GetAccess = 'public', SetAccess = 'protected')    
        segments = [];
        nclasses = 0;
        classes = []; % this is actually optional
        nconstraints = 0;
        class_map = [];
        cluster_idx = [];
        nclusters = 0;
        cluster_class_map = [];
        centroids = [];
        input_labels = [];
        non_empty_labels_idx = [];
        nlabels = 0;
        training_set = [];
        test_set = [];        
        errors = [];
        nerrors = 0;
        perrors = 0;
        nexternal_labels = 0;
        punknown = 0;
        punknown_test = 0;
    end
    
    properties(GetAccess = 'protected', SetAccess = 'protected')        
        cover_ = [];
        cover_flag_ = [];
    end
    
    methods
        function inst = clustering_results(seg, nc, lbls, train_set, tst_set, next, cstr, cm, ci, ccm, ce, cl)
            inst.segments = seg;
            inst.nclasses = nc;
            inst.input_labels = lbls;
            inst.training_set = train_set;
            inst.test_set = tst_set;
            inst.nexternal_labels = next;            
            inst.nconstraints = cstr;            
            inst.class_map = cm;
            inst.cluster_idx = ci;
            inst.cluster_class_map = ccm;
            inst.nclusters = length(inst.cluster_class_map);            
            inst.centroids = ce;
           
            if nargin > 10
                inst.classes = cl;
            end
            
            % look for non-empty labels
            for i = 1:length(inst.input_labels)
                tmp = inst.input_labels{i};
                if tmp ~= -1
                    inst.non_empty_labels_idx = [inst.non_empty_labels_idx, i];     
                    % in case that we have one label only, and the segment
                    % could not be classified adopt the manual label
                    if length(tmp) == 1 && tmp(1) > 0
                        if inst.class_map(i) == 0
                            inst.class_map(i) = tmp(1);
                        end
                    end
                end
            end
            if ~isempty(inst.class_map)
                inst.punknown = sum(inst.class_map == 0) / length(inst.class_map);
            end
            inst.nlabels = length(inst.non_empty_labels_idx); 
            
            if ~isempty(inst.class_map)
                inst.punknown_test = sum(inst.class_map(inst.non_empty_labels_idx(inst.test_set == 1)) == 0) / sum(inst.test_set);
            end            
            
            % show wrongly classified trajectories
            n = 0;
            inst.errors = zeros(1, inst.nlabels);
            for i = 1:inst.nlabels
                if tst_set(i) ~= 1
                    continue;
                end
                idx = inst.non_empty_labels_idx(i);
                tmp = inst.input_labels{idx};
                if tmp ~= -1                  
                    n = n + 1;
                    if inst.class_map(idx) ~= 0 && ~any(tmp == inst.class_map(idx))
                        inst.errors(i) = 1;  
                    end
                end
            end     
            inst.nerrors = sum(inst.errors);
            if n > 0
                inst.perrors = inst.nerrors / n;            
            end
        end
                        
        function res = entropy(inst)
            % TODO: have to fix the clustering function to deal with
            % multiple labels per element
            res = clustering_entropy(inst.nclusters, inst.cluster_idx(inst.non_empty_labels_idx), inst.nclasses, inst.input_labels(inst.non_empty_labels_idx));
        end
        
        function res = purity(inst)
            % TODO: have to fix the clustering function to deal with
            % multiple labels per element
            res = clustering_purity(inst.nclusters, inst.cluster_idx(inst.non_empty_labels_idx), inst.input_labels(inst.non_empty_labels_idx));
        end
        
        function res = confusion_matrix(inst)
            res = confusion_matrix(inst.input_labels(inst.non_empty_labels_idx(inst.test_set == 1)), inst.class_map(inst.non_empty_labels_idx(inst.test_set == 1)), inst.nclasses);
        end   
        
        % Allows to perform a non-standard mapping from clusters to classes
        % (e.g. for testing purposes). See global function custer_to_class
        % for possible parameters
        function res = remap_clusters(inst, varargin)
            % new cluster to class mappping
            map = cluster_to_class( ...
                arrayfun( @(ci) sum(inst.cluster_idx == ci), ...
                1:inst.nclusters), ...
                inst.input_labels(inst.non_empty_labels_idx(inst.training_set == 1)), ...
                inst.cluster_idx(inst.non_empty_labels_idx(inst.training_set == 1)), ...
                varargin{:} ... % non-default parameters are forwarded here
            );

            % remap elements
            idx = zeros(1, length(inst.cluster_idx));
            for i = 1:inst.nclusters
                sel = find(inst.cluster_idx == i);        
                if ~isempty(sel)
                    idx(sel) = map(i);
                end
            end
                          
            res = clustering_results( ...
                inst.segments, ...
                inst.nclasses, ...
                inst.input_labels, ...                
                inst.training_set, ...
                inst.test_set, ...
                inst.nexternal_labels, ...            
                inst.nconstraints, ...
                idx, ...
                inst.cluster_idx, ...
                map, ...
                inst.nclusters, ...
                inst.centroids);       
        end
        
        % This combines individual segment tags returned from the function
        % above into a single distribution per trajectory
        function [distr, ext_distr] = classes_distribution(inst, partitions, varargin)
            % neeed the process_options function
            addpath(fullfile(fileparts(mfilename('fullpath')), '/extern'));
            [normalize, ext_vals, empty_class, max_seg, reverse, ovlp, slen] = process_options(varargin, ...
                'Normalize', 0, 'ExternalValues', [], 'EmptyClass', 0, ... 
                'MaxSegments', 0, 'Reverse', 0, 'Overlap', 0, 'SegmentLength', 0 ...
            );
                                
            distr = [];
            ext_distr = [];            
            % number of classes
            if empty_class > 0
                nc = length(unique([1:inst.nclasses, empty_class]));
            else
                nc = inst.nclasses;
            end
            % number of external labels (not in this set of
            % trajectories/segments)
            next = inst.nexternal_labels;
            nt = 1; % trajectory number           
            ns = 0; % segment number 
                
            distr = zeros(length(partitions), nc);
            if ~isempty(ext_vals)
                ext_distr = zeros(length(partitions), nc);
            end    
            
            if ovlp > 0
                % both overlap and segment lenghts have to provided                
                assert( slen > 0 ) ;
                nbin = ceil(slen / ovlp);
                distr_traj = zeros(1, nc);
            end                
                      
            map = inst.mapping_ordered;
            if reverse
                map = map(end:-1:1);
                partitions = partitions(end:-1:1);
                ext_vals = ext_vals(end:-1:1);
            end
            
            for i = (next + 1):length(map)
                if ns >= partitions(nt)
                    ns = 0;                        
                    if partitions(nt) == 0
                        % do we have a default class ?                        
                        if empty_class > 0
                            distr(nt, empty_class) = 1;
                        end
                        nt = nt + 1;
                        continue;
                    else
                        if ovlp > 0
                            for j = 1:size(distr_traj, 1)
                                v = max(distr_traj(j, :));                                    
                                if v > 0
                                    % allow for more than one maximum
                                    p = find(distr_traj(j, :) == v);
                                    distr(nt, p) = distr(nt, p) + 1 / length(p);
                                end
                            end                            
                        end
                    end
                    if ovlp > 0
                        distr_traj = zeros(1, nc);
                    end
                    nt = nt + 1;
                end
                
                if map(i) ~= 0
                    if max_seg == 0 || ns <= max_seg
                        if ovlp == 0                        
                            distr(nt, map(i)) = distr(nt, map(i)) + 1;
                    
                            if ~isempty(ext_vals)
                                ext_distr(nt, map(i)) = ext_distr(nt, map(i)) + ext_vals(i);
                            end
                        else                           
                            for j = ns:(ns + nbin) 
                                distr_traj(j, map(i)) = distr_traj(j, map(i)) + 1;
                            end
                        end
                    end
                end
                ns = ns + 1;
            end
            
            if normalize
                distr= distr ./ repmat(sum(distr, 2) + (sum(distr, 2) == 0)*1e-5, 1, nc);
            end
            
            if reverse
                % un-reverse distribution
                distr = distr(end:-1:1, :);
                if ~isempty(ext_distr)
                    ext_distr = ext_distr(end:-1:1, :);
                end
            end
        end
        
        function [cover, cov_flag] = coverage(inst)
            if isempty(inst.cover_)
                id = [-1, -1, -1];
                inst.cover_flag_ = zeros(1, inst.segments.count); 
                % last _classified_ segment
                last_idx = 0;
                last_end = 0;           
                for i = 1:inst.segments.count
                    if ~isequal(id, inst.segments.items(i).data_identification)
                        id = inst.segments.items(i).data_identification;
                        % different trajectory
                        last_idx = 0;
                    end

                    % do we have a classified segment ?
                    if inst.class_map(i) > 0
                        % this segment is classified
                        off = inst.segments.items(i).offset;
                        seg_end = inst.segments.items(i).compute_feature(features.LENGTH) + off;
                        inst.cover_flag_(i) = 1;
                        if last_idx > 0 && last_end >= off
                            % mark every segment in between as covered
                            for j = (last_idx + 1):i
                                inst.cover_flag_(j) = 1;
                            end
                        end
                        last_end = seg_end;
                        last_idx = i;
                    end                
                end     
                inst.cover_ = sum(inst.cover_flag_) / inst.segments.count;
            end
            cover = inst.cover_;
            cov_flag = inst.cover_flag_;
        end
        
        % TODO: (tiago) remove this and replace by classes_mapping_ordered;
        % The should do the same but somehow I broke the other function ...
        % need to investigate
        function [major_classes, full_distr] = mapping_time(inst, bins, varargin)        
            % compute the prefered strategy for a small time window for each
            % trajectory
            addpath(fullfile(fileparts(mfilename('fullpath')), '/extern'));
            
            [classes, discard_unk, class_w, min_seg] = process_options(varargin, ...
                'Classes', [], 'DiscardUnknown', 1, 'ClassesWeights', [], 'MinSegments', 1);
          
            [~, ~, seg_class] = inst.mapping_ordered('Classes', classes, 'DiscardUnknown', discard_unk, 'ClassesWeights', class_w, 'MinSegments', min_seg);
            
            nbins = length(bins);
            
            if isempty(classes)
                map = 1:inst.nclasses;
                nclasses = inst.nclasses;
            else
                map = tag.mapping(classes, inst.classes);
                nclasses = length(classes);
            end
            
            if nargout > 1
                full_distr = {};
            end
            major_classes = [];
                
            tbins = [0, cumsum(bins)];
    
            id = [-1, -1, -1];
            class_distr_traj = [];
            unk = [];
            for i = 1:inst.segments.count    
                if ~isequal(id, inst.segments.items(i).data_identification)
                    id = inst.segments.items(i).data_identification;
                    % different trajectory
                    if ~isempty(class_distr_traj)
                        if nargout > 1
                            tmp = class_distr_traj;
                            tmp(tmp(:) == -1) = 0;
                            nrm = repmat(sum(tmp, 2) + 1e-6 + unk', 1, nclasses);
                            nrm(class_distr_traj == -1) = 1;
                            class_distr_traj = class_distr_traj ./ nrm;
                            full_distr = [full_distr, class_distr_traj];
                        end         
                        % take only the most frequent class for each
                        % bin and trajectory                            
                        traj_distr = zeros(1, nbins);
                        % for each window select the most common class
                        for j = 1:nbins
                            [val, pos] = max(class_distr_traj(j, :));                
                            if val > 0
                                if unk(j) > val && ~discard_unk
                                    traj_distr(j) = 0;
                                else
                                    traj_distr(j) = pos;
                                end
                            else
                                if inst.segments.items(i - 1).end_time < tbins(j)
                                    traj_distr(j) = -1;
                                else
                                    traj_distr(j) = 0;
                                end
                            end
                        end
                        major_classes = [major_classes; traj_distr];                        
                    end  
                    class_distr_traj = ones(nbins, nclasses)*-1;
                    unk = zeros(1, nbins);
                end

                % first and last time window that this segment crosses  
                ti = inst.segments.items(i).start_time;
                tf = inst.segments.items(i).end_time;

                wi = -1;
                wf = -1;
                for j = 1:nbins
                    if ti >= tbins(j) && ti <= tbins(j + 1)
                        wi = j;
                    end
                    if tf >= tbins(j) && tf <= tbins(j + 1)
                        wf = j;
                        break;
                    end
                end

                % for each one of them increment class count        
                for j = wi:wf 
                    if seg_class(i) > 0
                        col = map(seg_class(i));                    
                        if class_distr_traj(j, col) == -1
                            class_distr_traj(j, col) = 1;
                        else
                            class_distr_traj(j, col) = class_distr_traj(j, col) + 1;
                        end
                    elseif ~discard_unk
                        unk(j) = unk(j) + 1;                        
                    end                
                end
            end
        
            % final trajectory
            if ~isempty(class_distr_traj)
                if nargout > 1
                    tmp = class_distr_traj;
                    tmp(tmp(:) == -1) = 0;
                    nrm = repmat(sum(tmp, 2) + 1e-6, 1, nclasses);
                    nrm(class_distr_traj == -1) = 1;
                    class_distr_traj = class_distr_traj ./ nrm;
                    full_distr = [full_distr, class_distr_traj];                       
                end
                traj_distr = zeros(1, nbins);
                % for each window select the most common class
                for j = 1:nbins
                    [val, pos] = max(class_distr_traj(j, :));    
                    if val > 0
                        traj_distr(j) = pos;
                    else
                        if inst.segments.items(i - 1).end_time < tbins(j)
                            traj_distr(j) = -1;
                        else
                            traj_distr(j) = 0;
                        end
                    end
                end
                major_classes = [major_classes; traj_distr];
            end         
        end
        
        function [major_classes, full_distr, seg_class] = mapping_ordered(inst, varargin)        
            % compute the prefered strategy for a small time window for each
            % trajectory
            addpath(fullfile(fileparts(mfilename('fullpath')), '/extern'));
            [classes, discard_unk, class_w, min_seg] = process_options(varargin, ...
                'Classes', [], 'DiscardUnknown', 1, 'ClassesWeights', [], 'MinSegments', 1);
          
            seg_class = zeros(1, length(inst.class_map));
            % binning is done for each segment
            nbins = max(inst.segments.partitions);                   
            
            if isempty(classes)
                map = 1:inst.nclasses;
                nclasses = inst.nclasses;
                if isempty(class_w)                
                    class_w = arrayfun( @(x) x.weight, inst.classes);
                end            
            else
                map = tag.mapping(classes, inst.classes);
                nclasses = length(classes);
                if isempty(class_w)                
                    class_w = arrayfun( @(x) x.weight, classes);
                end            
            end
            
            if nargout > 1
                full_distr = {};
            end
            major_classes = [];
                            
            id = [-1, -1, -1];
            class_distr_traj = [];
            unk = [];
            iseg = 0;
            for i = 1:inst.segments.count    
                if ~isequal(id, inst.segments.items(i).data_identification)
                    id = inst.segments.items(i).data_identification;
                    % different trajectory
                    if ~isempty(class_distr_traj)
                        if nargout > 1
                            tmp = class_distr_traj;
                            tmp(tmp(:) == -1) = 0;
                            nrm = repmat(sum(tmp, 2) + 1e-6 + unk', 1, nclasses);
                            nrm(class_distr_traj == -1) = 1;
                            class_distr_traj = class_distr_traj ./ nrm;
                            full_distr = [full_distr, class_distr_traj];
                        end         
                        % take only the most frequent class for each
                        % bin and trajectory                            
                        traj_distr = zeros(1, nbins);
                        for j = 1:nbins
                            [val, pos] = max(class_distr_traj(j, :));                
                            if val > 0
                                if unk(j) > val && ~discard_unk
                                    traj_distr(j) = 0;
                                else
                                    traj_distr(j) = pos;                                    
                                end
                            else
                                if j > iseg
                                    traj_distr(j) = -1;
                                else
                                    traj_distr(j) = 0;
                                end                                
                            end
                        end
                        major_classes = [major_classes; traj_distr];                        
                    end  
                    class_distr_traj = ones(nbins, nclasses)*-1;
                    unk = zeros(1, nbins);
                    iseg = 0;
                end
                iseg = iseg + 1;

                wi = iseg;
                wf = iseg;
                xf = inst.segments.items(i).offset + inst.segments.items(i).compute_feature(features.LENGTH);
                for j = (i + 1):inst.segments.count
                    if ~isequal(id, inst.segments.items(j).data_identification) || inst.segments.items(j).offset > xf
                        wf = iseg - 1 + j - i - 1;
                        break;
                    end
                end                    
                                
                % for each one of them increment class count        
                m = (wi + wf) / 2; % mid-point
                 for j = wi:wf 
                    if inst.class_map(i) > 0
                        col = map(inst.class_map(i));                                            
                        val = class_w(col)*exp(-(j - m)^2/(2*4));
                        if class_distr_traj(j, col) == -1
                            class_distr_traj(j, col) = val;
                        else
                            class_distr_traj(j, col) = class_distr_traj(j, col) + val;
                        end
                    elseif ~discard_unk
                        unk(j) = unk(j) + 1;                        
                    end                
                end
            end
        
            % final trajectory
            if ~isempty(class_distr_traj)
                if nargout > 1
                    tmp = class_distr_traj;
                    tmp(tmp(:) == -1) = 0;
                    nrm = repmat(sum(tmp, 2) + 1e-6, 1, nclasses);
                    nrm(class_distr_traj == -1) = 1;
                    class_distr_traj = class_distr_traj ./ nrm;
                    full_distr = [full_distr, class_distr_traj];                       
                end
                traj_distr = zeros(1, nbins);
                   
                % for each window select the most common class
                for j = 1:nbins
                    [val, pos] = max(class_distr_traj(j, :));    
                    if val > 0
                        traj_distr(j) = pos;
                    else
                        if j > iseg
                            traj_distr(j) = -1;
                        else
                            traj_distr(j) = 0;
                        end                        
                    end                    
                end
                major_classes = [major_classes; traj_distr];
            end      
            
            % remove spurious segments (or "smooth" the data)
            if min_seg > 1
               for i = 1:size(major_classes, 1)
                  j = 1;
                  lastc = -1;
                  lasti = 0;
                  while(j <= size(major_classes, 2) && major_classes(i, j) ~= -1)
                     if lastc == -1
                        lastc = major_classes(i, j);
                        lasti = j;
                     elseif major_classes(i, j) ~= lastc
                        if (j - lasti) < min_seg && lastc ~= 0                                                       
                            if lasti > 1
                                % find middle point
                                m = floor( (j + lasti) / 2);
                                major_classes(i, lasti:m) = major_classes(i, lasti - 1);                                
                                major_classes(i, m + 1:j) = major_classes(i, j);                                
                            else
                           %     major_classes(i, 1:j) = major_classes(i, j);
                           %     seg_class(seg_off + 1:seg_off + j) = major_classes(i, j);
                            end
                            
                        end
                        lastc = major_classes(i, j);
                        lasti = j;
                     end                     
                     j = j + 1;
                  end
               %   if (j - lasti) < min_seg && lastc ~= 0
               %     major_classes(i, lasti:(j - 1)) = major_classes(i, lasti - 1);
               %     seg_off = sum(part(1:i - 1));                            
               %     seg_class(seg_off + 1:seg_off + i - 1) = major_classes(i, lasti - 1);
               %   end
               end               
            end
            
            % re-map distribution to the flat list of segments
            off = 1;
            traj_off = 1;
            part = inst.segments.partitions;
            part = part(part > 0);
            for i = 1:length(part)
                if part(i) > 0                    
                    seg_class(off:off + part(i) - 1) = major_classes(i, 1:part(i));                    
                end
                off = off + part(i);
            end
        end
        
        function [diff_set] = difference(inst, other_results, varargin)
            % current segment in the original set
               % trajectory
            addpath(fullfile(fileparts(mfilename('fullpath')), '/extern'));
            [tolerance] = process_options(varargin, ...
                'SegmentTolerance', 20);
         
            mapping = inst.segments.match_segments(other_results.segments, tolerance);
            tag_mapping = tag.mapping(inst.classes, other_results.classes);
            
            diff_set = ones(1, inst.segments.count)*-1;
            for k = 1:inst.segments.count          
                if (mapping(k) > 0)
                    if inst.class_map(k) > 0 && other_results.class_map(mapping(k)) > 0
                        otherc = tag_mapping(other_results.class_map(mapping(k)));
                        if inst.class_map(k) == otherc
                            diff_set(k) = 0;
                        else
                            diff_set(k) = otherc;
                        end
                    elseif inst.class_map(k) == 0 && other_results.class_map(mapping(k)) == 0
                        diff_set(k) = 0;
                    end                    
                end
            end
        end
        
        function [out] = combine(inst, other_results, varargin)
            % current segment in the original set
               % trajectory
            addpath(fullfile(fileparts(mfilename('fullpath')), '/extern'));
            [tolerance] = process_options(varargin, ...
                'SegmentTolerance', 20);
         
            mapping = inst.segments.match_segments(other_results.segments, tolerance);
            tag_mapping = tag.mapping(inst.classes, other_results.classes);
            
            new_map = inst.class_map;
            for k = 1:inst.segments.count          
                if mapping(k) > 0
                    otherc = other_results.class_map(mapping(k));
                    if otherc > 0                        
                        if inst.class_map(k) > 0
                            if inst.class_map(k) ~= tag_mapping(otherc)
                                % invalidate this one
                                new_map(k) = 0;
                            end
                        else
                            % take the other classification's class
                            new_map(k) = tag_mapping(otherc);
                        end
                    end
                end
            end           
            
            out = clustering_results( ...
                inst.segments, ...
                inst.nclasses, ...
                [], ...                
                [], ...
                [], ...
                0, ...            
                0, ...
                new_map, ...
                [], ...
                [], ...
                0, ...
                inst.classes);       
             
        end
    end    
end