function [countsAllSFiltCRSum, labels] = load_tiff_data(path)
    [~, ~, ext] = fileparts(path);
    if strcmp(ext, '.tiff') || strcmp(ext, '.tif') || strcmp(ext, '.TIFF') || strcmp(ext, '.TIF')
        % path is to tiff file
        [countsAllSFiltCRSum, labels] = load_multipage_tiff(path);
    elseif (strcmp(ext, ''))
        % path is to folder of tiffs
        [countsAllSFiltCRSum, labels] = load_tiff_folder(path);
    else
        % path is to a dark void in your soul
        error('Path provided is not to a folder or TIFF file');
    end
end