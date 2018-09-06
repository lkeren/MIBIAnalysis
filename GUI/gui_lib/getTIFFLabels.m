function [labels] = getTIFFLabels(path)
    [~, ~, ext] = fileparts(path);
    if strcmp(ext, '.tiff') || strcmp(ext, '.tif') || strcmp(ext, '.TIFF') || strcmp(ext, '.TIF')
        % path is to tiff file
        info = imfinfo(path);
        num_pages = numel(info);
        panel = {info.PageName}';
        [~, idx] = sort(upper(panel)); % note that we do a case-insensitive alphanumeric ordering here
        labels = cell(size(panel));
        for i=1:num_pages
            str = strsplit(panel{idx(i)},' ('); % this is where we actually use the ordering
            labels{i} = str{1}; % extracts label
        end
    elseif (strcmp(ext, ''))
        % path is to folder of tiffs
        fileList = dir(fullfile(path, '*.tiff'));
        num_pages = numel(fileList);
        files = {fileList.name}';
        [~, idx] = sort(upper(files));
        files = files(idx);
        panel = cell(size(files));
        infos = cell(size(files));

        for i=1:numel(files)
            info = imfinfo(fullfile(path, files{i}));
            infos{i} = info;
            panel{i} = info.PageName;
        end

        labels = cell(size(panel));
        for i=1:num_pages
            str = strsplit(panel{idx(i)},' ('); % this is where we actually use the ordering
            labels{i} = str{1}; % extracts label
        end
    else
        % path is to a dark void in your soul
        labels = {};
        warning('Path provided is not to a folder or TIFF file');
    end
end

