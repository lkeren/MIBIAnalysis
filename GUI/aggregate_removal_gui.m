function varargout = aggregate_removal_gui(varargin)
% AGGREGATE_REMOVAL_GUI MATLAB code for aggregate_removal_gui.fig
%      AGGREGATE_REMOVAL_GUI, by itself, creates a new AGGREGATE_REMOVAL_GUI or raises the existing
%      singleton*.
%
%      H = AGGREGATE_REMOVAL_GUI returns the handle to a new AGGREGATE_REMOVAL_GUI or the handle to
%      the existing singleton*.
%
%      AGGREGATE_REMOVAL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in AGGREGATE_REMOVAL_GUI.M with the given input arguments.
%
%      AGGREGATE_REMOVAL_GUI('Property','Value',...) creates a new AGGREGATE_REMOVAL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before aggregate_removal_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to aggregate_removal_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help aggregate_removal_gui

% Last Modified by GUIDE v2.5 06-Sep-2018 15:38:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @aggregate_removal_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @aggregate_removal_gui_OutputFcn, ...
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


% --- Executes just before aggregate_removal_gui is made visible.
function aggregate_removal_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to aggregate_removal_gui (see VARARGIN)

global pipeline_data;
json.startup;
pipeline_data = struct();
pipeline_data.tiffFigure = NaN;
pipeline_data.corePath = {};
pipeline_data.dataNoNoise = containers.Map;
pipeline_data.aggRM_params = containers.Map;
[path, name, ext] = fileparts(mfilename('fullpath'));
pipeline_data.ignore = json.read([path,filesep,'ignore.json']);
warning('off', 'MATLAB:hg:uicontrol:StringMustBeNonEmpty');
warning('off', 'MATLAB:imagesci:tifftagsread:expectedTagDataFormat');
path = strsplit(path, filesep);
path(end) = [];
path = strjoin(path, filesep);
pipeline_data.defaultPath = path;
% Choose default command line output for aggregate_removal_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes aggregate_removal_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = aggregate_removal_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function manage_loaded_data(handles)
% goal is to look at the corePath variable, check that all raw data is
% loaded, and if it's not, load it. If there are extra keys in
% pipeline_data.dataNoNoise, we should delete them.
    global pipeline_data;
    dataNoNoiseKeys = keys(pipeline_data.dataNoNoise); % data that's already loaded
    corePath = pipeline_data.corePath; % data that should be loaded
    deletePaths = setdiff(dataNoNoiseKeys, corePath); % data that needs to be deleted
    loadPaths = setdiff(corePath, dataNoNoiseKeys); % datat hat needs to be loaded
    for i=1:numel(deletePaths) % remove data we don't want anymore
        point = deletePaths{i};
        remove(pipeline_data.dataNoNoise, point); % remove debackgrounded data
%         for lab=1:numel(pipeline_data.labels)
%             channel = pipeline_data.labels{lab};
%             key = [point, '_', channel];
%         end
    end
    
    hedges = 0:0.25:30;
    startTime = tic;
    if numel(loadPaths)>0
        wait = waitbar(0, ['Loading TIFF data...', newline, '"When I let go of what I am, I become what I might be." - Lao Tzu']);
        for i=1:numel(loadPaths) % load unloaded data
            data = struct();
            [data.countsAllSFiltCRSum, data.labels] = loadTIFF_data(loadPaths{i});
            pipeline_data.dataNoNoise(loadPaths{i}) = data;
            pipeline_data.labels = data.labels;
            for j=1:numel(data.labels)
                key = [loadPaths{i},'_',data.labels{j}];
                if any(strcmp(pipeline_data.ignore, data.labels{j}))
                    k_val = 1;
                else
                    k_val = 25;
                end
                % note that we are establishing a naming convention here
                fraction = ((i-1)*numel(data.labels)+j)/(numel(loadPaths)*numel(data.labels));
                timeLeft = (toc(startTime)/fraction)*(1-fraction);

                min = floor(timeLeft/60);
                sec = round(timeLeft-60*min);
                waitbar(fraction, wait, ['Loading TIFF data. Time remaining: ', num2str(min), ' minutes and ', num2str(sec), ' seconds', newline, '"When I let go of what I am, I become what I might be." - Lao Tzu.']);
                %end
            end
        end
        close(wait);
    end


function point = getPointName(handles)
    contents = cellstr(get(handles.points_listbox,'String'));
    point = contents{get(handles.points_listbox,'Value')};

   
function channel_params = getChannelParams(handles)
    contents = cellstr(get(handles.channel_listbox,'String'));
    channel_params = strsplit(tabSplit(contents{get(handles.channel_listbox,'Value')}), char(8197));
    
    
function channel = getChannelName(handles)
    contents = cellstr(get(handles.channel_listbox,'String'));
    channel_params = strsplit(tabSplit(contents{get(handles.channel_listbox,'Value')}), char(8197));
    channel = channel_params{1};
    
function initAggRmParams(labels)
    % the init k-val will be 25
    % the init threshold will be 3.5
    global pipeline_data;
    for label = 1:numel(labels)
        param_struct = struct();
        param_struct.threshold = 100;
        param_struct.radius = 1;
        param_struct.capImage = 5;
        param_struct.status = 0;
        pipeline_data.aggRM_params(labels{label}) = param_struct;
    end
 
function generateAggRmParamText(handles)
    global pipeline_data;
    labels = keys(pipeline_data.aggRM_params);
    aggRMParamsText = cell(size(labels));
    for i = 1:numel(labels)
        label = labels{i};
        threshold = pipeline_data.aggRM_params(label).threshold;
        radius = pipeline_data.aggRM_params(label).radius;
        capImage = pipeline_data.aggRM_params(label).capImage;
        status = '.';
        switch pipeline_data.aggRM_params(label).status
            case 0
                status = '.';
            case 1
                status = 'X';
        end
        aggRMParamsText{i} = tabJoin({label, num2str(threshold), num2str(radius), num2str(capImage), status}, [15, 13, 10, 10]);
    end
    set(handles.channel_listbox, 'String', aggRMParamsText);
    

function setThresholdParam(handles)
    global pipeline_data;
    channel_params = getChannelParams(handles);
    channel = channel_params{1}; % channel name
    threshold = str2double(get(handles.threshold_display_text, 'String'));
    temp = struct();
    temp.threshold = threshold;
    temp.radius = pipeline_data.aggRM_params(channel).radius;
    temp.capImage = pipeline_data.aggRM_params(channel).capImage;
    temp.status = pipeline_data.aggRM_params(channel).status;
    pipeline_data.aggRM_params(channel) = temp;
    generateAggRmParamText(handles);
    
function setRadiusParam(handles)
    global pipeline_data;
    channel_params = getChannelParams(handles);
    channel = channel_params{1}; % channel name
    radius = str2double(get(handles.radius_display_text, 'String'));
    temp = struct();
    temp.radius = radius;
    temp.threshold = pipeline_data.aggRM_params(channel).threshold;
    temp.capImage = pipeline_data.aggRM_params(channel).capImage;
    temp.status = pipeline_data.aggRM_params(channel).status;
    pipeline_data.aggRM_params(channel) = temp;
    generateAggRmParamText(handles);
    
function setCapParam(handles)
    global pipeline_data;
    channel_params = getChannelParams(handles);
    channel = channel_params{1}; % channel name
    capImage = str2double(get(handles.cap_display_text, 'String'));
    temp = struct();
    temp.capImage = capImage;
    temp.threshold = pipeline_data.aggRM_params(channel).threshold;
    temp.radius = pipeline_data.aggRM_params(channel).radius;
    temp.status = pipeline_data.aggRM_params(channel).status;
    pipeline_data.aggRM_params(channel) = temp;
    generateAggRmParamText(handles);
    

function setThresholdSlider(val, handles)
    try
        % val = str2double(get(hObject,'String'));
        if val<get(handles.threshold_slider, 'Min')
            set(handles.threshold_slider, 'Min', val);
        elseif val>get(handles.threshold_slider, 'Max')
            set(handles.threshold_slider, 'Max', val);
        else
            
        end
        set(handles.threshold_slider, 'Value', val);
        setThresholdParam(handles);
    catch
        
    end
    
function setRadiusSlider(val, handles)
    try
        % val = str2double(get(hObject,'String'));
        if val<get(handles.radius_slider, 'Min')
            set(handles.radius_slider, 'Min', val);
        elseif val>get(handles.radius_slider, 'Max')
            set(handles.radius_slider, 'Max', val);
        else
            
        end
        set(handles.radius_slider, 'Value', val);
        setRadiusParam(handles);
    catch
        
    end
    
function setCapSlider(val, handles)
    try
        % val = str2double(get(hObject,'String'));
        if val<get(handles.cap_slider, 'Min')
            set(handles.cap_slider, 'Min', val);
        elseif val>get(handles.cap_slider, 'Max')
            set(handles.cap_slider, 'Max', val);
        else
            
        end
        set(handles.cap_slider, 'Value', val);
        setCapParam(handles);
    catch
        
    end
    
    
function plotAggRmParams(handles)
    global pipeline_data;
    channel_params = getChannelParams(handles);
    label = channel_params{1};
    threshold = str2double(channel_params{2});
    radius = str2double(channel_params{3});
    capImage = str2double(channel_params{4});
    temp = pipeline_data.aggRM_params(label);
    point = getPointName(handles);
    countsNoNoise = pipeline_data.dataNoNoise(point);
    plotChannelInd = find(strcmp(countsNoNoise.labels, label));
    xlimits = NaN;
    ylimits = NaN;
    try
        sfigure(pipeline_data.tiffFigure);
        xlimits = xlim;
        ylimits = ylim;
    catch
        pipeline_data.tiffFigure = sfigure();
        handles.reset_button = uicontrol('Parent',pipeline_data.tiffFigure,'Style','pushbutton','String','Reset','Units','normalized','Position',[0.015 .94 0.1 0.05],'Visible','on', 'Callback', @reset_plot_Callback);
    end
    
    try
        if radius==0
            gausFlag = 0;
        else
            gausFlag = 1;
        end
        countsNoNoiseNoAgg = gui_MibiFilterAggregates(countsNoNoise.countsAllSFiltCRSum(:,:,plotChannelInd),radius,threshold,gausFlag);
        size(countsNoNoiseNoAgg);
        
        currdata = countsNoNoiseNoAgg;
        currdata(currdata>capImage) = capImage;
        pipeline_data.currdata = currdata;
        sfigure(pipeline_data.tiffFigure);
        
        imagesc(currdata);
        if ~isnan(xlimits)
            xlim(xlimits);
            ylim(ylimits);
        end
        title(label);
    catch
        
    end   
    
    
function reset_plot_Callback(hObject, eventdata, hadles)
    % handles = guidata(hObject);
    global pipeline_data;
    sfigure(pipeline_data.tiffFigure);
    imagesc(pipeline_data.currdata);
%     channel_params = getChannelParams(handles);
%     label = channel_params{1};
%     title(label);
    
% --- Executes on button press in add_point_button.
function add_point_button_Callback(hObject, eventdata, handles)
% hObject    handle to add_point_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global pipeline_data
    pointdiles = uigetdiles(pipeline_data.defaultPath);
    pointdiles = setdiff(pointdiles, pipeline_data.corePath); % this should only add paths that haven't already been added
    if ~isempty(pointdiles)
        [filepath, name, ext] = fileparts(pointdiles{1});
        pipeline_data.defaultPath = filepath;
        curList = get(handles.points_listbox, 'String');
        curList = cat(1,curList, pointdiles');
        set(handles.points_listbox, 'String', curList);

        contents = cellstr(get(handles.points_listbox, 'String'));
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
    

% --- Executes on button press in remove_point_button.
function remove_point_button_Callback(hObject, eventdata, handles)
% hObject    handle to remove_point_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
        global pipeline_data;
        pointIndex = get(handles.points_listbox, 'Value');
        pointList = get(handles.points_listbox, 'String');
        removedPoint = pointList{pointIndex};
        if numel(pointList) ~= 0
            pointList(pointIndex) = [];
        end
        set(handles.points_listbox, 'String', pointList);
        if pointIndex~=1
            set(handles.points_listbox, 'Value', pointIndex-1);
        else
            set(handles.points_listbox, 'Value', 1);
        end
        pipeline_data.corePath = pointList;
        manage_loaded_data(handles);
    catch
        % probably no points to remove
    end

% --- Executes on button press in select_point_button.
function select_point_button_Callback(hObject, eventdata, handles)
% hObject    handle to select_point_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        global pipeline_data;
        point = getPointName(handles);
        set(handles.selected_point_text, 'String', point);
        pipeline_data.labels = pipeline_data.dataNoNoise(point).labels;
        if isempty(keys(pipeline_data.aggRM_params))
            initAggRmParams(pipeline_data.dataNoNoise(point).labels);
            generateAggRmParamText(handles)
            set(handles.channel_listbox, 'Value', 1);
        else
            % we're actually going to assume, for now at least, that all the
            % points have the same channels. We'll add code to handle this
            % exception later.
        end
        plotAggRmParams(handles);
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
        set(handles.threshold_display_text, 'String', num2str(val));
        setThresholdParam(handles);
        plotAggRmParams(handles);
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


function threshold_display_text_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_display_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of threshold_display_text as text
%        str2double(get(hObject,'String')) returns contents of threshold_display_text as a double
    try
        val = str2double(get(hObject,'String'));
        setThresholdSlider(val, handles);
        plotAggRmParams(handles);
    catch
        
    end

% --- Executes during object creation, after setting all properties.
function threshold_display_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_display_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in channel_listbox.
function channel_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns channel_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from channel_listbox
    try
        global pipeline_data;
        channel_params = getChannelParams(handles);
        label = channel_params{1};
        temp = pipeline_data.aggRM_params(label);
        if strcmp(get(gcf,'selectiontype'),'open')
            temp.status = 1-temp.status;
            pipeline_data.aggRM_params(label) = temp;
            generateAggRmParamText(handles);
        end
        threshold = channel_params{2};
        radius = channel_params{3};
        cap = channel_params{4};
        set(handles.threshold_display_text, 'String', threshold);
        set(handles.radius_display_text, 'String', radius);
        set(handles.cap_display_text, 'String', cap);
        setThresholdSlider(str2double(threshold), handles);
        setRadiusSlider(str2double(radius), handles);
        setCapSlider(str2double(cap), handles);
        plotAggRmParams(handles)
    catch
        
    end

% --- Executes during object creation, after setting all properties.
function channel_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to channel_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in threshold_button.
function threshold_button_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_button (see GCBO)
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
            set(handles.threshold_display_text, 'String', value);
            setThresholdParam(handles);
        else
            gui_warning('Threshold maximum must be greater than threshold minimum');
        end
    catch
        % gui_warning('You did not enter valid numbers');
    end

% --- Executes on button press in remove_aggregates_button.
function remove_aggregates_button_Callback(hObject, eventdata, handles)
% hObject    handle to remove_aggregates_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global pipeline_data;
    cleanDataPath = uigetdir();
    if cleanDataPath~=0
        set(handles.figure1, 'pointer', 'watch');
        drawnow
        cleanDataPath = [cleanDataPath, filesep, 'noAggData'];
        mkdir(cleanDataPath);
        waitfig = waitbar(0, 'Removing aggregates...');
        for i=1:numel(pipeline_data.corePath)
            % first we construct the aggregate-removed data using the
            % chosen parameters
            countsNoNoise = pipeline_data.dataNoNoise(pipeline_data.corePath{i}).countsAllSFiltCRSum;
            countsNoNoiseNoAgg = zeros(size(countsNoNoise));
            for j=1:numel(pipeline_data.labels)
                channel_params = pipeline_data.aggRM_params(pipeline_data.labels{j});
                threshold = channel_params.threshold;
                radius = channel_params.radius;
                if radius==0
                    gausFlag = 0;
                else
                    gausFlag = 1;
                end
                
                countsNoNoiseNoAgg(:,:,j) = gui_MibiFilterAggregates(countsNoNoise(:,:,j),radius,threshold,gausFlag);
            end
            [savePath, file, ~] = fileparts(pipeline_data.corePath{i});
            [savePath, ~, ~] = fileparts(savePath);
            savePath = [savePath, filesep, 'NoAggData'];
%             path = [cleanDataPath, filesep, file];
%             mkdir(path);
            gui_MibiSaveTifs([savePath,filesep,file,'_TIFsNoAgg', filesep], countsNoNoiseNoAgg, pipeline_data.labels);
            save([savePath, filesep,file,'_dataNoAgg.mat'],'countsNoNoiseNoAgg');
            waitbar(i/numel(pipeline_data.corePath), waitfig, 'Removing aggregates...');
        end
        close(waitfig);
        fid = fopen([cleanDataPath, filesep, '[', datestr(datetime('now')), ']_agg_removal.log'], 'wt');
        for i=1:numel(pipeline_data.labels)
            label = pipeline_data.labels{i};
            params = pipeline_data.aggRM_params(label);
            fprintf(fid, [label, ': {', newline]);
            fprintf(fid, [char(9), 'threshold: ', num2str(params.threshold), newline]);
            fprintf(fid, [char(9), '   radius: ', num2str(params.radius), ' }', newline]); 
        end
        fclose(fid);
        set(handles.figure1, 'pointer', 'arrow');
        msgbox('Done removing aggregates');
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
        save([path, filesep, file], 'pipeline_data')
    catch
        
    end

% --- Executes on button press in load_run_button.
function load_run_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_run_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    [file,path] = uigetfile('*.mat');
    set(handles.figure1, 'pointer', 'watch');
    drawnow
    global pipeline_data;
    try
        pipeline_data = load([path, filesep, file]);
        try
            pipeline_data = pipeline_data.pipeline_data;
            set(handles.points_listbox, 'String', pipeline_data.corePath);
            generateAggRmParamText(handles);
        catch
            gui_warning('Invalid file');
        end
    catch
        % do nothing
    end
    set(handles.figure1, 'pointer', 'arrow');

% --- Executes on slider movement.
function cap_slider_Callback(hObject, eventdata, handles)
% hObject    handle to cap_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    try
        val = get(hObject,'Value');
        set(handles.cap_display_text, 'String', num2str(val));
        setCapParam(handles);
        plotAggRmParams(handles);
    catch

    end

% --- Executes during object creation, after setting all properties.
function cap_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cap_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function cap_display_text_Callback(hObject, eventdata, handles)
% hObject    handle to cap_display_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cap_display_text as text
%        str2double(get(hObject,'String')) returns contents of cap_display_text as a double
    try
        val = str2double(get(hObject,'String'));
        setCapSlider(val, handles);
        plotAggRmParams(handles);
    catch
        
    end

% --- Executes during object creation, after setting all properties.
function cap_display_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cap_display_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in cap_button.
function cap_button_Callback(hObject, eventdata, handles)
% hObject    handle to cap_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
defaults = {num2str(get(handles.cap_slider, 'Min')), num2str(get(handles.cap_slider, 'Max'))};
vals = inputdlg({'Image cap minimum', 'Image cap maximum'}, 'Image cap range', 1, defaults);
    try
        vals = str2double(vals);
        if vals(2)>vals(1)
            value = get(handles.cap_slider, 'Value');
            if value<vals(1) % value less than minimum
                value = vals(1);
            elseif value>vals(2) % value greater than maximum
                value = vals(2);
            else
                % value is fine
            end
            set(handles.cap_slider, 'Min', vals(1));
            set(handles.cap_slider, 'Max', vals(2));
            set(handles.cap_slider, 'Value', value);
            set(handles.cap_display_text, 'String', value);
            setCapParam(handles);
            plotAggRmParams(handles);
        else
            gui_warning('Image cap maximum must be greater than image cap minimum');
        end
    catch
        % gui_warning('You did not enter valid numbers');
    end

% --- Executes on slider movement.
function radius_slider_Callback(hObject, eventdata, handles)
% hObject    handle to radius_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    try
        val = get(hObject,'Value');
        set(handles.radius_display_text, 'String', num2str(val));
        setRadiusParam(handles);
        plotAggRmParams(handles);
    catch

    end

% --- Executes during object creation, after setting all properties.
function radius_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radius_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function radius_display_text_Callback(hObject, eventdata, handles)
% hObject    handle to radius_display_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of radius_display_text as text
%        str2double(get(hObject,'String')) returns contents of radius_display_text as a double
    try
        val = str2double(get(hObject,'String'));
        setRadiusSlider(val, handles);
        plotAggRmParams(handles);
    catch
        
    end

% --- Executes during object creation, after setting all properties.
function radius_display_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radius_display_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in gauss_radius_button.
function gauss_radius_button_Callback(hObject, eventdata, handles)
% hObject    handle to gauss_radius_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
defaults = {num2str(get(handles.radius_slider, 'Min')), num2str(get(handles.radius_slider, 'Max'))};
vals = inputdlg({'Gaussian Radius minimum', 'Gaussian Radius maximum'}, 'Gaussian Radius range', 1, defaults);
    try
        vals = str2double(vals);
        if vals(2)>vals(1)
            value = get(handles.radius_slider, 'Value');
            if value<vals(1) % value less than minimum
                value = vals(1);
            elseif value>vals(2) % value greater than maximum
                value = vals(2);
            else
                % value is fine
            end
            set(handles.radius_slider, 'Min', vals(1));
            set(handles.radius_slider, 'Max', vals(2));
            set(handles.radius_slider, 'Value', value);
            set(handles.radius_display_text, 'String', value);
            setRadiusParam(handles);
            plotAggRmParams(handles);
        else
            gui_warning('Radius maximum must be greater than radius minimum');
        end
    catch
        % gui_warning('You did not enter valid numbers');
    end

% --- Executes on selection change in points_listbox.
function points_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to points_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns points_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from points_listbox


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
