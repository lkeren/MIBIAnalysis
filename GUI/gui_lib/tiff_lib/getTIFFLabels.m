function [labels] = getTIFFLabels(path, varargin)
% This is a function for loading tiff labels, whether it be a multipage tiff
% or a folder of individual tiff files. You are expected to provide a path
% to the Point that holds your data. If your Point is a folder that has
% some internal structure more complicated than just 'a bunch of tiffs',
% then you can either pass in a string as a second argument, XOR you can
% create a file called pathext.txt at the SAME LEVEL As this function. If
% your point is organized like this: 'Point#/TIFs/extra/Au.tiff', then you
% should put 'TIFs/extra' as the second argument or in the pathext.txt

    [~, ~, ext] = fileparts(path);
    if strcmp(ext, '.tiff') || strcmp(ext, '.tif') || strcmp(ext, '.TIFF') || strcmp(ext, '.TIF')
        % path is to multilayer tiff file, meaning it is from IonPath
        % disp(['Loading multilayer TIFF labels at ', path, '...']);
        [labels, tags] = loadLabels_multi(path);
    elseif (strcmp(ext, ''))
        % path is to folder of tiffs, meaning it could be from IonPath or
        % it could be from Leeat's extraction script
        % disp(['Loading folder of TIFF data at ', path, '...']);
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
            [labels, tags] = loadLabels_folder([path, filesep, pathext]);
        catch err % if that doesn't work we're going to assume that pathext.txt is bad
            disp(err);
            warning(['Failed to load labels from ', path, filesep, pathext]);
            warning(['Attemping to load labels from ', path]);
            [labels, tags] = loadLabels_folder(path);
        end
    else
        % path is to a dark void in your soul
        labels = {};
        tags = {};
        warning('Path provided is not to a folder or TIFF file, no labels were loaded');
    end
    
    try
        [~, labels, ~] = sortByMass([], labels, tags, path);
    catch err1
        disp(err1)
        warning('Failed to sort by mass, attempting to sort alphabetically');
        try
            [~, labels, ~] = sortByLabel([], labels, tags);
        catch err2
            disp(err2)
            warning('Failed to sort labels alphabetically');
        end
    end
end

