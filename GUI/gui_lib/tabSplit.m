function [clean_string] = tabSplit(string_to_split)
    clean_string = strrep(string_to_split, '  ', ' ');
    while ~strcmp(clean_string, string_to_split)
        string_to_split = clean_string;
        clean_string = strrep(string_to_split, '  ', ' ');
    end
    
end

