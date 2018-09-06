function [countsAllSFiltCRSum, labels] = load_multipage_tiff(fname)
    info = imfinfo(fname);
    num_pages = numel(info);
    panel = {info.PageName}';
    [~, idx] = sort(upper(panel)); % note that we do a case-insensitive alphanumeric ordering here
    widths = cell2mat({info.Width});
    heights = cell2mat({info.Height});
    if all(widths==widths(1)) && all(heights==heights(1))
        countsAllSFiltCRSum = zeros(widths(1), heights(1), num_pages);
        labels = cell(size(panel));
        for i=1:num_pages
            str = strsplit(panel{idx(i)},' ('); % this is where we actually use the ordering
            labels{i} = str{1}; % extracts label
            countsAllSFiltCRSum(:,:,i) = imread(fname, idx(i), 'Info', info);
        end
    else
        error('TIFF pages are not all the same size');
    end
end

