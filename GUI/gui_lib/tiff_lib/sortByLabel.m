function [counts, labels, tags] = sortByLabel(counts, labels, tags)
    [~, idx] = sort(upper(labels));
    try
        counts = counts(:,:,idx);
    catch
        % do nothing
    end
    labels = labels(idx);
    tags = tags(idx);
end

