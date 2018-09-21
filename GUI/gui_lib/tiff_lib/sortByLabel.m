function [counts, labels, tags] = sortByLabel(counts, labels, tags)
    [~, idx] = sort(upper(labels));
    counts = counts(:,:,idx);
    labels = labels(idx);
    tags = tags(idx);
end

