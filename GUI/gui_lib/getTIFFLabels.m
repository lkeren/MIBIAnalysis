function [labels] = getTIFFLabels(path)
    [~, ~, ext] = fileparts(path);
    if strcmp(ext, '.tiff') || strcmp(ext, '.tif') || strcmp(ext, '.TIFF') || strcmp(ext, '.TIF')
        % path is to tiff file
        disp(['Loading multilayer TIFF data at ', path, '...']);
        labels = load_multipage_tiff_labels(path);
    elseif (strcmp(ext, ''))
        % path is to folder of tiffs
        disp(['Loading folder of TIFF data at ', path, '...']);
        labels = load_tiff_folder_labels(path);
    else
        % path is to a dark void in your soul
        labels = {};
        warning('Path provided is not to a folder or TIFF file');
    end
end

