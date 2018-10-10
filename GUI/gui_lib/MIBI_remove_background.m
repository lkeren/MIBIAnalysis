function [] = MIBI_remove_background(pathToLog)
    % remove background for several cores according to removal params
    global pipeline_data;
    corePath = pipeline_data.points.getNames();
    bgChannel = pipeline_data.bgChannel;
    gausRad = pipeline_data.gausRad;
    t = pipeline_data.t;
    removeVal = pipeline_data.removeVal;
    capBgChannel = pipeline_data.capBgChannel;
    capEvalChannel = pipeline_data.capEvalChannel;

    waitfig = waitbar(0, 'Removing background');
    for i=1:length(corePath)
        disp(['Working on ' num2str(i), '...']);
        point = pipeline_data.points.get('name', corePath{i});
        countsAllSFiltCRSum = point.counts;
        labels = point.labels;
        
        [~,bgChannelInd] = ismember(bgChannel,labels);
        mask = MIBI_get_mask(countsAllSFiltCRSum(:,:,bgChannelInd),capBgChannel,t,gausRad,0,'');
        countsNoBg = gui_MibiRemoveBackgroundByMaskAllChannels(countsAllSFiltCRSum,mask,removeVal);
        [savePath, name, ~] = fileparts(corePath{i});
        [savePath, ~, ~] = fileparts(savePath);
        savePath = [savePath, filesep, 'NoBgData'];
        gui_MibiSaveTifs ([savePath,filesep,name,'_TIFsNoBg',filesep], countsNoBg, labels)
        save ([savePath,filesep,name,'_dataNoBg.mat'],'countsNoBg');
        waitbar(i/length(corePath), waitfig, 'Removing background');
    end
   close(waitfig);

   fid = fopen([pathToLog, filesep, '[', datestr(datetime('now')), ']_background_removal.log'], 'wt');
   fprintf(fid, 'background channel: %s\nbackground cap: %f\nevaluation cap: %f\ngaussian radius: %f\nthreshold: %f\nremove value: %f\n\n', bgChannel, capBgChannel, capEvalChannel, gausRad, t, removeVal);
   for i=1:numel(pipeline_data.corePath)
       fprintf(fid, '%s\n', pipeline_data.corePath{i});
   end
   fclose(fid);
   disp('Finished removing background.');
end

