classdef PointManager < handle
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        namesToPaths % map from names to paths
        pathsToNames % map from paths to names
        pathsToPoints % map from paths to Points
        % for denoising
        denoiseParams % cell array of denoising params
        channel_load_status
        point_load_status
        % for aggregate removal
        aggRmParams
    end
    
    methods
        function obj = PointManager()
            %UNTITLED3 Construct an instance of this class
            %   Detailed explanation goes here
            obj.namesToPaths = containers.Map;
            obj.pathsToNames = containers.Map;
            obj.pathsToPoints = containers.Map;
            
            obj.denoiseParams = {};
            obj.aggRmParams = {};
        end
        
        % given a path to a Point resource, adds a Point object
        function obj = addPoint(obj, pointPath)
            if ~obj.loaded('path', pointPath)
                try
                    point = Point(pointPath, 3);
                    obj.namesToPaths(point.name) = pointPath;
                    obj.pathsToNames(pointPath) = point.name;
                    obj.pathsToPoints(pointPath) = point;
                catch err
                    warning('Failed to load point');
                    disp(err)
                end
            else
                % do nothing, the point has already been loaded
            end
        end
        
        function obj = add(obj, pointPaths)
            waitfig = waitbar(0, 'Loading TIFF data...');
            for i=1:numel(pointPaths)
                obj.addPoint(pointPaths{i});
                try
                    waitbar(i/numel(pointPaths), waitfig, 'Loading TIFF data...');
                catch
                    waitfig = waitbar(i/numel(pointPaths), 'Loading TIFF data...');
                end
            end
            close(waitfig);
            if ~obj.checkLabelSetEquality()
                warning('Not all loaded points have the same labels!')
            end
            obj.initDenoiseParams();
            obj.initAggRmParams();
        end
        
        function obj = remove(obj, argType, arg)
            if strcmp(argType, 'name')
                if obj.loaded('name', arg)
                    name = arg;
                    path = obj.namesToPaths(name);
                    
                    remove(obj.namesToPaths, name);
                    remove(obj.pathsToNames, path);
                    remove(obj.pathsToPoints, path);
                else
                    warning(['No point with name ', arg, ' found']);
                end
            elseif strcmp(argType, 'path')
                if obj.loaded('path', arg)
                    path = arg;
                    name = obj.pathsToNames(path);
                    
                    remove(obj.namesToPaths, name);
                    remove(obj.pathsToNames, path);
                    remove(obj.pathsToPoints, path);
                else
                    warning(['No point with path ', arg, ' found']);
                end
            else
                error('Invalid argType');
            end
            if isempty(keys(obj.pathsToPoints))
                obj.denoiseParams = {};
            end
        end
        
        % checks if name or path key exists
        function check = loaded(obj, argType, arg)
            if strcmp(argType, 'name')
                if any(strcmp(keys(obj.namesToPaths), arg))
                    path = obj.namesToPaths(arg);
                    if any(strcmp(keys(obj.pathsToPoints), path))
                        check = true;
                    else
                        check = false;
                    end
                else
                    check = false;
                end
            elseif strcmp(argType, 'path')
                if any(strcmp(keys(obj.pathsToPoints), arg))
                    check = true;
                else
                    check = false;
                end
            end
        end
        
        % gets Point object by 
        function point = get(obj, argType, arg)
            if strcmp(argType, 'name')
                try
                    arg = strsplit(tabSplit(arg), char(8197));
                    arg = arg{1};
                    path = obj.namesToPaths(arg);
                    point = obj.pathsToPoints(path);
                catch
                    warning(['No point with name ', arg]);
                    point = [];
                end
            elseif strcmp(argType, 'path')
                try
                    point = obj.pathsToPoints(arg);
                catch
                    warning(['No point with path ', arg])
                    point = [];
                end
            else
                error('Invalid argType');
            end
        end
        
        % returns a cell array of all names of loaded points, sorted in a
        % natural way (thank you Stephen Cobeldick!!!)
        function names = getNames(obj)
            names = keys(obj.namesToPaths);
            try
                names = natsortfiles(names);
            catch err
                names = {};
            end
        end
        
        function obj = togglePointStatus(obj, pointName)
            point_path = obj.namesToPaths(pointName);
            point = obj.pathsToPoints(point_path);
            point.status = ~point.status;
            obj.pathsToPoints(point_path) = point;
        end
        
        function obj = setPointStatus(obj, pointName, status)
            point_path = obj.namesToPaths(pointName);
            point = obj.pathsToPoints(point_path);
            point.status = status;
            obj.pathsToPoints(point_path) = point;
        end
        
        function obj = setPointLoaded(obj, pointName, loaded)
            point_path = obj.namesToPaths(pointName);
            point = obj.pathsToPoints(point_path);
            point.loaded = loaded;
            obj.pathsToPoints(point_path) = point;
        end
        
        function point_text = getPointText(obj)
            names = obj.getNames();
            point_text = cell(size(names));
            for i=1:numel(names)
                status = obj.pathsToPoints(obj.namesToPaths(names{i})).status;
                loaded = obj.pathsToPoints(obj.namesToPaths(names{i})).loaded;
                if status==0 && loaded==0
                            mark = '.';
                    elseif status==0 && loaded==1
                        mark = 'x';
                    elseif status==1 && loaded==0
                        mark = char(9633);
                    elseif status==1 && loaded==1
                        mark = char(9632);
                    else
                        mark = '?';
                end
                point_text{i} = tabJoin({names{i}, mark}, 75);
            end
        end
        
        function labels = labels(obj)
            paths = keys(obj.pathsToPoints);
            if ~isempty(paths)
                labels = obj.pathsToPoints(paths{1}).labels;
            else
                labels = {};
            end
        end
        
        function check = checkLabelSetEquality(obj)
            labels = obj.labels();
            check = true;
            if ~isempty(labels)
                paths = keys(obj.pathsToPoints);
                for i=1:numel(paths)
                    if ~isequal(labels, obj.pathsToPoints(paths{1}).labels)
                        check = false;
                    end
                end
            end
        end
        
        function path = getPath(obj, name)
            if obj.loaded('name', name)
                path = obj.namesToPaths(name);
            else
                err0r(['Point ', name, ' not loaded, no path found'])
            end
        end
        
        function obj = initDenoiseParams(obj)
            if isempty(obj.denoiseParams)
                labels = obj.labels();
                max_name_length = 10;
                for i=1:numel(labels)
                    params = struct();
                    params.threshold = 3.5;
                    params.k_value = 25;
                    params.label = labels{i};
                    params.status = 0;
                    params.loaded = 0;
                    params.display_name = labels{i}(1:(min(max_name_length, end)));
                    obj.denoiseParams{i} = params;
                end
            end
        end
        
        function obj = initAggRmParams(obj)
            if isempty(obj.aggRmParams)
                labels = obj.labels();
                max_name_length = 10;
                for i=1:numel(labels)
                    params = struct();
                    params.threshold = 100;
                    params.radius = 1;
                    params.capImage = 5;
                    params.label = labels{i};
                    params.display_name = labels{i}(1:(min(max_name_length, end)));
                    obj.aggRmParams{i} = params;
                end
            end
        end
        
        function channel_param = getAggRmParam(obj, label_index)
            channel_param = obj.aggRmParams{label_index};
        end
        
        function aggRmParamsText = getAggRmText(obj, varargin)
            if isempty(varargin)
                if ~isempty(obj.aggRmParams)
                    aggRmParamsText = cell(size(obj.labels));
                    for i=1:numel(obj.labels())
                        params = obj.aggRmParams{i};
                        label = params.display_name;
                        threshold = params.threshold;
                        radius = params.radius;
                        capImage = params.capImage;
                        aggRmParamsText{i} = tabJoin({label, num2str(threshold), num2str(radius), num2str(capImage)}, 15);
                    end
                else
                    aggRmParamsText = {};
                end
            end
        end
        
        function obj = setDenoiseParam(obj, label_index, param, varargin)
            if strcmp(param, 'threshold')
                obj.denoiseParams{label_index}.threshold = varargin{1};
            elseif strcmp(param, 'k_value')
                obj.denoiseParams{label_index}.k_value = varargin{1};
            elseif strcmp(param, 'status')
                if numel(varargin)==0
                    obj.denoiseParams{label_index}.status = ~obj.denoiseParams{label_index}.status;
                else
                    obj.denoiseParams{label_index}.status = varargin{1};
                end
            elseif strcmp(param, 'loaded')
                obj.denoiseParams{label_index}.loaded = varargin{1};
            end
        end
        
        function obj = setAggRmParam(obj, label_index, param, varargin)
            if strcmp(param, 'threshold')
                obj.aggRmParams{label_index}.threshold = varargin{1};
            elseif strcmp(param, 'radius')
                obj.aggRmParams{label_index}.radius = varargin{1};
            elseif strcmp(param, 'capImage')
                obj.aggRmParams{label_index}.capImage = varargin{1};
            else
                % what did you do you monster
            end
        end
        
        function channel_param = getDenoiseParam(obj, label_index)
            channel_param = obj.denoiseParams{label_index};
        end
        
        function denoiseParamsText = getDenoiseText(obj, varargin)
            if isempty(varargin)
                if ~isempty(obj.denoiseParams)
                    denoiseParamsText = cell(size(obj.labels()));
                    for i=1:numel(obj.labels())
                        params = obj.denoiseParams{i};
                        
                        label = params.display_name;
                        threshold = params.threshold;
                        k_val = params.k_value;
                        if params.status==0 && params.loaded==0
                            mark = '.';
                        elseif params.status==0 && params.loaded==1
                            mark = 'x';
                        elseif params.status==1 && params.loaded==0
                            mark = char(9633);
                        elseif params.status==1 && params.loaded==1
                            mark = char(9632);
                        elseif params.status==-1
                            mark = '!';
                        else
                            mark = '?';
                        end
                        denoiseParamsText{i} = tabJoin({label, num2str(threshold), num2str(k_val), mark}, 15);
                    end
                else
                    denoiseParamsText = {};
                end
            else
                point_name = varargin{1};
                
            end
        end
        
        function obj = knn(obj, point_name, label, k_value)
            point_path = obj.namesToPaths(point_name);
            point = obj.pathsToPoints(point_path);
            point.knn(label, k_value);
            point.loaded = 1;
            obj.pathsToPoints(point_path) = point;
        end
        
        function point_names = getSelectedPointNames(obj)
            all_point_paths = keys(obj.pathsToPoints);
            point_names = {};
            for i=1:numel(all_point_paths)
                if obj.pathsToPoints(all_point_paths{i}).status == 1
                    point_names{end+1} = obj.pathsToPoints(all_point_paths{i}).name;
                end
            end
        end
        
        function label_indices = getSelectedLabelIndices(obj)
            label_indices = [];
            for i=1:numel(obj.labels())
                if obj.denoiseParams{i}.status == 1
                    label_indices(end+1) = i;
                end
            end
        end
        
        function obj = flush_data(obj)
            flush_indices = [];
            for i=1:numel(obj.denoiseParams)
                if obj.denoiseParams{i}.status==0 && obj.denoiseParams{i}.loaded==1
                    flush_indices(end+1) = i;
                    obj.setDenoiseParam(i, 'loaded', 0);
                end
            end
            % first we look through all points with status==0
            point_paths = keys(obj.pathsToPoints);
            for i=1:numel(point_paths)
                point = obj.pathsToPoints(point_paths{i});
                if point.status==0 && point.loaded==1
                    point.flush_all_data();
                    point.loaded = 0;
                    obj.pathsToPoints(point_paths{i}) = point;
                elseif point.status==1
                    point.flush_labels(flush_indices);
                    obj.pathsToPoints(point_paths{i}) = point;
                end
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
            
            point_paths = keys(obj.pathsToPoints);
            if numel(point_paths)>=1
                [logpath, ~, ~] = fileparts(point_paths{1});
                [logpath, ~, ~] = fileparts(logpath);
                logpath = [logpath, filesep, 'no_background'];
                mkdir(logpath)
                timestring = strrep(datestr(datetime('now')), ':', char(720));
                fid = fopen([logpath, filesep, '[', timestring, ']_background_removal.log'], 'wt');
                fprintf(fid, 'background channel: %s\nbackground cap: %f\nevaluation cap: %f\ngaussian radius: %f\nthreshold: %f\nremove value: %f\n\n', bgChannel, capBgChannel, capEvalChannel, gausRad, t, removeVal);
                
                waitfig = waitbar(0, 'Removing background...');
                for i=1:numel(point_paths)
                    waitbar(i/numel(point_paths), waitfig, ['Removing background from ', strrep(obj.pathsToNames(point_paths{i}), '_', '\_')]);
                    point = obj.pathsToPoints(point_paths{i});
                    point.save_no_background();
                    fprintf(fid, '%s\n', point_paths{i});
                end
                close(waitfig);
                fclose(fid);
                disp('Finished removing background.');
                gong = load('gong.mat');
                sound(gong.y, gong.Fs)
            end
        end
        
        function save_no_noise(obj)
            point_paths = keys(obj.pathsToPoints);
            if numel(point_paths)>=1
                [logpath, ~, ~] = fileparts(point_paths{1});
                [logpath, ~, ~] = fileparts(logpath);
                logpath = [logpath, filesep, 'no_noise'];
                mkdir(logpath)
                timestring = strrep(datestr(datetime('now')), ':', char(720));
                fid = fopen([logpath, filesep, '[', timestring, ']_noise_removal.log'], 'wt');
                all_labels = obj.labels();
                for i=1:numel(all_labels)
                    label = all_labels{i};
                    params = obj.getDenoiseParam(i);
                    if params.status~=-1
                        fprintf(fid, [label, ': {', newline]);
                        fprintf(fid, [char(9), '  K-value: ', num2str(params.k_value), newline]);
                        fprintf(fid, [char(9), 'threshold: ', num2str(params.threshold), ' }', newline]); 
                    else % params.status==-1
                        fprintf(fid, [label, ': { not denoised }', newline]);
                    end
                end
                fprintf(fid, [newline, newline]);
                waitfig = waitbar(0, 'Removing noise...');
                for i=1:numel(point_paths)
                    waitbar(i/numel(point_paths), waitfig, ['Removing noise from ', strrep(obj.pathsToNames(point_paths{i}), '_', '\_')]);
                    point = obj.pathsToPoints(point_paths{i});
                    point.save_no_noise();
                    fprintf(fid, '%s\n', point_paths{i});
                end
                close(waitfig);
                fclose(fid);
                disp('Finished removing noise.');
                gong = load('gong.mat');
                sound(gong.y, gong.Fs)
            end
        end
        
        function save_no_aggregates(obj)
            point_paths = keys(obj.pathsToPoints);
            if numel(point_paths)>=1
                [logpath, ~, ~] = fileparts(point_paths{1});
                [logpath, ~, ~] = fileparts(logpath);
                logpath = [logpath, filesep, 'no_aggregates'];
                mkdir(logpath)
                timestring = strrep(datestr(datetime('now')), ':', char(720));
                fid = fopen([logpath, filesep, '[', timestring, ']_aggregate_removal.log'], 'wt');
                all_labels = obj.labels();
                for i=1:numel(all_labels)
                    label = all_labels{i};
                    params = obj.getAggRmParam(i);
                    fprintf(fid, [label, ': {', newline]);
                    fprintf(fid, [char(9), 'threshold: ', num2str(params.threshold), ' }', newline]); 
                    fprintf(fid, [char(9), 'radius: ', num2str(params.radius), ' }', newline]);
                end
                fprintf(fid, [newline, newline]);
                waitfig = waitbar(0, 'Removing aggregates...');
                for i=1:numel(point_paths)
                    waitbar(i/numel(point_paths), waitfig, ['Removing aggregates from ', strrep(obj.pathsToNames(point_paths{i}), '_', '\_')]);
                    point = obj.pathsToPoints(point_paths{i});
                    point.save_no_aggregates();
                    fprintf(fid, '%s\n', point_paths{i});
                end
                close(waitfig);
                fclose(fid);
                disp('Finished removing aggregates.');
                gong = load('gong.mat');
                sound(gong.y, gong.Fs)
            end
        end
    end
end

