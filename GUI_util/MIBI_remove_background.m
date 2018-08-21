function [] = MIBI_remove_background()
    % remove background for several cores according to removal params
    global pipeline_data;
    corePath = pipeline_data.corePath;
    bgChannel = pipeline_data.bgChannel;
    gausRad = pipeline_data.gausRad;
    t = pipeline_data.t;
    removeVal = pipeline_data.removeVal;
    cap = pipeline_data.cap;

    for i=1:length(corePath)
        disp(['Working on ' num2str(i), '...']);
        [countsAllSFiltCRSum, labels] = load_tiff_data(corePath{i});
        [~,bgChannelInd] = ismember(bgChannel,labels);
        mask = MIBI_get_mask(countsAllSFiltCRSum(:,:,bgChannelInd),cap,t,gausRad,0,'');
        countsNoBg = MibiRemoveBackgroundByMaskAllChannels(countsAllSFiltCRSum,mask,removeVal);
        save ([corePath{i},'dataNoBg.mat'],'countsNoBg');
        [savePath, ~, ~] = fileparts(corePath{i});
        MibiSaveTifs ([savePath,'/TIFsNoBg/'], countsNoBg, labels)
    end
    disp("Finished removing background.");
end

