classdef PointManager
    %UNTITLED3 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        namesToPaths % map from names to paths
        pathsToNames % map from paths to names
        pathsToPoints % map from paths to Points
    end
    
    methods
        function obj = PointManager()
            %UNTITLED3 Construct an instance of this class
            %   Detailed explanation goes here
            obj.namesToPaths = containers.Map;
            obj.pathsToNames = containers.Map;
            obj.pathsToPoints = containers.Map;
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
    end
end

