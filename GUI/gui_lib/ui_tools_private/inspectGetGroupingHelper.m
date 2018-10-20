function info = inspectGetGroupingHelper(obj)
% This function is undocumented and will change in a future release

%   Copyright 2011-2015 The MathWorks, Inc.

info = [];

% Delegate to object
if ishandle(obj) && ismethod(obj,'getInspectorGrouping')
    
    % call the method
    try 
       info = getInspectorGrouping(obj,'-cellarray');
    catch %#ok<CTCH>
       % do nothing, author of method must debug the error
    end
    
% HG objects
elseif all(ishghandle(obj))
    % Container Objects
    if ishghandle(obj,'figure')
       info = localGetFigureGrouping;
    elseif ishghandle(obj,'axes')
       info = localGetAxesGrouping(obj);
    elseif ishghandle(obj,'hggroup')
       % hgtransform is also a group
       if ishghandle(obj,'hgtransform')
            info = localGetTransformGrouping;
       else
           info = localGetGroupGrouping;
       end
     
     % Primitive objects  
     elseif ishghandle(obj,'image')
        info = localGetImageGrouping;
     elseif ishghandle(obj,'light')
        info = localGetLightGrouping;
     elseif ishghandle(obj,'patch')
         info = localGetPatchGrouping;
     elseif ishghandle(obj,'line') % handles both chart.primitve and
                                  % primitive "lines"
        info = localGetLineGrouping;
     elseif ishghandle(obj,'surface') % handles both chart.primitive and 
                                     % primitive "surfaces"
        info = localGetSurfaceGrouping;
     elseif ishghandle(obj,'root')
       info = localGetRootGrouping; 
     elseif ishghandle(obj,'text')
        info = localGetTextGrouping;

    % Plotting Function Objects
    elseif isa(obj, 'matlab.graphics.animation.AnimatedLine')
        info = localGetAnimatedLineGrouping;
    elseif isa(obj, 'matlab.graphics.chart.primitive.Area')
        info = localGetAreaGrouping;
    elseif isa(obj, 'matlab.graphics.chart.primitive.Bar')
        info = localGetBarGrouping;
    elseif isa(obj, 'matlab.graphics.illustration.ColorBar')
        info = localGetColorBarGrouping;
    elseif isa(obj, 'matlab.graphics.chart.primitive.Contour')
        info = localGetContourGrouping;
    elseif isa(obj, 'matlab.graphics.chart.primitive.ErrorBar')
        info = localGetErrorBarGrouping;
    elseif isa(obj, 'matlab.graphics.illustration.Legend')
        info = localGetLegendGrouping;
    elseif isa(obj, 'matlab.graphics.chart.primitive.Quiver')
        info = localGetQuiverGrouping;
    elseif ishghandle(obj,'rectangle')
        info = localGetRectangleGrouping;
    elseif isa(obj, 'matlab.graphics.chart.primitive.Scatter')
        info = localGetScatterGrouping;
    elseif isa(obj, 'matlab.graphics.chart.primitive.Stair')
        info = localGetStairGrouping;
    elseif isa(obj, 'matlab.graphics.chart.primitive.Stem')
        info = localGetStemGrouping;    
        
    % Annotations
    elseif isa(obj, 'matlab.graphics.shape.Arrow')
        info = localGetAnnotationArrowGrouping; 
    elseif isa(obj, 'matlab.graphics.shape.DoubleEndArrow')
        info = localGetAnnotationDoubleEndArrowGrouping; 
    elseif isa(obj, 'matlab.graphics.shape.Ellipse')
        info = localGetAnnotationEllipseGrouping;
    elseif isa(obj, 'matlab.graphics.shape.Line')
        info = localGetAnnotationLineGrouping;
    elseif isa(obj, 'matlab.graphics.shape.Rectangle')
        info = localGetAnnotationRectangleGrouping;
    elseif isa(obj, 'matlab.graphics.shape.TextArrow')
        info = localGetAnnotationTextArrowGrouping;   
    elseif isa(obj, 'matlab.graphics.shape.TextBox')
        info = localGetAnnotationTextBoxGrouping;
        
    % GUI Controls  
    elseif ishghandle(obj,'uicontrol')
        info = localGetUIControlGrouping;    
    elseif ishghandle(obj, 'uitable')
        info = localGetUITableGrouping;
    elseif ishghandle(obj,'uipanel')
        % uibuttongroup is a subclass of uipanel
        if isa(obj, 'matlab.ui.container.ButtonGroup')
            info = localGetUIButtonGroupGrouping;
        else % panel that is not uibuttongroup
            info = localGetUIPanelGrouping;
        end
    elseif ishghandle(obj,'uitab')
        info = localGetUITabGrouping;    
    elseif ishghandle(obj,'uitabgroup')
        info = localGetUITabGroupGrouping;   
    end
end

%----------------------------------------------------%
function retval = localGetFigureGrouping

info{1} = 'Figure Appearance';
info{2} = {'Color','DockControls','MenuBar','Name','NumberTitle', ...
    'ToolBar','Visible','Clipping'};
retval{1} = info;

info{1} = 'Axes and Plot Appearance';
info{2} = {'GraphicsSmoothing','Renderer','RendererMode'};
retval{end+1} = info;

info{1} = 'Color and Transparency Mapping';
info{2} = {'Alphamap','Colormap'};
retval{end+1} = info;

info{1} = 'Location and Size';
info{2} = {'OuterPosition','Position','Resize','ResizeFcn', ...
    'SizeChangedFcn','Units'};
retval{end+1} = info;

info{1} = 'Multiple Plots';
info{2} = {'NextPlot'};
retval{end+1} = info;

info{1}= 'Interactive Control';
info{2}= {'Selected','SelectionHighlight'};
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'BusyAction','HitTest','Interruptible'};
retval{end+1} = info;

info{1} = 'Keyboard Control';
info{2} = {'CurrentCharacter','KeyPressFcn','KeyReleaseFcn',...
    'WindowKeyPressFcn','WindowKeyReleaseFcn'};
retval{end+1} = info;

info{1} = 'Mouse Control';
info{2} = {'ButtonDownFcn','CurrentPoint','SelectionType',...
    'WindowButtonDownFcn','WindowButtonMotionFcn','WindowButtonUpFcn',...
    'WindowScrollWheelFcn','UIContextMenu'};
retval{end+1} = info;

info{1} = 'Window Control';
info{2} = {'CloseRequestFcn','WindowStyle'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'BeingDeleted','CreateFcn','DeleteFcn'};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'CurrentAxes','CurrentObject','FileName','IntegerHandle',...
    'Number','Tag','Type','UserData',};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility'};
retval{end+1} = info;

info{1} = 'Pointers';
info{2} = {'Pointer','PointerShapeCData','PointerShapeHotSpot'};
retval{end+1} = info;

info{1} = 'Printing';
info{2} = {'InvertHardcopy','PaperOrientation','PaperPosition', ...
    'PaperPositionMode','PaperSize','PaperType','PaperUnits'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetRootGrouping

info{1}= 'Display Information';
info{2}= {'MonitorPositions','PointerLocation','ScreenDepth',...
    'ScreenPixelsPerInch','ScreenSize','FixedWidthFontName','Units'};
retval{1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility','ShowHiddenHandles'};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'CallbackObject','CurrentFigure','Tag','Type','UserData'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetAxesGrouping(ax)
names = get(handle(ax),'DimensionNames');
info{1}= 'Appearance';
info{2}= {'Color','Layer','LineWidth','Box','BoxStyle'};
retval{1} = info;

info{1} = 'Axis Color';
colors = makeProperties(names, 'Color');
colormodes = makeProperties(names, 'ColorMode');
info{2} = [colors, colormodes];
retval{end+1} = info;

info{1} = 'Font Style';
info{2} = {'FontAngle','FontName','FontSize','FontUnits',...
    'LabelFontSizeMultiplier','TitleFontSizeMultiplier','FontWeight',...
    'TitleFontWeight','FontSmoothing'};
retval{end+1} = info;

info{1} = 'Tick Values and Labels';
tick = makeProperties(names,'Tick');
tickmode = makeProperties(names,'TickMode');
ticklabel = makeProperties(names,'TickLabel');
ticklabelmode = makeProperties(names,'TickLabelMode');
ticklabelrot = makeProperties(names,'TickLabelRotation');
minortick = makeProperties(names,'MinorTick');
info{2} = [tick, tickmode, ticklabel, ticklabelmode, ...
           ticklabelrot, minortick, ...
           {'TickLabelInterpreter', 'TickLength', 'TickDir', 'TickDirMode'}];
retval{end+1} = info;

info{1} = 'Axis Scale and Direction';
dir = makeProperties(names, 'Dir');
loc = makeProperties(names, 'AxisLocation');
scale = makeProperties(names, 'Scale');
lim = makeProperties(names, 'Lim');
limmode = makeProperties(names, 'LimMode');
info{2} = [loc(1:2), dir, scale, lim, limmode, {'CLim','CLimMode'}];
retval{end+1} = info;

info{1} = 'Grid';
grid = makeProperties(names,'Grid');
minorgrid = makeProperties(names,'MinorGrid');
info{2} =[grid, minorgrid, ...
          {'GridLineStyle','MinorGridLineStyle',...
           'GridColor','GridColorMode',...
           'MinorGridColor','GridAlpha','GridAlphaMode','MinorGridAlpha',...
           'MinorGridAlphaMode'}];
retval{end+1} = info;

info{1} = 'Title and Axis Labels';
label = makeProperties(names,'Label');
info{2} = [{'Title'}, label];
retval{end+1} = info;

info{1} = 'Location and Size';
info{2} = {'Position','Units','OuterPosition','TightInset',...
    'ActivePositionProperty'};           
retval{end+1} = info;

info{1} = 'Multiple Plots';
info{2} = {'ColorOrder','ColorOrderIndex','LineStyleOrder',...
    'LineStyleOrderIndex','NextPlot','SortMethod'};           
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible','Clipping','ClippingStyle'};           
retval{end+1} = info;

if hasCameraProperties(handle(ax))
    info{1} = 'View';
    info{2} = {'CameraPosition','CameraPositionMode','CameraTarget',...
               'CameraTargetMode','CameraUpVector','CameraUpVectorMode',...
               'CameraViewAngle','CameraViewAngleMode','View'};           
    retval{end+1} = info;

    info{1} = 'Aspect Ratio';
    info{2} = {'DataAspectRatio','DataAspectRatioMode',...
               'PlotBoxAspectRatio','PlotBoxAspectRatioMode','Projection'};           
    retval{end+1} = info;
end

info{1} = 'Lighting and Transparency';
info{2} = {'ALim','ALimMode','AmbientLightColor'};           
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Tag','Type','UserData'};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','CurrentPoint','HitTest'...
    'PickableParts','Selected','SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'BusyAction','Interruptible'};           
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};           
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetGroupGrouping

info{1} = 'Visibility';
info{2} = {'Visible','Clipping','EraseMode'};
retval{1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetTransformGrouping

info{1}= 'Transform Matrix';
info{2}= {'Matrix'};
retval{1} = info;

info{1} = 'Visibility';
info{2} = {'Visible','EraseMode'};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction',};           
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};           
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetSurfaceGrouping

info{1}= 'Faces';
info{2}= {'FaceColor','FaceAlpha','FaceLighting','BackFaceLighting'};
retval{1} = info;

info{1} = 'Edges';
info{2} = {'EdgeColor','LineStyle','LineWidth','AlignVertexCenters',...
    'Marker','MarkerSize','MarkerEdgeColor','MarkerFaceColor',...
    'MeshStyle','EdgeAlpha','EdgeLighting'};
retval{end+1} = info;

info{1}= 'Face and Vertex Normals';
info{2}= {'FaceNormals','FaceNormalsMode','VertexNormals',...
    'VertexNormalsMode'};
retval{end+1} = info;

info{1} = 'Color and Transparency Mapping';
info{2} = {'AlphaData','AlphaDataMapping','CData','CDataSource',...
    'CDataMapping','CDataMode'};
retval{end+1} = info;

info{1} = 'Lighting';
info{2} = {'AmbientStrength','DiffuseStrength',...
    'SpecularColorReflectance','SpecularExponent','SpecularStrength'};
retval{end+1} = info;

info{1} = 'Data';
info{2} = {'XData','YData','ZData','XDataSource','YDataSource',...
    'ZDataSource','XDataMode','YDataMode'};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible','Clipping','EraseMode'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','HandleVisibility','Children'};           
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Tag','Type','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','BusyAction','Interruptible'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetPatchGrouping

info{1}= 'Faces';
info{2}= {'FaceColor','FaceAlpha','FaceLighting','BackFaceLighting'};
retval{1} = info;

info{1} = 'Edges';
info{2} = {'EdgeColor','LineStyle','LineWidth','EdgeAlpha',...
    'EdgeLighting','AlignVertexCenters'};
retval{end+1} = info;

info{1} = 'Markers';
info{2} = {'Marker','MarkerEdgeColor','MarkerFaceColor','MarkerSize'};
retval{end+1} = info;

info{1}= 'Face and Vertex Normals';
info{2}= {'FaceNormals','VertexNormals','FaceNormalsMode',...
    'VertexNormalsMode'};
retval{end+1} = info;

info{1} = 'Ambient Lighting';
info{2} = {'AmbientStrength','DiffuseStrength','SpecularStrength',...
    'SpecularColorReflectance','SpecularExponent'};
retval{end+1} = info;

info{1}= 'Color and Transparency';
info{2}= {'FaceVertexAlphaData','AlphaDataMapping','FaceVertexCData',...
    'CData','CDataMapping'};
retval{end+1} = info;

info{1} = 'Data';
info{2} = {'XData','YData','ZData','Faces','Vertices'};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible','Clipping','EraseMode'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetImageGrouping

info{1} = 'Image Data';
info{2} = {'CData','CDataMapping'};
retval{1} = info;

info{1} = 'Image Position';
info{2} = {'XData','YData'};
retval{end+1} = info;

info{1} = 'Image Transparency';
info{2} = {'AlphaData','AlphaDataMapping'};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible','Clipping'};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetLightGrouping

info{1}= 'Color, Position, and Style';
info{2}= {'Color','Position','Style'};
retval{1} = info;

info{1} = 'Visibility';
info{2} = {'Visible'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;

info{1} = 'Unused Properties';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight','PickableParts','HitTest','Interruptible',...
    'BusyAction'};           
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetTextGrouping

info{1}= 'Text';
info{2}= {'String','Interpreter',};
retval{1} = info;

info{1} = 'Font Style';
info{2} = {'Color','FontName','FontSize','FontUnits','FontAngle',...
    'FontWeight','FontSmoothing'};
retval{end+1} = info;

info{1}= 'Text Box';
info{2}= {'EdgeColor','BackgroundColor','Margin','LineStyle','LineWidth'};
retval{end+1} = info;

info{1}= 'Location and Size';
info{2}= {'Position','Extent','Units','Rotation','HorizontalAlignment',...
          'VerticalAlignment'};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible','Clipping','EraseMode'};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Parent and Children';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'Editing','ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};           
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetRectangleGrouping

info{1}= 'Appearance';
info{2}= {'Curvature','EdgeColor','FaceColor','LineStyle','LineWidth',...
    'AlignVertexCenters'};
retval{1} = info;

info{1} = 'Location and Size';
info{2} = {'Position'};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible','Clipping','EraseMode'};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetLineGrouping

info{1}= 'Line';
info{2}= {'LineStyle','LineWidth','Color','AlignVertexCenters'};
retval{1} = info;

info{1}= 'Markers';
info{2}= {'Marker','MarkerSize','MarkerEdgeColor','MarkerFaceColor',};
retval{end+1} = info;

info{1} = 'Data';
info{2} = {'XData','YData','ZData','XDataSource','YDataSource',...
    'ZDataSource','XDataMode'};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible','Clipping','EraseMode'};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;

%----------------------------------------------------%n 
function retval = localGetUIControlGrouping

info{1}= 'Appearance';
info{2}= {'Visible','BackgroundColor','ForegroundColor','CData'};
retval{1} = info;

info{1} = 'Location and Size';
info{2} = {'Position','Units','Extent'};
retval{end+1} = info;

info{1}= 'Font Style';
info{2}= {'FontName','FontSize','FontUnits','FontWeight','FontAngle'};
retval{end+1} = info;

info{1}= 'Text';
info{2}= {'String','HorizontalAlignment'};
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'Callback','ButtonDownFcn','KeyPressFcn','KeyReleaseFcn',...
    'Enable','TooltipString','UIContextMenu','Selected',...
    'SelectionHighlight'};
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'BusyAction','Interruptible','HitTest'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'BeingDeleted','CreateFcn','DeleteFcn',};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Tag','UserData','Type'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Type of Control';
info{2} = {'Style','Value','Max','Min','SliderStep','ListboxTop'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetUITableGrouping

info{1}= 'Appearance';
info{2}= {'Visible','BackgroundColor','ForegroundColor'};
retval{1} = info;

info{1} = 'Location and Size';
info{2} = {'Position','Units','Extent'};
retval{end+1} = info;

info{1} = 'Font Style';
info{2}= {'FontName','FontSize','FontUnits','FontWeight','FontAngle'};
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'CellEditCallback','CellSelectionCallback','ColumnEditable',...
    'RearrangeableColumns','ButtonDownFcn','KeyPressFcn',...
    'KeyReleaseFcn','Enable','TooltipString','UIContextMenu','Selected',...
    'SelectionHighlight'};
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'BusyAction','Interruptible','HitTest'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'BeingDeleted','CreateFcn','DeleteFcn',};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Tag','UserData','Type'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Table Data';
info{2} = {'Data'};
retval{end+1} = info;

info{1} = 'Table Layout';
info{2} = {'RowName','ColumnName','ColumnWidth','ColumnFormat',...
    'RowStriping'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetUIPanelGrouping

info{1}= 'Appearance';
info{2}= {'Visible','BackgroundColor','ForegroundColor','BorderType',...
    'BorderWidth' 'HighlightColor','ShadowColor','Clipping'};
retval{1} = info;

info{1} = 'Location and Size';
info{2} = {'Position','Units','SizeChangedFcn','ResizeFcn'};
retval{end+1} = info;

info{1} = 'Font Style';
info{2}= {'FontName','FontSize','FontUnits','FontWeight','FontAngle'};
retval{end+1} = info;

info{1} = 'Text';
info{2} = {'Title','TitlePosition'};
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'BusyAction','Interruptible','HitTest'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'BeingDeleted','CreateFcn','DeleteFcn',};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Tag','UserData','Type'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetUIButtonGroupGrouping

info{1}= 'Appearance';
info{2}= {'Visible','BackgroundColor','ForegroundColor','BorderType',...
    'BorderWidth' 'HighlightColor','ShadowColor','Clipping'};
retval{1} = info;

info{1} = 'Location and Size';
info{2} = {'Position','Units','SizeChangedFcn','ResizeFcn'};
retval{end+1} = info;

info{1} = 'Font Style';
info{2}= {'FontName','FontSize','FontUnits','FontWeight','FontAngle'};
retval{end+1} = info;

info{1} = 'Text';
info{2} = {'Title','TitlePosition'};
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','SelectionChangedFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'BusyAction','Interruptible','HitTest'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'BeingDeleted','CreateFcn','DeleteFcn',};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Tag','UserData','Type','SelectedObject'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetUITabGrouping

info{1}= 'Appearance';
info{2}= {'BackgroundColor','ForegroundColor',};
retval{1} = info;

info{1} = 'Location and Size';
info{2} = {'Position','Units','SizeChangedFcn','ResizeFcn'};
retval{end+1} = info;

info{1} = 'Text';
info{2} = {'Title'};
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','TooltipString','UIContextMenu'};
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'BusyAction','Interruptible'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'BeingDeleted','CreateFcn','DeleteFcn',};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Tag','UserData','Type'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetUITabGroupGrouping

info{1}= 'Appearance';
info{2}= {'Visible'};
retval{1} = info;

info{1} = 'Location and Size';
info{2} = {'TabLocation','Position','Units','SizeChangedFcn'};
retval{end+1} = info;

info{1} = 'Text';
info{2} = {'Title','TitlePosition'};
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'SelectionChangedFcn','ButtonDownFcn','UIContextMenu'};
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'BusyAction','Interruptible'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'BeingDeleted','CreateFcn','DeleteFcn',};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'SelectedTab','Tag','UserData','Type',};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetAnnotationArrowGrouping

info{1}= 'Appearance';
info{2}= {'Color','LineStyle','LineWidth','HeadStyle','HeadLength',...
    'HeadWidth'};
retval{1} = info;

info{1} = 'Location and Size';
info{2} = {'X','Y','Position','Units'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected','SelectionHighlight'};
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'BeingDeleted','CreateFcn','DeleteFcn',};
retval{end+1} = info;
 
info{1} = 'Identifiers';
info{2} = {'Tag','UserData','Type',};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetAnnotationDoubleEndArrowGrouping

info{1}= 'Appearance';
info{2}= {'Color','LineStyle','LineWidth','Head1Style','Head2Style',...
    'Head1Length','Head2Length','Head1Width','Head2Width'};
retval{1} = info;

info{1} = 'Location and Size';
%TODO why don't 'X' and 'Y' show up in the group?
info{2} = {'X','Y','Position','Units'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected','SelectionHighlight'};
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'BeingDeleted','CreateFcn','DeleteFcn',};
retval{end+1} = info;
 
info{1} = 'Identifiers';
info{2} = {'Tag','UserData','Type',};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible'};
retval{end+1} = info;
 
%----------------------------------------------------%
function retval = localGetAnnotationEllipseGrouping

info{1}= 'Appearance';
info{2}= {'Color','FaceColor','LineStyle','LineWidth'};
retval{1} = info;

info{1} = 'Location and Size';
info{2} = {'Position','Units'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected','SelectionHighlight'};
retval{end+1} = info;
 
info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;
 
info{1} = 'Creation and Deletion Control';
info{2} = {'BeingDeleted','CreateFcn','DeleteFcn',};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Tag','UserData','Type',};
retval{end+1} = info;
 
info{1} = 'Visibility';
info{2} = {'Visible'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetAnnotationLineGrouping

info{1}= 'Line Appearance';
info{2}= {'LineStyle','LineWidth','Color'};
retval{1} = info;

info{1} = 'Location and Size';
info{2} = {'X','Y','Position','Units'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected','SelectionHighlight'};
retval{end+1} = info;
 
info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;
 
info{1} = 'Creation and Deletion Control';
info{2} = {'BeingDeleted','CreateFcn','DeleteFcn',};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Tag','UserData','Type',};
retval{end+1} = info;
 
info{1} = 'Visibility';
info{2} = {'Visible'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetAnnotationRectangleGrouping

info{1}= 'Appearance';
info{2}= {'Color', 'FaceColor','FaceAlpha','LineStyle','LineWidth'};
retval{1} = info;

info{1} = 'Location and Size';
info{2} = {'Position','Units'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected','SelectionHighlight'};
retval{end+1} = info;
 
info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;
 
info{1} = 'Creation and Deletion Control';
info{2} = {'BeingDeleted','CreateFcn','DeleteFcn',};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Tag','UserData','Type',};
retval{end+1} = info;
 
info{1} = 'Visibility';
info{2} = {'Visible'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetAnnotationTextArrowGrouping

info{1}= 'Text';
info{2}= {'String','Interpreter','TextColor','TextRotation'};
retval{1} = info;

info{1} = 'Font Style';
info{2} = {'FontAngle','FontName','FontSize','FontUnits','FontWeight'};
retval{end+1} = info;

info{1}= 'Text Box';
info{2}= {'TextLineWidth','TextEdgeColor','TextBackgroundColor',...
    'TextMargin'};
retval{end+1} = info;

info{1}= 'Arrow Appearance';
info{2}= {'Color','LineStyle','LineWidth','HeadStyle','HeadLength',...
    'HeadWidth'};
retval{end+1} = info;

info{1}= 'Location and Size';
info{2}= {'X','Y','Position','Units','HorizontalAlignment','VerticalAlignment'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected','SelectionHighlight'};
retval{end+1} = info;
 
info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;
 
info{1} = 'Creation and Deletion Control';
info{2} = {'BeingDeleted','CreateFcn','DeleteFcn',};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Tag','UserData','Type',};
retval{end+1} = info;
 
info{1} = 'Visibility';
info{2} = {'Visible'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetAnnotationTextBoxGrouping

info{1}= 'Text';
info{2}= {'String','Interpreter'};
retval{1} = info;

info{1} = 'Font Style';
info{2} = {'Color','FontAngle','FontName','FontSize','FontUnits','FontWeight'};
retval{end+1} = info;

info{1}= 'Text Box';
info{2}= {'LineStyle','LineWidth','EdgeColor','BackgroundColor',...
    'FaceAlpha','FitBoxToText','Margin'};
retval{end+1} = info;

info{1}= 'Location and Size';
info{2}= {'Position','Units','HorizontalAlignment','VerticalAlignment'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected','SelectionHighlight'};
retval{end+1} = info;
 
info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;
 
info{1} = 'Creation and Deletion Control';
info{2} = {'BeingDeleted','CreateFcn','DeleteFcn',};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Tag','UserData','Type',};
retval{end+1} = info;
 
info{1} = 'Visibility';
info{2} = {'Visible'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetLegendGrouping

info{1}= 'Appearance';
info{2}= {'TextColor','Color','Box','EdgeColor','LineWidth'};
retval{1} = info;

info{1}= 'Location and Size';
info{2}= {'Location','Orientation','Position','Units'};
retval{end+1} = info;

info{1}= 'Text';
info{2}= {'String','Interpreter'};
retval{end+1} = info;

info{1} = 'Font Style';
info{2} = {'FontAngle','FontName','FontSize','FontWeight'};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible'};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Tag','UserData','Type',};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected','SelectionHighlight'};
retval{end+1} = info;
 
info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;
 
info{1} = 'Creation and Deletion Control';
info{2} = {'BeingDeleted','CreateFcn','DeleteFcn',};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetAnimatedLineGrouping

info{1}= 'Appearance';
info{2}= {'Color','LineStyle','LineWidth','MaximumNumPoints',...
    'AlignVertexCenters'};
retval{1} = info;

info{1}= 'Markers';
info{2}= {'Marker','MarkerSize','MarkerEdgeColor','MarkerFaceColor',};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible','Clipping','EraseMode'};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetAreaGrouping

info{1}= 'Appearance';
info{2}= {'EdgeColor','FaceColor','LineStyle','LineWidth',...
    'AlignVertexCenters'};
retval{1} = info;

info{1}= 'Baseline';
info{2}= {'BaseLine','BaseValue','ShowBaseLine'};
retval{end+1} = info;

info{1}= 'Data';
info{2}= {'XData','YData','XDataSource','YDataSource','XDataMode'};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible','Clipping','EraseMode'};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','HitTestArea','Interruptible',...
    'BusyAction'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetBarGrouping

info{1}= 'Bars';
info{2}= {'BarWidth','EdgeColor','FaceColor','LineStyle','LineWidth'};
retval{1} = info;

info{1}= 'Bar Graph Type';
info{2}= {'BarLayout','Horizontal'};
retval{end+1} = info;

info{1}= 'Baseline';
info{2}= {'BaseLine','BaseValue','ShowBaseLine'};
retval{end+1} = info;

info{1}= 'Data';
info{2}= {'XData','YData','XDataSource','YDataSource','XDataMode'};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible','Clipping','EraseMode'};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','HitTestArea','Interruptible',...
    'BusyAction'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetColorBarGrouping

info{1}= 'Appearance';
info{2}= {'Color','Box','LineWidth','Label'};
retval{1} = info;

info{1}= 'Location and Size';
info{2}= {'Location','Position','Units'};
retval{end+1} = info;

info{1} = 'Tick Marks and Tick Labels';
info{2} = {'Ticks','TicksMode','TickLabels','TickLabelsMode',...
    'TickLabelInterpreter','Direction','AxisLocation',...
    'AxisLocationMode','TickDirection','TickLength','Limits','LimitsMode'};
retval{end+1} = info;

info{1} = 'Font Style';
info{2} = {'FontAngle','FontName','FontSize','FontWeight'};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible'};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetContourGrouping

info{1}= 'Line Appearance';
info{2}= {'LineColor','LineStyle','LineWidth'};
retval{1} = info;

info{1}= 'Contour Levels';
info{2}= {'LevelList','LevelListMode','LevelStep','LevelStepMode'};
retval{end+1} = info;

info{1}= 'Contour Labels';
info{2}= {'ShowText','LabelSpacing','TextList','TextListMode',...
    'TextStep','TextStepMode'};
retval{end+1} = info;

info{1}= 'Filled Contours';
info{2}= {'Fill'};
retval{end+1} = info;

info{1}= 'Contour Matrix';
info{2}= {'ContourMatrix'};
retval{end+1} = info;

info{1}= 'Plotted Data';
info{2}= {'XData','YData','ZData','XDataSource','YDataSource',...
    'ZDataSource','XDataMode','YDataMode'};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible','Clipping','EraseMode'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetErrorBarGrouping

info{1}= 'Line Appearance';
info{2}= {'LineStyle','LineWidth','Color','AlignVertexCenters'};
retval{1} = info;

info{1}= 'Marker Appearance';
info{2}= {'Marker','MarkerSize','MarkerEdgeColor','MarkerFaceColor'};
retval{end+1} = info;

info{1}= 'Plotted Data';
info{2}= {'XData','YData','XDataSource','YDataSource','XDataMode',...
    'XNegativeDelta','XPositiveDelta','XNegativeDeltaSource','XPositiveDeltaSource',...
    'YNegativeDelta','YPositiveDelta','YNegativeDeltaSource','YPositiveDeltaSource'};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible','Clipping','EraseMode'};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetQuiverGrouping

info{1}= 'Arrows';
info{2}= {'Color','LineStyle','LineWidth','ShowArrowHead','MaxHeadSize',...
    'AutoScale','AutoScaleFactor','AlignVertexCenters'};
retval{1} = info;

info{1}= 'Markers';
info{2}= {'Marker','MarkerSize','MarkerEdgeColor','MarkerFaceColor'};
retval{end+1} = info;

info{1}= 'Data';
info{2}= {'UData','VData','WData','XData','YData','ZData','UDataSource',...
    'VDataSource','WDataSource','XDataSource','YDataSource',...
    'ZDataSource','XDataMode','YDataMode'};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible','Clipping','EraseMode'};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;
%----------------------------------------------------%
function retval = localGetScatterGrouping

info{1}= 'Marker Appearance';
info{2}= {'Marker','MarkerEdgeColor','MarkerFaceColor','LineWidth'};
retval{1} = info;

info{1}= 'Plotted Data';
info{2}= {'XData','YData','ZData','CData','SizeData','XDataSource',...
    'YDataSource','ZDataSource','CDataSource','SizeDataSource'};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible','Clipping','EraseMode'};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','HitTestArea','Interruptible',...
    'BusyAction'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetStairGrouping

info{1}= 'Line Appearance';
info{2}= {'LineStyle','LineWidth','Color'};
retval{1} = info;

info{1}= 'Markers';
info{2}= {'Marker','MarkerSize','MarkerEdgeColor','MarkerFaceColor'};
retval{end+1} = info;

info{1}= 'Data';
info{2}= {'XData','YData','XDataSource','YDataSource','XDataMode'};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible','Clipping','EraseMode'};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','Interruptible','BusyAction'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;

%----------------------------------------------------%
function retval = localGetStemGrouping

info{1}= 'Stems';
info{2}= {'Color','LineStyle','LineWidth'};
retval{1} = info;

info{1}= 'Markers';
info{2}= {'Marker','MarkerSize','MarkerEdgeColor','MarkerFaceColor'};
retval{end+1} = info;

info{1}= 'Baseline';
info{2}= {'BaseValue','ShowBaseLine','BaseLine'};
retval{end+1} = info;

info{1}= 'Data';
info{2}= {'XData','YData','ZData','XDataSource','YDataSource',...
    'ZDataSource','XDataMode'};
retval{end+1} = info;

info{1} = 'Visibility';
info{2} = {'Visible','Clipping','EraseMode'};
retval{end+1} = info;

info{1} = 'Identifiers';
info{2} = {'Type','Tag','UserData','DisplayName','Annotation'};
retval{end+1} = info;

info{1} = 'Handle Visibility';
info{2} = {'Parent','Children','HandleVisibility',};           
retval{end+1} = info;

info{1} = 'Interactive Control';
info{2} = {'ButtonDownFcn','UIContextMenu','Selected',...
    'SelectionHighlight'};           
retval{end+1} = info;

info{1} = 'Callback Execution Control';
info{2} = {'PickableParts','HitTest','HitTestArea','Interruptible',...
    'BusyAction'};
retval{end+1} = info;

info{1} = 'Creation and Deletion Control';
info{2} = {'CreateFcn','DeleteFcn','BeingDeleted'};
retval{end+1} = info;

%----------------------------------------------------%
function props = makeProperties(names, prop)
% Creates dimension-specific property names. For example XLim from 'X' and 'Lim'.
props = {[names{1} prop], [names{2} prop], [names{3} prop]};
