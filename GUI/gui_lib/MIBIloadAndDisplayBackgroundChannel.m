function [] = MIBIloadAndDisplayBackgroundChannel(reuseFigure)
    global pipeline_data;
    point = pipeline_data.points.get('name', pipeline_data.background_point);
    countsAllSFiltCRSum = point.counts;
    labels = point.labels;
    %countsAllSFiltCRSum = pipeline_data.rawData(pipeline_data.background_point).countsAllSFiltCRSum;
    % labels = pipeline_data.rawData(pipeline_data.background_point).labels;
    
    bgChannel = pipeline_data.bgChannel;
    capBgChannel = pipeline_data.capBgChannel;
    
    [~,bgChannelInd] = ismember(bgChannel,labels);
    point_name = pipeline_data.background_point;
    point_name = strrep(point_name, '_', '\_');
    if ~reuseFigure
        gui_MibiPlotDataAndCap(countsAllSFiltCRSum(:,:,bgChannelInd),capBgChannel,['Background channel - ',bgChannel,newline,newline,point_name], 'Background'); plotbrowser on;
    else
        try
            existAndValid = isvalid(pipeline_data.backgroundChannelFigure);
        catch
            existAndValid = 0;
        end
        if ~existAndValid
            pipeline_data.backgroundChannelFigure = sfigure(); plotbrowser on
        end
        gui_MibiPlotDataAndCap(countsAllSFiltCRSum(:,:,bgChannelInd),capBgChannel,['Background channel - ',bgChannel,newline,newline,point_name], 'Background', pipeline_data.backgroundChannelFigure); plotbrowser on;
    end
    
end

