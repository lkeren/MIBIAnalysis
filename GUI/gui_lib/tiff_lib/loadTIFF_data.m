function [counts, labels, tags, path_ext] = loadTIFF_data(path, varargin)
    [~, ~, ext] = fileparts(path);
    if strcmp(ext, '.tiff') || strcmp(ext, '.tif') || strcmp(ext, '.TIFF') || strcmp(ext, '.TIF')
        % path is to multilayer tiff file, meaning it is from IonPath
        disp(['Loading multilayer TIFF data at ', path, '...']);
        [counts, labels, tags] = loadTIFF_multi(path);
        path_ext = '';
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
                warning([masterPath, filesep, 'pathext.txt not found, proceding under assumption of basic Point directory structure']);
                pathext = '';
            end
        else
            pathext = varargin{2};
        end
        try % we assume that pathext actually respects the directory structure in use
            [counts, labels, tags] = loadTIFF_folder([path, filesep, pathext]);
            path_ext = pathext;
        catch err % if that doesn't work we're going to assume that pathext.txt is bad
            disp(err);
            warning(['Failed to load data from ', path, filesep, pathext]);
            warning(['Attemping to load data from ', path]);
            [counts, labels, tags] = loadTIFF_folder(path);
            path_ext = '';
        end
    else
        % path is to a dark void in your soul
        counts = [];
        labels = {};
        tags = {};
        error('Path provided is not to a folder or TIFF file, no TIFF files were loaded');
    end
    
    try
        [counts, labels, tags] = sortByMass(counts, labels, tags, path);
    catch err1
        disp(err1)
        warning('Failed to sort by mass, attempting to sort by label');
        try
            [counts, labels, tags] = sortByLabel(counts, labels, tags);
        catch err2
            disp(err2)
            warning('Failed to sort TIFF data by label');
        end
    end
end