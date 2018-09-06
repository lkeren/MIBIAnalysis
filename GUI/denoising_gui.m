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

% Last Modified by GUIDE v2.5 06-Sep-2018 12:37:27

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
pipeline_data.dataNoBg = containers.Map;
pipeline_data.IntNormD = containers.Map;
pipeline_data.denoise_params = containers.Map;
pipeline_data.histograms = containers.Map;
% pipeline_data.IntNormDFutures = containers.Map;
pipeline_data.corePath = {};
pipeline_data.labels = {};
pipeline_data.tiffFigure = NaN;
pipeline_data.histFigure = NaN;
% pipeline_data.ignore = {'C', 'Ca', 'Na', '181', '197'};
% Choose default command line output for denoising_gui
handles.output = hObject;
[path, name, ext] = fileparts(mfilename('fullpath'));
pipeline_data.ignore = json.read([path,filesep,'ignore.json']);
warning('off', 'MATLAB:hg:uicontrol:StringMustBeNonEmpty');
warning('off', 'MATLAB:imagesci:tifftagsread:expectedTagDataFormat');
path = strsplit(path, filesep);
path(end) = [];
path = strjoin(path, filesep);
pipeline_data.defaultPath = path;
% Update handles structure
guidata(hObject, handles);

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


function manage_loaded_data(handles)
% goal is to look at the corePath variable, check that all raw data is
% loaded, and if it's not, load it. If there are extra keys in
% pipeline_data.dataNoBg, we should delete them.
    global pipeline_data;
    dataNoBgKeys = keys(pipeline_data.dataNoBg); % data that's already loaded
    corePath = pipeline_data.corePath; % data that should be loaded
    deletePaths = setdiff(dataNoBgKeys, corePath); % data that needs to be deleted
    loadPaths = setdiff(corePath, dataNoBgKeys); % datat hat needs to be loaded
    for i=1:numel(deletePaths) % remove data we don't want anymore
        point = deletePaths{i};
        remove(pipeline_data.dataNoBg, point); % remove debackgrounded data
        for lab=1:numel(pipeline_data.labels)
            channel = pipeline_data.labels{lab};
            key = [point, '_', channel];
            remove(pipeline_data.IntNormD, key);
            remove(pipeline_data.histograms, key);
        end
    end
    
    % we need to look inside of pipeline_data.intNormD (which is indexed by
    % pathname_channel) and delete all deletePaths_*
    
    hedges = 0:0.25:30;
    startTime = tic;
    if numel(loadPaths)>0
        wait = waitbar(0, 'Calculating nearest neighbors');
        for i=1:numel(loadPaths) % load unloaded data
            data = struct();
            [data.countsAllSFiltCRSum, data.labels] = load_tiff_data(loadPaths{i});
            pipeline_data.dataNoBg(loadPaths{i}) = data;
            pipeline_data.labels = data.labels;
            for j=1:numel(data.labels)
                key = [loadPaths{i},'_',data.labels{j}];
                if any(strcmp(pipeline_data.ignore, data.labels{j}))
                    k_val = 1;
                else
                    k_val = 25;
                end
                % note that we are establishing a naming convention here
                pipeline_data.IntNormD(key) = MIBI_get_int_norm_dist(data.countsAllSFiltCRSum(:,:,j), k_val);
                pipeline_data.histograms(key) = histcounts(pipeline_data.IntNormD(key),hedges,'Normalization','probability');

                fraction = ((i-1)*numel(data.labels)+j)/(numel(loadPaths)*numel(data.labels));
                timeLeft = (toc(startTime)/fraction)*(1-fraction);

                min = floor(timeLeft/60);
                sec = round(timeLeft-60*min);
                waitbar(fraction, wait, ['Calculating nearest neighbors. Time remaining: ', num2str(min), ' minutes and ', num2str(sec), ' seconds']);
                %end
            end
        end
        close(wait);
    end

% --- Executes on button press in add_point.
function add_point_Callback(hObject, eventdata, handles)
% hObject    handle to add_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pipeline_data
    pointdiles = uigetdiles(pipeline_data.defaultPath);
    pointdiles = setdiff(pointdiles, pipeline_data.corePath); % this should only add paths that haven't already been added
    if ~isempty(pointdiles)
        [filepath, name, ext] = fileparts(pointdiles{1});
        pipeline_data.defaultPath = filepath;
        curList = get(handles.selected_points_listbox, 'String');
        curList = cat(1,curList, pointdiles');
        set(handles.selected_points_listbox, 'String', curList);

        contents = cellstr(get(handles.selected_points_listbox, 'String'));
        % extract all labels and make sure they match
        labelSets = cell(size(contents));
        for i=1:numel(labelSets)
            labelSets{i} = getTIFFLabels(contents{i});
        end
        if numel(labelSets)==1 || isequal(labelSets{:}) % all the sets of labels are equal
            % set(handles.background_channel_menu, 'String', labelSets{1});
            % set(handles.eval_channel_menu, 'String', labelSets{1});
%             chan = get(handles.background_channel_menu, 'Value');
%             set(handles.background_channel_menu, 'Value', 1);
        end
        pipeline_data.corePath = contents;
        manage_loaded_data(handles);
    end

    
% --- Executes on button press in remove_point.
function remove_point_Callback(hObject, eventdata, handles)
% hObject    handle to remove_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        global pipeline_data;
        pointIndex = get(handles.selected_points_listbox, 'Value');
        pointList = get(handles.selected_points_listbox, 'String');
        removedPoint = pointList{pointIndex};
        if numel(pointList) ~= 0
            pointList(pointIndex) = [];
        end
        set(handles.selected_points_listbox, 'String', pointList);
    %     if numel(pointList) == 0
    %         set(handles.background_channel_menu, 'String', ' ');
    %         set(handles.background_channel_menu, 'Value', 1);
    %         set(handles.eval_channel_menu, 'String', ' ');
    %         set(handles.eval_channel_menu, 'Value', 1);
    %     end
        if pointIndex~=1
            set(handles.selected_points_listbox, 'Value', pointIndex-1);
        else
            set(handles.selected_points_listbox, 'Value', 1);
        end
        pipeline_data.corePath = pointList;
        manage_loaded_data(handles);
    catch
        % probably no points to remove
    end
    
% --- Executes on selection change in selected_points_listbox.
function selected_points_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to selected_points_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selected_points_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selected_points_listbox


% --- Executes during object creation, after setting all properties.
function selected_points_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selected_points_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel_select_menu.
function channel_select_menu_Callback(hObject, eventdata, handles)
% hObject    handle to channel_select_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel_select_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel_select_menu
    contents = cellstr(get(hObject,'String'));
    selected_channel = contents{get(hObject,'Value')};
	contents = cellstr(get(handles.selected_points_listbox,'String'));
	selected_point = contents{get(handles.selected_points_listbox,'Value')};

% --- Executes during object creation, after setting all properties.
function channel_select_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_select_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function point = getPointName(handles)
    contents = cellstr(get(handles.selected_points_listbox,'String'));
    point = contents{get(handles.selected_points_listbox,'Value')};

   
function channel_params = getChannelParams(handles)
    contents = cellstr(get(handles.channel_list_box,'String'));
    channel_params = strsplit(tabSplit(contents{get(handles.channel_list_box,'Value')}), char(8197));
    
    
function channel = getChannelName(handles)
    contents = cellstr(get(handles.channel_list_box,'String'));
    channel_params = strsplit(tabSplit(contents{get(handles.channel_list_box,'Value')}), char(8197));
    channel = channel_params{1};
    
function initDenoiseParams(labels)
    % the init k-val will be 25
    % the init threshold will be 3.5
    global pipeline_data;
    for label = 1:numel(labels)
        param_struct = struct();
        if any(strcmp(pipeline_data.ignore, labels{label}))
            param_struct.k_val = 1;
        else
            param_struct.k_val = 25;
        end
        param_struct.threshold = 3.5;
        param_struct.status = 0;
        pipeline_data.denoise_params(labels{label}) = param_struct;
    end
 
function generateDenoiseParamText(handles)
    global pipeline_data;
    labels = keys(pipeline_data.denoise_params);
    denoiseParamsText = cell(size(labels));
    for i = 1:numel(labels)
        label = labels{i};
        threshold = pipeline_data.denoise_params(label).threshold;
        k_val = pipeline_data.denoise_params(label).k_val;
        status = '.';
        switch pipeline_data.denoise_params(label).status
            case 0
                status = '.';
            case 1
                status = 'X';
        end
        denoiseParamsText{i} = tabJoin({label, num2str(threshold), num2str(k_val), status}, 15);
    end
    set(handles.channel_list_box, 'String', denoiseParamsText);
    

function setThresholdParam(handles)
    global pipeline_data;
    channel_params = getChannelParams(handles);
    channel = channel_params{1}; % channel name
    threshold = str2double(get(handles.threshold_display_box, 'String'));
    k_val = pipeline_data.denoise_params(channel).k_val;
    temp = struct();
    temp.threshold = threshold;
    temp.k_val = k_val;
    temp.status = pipeline_data.denoise_params(channel).status;
    pipeline_data.denoise_params(channel) = temp;
    generateDenoiseParamText(handles);
    

function setKValParam(handles)
    global pipeline_data;
    channel_params = getChannelParams(handles);
    channel = channel_params{1}; % channel name
    threshold = pipeline_data.denoise_params(channel).threshold;
    k_val = str2double(get(handles.k_val_display_box, 'String'));
    temp = struct();
    temp.threshold = threshold;
    temp.k_val = k_val;
    temp.status = pipeline_data.denoise_params(channel).status;
    pipeline_data.denoise_params(channel) = temp;
    generateDenoiseParamText(handles);
    
function plotDenoisingParams(handles)
    global pipeline_data;
    channel_params = getChannelParams(handles);
    label = channel_params{1};
    temp = pipeline_data.denoise_params(label);
    point = getPointName(handles);
    countsNoBg = pipeline_data.dataNoBg(point);
    plotChannelInd = find(strcmp(countsNoBg.labels, label));
    key = [point,'_',label];
    hedges = 0:0.25:30;
    % at this point it's possible that we haven't actually calculated this
    % data, so we need to do that in case we don't get anything.
    try
        IntNormD = pipeline_data.IntNormD(key);
        countsNoNoise = MibiFilterImageByNNThreshold(countsNoBg.countsAllSFiltCRSum(:,:,plotChannelInd), IntNormD, temp.threshold);
    catch
        try
            set(handles.figure1, 'pointer', 'watch')
            drawnow
            pipeline_data.IntNormD(key) = MIBI_get_int_norm_dist(countsNoBg.countsAllSFiltCRSum(:,:,plotChannelInd), temp.k_val);
            pipeline_data.histograms(key) = histcounts(pipeline_data.IntNormD(key),hedges,'Normalization','probability');
            IntNormD = pipeline_data.IntNormD(key);
            countsNoNoise = MibiFilterImageByNNThreshold(countsNoBg.countsAllSFiltCRSum(:,:,plotChannelInd), IntNormD, temp.threshold);
            set(handles.figure1, 'pointer', 'arrow');
        catch e
            disp(e);
        end
    end
        
    try
        sfigure(pipeline_data.tiffFigure);
    catch
        pipeline_data.tiffFigure = sfigure();
    end
    imagesc(countsNoNoise);
    try
        sfigure(pipeline_data.histFigure);
    catch
        pipeline_data.histFigure = sfigure();
    end
    hedges(end) = [];
    h = pipeline_data.histograms(key);
    %h = histogram(IntNormD,hedges,'Normalization','probability');
    hold off;
    bar(hedges, h, 'histc');
    hold on;
    lim = ylim;
    plot([temp.threshold, temp.threshold], [0, lim(2)], 'r');
    ylim(lim);
    % plot(rand(5,1), rand(5,1));
    
    

% function getDenoiseParams(handles)
%     

% --- Executes on button press in select_point.
function select_point_Callback(hObject, eventdata, handles)
% hObject    handle to select_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        global pipeline_data;
        point = getPointName(handles);
        set(handles.selected_point_text, 'String', point);
        pipeline_data.labels = pipeline_data.dataNoBg(point).labels;
        if isempty(keys(pipeline_data.denoise_params))
            initDenoiseParams(pipeline_data.dataNoBg(point).labels);
            generateDenoiseParamText(handles)
            set(handles.channel_list_box, 'Value', 1);
        else
            % we're actually going to assume, for now at least, that all the
            % points have the same channels. We'll add code to handle this
            % exception later.
        end
        plotDenoisingParams(handles);
    catch
        % do nothing
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
        set(handles.threshold_display_box, 'String', num2str(val));
        setThresholdParam(handles);
        plotDenoisingParams(handles);
    catch

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

function threshold_display_box_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_display_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold_display_box as text
%        str2double(get(hObject,'String')) returns contents of threshold_display_box as a double
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

% --- Executes during object creation, after setting all properties.
function threshold_display_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_display_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function k_val_display_box_Callback(hObject, eventdata, handles)
% hObject    handle to k_val_display_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of k_val_display_box as text
%        str2double(get(hObject,'String')) returns contents of k_val_display_box as a double
    % setDenoiseParams(handles)

% --- Executes during object creation, after setting all properties.
function k_val_display_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to k_val_display_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reset_k_val.
function reset_k_val_Callback(hObject, eventdata, handles)
% hObject    handle to reset_k_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        channel_params = getChannelParams(handles);
        k_val = channel_params{3};
        set(handles.k_val_display_box, 'String', k_val);
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
        point = getPointName(handles);
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

% --- Executes on selection change in channel_list_box.
function channel_list_box_Callback(hObject, eventdata, handles)
% hObject    handle to channel_list_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel_list_box contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel_list_box
    try
        global pipeline_data;
        channel_params = getChannelParams(handles);
        label = channel_params{1};
        temp = pipeline_data.denoise_params(label);
        if strcmp(get(gcf,'selectiontype'),'open')
            temp.status = 1-temp.status;
            pipeline_data.denoise_params(label) = temp;
            generateDenoiseParamText(handles);
        end
        threshold = channel_params{2};
        k_val = channel_params{3};
        set(handles.threshold_display_box, 'String', threshold);
        set(handles.k_val_display_box, 'String', k_val);
        t = str2double(threshold);
        if t<get(handles.threshold_slider, 'Min')
            set(handles.threshold_slider, 'Min', t);
        elseif t>get(handles.threshold_slider, 'Max')
            set(handles.threshold_slider, 'Max', t);
        else
            
        end
        set(handles.threshold_slider, 'Value', str2double(threshold));
        plotDenoisingParams(handles)
    catch
        
    end
    
    
%     countsNoNoise{i} = MibiFilterImageByNNThreshold(p{i}.countsNoBg(:,:,plotChannelInd),p{i}.IntNormD{plotChannelInd},t);
%     MibiPlotDataAndCap(p{i}.countsNoBg(:,:,plotChannelInd),capImage,['Core number ',num2str(i), ' - Before']); plotbrowser on;
%     MibiPlotDataAndCap(countsNoNoise{i},capImage,['Core number ',num2str(i), ' - After. T=',num2str(t)]); plotbrowser on;
    

% --- Executes during object creation, after setting all properties.
function channel_list_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_list_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in threshold_minmax_button.
function threshold_minmax_button_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_minmax_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    vals = inputdlg({'Threshold minimum', 'Threshold maximum'});
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
            set(handles.threshold_display_box, 'String', value);
            setThresholdParam(handles);
            plotDenoisingParams(handles);
        else
            gui_warning('Threshold maximum must be greater than threshold minimum');
        end
    catch
        gui_warning('You did not enter valid numbers');
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
            set(handles.selected_points_listbox, 'String', pipeline_data.corePath);
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
    cleanDataPath = uigetdir(); % this is also where it will place the log
    if cleanDataPath~=0
        set(handles.figure1, 'pointer', 'watch');
        drawnow
        pipeline_data.noiseT = zeros(size(pipeline_data.labels));
        pipeline_data.IntNormDData = containers.Map;
        for lab=1:numel(pipeline_data.noiseT)
            pipeline_data.noiseT(lab) = pipeline_data.denoise_params(pipeline_data.labels{lab}).threshold;
        end
        for poi=1:numel(pipeline_data.corePath)
            IntNormDCell = cell(size(pipeline_data.labels));
            for lab=1:numel(pipeline_data.labels)
                key = [pipeline_data.corePath{poi}, '_', pipeline_data.labels{lab}];
                % disp(key);
                IntNormDCell{lab} = pipeline_data.IntNormD(key);
            end
            pipeline_data.IntNormDData(pipeline_data.corePath{poi}) = IntNormDCell;
        end

        cleanDataPath = [cleanDataPath, filesep, 'cleanData'];
        mkdir(cleanDataPath);
        waitfig = waitbar(0, 'Denoising points...');
        for i=1:numel(pipeline_data.corePath)
            path = pipeline_data.corePath{i};
            countsNoNoise = MibiFilterAllByNN(pipeline_data.dataNoBg(path).countsAllSFiltCRSum,pipeline_data.IntNormDData(path),pipeline_data.noiseT);
            mkdir([cleanDataPath,'/Point',num2str(i)]);
            save([cleanDataPath,'/Point',num2str(i),'/dataDeNoiseCohort.mat'],'countsNoNoise');
            MibiSaveTifs ([cleanDataPath,'/Point',num2str(i),'/TIFsNoNoise/'], countsNoNoise, pipeline_data.labels)
            waitbar(i/numel(pipeline_data.corePath), waitfig, 'Denoising points...');
    %         close all;
        end
        close(waitfig);
        fid = fopen([cleanDataPath, filesep, '[', datestr(datetime('now')), ']_denoising.log'], 'wt');
        for i=1:numel(pipeline_data.labels)
            label = pipeline_data.labels{i};
            params = pipeline_data.denoise_params(label);
            fprintf(fid, [label, ': {', newline]);
            fprintf(fid, [char(9), '  K-value: ', num2str(params.k_val), newline]);
            fprintf(fid, [char(9), 'threshold: ', num2str(params.threshold), ' }', newline]); 
        end
        fclose(fid);
        set(handles.figure1, 'pointer', 'arrow');
        disp('Done denoising');
        gong = load('gong.mat');
        sound(gong.y, gong.Fs)
    end
