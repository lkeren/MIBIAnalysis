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
%      AGGREGATE_REMOVAL_GUI('Property','value',...) creates a new AGGREGATE_REMOVAL_GUI or raises the
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
pipeline_data.points = PointManager();
pipeline_data.tiffFigure = NaN;
pipeline_data.corePath = {};
pipeline_data.dataNoNoise = containers.Map;
pipeline_data.aggRM_params = containers.Map;
[path, name, ext] = fileparts(mfilename('fullpath'));
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

function point = getPointName(handles)
    contents = cellstr(get(handles.points_listbox,'string'));
    point = contents{get(handles.points_listbox,'value')};

   
function channel_params = getChannelParams(handles)
    global pipeline_data;
    channel_index = get(handles.channel_listbox, 'value');
    channel_params = pipeline_data.points.getAggRmParam(channel_index);
    
function generateAggRmParamText(handles)
    global pipeline_data;
    set(handles.channel_listbox, 'string', pipeline_data.points.getAggRmText());
    
function setThresholdParam(handles)
    global pipeline_data;
    channel_index = get(handles.channel_listbox, 'value');
    threshold = str2double(get(handles.threshold_display_text, 'string'));
    pipeline_data.points.setAggRmParam(channel_index, 'threshold', threshold);
    generateAggRmParamText(handles);
    
function setRadiusParam(handles)
    global pipeline_data;
    channel_index = get(handles.channel_listbox, 'value');
    radius = str2double(get(handles.radius_display_text, 'string'));
    pipeline_data.points.setAggRmParam(channel_index, 'radius', radius);
    generateAggRmParamText(handles);
    
function setCapParam(handles)
    global pipeline_data;
    channel_index = get(handles.channel_listbox, 'value');
    capImage = str2double(get(handles.radius_display_text, 'string'));
    pipeline_data.points.setAggRmParam(channel_index, 'capImage', capImage);
    generateAggRmParamText(handles);
    
function setThresholdSlider(val, handles)
    try
        if val<get(handles.threshold_slider, 'min')
            set(handles.threshold_slider, 'min', val);
        elseif val>get(handles.threshold_slider, 'max')
            set(handles.threshold_slider, 'max', val);
        else
        end
        set(handles.threshold_slider, 'value', val);
        setThresholdParam(handles);
    catch
        
    end
    
function setRadiusSlider(val, handles)
    try
        if val<get(handles.radius_slider, 'min')
            set(handles.radius_slider, 'min', val);
        elseif val>get(handles.radius_slider, 'max')
            set(handles.radius_slider, 'max', val);
        else
        end
        set(handles.radius_slider, 'value', val);
        setRadiusParam(handles);
    catch
        
    end
    
function setCapSlider(val, handles)
    try
        if val<get(handles.cap_slider, 'min')
            set(handles.cap_slider, 'min', val);
        elseif val>get(handles.cap_slider, 'max')
            set(handles.cap_slider, 'max', val);
        else
        end
        set(handles.cap_slider, 'value', val);
        setCapParam(handles);
    catch
        
    end
    
function plotAggRmParams(handles)
    global pipeline_data;
    label_index = get(handles.channel_listbox, 'value');
    params = pipeline_data.points.getAggRmParam(label_index);
    label = params.label;
    threshold = params.threshold;
    radius = params.radius;
    capImage = params.capImage;
    point = pipeline_data.points.get('name', getPointName(handles));
    countsNoNoise = point.counts;
    plotChannelInd = find(strcmp(pipeline_data.points.labels(), label));
    xlimits = NaN;
    ylimits = NaN;
    try
        sfigure(pipeline_data.tiffFigure);
        xlimits = xlim;
        ylimits = ylim;
    catch
        pipeline_data.tiffFigure = sfigure();
        handles.reset_button = uicontrol('Parent',pipeline_data.tiffFigure,'Style','pushbutton','string','Reset','Units','normalized','Position',[0.015 .94 0.1 0.05],'Visible','on', 'Callback', @reset_plot_Callback);
    end
    
    try
        if radius==0
            gausFlag = 0;
        else
            gausFlag = 1;
        end
        countsNoNoiseNoAgg = gui_MibiFilterAggregates(countsNoNoise(:,:,plotChannelInd),radius,threshold,gausFlag);
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
    
% --- Executes on button press in add_point_button.
function add_point_button_Callback(hObject, eventdata, handles)
    global pipeline_data;
    pointdiles = uigetdiles(pipeline_data.defaultPath);
    if ~isempty(pointdiles)
        [pipeline_data.defaultPath, ~, ~] = fileparts(pointdiles{1});
        pipeline_data.points.add(pointdiles);
        point_names = pipeline_data.points.getNames();
        set(handles.points_listbox, 'string', point_names)
        set(handles.points_listbox, 'value', 1);
        set(handles.channel_listbox, 'value', 1);
        generateAggRmParamText(handles)
        plotAggRmParams(handles);
    end
    
function fix_handle(handle)
    try
        if get(handle, 'value') > numel(get(handle, 'string'))
            set(handle, 'value', numel(get(handle, 'string')));
        end
        if isempty(get(handle, 'string'))
            set(handle, 'string', '');
            set(handle, 'value', 1)
        end
        if ~isnumeric(get(handle, 'value'))
            set(handle, 'value', 1)
        end
    catch
        
    end

function fix_menus_and_lists(handles)
    fix_handle(handles.points_listbox);
    fix_handle(handles.channel_listbox);

% --- Executes on button press in remove_point_button.
function remove_point_button_Callback(hObject, eventdata, handles)
    global pipeline_data;
    pointIndex = get(handles.points_listbox, 'value');
    pointList = pipeline_data.points.getNames();
    try
        removedPoint = pointList{pointIndex};
        if ~isempty(removedPoint)
            pipeline_data.points.remove('name', removedPoint);
            set(handles.points_listbox, 'string', pipeline_data.points.getNames());
            set(handles.channel_listbox, 'string', pipeline_data.points.getAggRmText());
        end
        fix_menus_and_lists(handles);
    catch
    end

% --- Executes on button press in select_point_button.
function select_point_button_Callback(hObject, eventdata, handles)
    try
        global pipeline_data;
        point = getPointName(handles);
        set(handles.selected_point_text, 'string', point);
        pipeline_data.labels = pipeline_data.dataNoNoise(point).labels;
        if isempty(keys(pipeline_data.aggRM_params))
            initAggRmParams(pipeline_data.dataNoNoise(point).labels);
            generateAggRmParamText(handles)
            set(handles.channel_listbox, 'value', 1);
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
    try
        val = get(hObject,'value');
        set(handles.threshold_display_text, 'string', num2str(val));
        setThresholdParam(handles);
        plotAggRmParams(handles);
    catch

    end

% --- Executes during object creation, after setting all properties.
function threshold_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function threshold_display_text_Callback(hObject, eventdata, handles)
    try
        val = str2double(get(hObject,'string'));
        setThresholdSlider(val, handles);
        plotAggRmParams(handles);
    catch
        
    end

% --- Executes during object creation, after setting all properties.
function threshold_display_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in channel_listbox.
function channel_listbox_Callback(hObject, eventdata, handles)
    % try
        global pipeline_data;
        channel_params = pipeline_data.points.getAggRmParam(get(handles.channel_listbox, 'value'));
        threshold = channel_params.threshold;
        radius = channel_params.radius;
        cap = channel_params.capImage;
        set(handles.threshold_display_text, 'string', threshold);
        set(handles.radius_display_text, 'string', radius);
        set(handles.cap_display_text, 'string', cap);
        setThresholdSlider(threshold, handles);
        setRadiusSlider(radius, handles);
        setCapSlider(cap, handles);
        plotAggRmParams(handles)
    % catch
        
    % end

% --- Executes during object creation, after setting all properties.
function channel_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in threshold_button.
function threshold_button_Callback(hObject, eventdata, handles)
defaults = {num2str(get(handles.threshold_slider, 'min')), num2str(get(handles.threshold_slider, 'max'))};
vals = inputdlg({'Threshold minimum', 'Threshold maximum'}, 'Threshold range', 1, defaults);
    try
        vals = str2double(vals);
        if vals(2)>vals(1)
            value = get(handles.threshold_slider, 'value');
            if value<vals(1) % value less than minimum
                value = vals(1);
            elseif value>vals(2) % value greater than maximum
                value = vals(2);
            else
                % value is fine
            end
            set(handles.threshold_slider, 'min', vals(1));
            set(handles.threshold_slider, 'max', vals(2));
            set(handles.threshold_slider, 'value', value);
            set(handles.threshold_display_text, 'string', value);
            setThresholdParam(handles);
        else
            gui_warning('Threshold maximum must be greater than threshold minimum');
        end
    catch
        % gui_warning('You did not enter valid numbers');
    end

% --- Executes on button press in remove_aggregates_button.
function remove_aggregates_button_Callback(hObject, eventdata, handles)
    global pipeline_data;
    set(handles.figure1, 'pointer', 'watch');
    pipeline_data.points.save_no_aggregates();
    set(handles.figure1, 'pointer', 'arrow');
    
    msg = {'+----------------------------------------------+',...
           '|                                              |',...
           '|           Done removing aggregates           |',...
           '|                                              |',...
           '+----------------------------------------------+'};
    m = gui_msgbox(msg);
    


% --- Executes on button press in save_run_button.
function save_run_button_Callback(hObject, eventdata, handles)
    [file,path] = uiputfile('*.mat');
    global pipeline_data;
    try
        pipeline_data.tiffFigure = NaN;
        save([path, filesep, file], 'pipeline_data')
    catch
        
    end

% --- Executes on button press in load_run_button.
function load_run_button_Callback(hObject, eventdata, handles)
    [file,path] = uigetfile('*.mat');
    set(handles.figure1, 'pointer', 'watch');
    drawnow
    global pipeline_data;
    try
        pipeline_data = load([path, filesep, file]);
        try
            pipeline_data = pipeline_data.pipeline_data;
            set(handles.points_listbox, 'string', pipeline_data.corePath);
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
    try
        val = get(hObject,'value');
        set(handles.cap_display_text, 'string', num2str(val));
        setCapParam(handles);
        plotAggRmParams(handles);
    catch

    end

% --- Executes during object creation, after setting all properties.
function cap_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function cap_display_text_Callback(hObject, eventdata, handles)
    try
        val = str2double(get(hObject,'string'));
        setCapSlider(val, handles);
        plotAggRmParams(handles);
    catch
        
    end

% --- Executes during object creation, after setting all properties.
function cap_display_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in cap_button.
function cap_button_Callback(hObject, eventdata, handles)
defaults = {num2str(get(handles.cap_slider, 'min')), num2str(get(handles.cap_slider, 'max'))};
vals = inputdlg({'Image cap minimum', 'Image cap maximum'}, 'Image cap range', 1, defaults);
    try
        vals = str2double(vals);
        if vals(2)>vals(1)
            value = get(handles.cap_slider, 'value');
            if value<vals(1) % value less than minimum
                value = vals(1);
            elseif value>vals(2) % value greater than maximum
                value = vals(2);
            else
                % value is fine
            end
            set(handles.cap_slider, 'min', vals(1));
            set(handles.cap_slider, 'max', vals(2));
            set(handles.cap_slider, 'value', value);
            set(handles.cap_display_text, 'string', value);
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
    try
        val = get(hObject,'value');
        set(handles.radius_display_text, 'string', num2str(val));
        setRadiusParam(handles);
        plotAggRmParams(handles);
    catch

    end

% --- Executes during object creation, after setting all properties.
function radius_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function radius_display_text_Callback(hObject, eventdata, handles)
    try
        val = str2double(get(hObject,'string'));
        setRadiusSlider(val, handles);
        plotAggRmParams(handles);
    catch
        
    end

% --- Executes during object creation, after setting all properties.
function radius_display_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in gauss_radius_button.
function gauss_radius_button_Callback(hObject, eventdata, handles)
defaults = {num2str(get(handles.radius_slider, 'min')), num2str(get(handles.radius_slider, 'max'))};
vals = inputdlg({'Gaussian Radius minimum', 'Gaussian Radius maximum'}, 'Gaussian Radius range', 1, defaults);
    try
        vals = str2double(vals);
        if vals(2)>vals(1)
            value = get(handles.radius_slider, 'value');
            if value<vals(1) % value less than minimum
                value = vals(1);
            elseif value>vals(2) % value greater than maximum
                value = vals(2);
            else
                % value is fine
            end
            set(handles.radius_slider, 'min', vals(1));
            set(handles.radius_slider, 'max', vals(2));
            set(handles.radius_slider, 'value', value);
            set(handles.radius_display_text, 'string', value);
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
    generateAggRmParamText(handles);
    plotAggRmParams(handles);

% --- Executes during object creation, after setting all properties.
function points_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
