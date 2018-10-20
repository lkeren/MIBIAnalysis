function img = gui_MibiPlotDataAndCap(data,cap,titlestr,figureTitle,varargin)
% function MibiPlotDataAndCap(data,cap)
% function plots the data and sets any value larger than cap to cap
global pipeline_data
currdata = data;
currdata(currdata>cap) = cap;
if numel(varargin)==1
    sfigure(varargin{1});
else
    pipeline_data.backgroundChannelFigure = sfigure(figure('Name', figureTitle));
end
imagesc(currdata);
title(titlestr);
img = imgca(pipeline_data.backgroundChannelFigure);