function [labels] = getTIFFLabels(path)
    [masterPath, ~, ~] = fileparts(mfilename('fullpath'));
    fileID = fopen([masterPath, filesep, 'pathext.txt'], 'r');
    pathext = fscanf(fileID, '%s');
    path = [path, filesep, pathext];
    [~, ~, ext] = fileparts(path);
    if strcmp(ext, '.tiff') || strcmp(ext, '.tif') || strcmp(ext, '.TIFF') || strcmp(ext, '.TIF')
        % path is to tiff file
        labels = load_multipage_tiff_labels(path);
    elseif (strcmp(ext, ''))
        % path is to folder of tiffs
        labels = load_tiff_folder_labels(path);
    else
        % path is to a dark void in your soul
        labels = {};
        warning('Path provided is not to a folder or TIFF file');
    end
end

