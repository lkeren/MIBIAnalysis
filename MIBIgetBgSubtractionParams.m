% Get parameters for background subtraction

corePath = {'SampleData/extracted/Point1/'}; % path to data generated from the extraction process
bgChannel = ('Background'); % channel used for background signal. (Typically Au/Ta/Si/Background)
gausRad= 1; % radius of gaussian to use for signal smoothing (typically 1-3)
t= 0.2; % threshold for binary thresholding (0-1)
removeVal= 2; % value to remove from all channels in background-positive areas (increase for more aggressive removal)
evalChannel = ('CD45'); % channel to plot for evaluating the background removal

% Other parameters
cap = 10;
coreNum = length(corePath);

for i=1:coreNum
    load([corePath{i},'dataDeNoise.mat']);
    [~,bgChannelInd] = ismember(bgChannel,massDS.Label);
    MibiPlotDataAndCap(countsAllSFiltCRSum(:,:,bgChannelInd),cap,['Background channel - ',bgChannel]); plotbrowser on;
    mask = MibiGetMask(countsAllSFiltCRSum(:,:,bgChannelInd),cap,t,gausRad);
    countsNoBg = MibiRemoveBackgroundByMaskAllChannels(countsAllSFiltCRSum,mask,removeVal);
    [~,evalChannelInd] = ismember(evalChannel,massDS.Label);
    MibiPlotDataAndCap(countsAllSFiltCRSum(:,:,evalChannelInd),cap,[evalChannel , ' - before']); plotbrowser on;
    MibiPlotDataAndCap(countsNoBg(:,:,evalChannelInd),cap,[evalChannel , ' - after']); plotbrowser on;
end

