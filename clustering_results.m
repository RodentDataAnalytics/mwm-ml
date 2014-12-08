classdef clustering_results
    % CLUSTERING_RESULTS Stores results of the clustering
    
    properties(GetAccess = 'public', SetAccess = 'protected')    
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
    
    methods
        function inst = clustering_results(nc, lbls, train_set, tst_set, next, cstr, cm, ci, ccm, ce, cl)
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
            if ~isempty(inst.class_map)
                inst.punknown = sum(inst.class_map == 0) / length(inst.class_map);
            end
            if nargin > 10
                inst.classes = cl;
            end
            
            % look for non-empty labels
            for i = 1:length(inst.input_labels)
                tmp = inst.input_labels{i};
                if tmp ~= -1
                    inst.non_empty_labels_idx = [inst.non_empty_labels_idx, i];                    
                end
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
            res = confusion_matrix(inst.input_labels(inst.non_empty_labels_idx(inst.test_set)), inst.class_map(inst.non_empty_labels_idx(inst.test_set)), inst.nclasses);
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
            [normalize, ext_vals, empty_class, max_seg, reverse] = process_options(varargin, ...
                'Normalize', 0, 'ExternalValues', [], 'EmptyClass', 0, 'MaxSegments', 0, 'Reverse', 0 ...
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
            
            if reverse
                map = inst.class_map(end:-1:1);
                partitions = partitions(end:-1:1);
                ext_vals = ext_vals(end:-1:1);
            else
                map = inst.class_map;
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
                    end          
                    nt = nt + 1;
                end
                
                if map(i) ~= 0
                    if max_seg == 0 || ns <= max_seg
                        distr(nt, map(i)) = distr(nt, map(i)) + 1;
                    
                        if ~isempty(ext_vals)
                            ext_distr(nt, map(i)) = ext_distr(nt, map(i)) + ext_vals(i);
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
        
    end    
end