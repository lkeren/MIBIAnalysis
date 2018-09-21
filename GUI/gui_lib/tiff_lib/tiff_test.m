paths = uigetdiles('/Users/raymondbaranski/GitHub/MIBIAnalysis/');
waitfig = waitbar(0, 'Converting TIFF organization...');
for point=1:numel(paths)
    readPath = paths{point};
    writePath = strsplit(readPath, filesep);
    writePath{end-1} = [writePath{end-1}, '_convert'];
    writeDir = writePath; writeDir(end) = [];
    writeDir = strjoin(writeDir, filesep);
    writePath = strjoin(writePath, filesep);
    rmkdir(writeDir);
    [counts, labels, tags] = loadTIFF_data(readPath);
    saveTIFF_multi(counts, labels, tags, writePath);
    waitbar(point/numel(paths), waitfig, 'Converting TIFF organization...');
end
close(waitfig);
