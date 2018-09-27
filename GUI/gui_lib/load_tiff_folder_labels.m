function [labels] = load_tiff_folder_labels(dirname)
    fileList = dir(fullfile(dirname, '*.tiff'));
    if isempty(fileList)
        fileList = dir(fullfile(dirname, '*.tif'));
    end
    fileList.name
    num_pages = numel(fileList);
    files = {fileList.name}';
    [~, idx] = sort(upper(files));
    files = files(idx);
    widths = zeros(size(files));
    heights = zeros(size(files));
    panel = cell(size(files));
    infos = cell(size(files));
    for i=1:numel(files)
        info = imfinfo(fullfile(dirname, files{i}));
        infos{i} = info;
        widths(i) = info.Width;
        heights(i) = info.Height;
        try
            panel{i} = info.PageName;
        catch
            [~, panel{i}, ~] = fileparts(files{i});
        end
    end

    if all(widths==widths(1)) && all(heights==heights(1))
        labels = cell(size(panel));
        for i=1:num_pages
            str = strsplit(panel{i},' ('); % this is where we actually use the ordering
            labels{i} = str{1}; % extracts label
        end
    else
        error('TIFF pages are not all the same size');
    end
end

