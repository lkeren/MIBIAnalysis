function [new_text] = wrap_text(old_text,columns,breaks)
    new_text = {};
    sub = '';
    count = 1;
    while ~isequal(sub, old_text)
        [sub, old_text] = sub_text(old_text, columns, breaks);
        new_text{count} = sub;
        count = count + 1;
    end
end

