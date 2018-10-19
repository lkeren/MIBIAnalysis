classdef Point < handle
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        point_path
        path_ext
        counts
        labels
        tags
        % for denoising
        int_norm_d
        k_values
        count_hist
        status
        loaded
    end
    
    methods
        function obj = Point(point_path, len)
            % note: it is assumed that the order of counts will correspond
            % to the labels.
            obj.point_path = point_path;
            [obj.counts, obj.labels, obj.tags, obj.path_ext] = loadTIFF_data(point_path);
            [path, name, ~] = fileparts(point_path);
            name = [path, filesep, name];
            name = strsplit(name, filesep);
            try
                name = name((end-len+1):end);
            catch
                % do nothing
            end
            obj.name = strjoin(name, filesep);
            obj.checkAllLabelsUnique();
            
            obj.int_norm_d = containers.Map;
            obj.count_hist = containers.Map;
            obj.k_values = [];
            for i=1:numel(obj.labels)
                obj.k_values(i) = -1;
            end
            obj.status = 0;
            obj.loaded = 0;
        end
        
        function check = checkAllLabelsUnique(obj)
            if numel(unique(obj.labels))==numel(obj.labels)
                check = true;
            else
                check = false;
                warning('NOT ALL LABELS ARE UNIQUE')
            end
        end
        
        function obj = knn(obj, label, k_value)
            if ischar(label)
                label_index = find(strcmp(obj.labels, label));
            else
                label_index = label;
            end
            label = obj.labels{label_index};
            if isempty(label_index)
                error([label, ' not found in labels']);
            else
                if k_value~=obj.k_values(label_index)
                    obj.int_norm_d(label) = MIBI_get_int_norm_dist(obj.counts(:,:,label_index), k_value);
                    hedges = 0:0.25:30;
                    obj.count_hist(label) = histcounts(obj.int_norm_d(label), hedges, 'Normalization', 'probability');
                    obj.k_values(label_index) = k_value;
                end
            end
        end
        
        function [int_norm_d, k_val] = get_IntNormD(obj, label)
            try
                int_norm_d = obj.int_norm_d(label);
            catch
                int_norm_d = [];
            end
            label_index = find(strcmp(label, obj.labels));
            k_val = obj.k_values(label_index);
        end
        
        function count_hist = get_countHist(obj, label)
            try
                count_hist = obj.count_hist(label);
            catch
                count_hist = [];
            end
        end
        
        function loadstatus = get_label_loadstatus(obj)
            loadstatus = zeros(size(obj.labels));
            for i=1:numel(obj.labels)
                if ~isequaln(obj.int_norm_d(obj.labels(i)), [])
                    loadstatus(i) = 1;
                end
            end
        end
        
        function obj = flush_all_data(obj)
            for i=1:numel(obj.labels)
                obj.k_values(i) = -1;
                obj.int_norm_d(obj.labels{i}) = [];
                obj.count_hist(obj.labels{i}) = [];
            end
        end
        
        function obj = flush_labels(obj, label_indices)
            for i=label_indices
                obj.k_values(i) = -1;
                obj.int_norm_d(obj.labels{i}) = [];
                obj.count_hist(obj.labels{i}) = [];
            end
        end
        
        function save_no_background(obj)
            global pipeline_data;
            bgChannel = pipeline_data.bgChannel;
            gausRad = pipeline_data.gausRad;
            t = pipeline_data.t;
            removeVal = pipeline_data.removeVal;
            capBgChannel = pipeline_data.capBgChannel;
            capEvalChannel = pipeline_data.capEvalChannel;
            [~,bgChannelInd] = ismember(bgChannel,obj.labels);
            mask = MIBI_get_mask(obj.counts(:,:,bgChannelInd),capBgChannel,t,gausRad,0,'');
            countsNoBg = gui_MibiRemoveBackgroundByMaskAllChannels(obj.counts,mask,removeVal);
            
            path_parts = strsplit(obj.point_path, filesep);
            path_parts{end-1} = 'no_background';
            new_path = strjoin(path_parts, filesep);
            if ~isempty(obj.path_ext)
                new_path = [new_path, filesep, obj.path_ext];
            end
            disp(['Saving to ', new_path])
            saveTIFF_folder(obj.counts, obj.labels, obj.tags, new_path);
        end
        
        function save_no_noise(obj)
            
        end
    end
end

