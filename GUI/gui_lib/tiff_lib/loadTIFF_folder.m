function [counts, labels, tags] = loadTIFF_folder(path)
    fileList = [dir(fullfile(path, '*.tiff'));...
                dir(fullfile(path, '*.tif'))];
    if isempty(fileList)
        warning('No TIFF files found');
    end
    num_pages = numel(fileList);
    files = {fileList.name}';
    counts = [];
    labels = {};
    tags = {};
    for index=1:num_pages
        tiff = Tiff([path, filesep, files{index}]);
        counts(:,:,index) = read(tiff);
        tags{index} = getTagStruct(tiff);
        try
            desc = json.load(tags{index}.ImageDescription);
            labels{index} = desc.channel0x2Etarget;
        catch
            [~, labels{index}, ~] = fileparts(files{index});
        end
    end
    
    [counts, labels, tags] = sortByLabel(counts, labels, tags);
end