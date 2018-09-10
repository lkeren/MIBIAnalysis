function [] = MIBIevaluateBackgroundParameters(points)
    global pipeline_data;
    
    for i=1:numel(points)
        countsAllSFiltCRSum = pipeline_data.rawData(points{i}).countsAllSFiltCRSum;
        labels = pipeline_data.rawData(points{i}).labels;
        
        evalChannel = pipeline_data.evalChannel;
        bgChannel = pipeline_data.bgChannel;
        evalChannelInd = pipeline_data.evalChannelInd;
        capEvalChannel = pipeline_data.capEvalChannel;
        capBgChannel = pipeline_data.capBgChannel;
        t = pipeline_data.t;
        gausRad = pipeline_data.gausRad;
        removeVal = pipeline_data.removeVal;
        
        [~,bgChannelInd] = ismember(bgChannel, labels);
        mask = MIBI_get_mask(countsAllSFiltCRSum(:,:,bgChannelInd),capBgChannel,t,gausRad,0);
        countsNoBg = MibiRemoveBackgroundByMaskAllChannels(countsAllSFiltCRSum,mask,removeVal);
        
        point_name = points{i};
        point_name = strrep(point_name, '_', '\_');
        
        MibiPlotDataAndCap(countsAllSFiltCRSum(:,:,evalChannelInd),capEvalChannel,[point_name, newline, evalChannel , ' - before']); plotbrowser on;
        MibiPlotDataAndCap(countsNoBg(:,:,evalChannelInd),capEvalChannel,[point_name, newline, evalChannel , ' - Params ', pipeline_data.all_param_TITLEstring, ' - after']); plotbrowser on;
    end
end

