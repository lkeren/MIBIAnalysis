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
%      BACKGROUND_REMOVAL_GUI('Property','Value',...) creates a new BACKGROUND_REMOVAL_GUI or raises the
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

% Last Modified by GUIDE v2.5 21-Aug-2018 17:45:01

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
pipeline_data.rawData = containers.Map;
pipeline_data.corePath = {};
pipeline_data.background_point = '';
% Choose default command line output for background_removal_gui
handles.output = hObject;
[path, name, ext] = fileparts(mfilename('fullpath'));
warning('off', 'MATLAB:hg:uicontrol:StringMustBeNonEmpty');
warning('off', 'MATLAB:imagesci:tifftagsread:expectedTagDataFormat');
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

function manage_loaded_data(handles)
% goal is to look at the corePath variable, check that all raw data is
% loaded, and if it's not, load it. If there are extra keys in
% pipeline_data.rawData, we should delete them.
    global pipeline_data;
    rawDataKeys = keys(pipeline_data.rawData); % data that's already loaded
    corePath = pipeline_data.corePath; % data that should be loaded
    deletePaths = setdiff(rawDataKeys, corePath); % data that needs to be deleted
    loadPaths = setdiff(corePath, rawDataKeys); % datat hat needs to be loaded
    for i=1:numel(deletePaths) % remove data we don't want anymore
        remove(pipeline_data.rawData, deletePaths{i});
    end
    for i=1:numel(loadPaths) % load unloaded data
        data = struct();
        [data.countsAllSFiltCRSum, data.labels] = load_tiff_data(loadPaths{i});
        pipeline_data.rawData(loadPaths{i}) = data;
    end
    


% --- Executes on button press in add_point.
function add_point_Callback(hObject, eventdata, handles)
    global pipeline_data
    pointdiles = uigetdiles(pipeline_data.defaultPath);
    pointdiles = setdiff(pointdiles, pipeline_data.corePath); % this should only add paths that haven't already been added
    if ~isempty(pointdiles)
        [filepath, name, ext] = fileparts(pointdiles{1});
        pipeline_data.defaultPath = filepath;
        curList = get(handles.selected_points_listbox, 'String');
        curList = cat(1,curList, pointdiles');
        set(handles.selected_points_listbox, 'String', curList);
        set(handles.eval_point_menu, 'String', curList);

        contents = cellstr(get(handles.selected_points_listbox, 'String'));
        % extract all labels and make sure they match
        labelSets = cell(size(contents));
        for i=1:numel(labelSets)
            labelSets{i} = getTIFFLabels(contents{i});
        end
        if numel(labelSets)==1 || isequal(labelSets{:}) % all the sets of labels are equal
            set(handles.background_channel_menu, 'String', labelSets{1});
            set(handles.eval_channel_menu, 'String', labelSets{1});
%             chan = get(handles.background_channel_menu, 'Value');
%             set(handles.background_channel_menu, 'Value', 1);
        end
        pipeline_data.corePath = contents;
        manage_loaded_data(handles);
    end

% --- Executes on button press in remove_point.
function remove_point_Callback(hObject, eventdata, handles)
    try
        global pipeline_data;
        pointIndex = get(handles.selected_points_listbox, 'Value');
        pointList = get(handles.selected_points_listbox, 'String');
        removedPoint = pointList{pointIndex};
        if strcmp(removedPoint, pipeline_data.background_point) % are we removing a point we've loaded as background?
            set(handles.background_selection_indicator, 'String', '');
        end
        if numel(pointList) ~= 0
            pointList(pointIndex) = [];
        end
        set(handles.selected_points_listbox, 'String', pointList);
        set(handles.eval_point_menu, 'String', pointList);
        if numel(pointList) == 0
            set(handles.background_channel_menu, 'String', ' ');
            set(handles.background_channel_menu, 'Value', 1);
            set(handles.eval_channel_menu, 'String', ' ');
            set(handles.eval_channel_menu, 'Value', 1);
        end
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
% Hints: contents = cellstr(get(hObject,'String')) returns selected_points_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selected_points_listbox

% --- Executes during object creation, after setting all properties.
function selected_points_listbox_CreateFcn(hObject, eventdata, handles)
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', {});

% --- Executes on selection change in background_channel_menu.
function background_channel_menu_Callback(hObject, eventdata, handles)
% Hints: contents = cellstr(get(hObject,'String')) returns background_channel_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from background_channel_menu

    % get(hObject, 'String')

% --- Executes during object creation, after setting all properties.
function background_channel_menu_CreateFcn(hObject, eventdata, handles)
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in load_background.
function load_background_Callback(hObject, eventdata, handles)
% hObject    handle to load_background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        global pipeline_data;
        point_index = get(handles.selected_points_listbox, 'Value');
        contents = cellstr(get(handles.selected_points_listbox, 'String'));
        point_filename = contents{point_index};
        pipeline_data.background_point = point_filename;
        channel_index = get(handles.background_channel_menu, 'Value');
        contents = cellstr(get(handles.background_channel_menu, 'String'));
        channel = contents{channel_index};

        contents = cellstr(get(handles.background_channel_menu, 'String'));
        pipeline_data.bgChannelInd = get(handles.background_channel_menu,'Value');
        pipeline_data.bgChannel = contents{pipeline_data.bgChannelInd};
        pipeline_data.capBgChannel = str2double(get(handles.background_cap_display, 'String'));
        % ' (?°?°)?   '
        % ' (^_^)_/¯   '
        nums = [32, 40, 9583, 176, 9633, 176, 41, 9583, 32, 32, 32];
        set(handles.background_selection_indicator, 'String', [point_filename, newline, char(nums), channel]);
        
        MIBIloadAndDisplayBackgroundChannel()
    catch
        % warning('Failed to load point');
    end

% Background Removal Parameters ===========================================

function gaussian_radius_bkg_Callback(hObject, eventdata, handles)
% hObject    handle to gaussian_radius_bkg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of gaussian_radius_bkg as text
%        str2double(get(hObject,'String')) returns contents of gaussian_radius_bkg as a double
    % global pipeline_data;
    try
        % pipeline_data.gausRad = str2double(get(hObject,'String'));
        if isnan(str2double(get(hObject,'String')))
            set(hObject, 'String', '0');
            warning('Value for Gaussian radius is not a number');
        end
    catch
        warning('Value for Gaussian radius is not a number');
    end

% --- Executes during object creation, after setting all properties.
function gaussian_radius_bkg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gaussian_radius_bkg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    global pipeline_data;
    try
        pipeline_data.gausRad = str2double(get(hObject,'String'));
    catch
        warning('Value for Gaussian radius is not a number');
    end

function threshold_bkg_Callback(hObject, eventdata, handles)
% hObject    handle to threshold_bkg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of threshold_bkg as text
%        str2double(get(hObject,'String')) returns contents of threshold_bkg as a double
    % global pipeline_data;
    try
        % pipeline_data.t = str2double(get(hObject,'String'));
        if isnan(str2double(get(hObject,'String')))
            set(hObject, 'String', '0');
            warning('Value for Threshold is not a number');
        end
    catch
        warning('Value for Threshold is not a number');
    end

% --- Executes during object creation, after setting all properties.
function threshold_bkg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to threshold_bkg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    global pipeline_data;
    try
        pipeline_data.t = str2double(get(hObject,'String'));
    catch
        warning('Value for Threshold is not a number');
    end

function rm_val_Callback(hObject, eventdata, handles)
% hObject    handle to rm_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of rm_val as text
%        str2double(get(hObject,'String')) returns contents of rm_val as a double
    % global pipeline_data;
    try
        % pipeline_data.removeVal = str2double(get(hObject,'String'));
        if isnan(str2double(get(hObject,'String')))
            set(hObject, 'String', '0');
            warning('Value for Removal Value is not a number');
        end
    catch
        warning('Value for Removal Value is not a number');
    end

% --- Executes during object creation, after setting all properties.
function rm_val_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rm_val (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    global pipeline_data;
    try
        pipeline_data.removeVal = str2double(get(hObject,'String'));
    catch
        warning('Value for Removal Value is not a number');
    end


function background_cap_display_Callback(hObject, eventdata, handles)
% hObject    handle to background_cap_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'String') returns contents of background_cap_display as text
%        str2double(get(hObject,'String')) returns contents of background_cap_display as a double
    % global pipeline_data;
    try
        % pipeline_data.capBgChannel = str2double(get(hObject,'String'));
        if isnan(str2double(get(hObject,'String')))
            set(hObject, 'String', '0');
            warning('Value for Background Cap is not a number');
        end
    catch
        warning('Value for Background Cap is not a number');
    end

% --- Executes during object creation, after setting all properties.
function background_cap_display_CreateFcn(hObject, eventdata, handles)
% hObject    handle to background_cap_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    global pipeline_data;
    try
        pipeline_data.capBgChannel = str2double(get(hObject,'String'));
    catch
        warning('Value for Background Cap is not a number');
    end
    
function evaluation_cap_display_Callback(hObject, eventdata, handles)
% hObject    handle to evaluation_cap_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        if isnan(str2double(get(hObject,'String')))
            set(hObject, 'String', '0');
            warning('Value for Evaluation Cap is not a number');
        end
    catch
        warning('Value for Evaluation Cap is not a number');
    end

% --- Executes during object creation, after setting all properties.
function evaluation_cap_display_CreateFcn(hObject, eventdata, handles)
% hObject    handle to evaluation_cap_display (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end    
    try
        global pipeline_data;
        pipeline_data.capEvalChannel = str2double(get(hObject,'String'));
    catch
        warning('Value for Evaluation Cap is not a number');
    end
    
function handle_background_and_evaluation_params(handles)
    global pipeline_data;
    gausRad = get(handles.gaussian_radius_bkg, 'String');
    threshold = get(handles.threshold_bkg, 'String');
    rm_val = get(handles.rm_val, 'String');
    capBgChannel = get(handles.background_cap_display, 'String');
    capEvalChannel = get(handles.evaluation_cap_display, 'String');
    
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
% hObject    handle to test (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        global pipeline_data;
        point_index = get(handles.selected_points_listbox, 'Value');
        contents = cellstr(get(handles.selected_points_listbox, 'String'));
        point_filename = contents{point_index};
        pipeline_data.background_point = point_filename;

        handle_background_and_evaluation_params(handles);

        MIBItestBackgroundParameters();
        % when we run test, we want to store the params we just used in bkg_rm_settings_listbox
        % this means store gaussian_radius_bkg, threshold_bkg, rm_val, background_cap_display
        % param_string = tabJoin({gausRad, threshold, rm_val, capBgChannel, capEvalChannel}, 6);
        curList = get(handles.bkg_rm_settings_listbox, 'String');
        set(handles.bkgrm_params_display, 'String', pipeline_data.all_param_DISPstring);

        if numel(curList)==0 || ~strcmp(pipeline_data.background_param_LISTstring, curList{1})
            curList(2:end+1) = curList(1:end);
            curList{1} = pipeline_data.background_param_LISTstring;
            set(handles.bkg_rm_settings_listbox, 'String', curList);
        end
    catch
        warning('No point selected');
    end

% --- Executes on selection change in bkg_rm_settings_listbox.
function bkg_rm_settings_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to bkg_rm_settings_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns bkg_rm_settings_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bkg_rm_settings_listbox

% --- Executes during object creation, after setting all properties.
function bkg_rm_settings_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bkg_rm_settings_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', {});

% --- Executes on button press in reload_bkg_params.
function reload_bkg_params_Callback(hObject, eventdata, handles)
% hObject    handle to reload_bkg_params (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        contents = cellstr(get(handles.bkg_rm_settings_listbox,'String'));
        settings = str2double(strsplit(tabSplit(contents{get(handles.bkg_rm_settings_listbox,'Value')}), ' ') );

        gausRad = settings(1);
        threshold = settings(2);
        % rm_val = settings(3);
        capBgChannel = settings(3);
        % capEvalChannel = settings(5);

        set(handles.gaussian_radius_bkg, 'String', num2str(gausRad));
        set(handles.threshold_bkg, 'String', num2str(threshold));
        % set(handles.rm_val, 'String', num2str(rm_val));
        set(handles.background_cap_display, 'String', num2str(capBgChannel));
        % set(handles.evaluation_cap_display, 'String', num2str(capEvalChannel));

        global pipeline_data;
        pipeline_data.capBgChannel = capBgChannel;
        % pipeline_data.capEvalChannel = capEvalChannel;
        pipeline_data.t = threshold;
        pipeline_data.gausRad = gausRad;
        % pipeline_data.removeVal = rm_val;
    catch
        % do nothing
    end
    

% --- Executes on button press in delete_bkg_setting.
function delete_bkg_setting_Callback(hObject, eventdata, handles)
% hObject    handle to delete_bkg_setting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        index = get(handles.bkg_rm_settings_listbox,'Value');
        contents = cellstr(get(handles.bkg_rm_settings_listbox,'String'));
        contents(index) = [];
        set(handles.bkg_rm_settings_listbox, 'String', contents);
        if (index~=1)
            set(handles.bkg_rm_settings_listbox, 'Value', index-1);
        else
            set(handles.bkg_rm_settings_listbox, 'Value', 1);
        end
    catch
        % uh oh
    end

% Select Evaluation Channels ==============================================

% --- Executes on selection change in eval_channels_list.
function eval_channels_list_Callback(hObject, eventdata, handles)
% hObject    handle to eval_channels_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns eval_channels_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from eval_channels_list

% --- Executes during object creation, after setting all properties.
function eval_channels_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eval_channels_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', {});


% --- Executes on selection change in eval_point_menu.
function eval_point_menu_Callback(hObject, eventdata, handles)
% hObject    handle to eval_point_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns eval_point_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from eval_point_menu


% --- Executes during object creation, after setting all properties.
function eval_point_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eval_point_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in eval_channel_menu.
function eval_channel_menu_Callback(hObject, eventdata, handles)
% hObject    handle to eval_channel_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns eval_channel_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from eval_channel_menu


% --- Executes during object creation, after setting all properties.
function eval_channel_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eval_channel_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in evaluate_point.
function evaluate_point_Callback(hObject, eventdata, handles)
% hObject    handle to evaluate_point (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        contents = cellstr(get(handles.eval_point_menu,'String'));
        evalPoint = contents{get(handles.eval_point_menu,'Value')};
        contents = cellstr(get(handles.eval_channel_menu,'String'));
        evalChannelInd = get(handles.eval_channel_menu,'Value');
        evalChannel = contents{evalChannelInd};

        handle_background_and_evaluation_params(handles)
        global pipeline_data;

        pipeline_data.evalChannel = evalChannel;
        pipeline_data.evalChannelInd = evalChannelInd;
        MIBIevaluateBackgroundParameters({evalPoint});

        curList = get(handles.eval_settings_listbox, 'String');

        set(handles.bkgrm_params_display, 'String', pipeline_data.all_param_DISPstring);

        if numel(curList)==0 || ~strcmp(pipeline_data.evaluation_param_LISTstring, curList{1})
            curList(2:end+1) = curList(1:end);
            curList{1} = pipeline_data.evaluation_param_LISTstring;
            set(handles.eval_settings_listbox, 'String', curList);
        end
    catch
        warning('No point selected');
    end

% --- Executes on button press in evaluate_all_points.
function evaluate_all_points_Callback(hObject, eventdata, handles)
% hObject    handle to evaluate_all_points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    contents = cellstr(get(handles.eval_channel_menu,'String'));
    evalPoints = cellstr(get(handles.eval_point_menu,'String'));
    evalChannelInd = get(handles.eval_channel_menu,'Value');
    evalChannel = contents{evalChannelInd};
    
    handle_background_and_evaluation_params(handles)
    global pipeline_data;
    
    pipeline_data.evalChannel = evalChannel;
    pipeline_data.evalChannelInd = evalChannelInd;
    MIBIevaluateBackgroundParameters(evalPoints);
    
    curList = get(handles.eval_settings_listbox, 'String');
    
    set(handles.bkgrm_params_display, 'String', pipeline_data.all_param_DISPstring);
    
    if numel(curList)==0 || ~strcmp(pipeline_data.evaluation_param_LISTstring, curList{1})
        curList(2:end+1) = curList(1:end);
        curList{1} = pipeline_data.evaluation_param_LISTstring;
        set(handles.eval_settings_listbox, 'String', curList);
    end


% --- Executes on button press in remove_background.
function remove_background_Callback(hObject, eventdata, handles)
% hObject    handle to remove_background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    pathToLog = uigetdir();
    if pathToLog~=0
        set(hObject, 'Enable', 'off');
        MIBI_remove_background(pathToLog);
        set(hObject, 'Enable', 'on');
    end


% --- Executes on button press in load_params.
function load_params_Callback(hObject, eventdata, handles)
% hObject    handle to load_params (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global pipeline_data;
    handle_background_and_evaluation_params(handles);
    set(handles.bkgrm_params_display, 'String', pipeline_data.all_param_DISPstring);
    


% --- Executes on selection change in eval_settings_listbox.
function eval_settings_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to eval_settings_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns eval_settings_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from eval_settings_listbox


% --- Executes during object creation, after setting all properties.
function eval_settings_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eval_settings_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reload_eval_params.
function reload_eval_params_Callback(hObject, eventdata, handles)
% hObject    handle to reload_eval_params (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        contents = cellstr(get(handles.eval_settings_listbox, 'String'));
        settings = str2double(strsplit(tabSplit(contents{get(handles.eval_settings_listbox, 'Value')}), ' ') );
        
        rm_val = settings(1);
        capEvalChannel = settings(2);
        
        set(handles.rm_val, 'String', num2str(rm_val));
        set(handles.evaluation_cap_display, 'String', num2str(capEvalChannel));
        
        global pipeline_data;
        pipeline_data.removeVal = rm_val;
        pipeline_data.capEvalChannel = capEvalChannel;
    catch
        % do nothing
    end

% --- Executes on button press in delete_eval_setting.
function delete_eval_setting_Callback(hObject, eventdata, handles)
% hObject    handle to delete_eval_setting (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        index = get(handles.eval_settings_listbox,'Value');
        contents = cellstr(get(handles.eval_settings_listbox,'String'));
        contents(index) = [];
        set(handles.eval_settings_listbox, 'String', contents);
        if (index~=1)
            set(handles.eval_settings_listbox, 'Value', index-1);
        else
            set(handles.eval_settings_listbox, 'Value', 1);
        end
    catch
        % uh oh
    end
