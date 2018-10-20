function selectedColor = uisetcolor_helper(varargin)
%   Copyright 2007-2014 The MathWorks, Inc.
[rgbColorVector,title,fhandle] = parseArgs(varargin{:});

ccDialog = matlab.ui.internal.dialog.DialogUtils.createColorChooser();
ccDialog.Title = title;
if ~isempty(rgbColorVector)
    ccDialog.InitialColor = rgbColorVector;
end

c = matlab.ui.internal.dialog.DialogUtils.disableAllWindowsSafely();
selectedColor = showDialog(ccDialog);
delete(c);

if (~isempty(rgbColorVector) && ~(size(selectedColor,2)==3))
    selectedColor = rgbColorVector;
end

if  ~isempty(fhandle)
    try
        set(fhandle,'Color',selectedColor);
    catch
        try
            set(fhandle,'ForegroundColor',selectedColor);
        catch
            try
                set(fhandle,'BackgroundColor',selectedColor);
            catch
            end
        end
    end

end


function [rgbColorVector,title,handle] = parseArgs(varargin)
handle = [];
rgbColorVector = [];
title = getString(message('MATLAB:uistring:uisetcolor:TitleColor'));
if nargin>2
    error(message('MATLAB:uisetcolor:TooManyInputs')) ;
end
if (nargin==2)
    if ~ischar(varargin{2})
        error(message('MATLAB:uisetcolor:InvalidSecondParameter'));
    end
    title = varargin{2};
end
if  (nargin>=1)
    if (isscalar(varargin{1}) && ishghandle(varargin{1}))
        handle = varargin{1};
        rgbColorVector = getrgbColorVectorFromHandle(handle);
    elseif (~ischar(varargin{1}) && isnumeric(varargin{1})) 
        rgbColorVector = varargin{1};
    elseif ischar(varargin{1})
        if (nargin > 1)
            error(message('MATLAB:uisetcolor:InvalidParameterList'));
        end
        title = varargin{1};
    else
        error(message('MATLAB:uisetcolor:InvalidFirstParameter'));
    end
end

%Given the dialog, user chooses to select or not select
function rgbColorVector = showDialog(ccDialog)
ccDialog.show;
rgbColorVector = ccDialog.SelectedColor;
if isempty(rgbColorVector)
    rgbColorVector = 0;
end


%Helper functions to extract color(rgbColorVector) from the given handle


function rgbValue = getrgbColorVectorFromHandle(fhandle)
rgbValue = [0 0 0];
try
    rgbValue = get(fhandle,'Color');
catch
    try
        rgbValue = get(fhandle,'ForegroundColor');
    catch
        try
            rgbValue = get(fhandle,'BackgroundColor');
        catch
        end
    end
end

