function [counts, labels, tags] = loadTIFF_data(path, varargin)
    [~, ~, ext] = fileparts(path);
    if strcmp(ext, '.tiff') || strcmp(ext, '.tif') || strcmp(ext, '.TIFF') || strcmp(ext, '.TIF')
        % path is to multilayer tiff file, meaning it is from IonPath
        disp(['Loading multilayer TIFF data at ', path, '...']);
        [counts, labels, tags] = loadTIFF_multi(path);
        [counts, labels, tags] = sortByMass(counts, labels, tags, path);
    elseif (strcmp(ext, ''))
        % path is to folder of tiffs, meaning it could be from IonPath or
        % it could be from Leeat's extraction script
        disp(['Loading folder of TIFF data at ', path, '...']);
        % looks for a pathext.txt file in case there is a more complicated
        % subfolder structure
        if numel(varargin)==0
            [masterPath, ~, ~] = fileparts(mfilename('fullpath'));
            try
                fileID = fopen([masterPath, filesep, 'pathext.txt'], 'r');
                pathext = fscanf(fileID, '%s');
            catch
                disp(['No file found at ', masterPath, filesep, 'pathext.txt']);
                pathext = '';
            end
        else
            pathext = varargin{2};
        end
        try % we assume that pathext actually respects the directory structure in use
            [counts, labels, tags] = loadTIFF_folder([path, filesep, pathext]);
        catch err % if that doesn't work we're going to assume that pathext.txt is bad
            disp(err);
            [counts, labels, tags] = loadTIFF_folder(path);
        end
        [counts, labels, tags] = sortByMass(counts, labels, tags, path);
    else
        % path is to a dark void in your soul
        counts = [];
        labels = {};
        tags = {};
        warning('Path provided is not to a folder or TIFF file');
    end
end