classdef Point
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        point_path
        counts
        labels
    end
    
    methods
        function obj = Point(point_path)
            obj.point_path = point_path;
            [obj.counts, obj.labels] = loadTIFF_data(point_path);
            [path, name, ~] = fileparts(point_path);
            name = [path, filesep, name];
            name = strsplit(path, filesep);
            try
                name = name((end-3):end);
            catch
                % do nothing
            end
            obj.name = strjoin(name, filesep);
        end
        
%         function outputArg = method1(obj,inputArg)
%             %METHOD1 Summary of this method goes here
%             %   Detailed explanation goes here
%             outputArg = obj.Property1 + inputArg;
%         end
    end
end

