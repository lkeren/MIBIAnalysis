function [countsAllSFiltCRSum, labels] = load_tiff_data(path, varargin)
% This is a function for loading tiff data, whether it be a multipage tiff
% or a folder of individual tiff files. You are expected to provide a path
% to the Point that holds your data. If your Point is a folder that has
% some internal structure more complicated than just 'a bunch of tiffs',
% then you can either pass in a string as a second argument, XOR you can
% create a file called pathext.txt at the SAME LEVEL As this function. If
% your point is organized like this: 'Point#/TIFs/extra/Au.tiff', then you
% should put 'TIFs/extra' as the second argument or in the pathext.txt

    if numel(varargin)==0
        try
            [masterPath, ~, ~] = fileparts(mfilename('fullpath'));
            fileID = fopen([masterPath, filesep, 'pathext.txt'], 'r');
            pathext = fscanf(fileID, '%s');
        catch
            pathext = '';
        end
    else
        pathext = varargin{2};
    end
    path = [path, filesep, pathext];
    disp(path);
    [~, ~, ext] = fileparts(path);
    if strcmp(ext, '.tiff') || strcmp(ext, '.tif') || strcmp(ext, '.TIFF') || strcmp(ext, '.TIF')
        % path is to tiff file
        disp(['Loading multilayer TIFF data at ', path, '...']);
        [countsAllSFiltCRSum, labels] = load_multipage_tiff(path);
    elseif (strcmp(ext, ''))
        % path is to folder of tiffs
        disp(['Loading folder of TIFF data at ', path, '...']);
        [countsAllSFiltCRSum, labels] = load_tiff_folder(path);
    else
        % path is to a dark void in your soul
        countsAllSFiltCRSum = [];
        labels = {};
        warning('Path provided is not to a folder or TIFF file');
    end
end