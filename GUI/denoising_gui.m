function varargout = denoising_gui(varargin)
    % DENOISING_GUI MATLAB code for denoising_gui.fig
    %      DENOISING_GUI, by itself, creates a new DENOISING_GUI or raises the existing
    %      singleton*.
    %
    %      H = DENOISING_GUI returns the handle to a new DENOISING_GUI or the handle to
    %      the existing singleton*.
    %
    %      DENOISING_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in DENOISING_GUI.M with the given input arguments.
    %
    %      DENOISING_GUI('Property','Value',...) creates a new DENOISING_GUI or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before denoising_gui_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to denoising_gui_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES

    % Edit the above text to modify the response to help denoising_gui

    % Last Modified by GUIDE v2.5 17-Oct-2018 16:54:53

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @denoising_gui_OpeningFcn, ...
                       'gui_OutputFcn',  @denoising_gui_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);
    if nargin && ischar(varargin{1})
        gui_State.gui_Callback = str2func(varargin{1});
    end

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
    % End initialization code - DO NOT EDIT


% --- Executes just before denoising_gui is made visible.
function denoising_gui_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to denoising_gui (see VARARGIN)
    global pipeline_data;
    json.startup;
    pipeline_data = struct();
    pipeline_data.denoise_params = containers.Map;
    % pipeline_data.IntNormDFutures = containers.Map;
    pipeline_data.points = PointManager();
    pipeline_data.labels = {};
    pipeline_data.figures = struct();
    pipeline_data.figures.tiffFigure = NaN;
    pipeline_data.figures.histFigure = NaN;
    % pipeline_data.ignore = {'C', 'Ca', 'Na', '181', '197'};
    % Choose default command line output for denoising_gui
    handles.output = hObject;
    [rootpath, name, ext] = fileparts(mfilename('fullpath'));
    pipeline_data.woahdude = imread([rootpath, filesep, 'gui_lib', filesep, 'resources', filesep, 'woah', filesep, '6.png']);
    pipeline_data.ignore = json.read([rootpath,filesep,'ignore.json']);
    warning('off', 'MATLAB:hg:uicontrol:StringMustBeNonEmpty');
    warning('off', 'MATLAB:imagesci:tifftagsread:expectedTagDataFormat');
    rootpath = strsplit(rootpath, filesep);
    rootpath(end) = [];
    rootpath = strjoin(rootpath, filesep);
    pipeline_data.defaultPath = rootpath;
    % Update handles structure
    guidata(hObject, handles);
    
    set(handles.points_listbox, 'KeyPressFcn', {@points_listbox_keypressfcn, {eventdata, handles}});
    set(handles.channels_listbox, 'KeyPressFcn', {@channels_listbox_keypressfcn, {eventdata, handles}});

% UIWAIT makes denoising_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = denoising_gui_OutputFcn(hObject, eventdata, handles) 
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;


function fix_handle(handle)
    try
        if get(handle, 'value') > numel(get(handle, 'string'))
            set(handle, 'value', numel(get(handle, 'string')));
        end
        if isempty(get(handle, 'string'))
            set(handle, 'String', '');
            set(handle, 'Value', 1)
        end
        if ~isnumeric(get(handle, 'Value'))
            set(handle, 'Value', 1)
        end
    catch
        
    end

function fix_menus_and_lists(handles)
    fix_handle(handles.points_listbox);
    fix_handle(handles.channels_listbox);

function point_names = getPointNames(handles)
    contents = cellstr(get(handles.points_listbox,'string'));
    point_idx = get(handles.points_listbox,'value');
    if isempty(contents)
        point_names = [];
    else
        point_names = contents(point_idx);
    end
    for i=1:numel(point_names)
        point_names{i} = strsplit(point_names{i}, char(8197));
        point_names{i} = point_names{i}{1};
    end

function channel_params = getChannelParams(handles)
    global pipeline_data;
    label_index = get(handles.channels_listbox,'Value');
    channel_params = pipeline_data.points.getDenoiseParam(label_index);

function setThresholdParam(handles)
    global pipeline_data;
    label_index = get(handles.channels_listbox,'value'); 
    threshold = str2double(get(handles.threshold_edit, 'string'));
    pipeline_data.points.setDenoiseParam(label_index, 'threshold', threshold);
    set(handles.channels_listbox, 'string', pipeline_data.points.getDenoiseText());
    
function setKValParam(handles)
    global pipeline_data;
    k_val = str2double(get(handles.k_val_edit, 'string'));
    label_indices = get(handles.channels_listbox, 'value');
    if numel(label_indices)>0
        for index = label_indices
            pipeline_data.points.setDenoiseParam(index, 'k_value', k_val);
        end
    end
%     pipeline_data.points.setDenoisingParam
%     temp = struct();
%     temp.threshold = threshold;
%     temp.k_val = k_val;
%     temp.status = pipeline_data.denoise_params(channel).status;
%     pipeline_data.denoise_params(channel) = temp;
    set(handles.channels_listbox, 'string', pipeline_data.points.getDenoiseText());
    
function plotDenoisingParams(handles)
    global pipeline_data;
    label_index = get(handles.channels_listbox,'Value');
    point_name = getPointNames(handles);
    if numel(point_name)==1 && numel(label_index)==1
        point_name = point_name{1};
        point = pipeline_data.points.get('name', point_name);
        channel_params = pipeline_data.points.getDenoiseParam(label_index);
        label = channel_params.label;

        int_norm_d = point.get_IntNormD(label);
        if isequaln(int_norm_d, [])
            % then the knn calculation hasn't been performed, we should just
            % plot the data;
            try sfigure(pipeline_data.figures.tiffFigure);
            catch
                pipeline_data.figures.tiffFigure = sfigure();
            end
            clf;
            imagesc(point.counts(:,:,label_index))
            title([strrep(point_name, '_', '\_'), ' : ', label, ' - raw image']);
            try sfigure(pipeline_data.histFigure);
            catch
                pipeline_data.histFigure = sfigure();
            end
            clf;
            imagesc(pipeline_data.woahdude);
            % imshow(pipeline_data.woahdude,'InitialMagnification','fit');
            title('woah');
        else
            % the knn calculation HAS been performed, plot the denoise image
            % and the histogram
            counts_NoNoise = gui_MibiFilterImageByNNThreshold(point.counts(:,:,label_index), int_norm_d, channel_params.threshold);
            hist_counts = point.get_countHist(label);
            try sfigure(pipeline_data.figures.tiffFigure);
            catch
                pipeline_data.figures.tiffFigure = sfigure();
            end
            clf;
            imagesc(counts_NoNoise)
            title([strrep(point_name, '_', '\_'), ' : ', label, ' - denoised']);
            try sfigure(pipeline_data.histFigure);
            catch
                pipeline_data.histFigure = sfigure();
            end
            clf;
            hedges = 0:0.25:30;
            hedges = hedges(1:end-1);
            hold off;
            bar(hedges, hist_counts, 'histc');
            hold on;
            lim = ylim;
            plot([channel_params.threshold, channel_params.threshold], [0, lim(2)], 'r');
            ylim(lim);
            title([strrep(point_name, '_', '\_'), ' : ', label, ' - histogram']);
        end
    end

function set_gui_state(handles, state)
    handle_names = fieldnames(handles);
    for i=1:numel(handle_names)
        try
            set(handles.(handle_names{i}), 'enable', state);
        catch
        end
    end
    drawnow
% --- Executes on button press in add_point.


function add_point_Callback(hObject, eventdata, handles)
% hObject    handle to add_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global pipeline_data;
    pointdiles = uigetdiles(pipeline_data.defaultPath);
    if ~isempty(pointdiles)
        pipeline_data.points.add(pointdiles);
        point_names = pipeline_data.points.getNames();
        disp(pipeline_data.points.getPointText());
        set(handles.points_listbox, 'string', pipeline_data.points.getPointText())
        set(handles.points_listbox, 'max', numel(point_names));
        denoise_text = pipeline_data.points.getDenoiseText();
        set(handles.channels_listbox, 'string', denoise_text);
        set(handles.channels_listbox, 'max', numel(denoise_text));
        % pipeline_data.labels = pipeline_data.points.labels();
    end

% --- Executes on button press in remove_point.
function remove_point_Callback(hObject, eventdata, handles)
% hObject    handle to remove_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global pipeline_data;
    pointIndex = get(handles.points_listbox, 'Value');
    pointList = pipeline_data.points.getNames();
    % pointList = get(handles.points_listbox, 'String');
    try
        removedPoint = pointList{pointIndex};
        if ~isempty(removedPoint)
            pipeline_data.points.remove('name', removedPoint);
            set(handles.points_listbox, 'String', pipeline_data.points.getNames());
            set(handles.channels_listbox, 'string', pipeline_data.points.getDenoiseText());
        end
        fix_menus_and_lists(handles);
    catch
    end

    
function run_knn(handles)
    global pipeline_data;
    point_names = pipeline_data.points.getSelectedPointNames();
    label_indices = pipeline_data.points.getSelectedLabelIndices();
    set(handles.figure1, 'pointer', 'watch')
    wait = waitbar(0, 'Calculating nearest neighbors');
    startTime = tic;
    set_gui_state(handles, 'off');
    labels = pipeline_data.points.labels();
    for i=1:numel(point_names)
        for j=1:numel(label_indices)
            fraction = ((i-1)*numel(label_indices)+j)/(numel(point_names)*numel(label_indices));
            timeLeft = (toc(startTime)/fraction)*(1-fraction);

            min = floor(timeLeft/60);
            sec = round(timeLeft-60*min);
            waitbar(fraction, wait, ['Calculating KNN for ' strrep(point_names{i}, '_', '\_'), ':', labels{label_indices(j)}, '.' newline, 'Time remaining: ', num2str(min), ' minutes and ', num2str(sec), ' seconds']);
            figure(wait);
            k_value = pipeline_data.points.getDenoiseParam(label_indices(j)).k_value;
            pipeline_data.points.knn(point_names{i}, label_indices(j), k_value);
        end
    end
    for i=1:numel(point_names)
        for j=1:numel(label_indices)
            pipeline_data.points.setDenoiseParam(label_indices(j), 'loaded', 1);
        end
    end
    set(handles.figure1, 'pointer', 'arrow')
    close(wait);
    set_gui_state(handles, 'on');
    pipeline_data.points.flush_data();
    plotDenoisingParams(handles);
    set(handles.points_listbox, 'string', pipeline_data.points.getPointText());
    set(handles.channels_listbox, 'string', pipeline_data.points.getDenoiseText());

% --- Executes on button press in run_knn.
function run_knn_Callback(hObject, eventdata, handles)
% hObject    handle to run_knn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    run_knn(handles);

        

% --- Executes on selection change in points_listbox.
function points_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to points_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: contents = cellstr(get(hObject,'String')) returns points_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from points_listbox
    try
        global pipeline_data;
        if strcmp(get(gcf,'selectiontype'), 'open')
            point_names = getPointNames(handles);
            % point_names
            if numel(point_names)==1
                for i=1:numel(point_names)
                    pipeline_data.points.togglePointStatus(point_names{i});
                end
            end
            set(handles.points_listbox, 'string', pipeline_data.points.getPointText());
        end
        label_index = get(handles.channels_listbox,'value');
        if ~isempty(label_index)
            channel_params = pipeline_data.points.getDenoiseParam(label_index);
            k_val = channel_params.k_value;
            threshold = channel_params.threshold;

            set(handles.threshold_edit, 'string', threshold);
            set(handles.k_val_edit, 'string', k_val);
            if threshold<get(handles.threshold_slider, 'min')
                set(handles.threshold_slider, 'min', threshold);
            elseif threshold>get(handles.threshold_slider, 'max')
                set(handles.threshold_slider, 'max', threshold);
            else

            end
            set(handles.threshold_slider, 'value', threshold);
            plotDenoisingParams(handles);
            fix_menus_and_lists(handles);
        end
    catch err
        disp(err)
    end

% --- Executes on slider movement.
function threshold_slider_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    try
        val = get(hObject,'Value');
        set(handles.threshold_edit, 'String', num2str(val));
        setThresholdParam(handles);
        plotDenoisingParams(handles);
    catch

    end

function threshold_edit_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold_edit as text
%        str2double(get(hObject,'String')) returns contents of threshold_edit as a double
    try
        val = str2double(get(hObject,'String'));
        if val<get(handles.threshold_slider, 'Min')
            set(handles.threshold_slider, 'Min', val);
        elseif val>get(handles.threshold_slider, 'Max')
            set(handles.threshold_slider, 'Max', val);
        else
            
        end
        set(handles.threshold_slider, 'Value', val);
        setThresholdParam(handles);
        plotDenoisingParams(handles);
    catch
        
    end

function k_val_edit_Callback(hObject, eventdata, handles)
% hObject    handle to k_val_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    setKValParam(handles);

% --- Executes on button press in reset_k_val.
function reset_k_val_Callback(hObject, eventdata, handles)
% hObject    handle to reset_k_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        channel_params = getChannelParams(handles);
        k_val = channel_params{3};
        set(handles.k_val_edit, 'String', k_val);
    catch
        
    end

% --- Executes on button press in recalculate_k_val.
function recalculate_k_val_Callback(hObject, eventdata, handles)
% hObject    handle to recalculate_k_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        global pipeline_data;
        set(handles.figure1, 'pointer', 'watch')
        drawnow
        setThresholdParam(handles);
        setKValParam(handles);
        channel_params = getChannelParams(handles);
        channel = channel_params{1};
        k_val = str2double(channel_params{3});
        point = getPointNames(handles);
        data = pipeline_data.dataNoBg(point);
        plotChannelInd = find(strcmp(data.labels, channel));
        key = [point,'_',channel];
        pipeline_data.IntNormD(key) = MIBI_get_int_norm_dist(data.countsAllSFiltCRSum(:,:,plotChannelInd), k_val);
        hedges = 0:0.25:30;
        pipeline_data.histograms(key) = histcounts(pipeline_data.IntNormD(key),hedges,'Normalization','probability');
        plotDenoisingParams(handles)
        set(handles.figure1, 'pointer', 'arrow')
    catch
        
    end

% --- Executes on selection change in channels_listbox.
function channels_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to channels_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channels_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channels_listbox
    try
        global pipeline_data;
        label_index = get(handles.channels_listbox,'Value');
        if numel(label_index)>1 && false
            if strcmp(get(gcf,'selectiontype'),'open')
                for i=1:numel(label_index)
                    pipeline_data.points.setDenoiseParam(label_index(i), 'status');
                end
                set(handles.channels_listbox, 'string', pipeline_data.points.getDenoiseText());
            end
        elseif ~isempty(label_index)
            channel_params = pipeline_data.points.getDenoiseParam(label_index);
            % channel_params = getChannelParams(handles);
            k_val = channel_params.k_value;
            threshold = channel_params.threshold;

            % label = channel_params{1};
            % temp = pipeline_data.denoise_params(label);
            if strcmp(get(gcf,'selectiontype'),'open')
                pipeline_data.points.setDenoiseParam(label_index, 'status');
                % temp.status = 1-temp.status;
                % pipeline_data.denoise_params(label) = temp;
                set(handles.channels_listbox, 'string', pipeline_data.points.getDenoiseText());
            end
            set(handles.threshold_edit, 'String', threshold);
            set(handles.k_val_edit, 'String', k_val);
            if threshold<get(handles.threshold_slider, 'Min')
                set(handles.threshold_slider, 'Min', threshold);
            elseif threshold>get(handles.threshold_slider, 'Max')
                set(handles.threshold_slider, 'Max', threshold);
            else

            end
            set(handles.threshold_slider, 'Value', threshold);
            plotDenoisingParams(handles);
            fix_menus_and_lists(handles);
        else
            
        end
    catch
    end
    
% --- Executes on button press in threshold_minmax_button.
function threshold_minmax_button_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_minmax_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    defaults = {num2str(get(handles.threshold_slider, 'Min')), num2str(get(handles.threshold_slider, 'Max'))};
    vals = inputdlg({'Threshold minimum', 'Threshold maximum'}, 'Threshold range', 1, defaults);
    try
        vals = str2double(vals);
        if vals(2)>vals(1)
            value = get(handles.threshold_slider, 'Value');
            if value<vals(1) % value less than minimum
                value = vals(1);
            elseif value>vals(2) % value greater than maximum
                value = vals(2);
            else
                % value is fine
            end
            set(handles.threshold_slider, 'Min', vals(1));
            set(handles.threshold_slider, 'Max', vals(2));
            set(handles.threshold_slider, 'Value', value);
            set(handles.threshold_edit, 'String', value);
            setThresholdParam(handles);
            plotDenoisingParams(handles);
        else
            gui_warning('Threshold maximum must be greater than threshold minimum');
        end
    catch
        % do nothing
    end


% --- Executes on button press in load_run_button.
function load_run_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [file,path] = uigetfile('*.mat');
    global pipeline_data;
    try
        pipeline_data = load([path, filesep, file]);
        try
            pipeline_data = pipeline_data.pipeline_data;
            set(handles.points_listbox, 'String', pipeline_data.corePath);
            generateDenoiseParamText(handles);
        catch
            gui_warning('Invalid file');
        end
    catch
        % do nothing
    end

% --- Executes on button press in save_run_button.
function save_run_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [file,path] = uiputfile('*.mat');
    global pipeline_data;
    try
        pipeline_data.tiffFigure = NaN;
        pipeline_data.histFigure = NaN;
        save([path, filesep, file], 'pipeline_data')
    catch
        
    end

% --- Executes on button press in denoise_button.
function denoise_button_Callback(hObject, eventdata, handles)
% hObject    handle to denoise_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global pipeline_data;
    % first we have to finish running the knn calculation
    point_names = pipeline_data.points.getNames();
    for i=1:numel(point_names)
        pipeline_data.points.setPointStatus(point_names{i}, 1);
    end
    for i=1:numel(pipeline_data.points.labels())
        if pipeline_data.points.getDenoiseParam(i).status~=-1
            pipeline_data.points.setDenoiseParam(i, 'status', 1);
        end
    end
    set(handles.points_listbox, 'string', pipeline_data.points.getPointText());
    set(handles.channels_listbox, 'string', pipeline_data.points.getDenoiseText());
    
    run_knn(handles);
    
    set(handles.points_listbox, 'string', pipeline_data.points.getPointText());
    set(handles.channels_listbox, 'string', pipeline_data.points.getDenoiseText());
%     
%     cleanDataPath = uigetdir(); % this is also where it will place the log
%     if cleanDataPath~=0
%         set(handles.figure1, 'pointer', 'watch');
%         drawnow
%         pipeline_data.noiseT = zeros(size(pipeline_data.labels));
%         pipeline_data.IntNormDData = containers.Map;
%         for lab=1:numel(pipeline_data.noiseT)
%             pipeline_data.noiseT(lab) = pipeline_data.denoise_params(pipeline_data.labels{lab}).threshold;
%         end
%         for poi=1:numel(pipeline_data.corePath)
%             IntNormDCell = cell(size(pipeline_data.labels));
%             for lab=1:numel(pipeline_data.labels)
%                 key = [pipeline_data.corePath{poi}, '_', pipeline_data.labels{lab}];
%                 % disp(key);
%                 IntNormDCell{lab} = pipeline_data.IntNormD(key);
%             end
%             pipeline_data.IntNormDData(pipeline_data.corePath{poi}) = IntNormDCell;
%         end
% 
% %         cleanDataPath = [cleanDataPath, filesep, 'cleanData'];
% %         mkdir(cleanDataPath);
%         waitfig = waitbar(0, 'Denoising points...');
%         for i=1:numel(pipeline_data.corePath)
%             path = pipeline_data.corePath{i};
%             [savePath, name, ~] = fileparts(path);
%             [savePath, ~, ~] = fileparts(savePath);
%             savePath = [savePath, filesep, 'NoNoiseData'];
%             countsNoNoise = gui_MibiFilterAllByNN(pipeline_data.dataNoBg(path).countsAllSFiltCRSum,pipeline_data.IntNormDData(path),pipeline_data.noiseT);
%             % mkdir([cleanDataPath,'/Point',num2str(i)]);
%             gui_MibiSaveTifs ([savePath,filesep,name,'_TIFsNoNoise',filesep], countsNoNoise, pipeline_data.labels)
%             save([savePath,filesep,name,'_dataDeNoiseCohort.mat'],'countsNoNoise');
%             waitbar(i/numel(pipeline_data.corePath), waitfig, 'Denoising points...');
%     %         close all;
%         end
%         close(waitfig);
%         fid = fopen([cleanDataPath, filesep, '[', datestr(datetime('now')), ']_denoising.log'], 'wt');
%         for i=1:numel(pipeline_data.labels)
%             label = pipeline_data.labels{i};
%             params = pipeline_data.denoise_params(label);
%             fprintf(fid, [label, ': {', newline]);
%             fprintf(fid, [char(9), '  K-value: ', num2str(params.k_val), newline]);
%             fprintf(fid, [char(9), 'threshold: ', num2str(params.threshold), ' }', newline]); 
%         end
%         fclose(fid);
%         set(handles.figure1, 'pointer', 'arrow');
%         disp('Done denoising');
%         gong = load('gong.mat');
%         sound(gong.y, gong.Fs)
%     end


function points_listbox_keypressfcn(hObject, eventdata, handles)
    global pipeline_data;
    if strcmp(eventdata.Key, 'return')
        point_names = getPointNames(handles{2});
        % point_names
        if numel(point_names)>1 || true
            for i=1:numel(point_names)
                pipeline_data.points.togglePointStatus(point_names{i});
            end
            set(handles{2}.points_listbox, 'string', pipeline_data.points.getPointText());
        end
    end
    
function channels_listbox_keypressfcn(hObject, eventdata, handles)
    global pipeline_data;
    if strcmp(eventdata.Key, 'return')
        channel_indices = get(handles{2}.channels_listbox,'value');
        if numel(channel_indices)>1 || true
            for i=1:numel(channel_indices)
                pipeline_data.points.setDenoiseParam(channel_indices(i), 'status');
            end
        end
        set(handles{2}.channels_listbox, 'string', pipeline_data.points.getDenoiseText());
    elseif strcmp(eventdata.Key, 'backspace')
        channel_indices = get(handles{2}.channels_listbox,'value');
        if numel(channel_indices)>1 || true
            for i=1:numel(channel_indices)
                pipeline_data.points.setDenoiseParam(channel_indices(i), 'status', -1);
            end
        end
        set(handles{2}.channels_listbox, 'string', pipeline_data.points.getDenoiseText());
    end

    
% --- Executes during object creation, after setting all properties.
function points_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to points_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end

% --- Executes during object creation, after setting all properties.
function threshold_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes during object creation, after setting all properties.
function threshold_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function k_val_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to k_val_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function channels_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channels_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
