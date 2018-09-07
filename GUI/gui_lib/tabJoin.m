function [tabbed_string] = tabJoin(cell_of_strings, tab_length)
    tabbed_string = '';
    for i=1:(numel(cell_of_strings)-1)
        if numel(tab_length)==1
            tab = tab_length-length(cell_of_strings{i});
        else
            tab = tab_length(i)-length(cell_of_strings{i});
        end
        tabbed_string = [tabbed_string, cell_of_strings{i}, repmat(char(8197), 1, tab)];
    end
    tabbed_string = [tabbed_string, cell_of_strings{end}];
end

