function [ishidden] = isHiddenName(filename)
    ishidden = strcmp(filename(1), '.');
end

