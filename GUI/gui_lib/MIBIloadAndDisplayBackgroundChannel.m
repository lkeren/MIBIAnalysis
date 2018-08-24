function [] = MIBIloadAndDisplayBackgroundChannel()
    global pipeline_data;
    countsAllSFiltCRSum = pipeline_data.rawData(pipeline_data.background_point).countsAllSFiltCRSum;
    labels = pipeline_data.rawData(pipeline_data.background_point).labels;
    
    bgChannel = pipeline_data.bgChannel;
    capBgChannel = pipeline_data.capBgChannel;
    
    [~,bgChannelInd] = ismember(bgChannel,labels);
    point_name = pipeline_data.background_point;
    point_name = strrep(point_name, '_', '\_');
    MibiPlotDataAndCap(countsAllSFiltCRSum(:,:,bgChannelInd),capBgChannel,['Background channel - ',bgChannel,newline,newline,point_name]); plotbrowser on;
    
end

