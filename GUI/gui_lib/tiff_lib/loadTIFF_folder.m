function [counts, labels, tags] = loadTIFF_folder(path)
    % First we look for all TIFF files in the given path
    fileList = [dir(fullfile(path, '*.tiff'));...
                dir(fullfile(path, '*.tif'))];
    if isempty(fileList)
        warning(['No TIFF files found in ', path]);
    end
    files = {fileList.name}';
    rmIdx = [find(strcmp(files, 'totalIon.tif')), find(strcmp(files, 'totalIon.tiff'))];
    files(rmIdx) = []; % removes totalIon.tif and/or totalIon.tiff
    num_pages = numel(files);
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
end