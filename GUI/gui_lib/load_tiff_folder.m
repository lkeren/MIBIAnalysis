function [countsAllSFiltCRSum, labels] = load_tiff_folder(dirname)
    fileList = dir(fullfile(dirname, '*.tiff'));
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
        panel{i} = info.PageName;
    end

    if all(widths==widths(1)) && all(heights==heights(1))
            countsAllSFiltCRSum = zeros(widths(1), heights(1), num_pages);
            labels = cell(size(panel));
            for i=1:num_pages
                str = strsplit(panel{idx(i)},' ('); % this is where we actually use the ordering
                labels{i} = str{1}; % extracts label
                fname = fullfile(dirname, files{i});
                info = infos{i};
                countsAllSFiltCRSum(:,:,i) = imread(fname, 1, 'Info', info);
            end
        else
            error('TIFF pages are not all the same size');
    end
end

