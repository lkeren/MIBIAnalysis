function [] = MIBI_remove_background(pathToLog)
    % remove background for several cores according to removal params
    global pipeline_data;
    corePath = pipeline_data.corePath;
    bgChannel = pipeline_data.bgChannel;
    gausRad = pipeline_data.gausRad;
    t = pipeline_data.t;
    removeVal = pipeline_data.removeVal;
    capBgChannel = pipeline_data.capBgChannel;
    capEvalChannel = pipeline_data.capEvalChannel;

    for i=1:length(corePath)
        disp(['Working on ' num2str(i), '...']);
        countsAllSFiltCRSum = pipeline_data.rawData(corePath{i}).countsAllSFiltCRSum;
        labels = pipeline_data.rawData(corePath{i}).labels;
        
        [~,bgChannelInd] = ismember(bgChannel,labels);
        mask = MIBI_get_mask(countsAllSFiltCRSum(:,:,bgChannelInd),capBgChannel,t,gausRad,0,'');
        countsNoBg = MibiRemoveBackgroundByMaskAllChannels(countsAllSFiltCRSum,mask,removeVal);
        save ([corePath{i},'dataNoBg.mat'],'countsNoBg');
        [savePath, ~, ~] = fileparts(corePath{i});
        MibiSaveTifs ([savePath,'/TIFsNoBg/'], countsNoBg, labels)
    end
    
    fid = fopen([pathToLog, '/[', datestr(datetime('now')), ']_background_removal.log'], 'wt');
    fprintf(fid, 'background channel: %s\nbackground cap: %f\nevaluation cap: %f\ngaussian radius: %f\nthreshold: %f\nremove value: %f', bgChannel, capBgChannel, capEvalChannel, gausRad, t, removeVal);
    fclose(fid);
    disp("Finished removing background.");
end

