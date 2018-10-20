% Thing I'd like to add: ability to lock all the figures from a point, so
% that when you zoom in or scan one fig, you zoom in and scan all the figs
% for that point. Probably have to keep track of each figure, and also add
% listeners to all them or something.

function varargout = background_removal_gui(varargin)
% BACKGROUND_REMOVAL_GUI MATLAB code for background_removal_gui.fig
%      BACKGROUND_REMOVAL_GUI, by itself, creates a new BACKGROUND_REMOVAL_GUI or raises the existing
%      singleton*.
%
%      H = BACKGROUND_REMOVAL_GUI returns the handle to a new BACKGROUND_REMOVAL_GUI or the handle to
%      the existing singleton*.
%
%      BACKGROUND_REMOVAL_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BACKGROUND_REMOVAL_GUI.M with the given input arguments.
%
%      BACKGROUND_REMOVAL_GUI('Property','value',...) creates a new BACKGROUND_REMOVAL_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before background_removal_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to background_removal_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help background_removal_gui

% Last Modified by GUIDE v2.5 05-Oct-2018 14:56:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @background_removal_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @background_removal_gui_OutputFcn, ...
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


% --- Executes just before background_removal_gui is made visible.
function background_removal_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to background_removal_gui (see VARARGIN)
feature('DefaultCharacterSet','UTF-8');
global pipeline_data;
pipeline_data = struct();
pipeline_data.bgChannel = '181';
pipeline_data.removingBackground = false;
pipeline_data.points = PointManager();
pipeline_data.background_point = '';
% Choose default command line output for background_removal_gui
handles.output = hObject;
[path, name, ext] = fileparts(mfilename('fullpath'));
warning('off', 'MATLAB:hg:uicontrol:StringMustBeNonEmpty');
warning('off', 'MATLAB:imagesci:tifftagsread:expectedTagDataFormat');
path = strsplit(path, filesep);
path(end) = [];
path = strjoin(path, filesep);
pipeline_data.defaultPath = path;
% Update handles structure
guidata(hObject, handles);

% UIWAIT mak es background_removal_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = background_removal_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% Manage Points and Select Background Channel =============================

% --- Executes on button press in add_point.
function add_point_Callback(hObject, eventdata, handles)
    global pipeline_data;
    pointdiles = uigetdiles(pipeline_data.defaultPath);
    if ~isempty(pointdiles)
        [pipeline_data.defaultPath, ~, ~] = fileparts(pointdiles{1});
        pipeline_data.points.add(pointdiles);
        set(handles.selected_points_listbox, 'string', pipeline_data.points.getNames());
        set(handles.eval_point_menu, 'string', pipeline_data.points.getNames());
        set(handles.background_channel_menu, 'string', pipeline_data.points.labels());
        set(handles.eval_channel_menu, 'string', pipeline_data.points.labels())
    end
    fix_menus_and_lists(handles);
    load_background(handles);

    
function fix_handle(handle)
    try
        if isempty(get(handle, 'string'))
            set(handle, 'string', {''});
            set(handle, 'value', 1)
        end
        if ~isnumeric(get(handle, 'value'))
            set(handle, 'value', 1)
        end
    catch
        
    end
    
    
function fix_menus_and_lists(handles)
    fix_handle(handles.selected_points_listbox);
    fix_handle(handles.background_channel_menu);
    fix_handle(handles.eval_point_menu);
    fix_handle(handles.eval_channel_menu);
    
% --- Executes on button press in remove_point.
function remove_point_Callback(hObject, eventdata, handles)
    global pipeline_data;
    pointIndex = get(handles.selected_points_listbox, 'value');
    pointList = get(handles.selected_points_listbox, 'string');
    removedPoint = pointList{pointIndex};
    if ~isempty(removedPoint)
        pipeline_data.points.remove('name', removedPoint);
        set(handles.selected_points_listbox, 'string', pipeline_data.points.getNames());
        set(handles.eval_point_menu, 'string', pipeline_data.points.getNames());
        set(handles.background_channel_menu, 'string', pipeline_data.points.labels());
        set(handles.eval_channel_menu, 'string', pipeline_data.points.labels())

        % we may not need this anymore, only used for displaying point
        % identity?
        if strcmp(removedPoint, pipeline_data.background_point)
            set(handles.background_selection_indicator, 'string', '');
        end
        if pointIndex~=1
            set(handles.selected_points_listbox, 'value', pointIndex-1);
        else
            set(handles.selected_points_listbox, 'value', 1);
        end
    end
    fix_menus_and_lists(handles);
    

% --- Executes on selection change in selected_points_listbox.
function selected_points_listbox_Callback(hObject, eventdata, handles)
    load_background(handles);

% --- Executes during object creation, after setting all properties.
function selected_points_listbox_CreateFcn(hObject, eventdata, handles)
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'string', {});

% --- Executes on selection change in background_channel_menu.
function background_channel_menu_Callback(hObject, eventdata, handles)
    load_background(handles);
    

% --- Executes during object creation, after setting all properties.
function background_channel_menu_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end


function load_background(handles)
    % try
        global pipeline_data;
        contents = cellstr(get(handles.selected_points_listbox, 'string'));
        point_index = get(handles.selected_points_listbox, 'value');
        point_name = contents{point_index};
        if ~isempty(point_name)
            pipeline_data.background_point = point_name;
            channel_index = get(handles.background_channel_menu, 'value');
            contents = cellstr(get(handles.background_channel_menu, 'string'));
            channel = contents{channel_index};

            contents = cellstr(get(handles.background_channel_menu, 'string'));
            pipeline_data.bgChannelInd = get(handles.background_channel_menu,'value');
            pipeline_data.bgChannel = contents{pipeline_data.bgChannelInd};
            pipeline_data.capBgChannel = str2double(get(handles.background_cap_display, 'string'));
            nums = [32, 40, 9583, 176, 9633, 176, 41, 9583, 32, 32, 32];
            % set(handles.background_selection_indicator, 'string', [point_filename, newline, char(nums), channel]);
            set(handles.background_selection_indicator, 'string', [char(nums), channel]);

            MIBIloadAndDisplayBackgroundChannel(get(handles.radiobutton1, 'value'))
        end
    % catch err
        % err
        % warning('Failed to load point');
    % end

% Background Removal Parameters ===========================================

function gaussian_radius_bkg_Callback(hObject, eventdata, handles)
    try
        if isnan(str2double(get(hObject,'string')))
            set(hObject, 'string', '0');
            gui_warning('Value for Gaussian radius is not a number');
        end
    catch
        gui_warning('Value for Gaussian radius is not a number');
    end

% --- Executes during object creation, after setting all properties.
function gaussian_radius_bkg_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    global pipeline_data;
    try
        pipeline_data.gausRad = str2double(get(hObject,'string'));
    catch
        gui_warning('Value for Gaussian radius is not a number');
    end

function threshold_bkg_Callback(hObject, eventdata, handles)
    try
        if isnan(str2double(get(hObject,'string')))
            set(hObject, 'string', '0');
            gui_warning('Value for Threshold is not a number');
        end
    catch
        gui_warning('Value for Threshold is not a number');
    end

% --- Executes during object creation, after setting all properties.
function threshold_bkg_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    global pipeline_data;
    try
        pipeline_data.t = str2double(get(hObject,'string'));
    catch
        gui_warning('Value for Threshold is not a number');
    end

function rm_val_Callback(hObject, eventdata, handles)
    try
        if isnan(str2double(get(hObject,'string')))
            set(hObject, 'string', '0');
            gui_warning('Value for Removal Value is not a number');
        end
    catch
        gui_warning('Value for Removal Value is not a number');
    end

% --- Executes during object creation, after setting all properties.
function rm_val_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    global pipeline_data;
    try
        pipeline_data.removeVal = str2double(get(hObject,'string'));
    catch
        gui_warning('Value for Removal Value is not a number');
    end


function background_cap_display_Callback(hObject, eventdata, handles)
    try
        if isnan(str2double(get(hObject,'string')))
            set(hObject, 'string', '0');
            gui_warning('Value for Background Cap is not a number');
        end
    catch
        gui_warning('Value for Background Cap is not a number');
    end

% --- Executes during object creation, after setting all properties.
function background_cap_display_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    global pipeline_data;
    try
        pipeline_data.capBgChannel = str2double(get(hObject,'string'));
    catch
        gui_warning('Value for Background Cap is not a number');
    end
    
function evaluation_cap_display_Callback(hObject, eventdata, handles)
    try
        if isnan(str2double(get(hObject,'string')))
            set(hObject, 'string', '0');
            gui_warning('Value for Evaluation Cap is not a number');
        end
    catch
        gui_warning('Value for Evaluation Cap is not a number');
    end

% --- Executes during object creation, after setting all properties.
function evaluation_cap_display_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end    
    try
        global pipeline_data;
        pipeline_data.capEvalChannel = str2double(get(hObject,'string'));
    catch
        gui_warning('Value for Evaluation Cap is not a number');
    end
    
function handle_background_and_evaluation_params(handles)
    global pipeline_data;
    gausRad = get(handles.gaussian_radius_bkg, 'string');
    threshold = get(handles.threshold_bkg, 'string');
    rm_val = get(handles.rm_val, 'string');
    capBgChannel = get(handles.background_cap_display, 'string');
    capEvalChannel = get(handles.evaluation_cap_display, 'string');
    
    pipeline_data.gausRad = str2double(gausRad);
    pipeline_data.t = str2double(threshold);
    pipeline_data.removeVal = str2double(rm_val);
    pipeline_data.capEvalChannel = str2double(capEvalChannel);
    pipeline_data.capBgChannel = str2double(capBgChannel);
    
    pipeline_data.background_param_LISTstring = tabJoin({gausRad, threshold, capBgChannel}, 10);
    pipeline_data.evaluation_param_LISTstring = tabJoin({rm_val, capEvalChannel}, 19);
    pipeline_data.all_param_TITLEstring = [ '[ ', gausRad, ' : ', threshold, ' : ', capBgChannel, ' : ', rm_val, ' : ', capEvalChannel, ' ]'];
    pipeline_data.all_param_DISPstring = [gausRad, newline, threshold, newline, capBgChannel, newline, rm_val, newline, capEvalChannel];
    
% --- Executes on button press in test.
function test_Callback(hObject, eventdata, handles)
    try
        global pipeline_data;
        point_index = get(handles.selected_points_listbox, 'value');
        contents = cellstr(get(handles.selected_points_listbox, 'string'));
        point_filename = contents{point_index};
        pipeline_data.background_point = point_filename;

        handle_background_and_evaluation_params(handles);
        
        set(handles.figure1, 'pointer', 'watch')
        drawnow
        MIBItestBackgroundParameters(get(handles.radiobutton2, 'value'));
        set(handles.figure1, 'pointer', 'arrow')
        % when we run test, we want to store the params we just used in bkg_rm_settings_listbox
        % this means store gaussian_radius_bkg, threshold_bkg, rm_val, background_cap_display
        % param_string = tabJoin({gausRad, threshold, rm_val, capBgChannel, capEvalChannel}, 6);
        curList = get(handles.bkg_rm_settings_listbox, 'string');
        set(handles.bkgrm_params_display, 'string', pipeline_data.all_param_DISPstring);

        if numel(curList)==0 || ~strcmp(pipeline_data.background_param_LISTstring, curList{1})
            curList(2:end+1) = curList(1:end);
            curList{1} = pipeline_data.background_param_LISTstring;
            set(handles.bkg_rm_settings_listbox, 'string', curList);
        end
        set(handles.remove_background, 'Enable', 'on');
    catch e
        disp(e);
        gui_warning('No point selected');
    end

% --- Executes on selection change in bkg_rm_settings_listbox.
function bkg_rm_settings_listbox_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function bkg_rm_settings_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'string', {});

% --- Executes on button press in reload_bkg_params.
function reload_bkg_params_Callback(hObject, eventdata, handles)
    try
        contents = cellstr(get(handles.bkg_rm_settings_listbox,'string'));
        settings = str2double(strsplit(tabSplit(contents{get(handles.bkg_rm_settings_listbox,'value')}), char(8197)) );

        gausRad = settings(1);
        threshold = settings(2);
        capBgChannel = settings(3);

        set(handles.gaussian_radius_bkg, 'string', num2str(gausRad));
        set(handles.threshold_bkg, 'string', num2str(threshold));
        set(handles.background_cap_display, 'string', num2str(capBgChannel));

        global pipeline_data;
        pipeline_data.capBgChannel = capBgChannel;
        pipeline_data.t = threshold;
        pipeline_data.gausRad = gausRad;
    catch
        % do nothing
    end
    

% --- Executes on button press in delete_bkg_setting.
function delete_bkg_setting_Callback(hObject, eventdata, handles)
    try
        index = get(handles.bkg_rm_settings_listbox,'value');
        contents = cellstr(get(handles.bkg_rm_settings_listbox,'string'));
        contents(index) = [];
        set(handles.bkg_rm_settings_listbox, 'string', contents);
        if (index~=1)
            set(handles.bkg_rm_settings_listbox, 'value', index-1);
        else
            set(handles.bkg_rm_settings_listbox, 'value', 1);
        end
    catch
        % uh oh
    end

% Select Evaluation Channels ==============================================

% --- Executes on selection change in eval_channels_list.
function eval_channels_list_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function eval_channels_list_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'string', {});


% --- Executes on selection change in eval_point_menu.
function eval_point_menu_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function eval_point_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in eval_channel_menu.
function eval_channel_menu_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function eval_channel_menu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in evaluate_point.
function evaluate_point_Callback(hObject, eventdata, handles)
    try
        contents = cellstr(get(handles.eval_point_menu,'string'));
        evalPoint = contents{get(handles.eval_point_menu,'value')};
        contents = cellstr(get(handles.eval_channel_menu,'string'));
        evalChannelInd = get(handles.eval_channel_menu,'value');
        evalChannel = contents{evalChannelInd};

        handle_background_and_evaluation_params(handles)
        global pipeline_data;

        pipeline_data.evalChannel = evalChannel;
        pipeline_data.evalChannelInd = evalChannelInd;
        
        set(handles.figure1, 'pointer', 'watch');
        drawnow;
        MIBIevaluateBackgroundParameters({evalPoint});
        set(handles.figure1, 'pointer', 'arrow');

        curList = get(handles.eval_settings_listbox, 'string');

        set(handles.bkgrm_params_display, 'string', pipeline_data.all_param_DISPstring);

        if numel(curList)==0 || ~strcmp(pipeline_data.evaluation_param_LISTstring, curList{1})
            curList(2:end+1) = curList(1:end);
            curList{1} = pipeline_data.evaluation_param_LISTstring;
            set(handles.eval_settings_listbox, 'string', curList);
        end
        set(handles.remove_background, 'Enable', 'on');
    catch err
        set(handles.figure1, 'pointer', 'arrow');
        gui_warning('No point selected');
    end

% --- Executes on button press in evaluate_all_points.
function evaluate_all_points_Callback(hObject, eventdata, handles)
    try
        contents = cellstr(get(handles.eval_channel_menu,'string'));
        evalPoints = cellstr(get(handles.eval_point_menu,'string'));
        evalChannelInd = get(handles.eval_channel_menu,'value');
        evalChannel = contents{evalChannelInd};

        handle_background_and_evaluation_params(handles)
        global pipeline_data;

        pipeline_data.evalChannel = evalChannel;
        pipeline_data.evalChannelInd = evalChannelInd;
        set(handles.figure1, 'pointer', 'watch');
        drawnow
        MIBIevaluateBackgroundParameters(evalPoints);
        set(handles.figure1, 'pointer', 'arrow');

        curList = get(handles.eval_settings_listbox, 'string');

        set(handles.bkgrm_params_display, 'string', pipeline_data.all_param_DISPstring);

        if numel(curList)==0 || ~strcmp(pipeline_data.evaluation_param_LISTstring, curList{1})
            curList(2:end+1) = curList(1:end);
            curList{1} = pipeline_data.evaluation_param_LISTstring;
            set(handles.eval_settings_listbox, 'string', curList);
        end
        set(handles.remove_background, 'Enable', 'on');
    catch
        
        set(handles.figure1, 'pointer', 'arrow');
    end

% --- Executes on button press in remove_background.
function remove_background_Callback(hObject, eventdata, handles)
    set(handles.figure1, 'pointer', 'watch');
    drawnow
    global pipeline_data;
    pipeline_data.points.save_no_background();
    set(handles.figure1, 'pointer', 'arrow');
    msg = {'+----------------------------------------------+',...
           '|                                              |',...
           '|           Done removing background           |',...
           '|                                              |',...
           '+----------------------------------------------+'};
    m = gui_msgbox(msg);

% --- Executes on button press in load_params.
function load_params_Callback(hObject, eventdata, handles)
    global pipeline_data;
    handle_background_and_evaluation_params(handles);
    set(handles.bkgrm_params_display, 'string', pipeline_data.all_param_DISPstring);
    set(handles.remove_background, 'Enable', 'on');
    


% --- Executes on selection change in eval_settings_listbox.
function eval_settings_listbox_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function eval_settings_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reload_eval_params.
function reload_eval_params_Callback(hObject, eventdata, handles)
    try
        contents = cellstr(get(handles.eval_settings_listbox, 'string'));
        settings = str2double(strsplit(tabSplit(contents{get(handles.eval_settings_listbox, 'value')}), char(8197)) );
        
        rm_val = settings(1);
        capEvalChannel = settings(2);
        
        set(handles.rm_val, 'string', num2str(rm_val));
        set(handles.evaluation_cap_display, 'string', num2str(capEvalChannel));
        
        global pipeline_data;
        pipeline_data.removeVal = rm_val;
        pipeline_data.capEvalChannel = capEvalChannel;
    catch e
        disp(e);
    end

% --- Executes on button press in delete_eval_setting.
function delete_eval_setting_Callback(hObject, eventdata, handles)
    try
        index = get(handles.eval_settings_listbox,'value');
        contents = cellstr(get(handles.eval_settings_listbox,'string'));
        contents(index) = [];
        set(handles.eval_settings_listbox, 'string', contents);
        if (index~=1)
            set(handles.eval_settings_listbox, 'value', index-1);
        else
            set(handles.eval_settings_listbox, 'value', 1);
        end
    catch
        % uh oh
    end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)


% --- Executes on button press in radiobutton2.
function radiobutton2_Callback(hObject, eventdata, handles)
