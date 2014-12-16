classdef trajectories < handle
    %TRAJECTORIES Summary of this class goes here
    %   Detailed explanation goes here
    properties(GetAccess = 'public', SetAccess = 'public')
        % use two-phase clustering
        clustering_two_phase = 1;
        % force use of must link constraints in the first phase
        clustering_must_link = 0;
    end
    
    properties(GetAccess = 'public', SetAccess = 'protected')
        items = [];        
    end
    
    properties(GetAccess = 'protected', SetAccess = 'protected')
        hash_ = -1;
        trajhash_ = [];
    end
    
    methods
        % constructor
        function inst = trajectories(traj)
            inst.items = traj;
            trajectories.load_cache;            
        end
               
        function sz = count(obj)
            sz = length(obj.items);            
        end          
        
        function obj2 = append(obj, x)
            obj2 = trajectories([]);    
            if isa(x, 'trajectory')
                obj2.items = [obj.items, x];
            elseif isa(x, 'trajectories')
                obj2.items = [obj.items, x.items];
            else
                error('Ops');
            end
        end    
        
        function idx = index_of(obj, set, trial, track, off, len)
            if isempty(obj.trajhash_ )
               % compute hashes of trajectories and add them to a hashtable               
               obj.trajhash_ = containers.Map(arrayfun( @(t) t.hash_value, obj.items), 1:obj.count);
            end
            
            hash = trajectory.compute_hash(set, trial, track, off, len);
            % do we have it?
            if obj.trajhash_.isKey(hash)
                idx = obj.trajhash_(hash);
            else
                idx = -1;
            end            
        end            
        
        function out = hash_value(obj)            
            if obj.hash_ == -1                                          
                % compute hash
                if obj.count == 0
                    obj.hash_ = 0;
                else
                    obj.hash_ = obj.items(1).hash_value;
                    for i = 2:obj.count                        
                        obj.hash_ = hash_combine(obj.hash_, obj.items(i).hash_value);
                    end
                end                
            end
            out = obj.hash_;
        end
        
        function [ segments, partition, cum_partitions ] = divide_into_segments(obj, lseg, ovlp, nmin)
        %   SEGMENT(LSEG, OVLP) breaks all trajectories into segments
        %   of length LEN and overlap OVL (given in %)   
        %   returns an array of trajectory segments
            fprintf('Segmenting trajectories... ');
            % construct new object
            segments = trajectories([]);
            partition = zeros(1, obj.count);
            cum_partitions = zeros(1, obj.count);
            p = 1;
            off = 0;
            for i = 1:obj.count
                newseg = obj.items(i).divide_into_segments(lseg, ovlp);
                if newseg.count >= nmin                    
                    segments = segments.append(newseg);
                    partition(i) = newseg.count;
                    cum_partitions(i) = off;
                    off = off + newseg.count;
                else
                    cum_partitions(i) = off;
                end
                
                if segments.count > p*1000
                    fprintf('%d ', segments.count);
                    p = p + 1;
                end
            end

            fprintf(': %d segments created.\n', segments.count);
        end
        
        function out = remove_outliers(obj, feat, k, n)
            global g_feature_values_cache;            
            global g_outliers_cache;
            
            % check if we already have the values cached
            key = hash_combine(obj.hash_value, hash_value(feat));
            key = hash_combine(key, k);
            key = hash_combine(key, n);
                        
            if isempty(g_outliers_cache) || ~g_outliers_cache.isKey(key)  
                % get features
                feat_val = obj.compute_features(feat);
                        
                out = top_outliers(feat_val, k, n, 1);
                no_idx = setdiff(1:size(feat_val, 1), out);
                feat_val = feat_val(no_idx, :);
                
                if isempty(g_outliers_cache)
                    g_outliers_cache = containers.Map('KeyType','uint32', 'ValueType','any');
                end  
                g_outliers_cache(key) = no_idx;                                
                
                % trash old cached data, this changed now
                obj.hash_ = -1;
                obj.trajhash_ = [];
            
                % also cache new feature values            
                key2 = hash_combine(obj.hash_value, hash_value(feat));
                if isempty(g_feature_values_cache)
                    g_feature_values_cache = containers.Map('KeyType','uint32', 'ValueType','any');
                end            
                g_feature_values_cache(key2) = feat_val;
                trajectories.save_cache;
            end
            
            obj.hash_ = -1;
            obj.trajhash_ = [];            
            obj.items = obj.items(g_outliers_cache(key));                                            
            out = g_outliers_cache(key);            
        end
        
        function V = compute_features(obj, feat)
            %COMPUTE_FEATURES Computes feature values for each trajectory/segment. Returns a vector of
            %   features.
            
            % cache feature values            
            global g_feature_values_cache;
                        
            % check if we already have the values cached
            key = hash_combine(obj.hash_value, hash_value(feat));
            
            if isempty(g_feature_values_cache) || ~g_feature_values_cache.isKey(key)                                        
            	% compute it we shall
                fprintf('Computing feature set for %d trajectories/segments...', obj.count);
                featval = zeros(obj.count, length(feat));
                
                q = floor(obj.count / 1000);
                fprintf('0.0% '); 
                
                for i = 1:obj.count
                    % compute and append feature values for each segment
                    featval(i, :) = obj.items(i).compute_features(feat);

                    if mod(i, q) == 0
                        val = 100.*i/obj.count;
                        if val < 10.
                            fprintf('\b\b\b\b\b%02.1f%% ', val);
                        else
                            fprintf('\b\b\b\b\b%04.1f%%', val);
                        end    
                    end                       
                end
                
                fprintf('\b\b\b\b\bDone.\n');
                if isempty(g_feature_values_cache)
                    g_feature_values_cache = containers.Map('KeyType','uint32', 'ValueType','any');
                end
                g_feature_values_cache(key) = featval;
                trajectories.save_cache;
            end    
                
            % return it
            V = g_feature_values_cache(key);                            
            assert( size(V, 1) == obj.count );
        end

        function save_tags(obj, fn, tags, map, filter)
            %SAVE_TAGS Summary of this function goes here
            %   Detailed explanation goes here            
            if isempty(filter)
                 filter = 1:obj.count;
            end
            fid = fopen(fn, 'w');
            for i = 1:length(filter)  
                if sum(map(i, :)) > 0 % is there anything to be written?
                    % we have something to write
                    data_id = obj.items(filter(i)).data_identification;
                    id = obj.items(filter(i)).identification;
                    if id(4) == -1 % full trajectory ?
                        d = -1; % offset
                        l = 0; % len
                    else % a segment -> use real values for offset/length
                        d = floor(obj.items(filter(i)).offset); % take only the integer part
                        l = floor(obj.items(filter(i)).compute_feature(features.LENGTH)); % idem, only integer part
                    end
                    
                    % store set,session,track#,offset,length
                    str = sprintf('%d,%d,%d,%d,%d', data_id(1), data_id(2), data_id(3), d, l);
                    for j = 1:length(tags)
                        if map(i, j) == 1
                            str = strcat(str, sprintf(',%s', tags(j).abbreviation));
                        end
                    end                
                    fprintf(fid, '%s\n', str);
                end
            end
            fclose(fid);
        end              
        
        function [map, idx, tag_map] = match_tags(obj, labels, tags, sel_tags)
            % start with an empty set
            map = zeros(obj.count, length(tags));
            idx = repmat(-1, 1, length(labels));
                                
            % for each label
            for i = 1:size(labels, 1)
                % see if we have this trajectory/segment
                id = labels{i, 1};
                pos = obj.index_of(id(1), id(2), id(3), id(4), id(5));
                if pos ~= -1
                    idx(i) = pos;
                    % add labels        
                    tmp = labels{i, 2};
                    for k = 1:length(tmp)
                        map(pos, tmp(k)) = 1;                        
                    end                    
                end                
            end 
            
            if nargin > 3
                tag_map = zeros(1, length(tags));
                % remap labels
                new_map = zeros(length(map), length(sel_tags));                
                for i = 1:length(tags)
                    tag_map(i) = 0; % default = no mapping
                    for j = 1:length(sel_tags)
                        if sel_tags(j).matches(tags(i).abbreviation)
                            tag_map(i) = j;
                            new_map(:, j) = new_map(:,j) | map(:, i);
                            break;
                        end
                    end
                end
                % replace tags with new selection
                map = new_map;
            else
                tag_map = 1:length(tags);
            end
        end          
        
        function res = classifier(inst, labels_fn, feat, tags_type, hyper_tags)
            if nargin > 3
                [labels_data, tags] = trajectories.read_tags(labels_fn, tags_type);            
            else
                [labels_data, tags] = trajectories.read_tags(labels_fn);                            
            end
            
            if nargin > 4 && ~isempty(hyper_tags)            
                [labels_map, labels_idx] = inst.match_tags(labels_data, tags, hyper_tags);
                tags = hyper_tags;
            else
                [labels_map, labels_idx] = inst.match_tags(labels_data, tags);                
            end                
            
            % add the 'undefined' tag index
            undef_tag_idx = tag.tag_position(tags, g_config.UNDEFINED_TAG_ABBREVIATION);
            if undef_tag_idx > 0
                tags = tags([1:undef_tag_idx - 1, (undef_tag_idx + 1):length(tags)]);          
                tag_new_idx = [1:undef_tag_idx, undef_tag_idx:length(tags)];
                tag_new_idx(undef_tag_idx) = 0;
            else
                tag_new_idx = 1:length(tags);
            end
            
            assert(size(labels_map, 1) == inst.count);
            labels = repmat({-1}, 1, inst.count);
            for i = 1:inst.count
                class = find(labels_map(i, :) == 1);
                if ~isempty(class)
                    % for the 'undefined' class set label idx to zero..
                    if class(1) == undef_tag_idx
                        labels{i} = 0;
                    else
                        % rebase all tags after the undefined index
                        labels{i} = arrayfun( @(x) tag_new_idx(x), class);
                    end                                       
                end
            end
                         
            global g_trajectories;            
            unmatched = find(labels_idx == -1);
            extra_lbl = {};
            extra_feat = []; 
            extra_ids = [];
            if ~isempty(unmatched)
                % load all trajectories
                cache_trajectories;
            
                for i = 1:length(unmatched)
                    id = labels_data{unmatched(i), 1};
                    % unmatched segments - look at the global trajectories cache               
                    idx = g_trajectories.index_of(id(1), id(2), id(3), -1, 0);                
                    if idx == -1
                        fprintf('Warning: could not match label #%d to any trajectory\n', unmatched(i));
                    else
                        seg = g_trajectories.items(idx).sub_segment(id(4), id(5));
                        extra_feat = [extra_feat; seg.compute_features(feat)];
                        tmp = labels_data{unmatched(i), 2};
                        extra_lbl = [extra_lbl, tag_new_idx(tmp)];
                        extra_ids = [extra_ids; id];
                    end
                end
            end
                                    
            res = semisupervised_clustering([extra_feat; inst.compute_features(feat)], [extra_lbl, labels], tags, length(extra_lbl));            
        end                            
        
        function [major_classes, full_distr] = classes_mapping_time(inst, results, bins, varargin)        
            % compute the prefered strategy for a small time window for each
            % trajectory
            addpath(fullfile(fileparts(mfilename('fullpath')), '/extern'));
            [classes, discard_unk] = process_options(varargin, ...
                'Classes', [], 'DiscardUnknown', 1);
          
            if isvector(bins)
                nbins = length(bins);
            else
                nbins = bins;
                bins = repmat(g_config.TRIAL_TIMEOUT / nbins, 1, nbins);
            end
            
            if isempty(classes)
                map = 1:results.nclasses;
                nclasses = results.nclasses;
            else
                map = tag.mapping(classes, results.classes);
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
            for i = 1:inst.count    
                if ~isequal(id, inst.items(i).data_identification)
                    id = inst.items(i).data_identification;
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
                                if inst.items(i - 1).end_time < tbins(j)
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
                ti = inst.items(i).start_time;
                tf = inst.items(i).end_time;

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
                    if results.class_map(i) > 0
                        col = map(results.class_map(i));                    
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
                        if inst.items(i - 1).end_time < tbins(j)
                            traj_distr(j) = -1;
                        else
                            traj_distr(j) = 0;
                        end
                    end
                end
                major_classes = [major_classes; traj_distr];
            end              
        end
    end
    
    %%
    %% STATIC MEMBERS
    %%
    methods(Static)
        function save_cache
            global g_feature_values_cache;
            global g_outliers_cache;
            
            cache_dir = fullfile(fileparts(mfilename('fullpath')),'/cache');
            if ~exist(cache_dir, 'dir')
                mkdir(cache_dir);
            end
            
            if ~isempty(g_feature_values_cache)
                fn = fullfile(cache_dir,'feature_values.mat');
                save(fn, 'g_feature_values_cache');
            end
            
            if ~isempty(g_outliers_cache)
                fn = fullfile(cache_dir, 'outliers.mat');
                save(fn, 'g_outliers_cache');
            end            
        end
        
        function load_cache
            global g_feature_values_cache;
            global g_outliers_cache;
            
            if isempty(g_feature_values_cache)                          
                fn = fullfile(fileparts(mfilename('fullpath')),'/cache/feature_values.mat');                
                if exist(fn, 'file')
                    load(fn, 'g_feature_values_cache');
                end
            end
            
            if isempty(g_outliers_cache)
                fn = fullfile(fileparts(mfilename('fullpath')),'/cache/outliers.mat');                
                if exist(fn, 'file')
                    load(fn, 'g_outliers_cache');
                end
            end
        end
        
        function purge_cache
            fn = fullfile(fileparts(mfilename('fullpath')),'/cache/feature_values.mat');                
            if exist(fn, 'file')
                delete(fn);
            end
            
            fn = fullfile(fileparts(mfilename('fullpath')),'/cache/outliers.mat');                
            if exist(fn, 'file')
                delete(fn);
            end            
        end            
            
        function [map, tags] = read_tags(fn, tag_type)
            % READ_TAGS(FN, TAG_TYPE)
            %   Reads tags from file FN filtering by tags of type TAG_TYPE only
            %   Tags are sorted according to their score value (if available)
            if ~exist(fn, 'file')
                error('file not found');
            end    
            tags = [];
            % use an 3rd party function to read the file since matlab is unable to
            % parse anything other than a very basicc CSV file (!)
            labels = robustcsvread(fn);
            map = cell([size(labels, 1), 2]);            
            for i = 1:size(labels, 1)
                % set and track numbers
                set = sscanf(labels{i, 1}, '%d');
                day = sscanf(labels{i, 2}, '%d');
                track = sscanf(labels{i, 3}, '%d');
                off = sscanf(labels{i, 4}, '%d');
                len = sscanf(labels{i, 5}, '%d');
                
                lbls_idx = [];
                
                for k = 6:size(labels, 2)
                    if ~isempty(labels{i, k})
                        found = 0;
                        for l = 1:length(tags)
                            if strcmp(tags(l).abbreviation, labels{i, k})
                                found = 1;
                                lbls_idx = [lbls_idx, l];
                                break;
                            end
                        end
                        if ~found                            
                            % add to tags list
                            for l = 1:length(g_config.TAGS)
                                if strcmp(g_config.TAGS(l).abbreviation, labels{i, k})
                                    found = 1;                                        
                                    if nargin < 2 || tag_type == g_config.TAG_TYPE_ALL || g_config.TAGS(l).type == tag_type
                                        tags = [tags, g_config.TAGS(l)];
                                        lbls_idx = [lbls_idx, length(tags)];
                                    end
                                    break;
                                end
                            end     
                            if ~found
                                fprintf('Warning: unknown tag ''%s''\n', labels{i, k});
                            end
                        end
                    end
                end
                
                map{i, 1} = [set, day, track, off, len];
                map{i, 2} = lbls_idx;
            end
            % sort tags
            scores = arrayfun( @(t) t.score, tags);
            [~, ord] = sort(scores);
            tag_per = 1:length(ord);
            tag_per(ord) = 1:length(ord);
            tags = tags(ord);
            for i = 1:length(map)
                lbls = map{i, 2};
                lbls = arrayfun( @(x) tag_per(x), lbls);
                map{i, 2} = lbls; 
            end
        end
    end
end

