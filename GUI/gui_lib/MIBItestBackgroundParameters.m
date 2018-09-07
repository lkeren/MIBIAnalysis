function [] = MIBItestBackgroundParameters()
    global pipeline_data;
    countsAllSFiltCRSum = pipeline_data.rawData(pipeline_data.background_point).countsAllSFiltCRSum;
    labels = pipeline_data.rawData(pipeline_data.background_point).labels;
    
    capBgChannel = pipeline_data.capBgChannel;
    t = pipeline_data.t;
    gausRad = pipeline_data.gausRad;
    bgChannel = pipeline_data.bgChannel;
    removeVal = pipeline_data.removeVal;
    
    titletext = ['Mask: [ ', pipeline_data.background_point, ' ] Channel [ ', bgChannel, ' ] Params: ', pipeline_data.all_param_TITLEstring];
    titletext = strrep(titletext, '_', '\_');
    
    [~,bgChannelInd] = ismember(bgChannel,labels);
    mask = MIBI_get_mask(countsAllSFiltCRSum(:,:,bgChannelInd),capBgChannel,t,gausRad,1, titletext);
    countsNoBg = MibiRemoveBackgroundByMaskAllChannels(countsAllSFiltCRSum,mask,removeVal);
    pipeline_data.countsNoBg = countsNoBg;
end

