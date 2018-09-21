function [counts, labels, tags] = loadTIFF_multi(path)
    % expects path to specify a folder
    tiff = Tiff(path);
    counts = [];
    labels = {};
    tags = {};
    
    last = 0;
    while ~last
        index = currentDirectory(tiff);
        counts(:,:,index) = read(tiff);
        tags{index} = getTagStruct(tiff);
        try
            desc = json.load(tags{index}.ImageDescription);
            labels{index} = desc.channel0x2Etarget;
        catch
            try
                labels{index} = tags{index}.PageName;
            catch
                labels{index} = 'How Can Mirrors Be Real If Our Eyes Aren''t Real';
                warning('No Label Found');
            end
        end
        if lastDirectory(tiff)
            last = 1;
        else
            nextDirectory(tiff);
        end
    end
    
    [counts, labels, tags] = sortByLabel(counts, labels, tags);
end