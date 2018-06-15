function MibiSaveTifs (savePath, dataMat, chanelNames)
% function MibiSaveTifs (folder, dataMat, chanelNames)
% function gets 3d Mibi data and saves it as individual tif files

if 7~=exist(savePath,'dir')
    mkdir(savePath);
end

for i=1:length(chanelNames)
    data = uint16(dataMat(:,:,i));
    imwrite(data,[savePath,'/',chanelNames{i},'.tif']);
end