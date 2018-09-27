function [labels] = load_multipage_tiff_labels(fname)
    info = imfinfo(fname);
    num_pages = numel(info);
    panel = {info.PageName}';
    [~, idx] = sort(upper(panel)); % note that we do a case-insensitive alphanumeric ordering here
    widths = cell2mat({info.Width});
    heights = cell2mat({info.Height});
    if all(widths==widths(1)) && all(heights==heights(1))
        labels = cell(size(panel));
        for i=1:num_pages
            str = strsplit(panel{idx(i)},' ('); % this is where we actually use the ordering? we might not need to actually use the ordering
            labels{i} = str{1}; % extracts label
        end
    else
        error('TIFF pages are not all the same size');
    end
end

