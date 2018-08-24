function [sub, text] = sub_text(text,columns,breaks)
    if numel(text)<=columns
        sub = text;
    else
        found = false;
        index = columns;
        for i=columns:-1:1
            if contains(breaks, text(i))
                sub = text(1:i);
                text = text((i+1):end);
                found = true;
                break;
            end
        end
        if ~found
            sub = text(1:columns);
            text = text((columns+1):end);
        end
    end
end

