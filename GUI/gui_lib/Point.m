classdef Point
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name
        point_path
        counts
        labels
        tags
    end
    
    methods
        function obj = Point(point_path, len)
            obj.point_path = point_path;
            [obj.counts, obj.labels, obj.tags] = loadTIFF_data(point_path);
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
        end
        
        function check = checkAllLabelsUnique(obj)
            if numel(unique(obj.labels))==numel(obj.labels)
                check = true;
            else
                check = false;
                warning('NOT ALL LABELS ARE UNIQUE')
            end
        end
    end
end

