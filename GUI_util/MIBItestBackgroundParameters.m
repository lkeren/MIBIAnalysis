function [] = MIBItestBackgroundParameters()
    global pipeline_data;
    [countsAllSFiltCRSum, labels] = load_tiff_data(pipeline_data.background_point);
    % load([getExtractedDir(pipeline_data.background_point),filesep,'dataDeNoise.mat']);
    % cap = pipeline_data.cap;
    capBgChannel = pipeline_data.capBgChannel;
    t = pipeline_data.t;
    gausRad = pipeline_data.gausRad;
    bgChannel = pipeline_data.bgChannel;
    removeVal = pipeline_data.removeVal;
    
    titletext = ['Mask: ', pipeline_data.background_point, ' <=> ', bgChannel, ' <=> Params: [ ', num2str(gausRad), ' : ', num2str(t), ' : ', num2str(removeVal), ' : ', num2str(capBgChannel), ' ]'];
    titletext = strrep(titletext, '_', '\_');
    
    [~,bgChannelInd] = ismember(bgChannel,labels);
    mask = MIBI_get_mask(countsAllSFiltCRSum(:,:,bgChannelInd),capBgChannel,t,gausRad,1, titletext);
    countsNoBg = MibiRemoveBackgroundByMaskAllChannels(countsAllSFiltCRSum,mask,removeVal);
    pipeline_data.countsNoBg = countsNoBg;
end

