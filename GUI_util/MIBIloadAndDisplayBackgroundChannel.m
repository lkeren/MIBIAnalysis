function [] = MIBIloadAndDisplayBackgroundChannel()
    global pipeline_data;
    [countsAllSFiltCRSum, labels] = load_tiff_data(pipeline_data.background_point);
    % load([getExtractedDir(pipeline_data.background_point),filesep,'dataDeNoise.mat']);
    bgChannel = pipeline_data.bgChannel;
    capBgChannel = pipeline_data.capBgChannel;
    
    [~,bgChannelInd] = ismember(bgChannel,labels);
    disp(bgChannel)
    point_name = pipeline_data.background_point;
    point_name = strrep(point_name, '_', '\_');
    MibiPlotDataAndCap(countsAllSFiltCRSum(:,:,bgChannelInd),capBgChannel,['Background channel - ',bgChannel,newline,newline,point_name]); plotbrowser on;
    
end

