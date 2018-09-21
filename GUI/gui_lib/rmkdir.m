function rmkdir(path)
    path = strsplit(path, filesep);
    dirString = '';
    for i=1:numel(path)
        dirString = [dirString, filesep, path{i}];
        [~,~,~] = mkdir(dirString);
    end
end