function [filename, pathname, filterindex] = uigetputfile_helper(varargin)

% Copyright 2006-2012 The MathWorks, Inc.

% Use the first argument to determine if we are doing uigetfile (0)
% or uiputfile (1), then remove that first argument.
narginchk(1, 8);
uigetputtype = varargin{1};
if ((uigetputtype ~= 0) && (uigetputtype ~= 1))
    error(message('MATLAB:uigetputfile_helper:WrongType'));
end

% Check the number of arguments, if more than the maximum
% (uigetfile = 7, uiputfile = 5) plus uigetputtype (first
% argument added by uigetfile/uiputfile), then error out.
if (uigetputtype == 0)
    narginchk(1, 8);
else
    narginchk(1, 6);
end

% Remove the uigetputtype argument, so we can work on pure
% uigetfile/uiputfile arguments.
varargin = varargin(2:end);

% Parse the arguments and set up the file dialog parameters.
[dialog_filter, dialog_title, dialog_filename, dialog_pathname, dialog_multiselect] = parseArguments();

% Call the appropriate file dialog depending on uigetputtype,
% setting MultiSelect if we are doing a uigetfile.
warning_state = warning('off', 'MATLAB:class:inUseRedefined');
if (uigetputtype == 0)
    ufd = matlab.ui.internal.dialog.FileOpenChooser();
    ufd.MultiSelection = dialog_multiselect;
else
    ufd = matlab.ui.internal.dialog.FileSaveChooser();
end
warning(warning_state);

% Set the remaining file dialog parameters and show the dialog.
ufd.FileFilter = dialog_filter;
ufd.Title = dialog_title;
ufd.InitialFileName = dialog_filename;
ufd.InitialPathName = dialog_pathname;
c = matlab.ui.internal.dialog.DialogUtils.disableAllWindowsSafely();
ufd.show();
delete(c);

% Set the returned filename; if it is empty, set filename to 0
% as this is what is expected by uigetfile/uiputfile.
filename = ufd.FileName;
if (isempty(filename))
    filename = 0;
elseif (iscell(filename) && (length(filename) == 1))
    %For backward compatibility, always return a char array if only one
    %file is selected, irrespective of the MultiSelection flag.
    filename = filename{1};
end

% If the user changed the "type" of file filter, we need to add the
% file extension back on.
if (uigetputtype~=0)
    filename = fixFileExtensions(filename);
end

% Set the returned pathname; if it is empty, set pathname to 0
% as this is what is expected by uigetfile/uiputfile.
pathname = ufd.PathName;
if (isempty(pathname))
    pathname = 0;
else
    if (~isequal(pathname(end), filesep))
        pathname = strcat(pathname, filesep);
    end
end

% Set the returned file filter index.
filterindex = ufd.FilterIndex;

% Done - cleanup after oneself.
% MCOS Object ufd cleans up and its java peer at the end of its
% scope(AbstractDialog has a destructor that every subclass
% inherits)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     N E S T E D   F U N C T I O N S                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%---------------------------------------------------------------------
% parse the arguments sent to uigetfile/uiputfile and set up the
% file dialog parameters appropriately.
    function [dialog_filter, dialog_title, dialog_filename, dialog_pathname, dialog_multiselect] = parseArguments()
        % Initialize parameters for UiFileDialog.
        dialog_filename = '';
        dialog_pathname = '';
        dialog_filter = '';

        % Set the dialog title depending on which file dialog we are using.
        % This is in sync with the File Dialog text.
        if (uigetputtype == 0)
            dialog_title = getString(message('MATLAB:uistring:filedialogs:SelectFileToOpen'));
        else
            dialog_title = getString(message('MATLAB:uistring:filedialogs:SelectFileToWrite'));
        end

        % Get the number of arguments sent in.
        numArgs = numel(varargin);

        % First, check to see if the user entered in two integers as the last two
        % arguments.  If so, they entered in the obsoleted 'x' and 'y' location
        % parameters, which will be ignored.  Warn the user, but since this is
        % not a fatal error, trim these arguments off and continue.
        if (numArgs > 1)
            if (isnumeric(varargin{numArgs}) && isnumeric(varargin{numArgs - 1}))
                warning(message('MATLAB:uigetputfile_helper:xyobsolete'));
                if (numArgs > 2)
                    varargin = varargin(1:numArgs-2);
                end
                numArgs = numel(varargin);
            end
        end

        % Next, see if there are any property-value pairs.  The only
        % properties allowed are 'MultiSelection' and 'Location'.
        % 'Location' is being obsoleted; we will warn the user and ignore
        % the value.  Trim off the property-value pairs so we are left with
        % just convenience arguments.
        [dialog_multiselect, varargin, numArgs] = parsePropertyValuePairs(varargin, numArgs);

        % Now if there are more than 3 arguments left, the user added extra
        % convenience arguments or parameter-value pairs that are not
        % supported, so let him/her know.
        if (numArgs > 3)
            error(message('MATLAB:uigetdir_helper:BadSyntax'))
        end

        % What we have left are filterspec/filename and optionally title and
        % default filename.  We will deal with these in order.
        % Set the filter.
        if (numArgs > 0)
            dialog_filter = varargin{1};
            % Make sure dialog_filter is a string or cellarray. - g392289.
            if (~(ischar(dialog_filter)) && ~(iscell(dialog_filter)))
                error(message('MATLAB:uigetdir_helper:BadFilename'))
            end
            checkForEmptyDescriptors(dialog_filter);
            [dialog_filter, dialog_filename, dialog_pathname] = getFilterFileAndPath(dialog_filter);
        end

        % Check for title and set appropriate variable (must be string).
        if (numArgs > 1)
            title = varargin{2};
            dialog_title = checkString(title, 'Title');
        end

        % Check for default filename.
        if (numArgs > 2)
            defaultfile = varargin{3};
            defaultfilepath = checkString(defaultfile, 'Filename');

            % Peel the defaultfilepath apart, as long as there is something to work with.
            if (~isempty(defaultfilepath))
                % The third 'default file' argument may consist of a
                % pathname as well as a filename.  The pathname and
                % filename of the 'default file' third argument trumps the
                % pathname and filename of the 'filter' first argument,
                % however the filter previously determined by the first
                % argument is not touched.
                [dialog_filename, dialog_pathname] = getFileAndPath(defaultfilepath);
            end
        end
    end % parseArguments

%---------------------------------------------------------------------
% Parses for property/value pairs multiselect (supported) and
% location (obsoleted), trims any property/value pairs found and returns
% the argument list sans p/v pairs.
    function [multiselect, newVarArgIn, newNumArgs] = parsePropertyValuePairs(varArgIn, numArgs)
        % Initialize return values.
        multiselect = false;
        newVarArgIn = varArgIn;
        newNumArgs = numArgs;
        
        % Start looking.
        oldPropList = {'location', 'multiselect'};
        index = 1;
        while (index < newNumArgs)
            oldPropsFound = [0 0];
            if (iscellstr(newVarArgIn(index)))
                propEntered = newVarArgIn{index};
                if ~isempty(propEntered)
                    oldPropsFound = strncmpi(propEntered, oldPropList, length(propEntered));
                else
                    oldPropsFound = [false false];
                end
            end
            if ((oldPropsFound(1) == 0) && (oldPropsFound(2) == 0)) 
                index = index + 1;
            else
                if (oldPropsFound(1) == 1)
                    warning(message('MATLAB:uigetputfile_helper:locationobsolete'));
                else
                    if (uigetputtype == 0)
                        multiSelectValue = newVarArgIn{index+1};
                        if (~(strcmpi('on', multiSelectValue)) && ~(strcmpi('off', multiSelectValue)))
                            error(message('MATLAB:uigetputfile_helper:badmultiselect'));
                        else
                            if (strcmpi('on', multiSelectValue))
                                multiselect = true;
                            end
                        end
                    else
                        error(message('MATLAB:uigetputfile_helper:multiselectgetonly'));
                    end
                end
                % Remove this property-value pair.
                newVarArgIn(:,index:index+1) = [];
                newNumArgs = newNumArgs - 2;
            end
        end
    end % parsePropertyValuePairs
            
%---------------------------------------------------------------------
% Determine the filename, pathname and filter.
% Filters can be either:
%   strings:
%     'myfile.bar' => filter is '*.bar', default filename
%                            is 'myfile.bar', All Files appended.
%     '*.m' => filter is '*.m', All Files appended.
%     '<char>*<char>.m => filter is '<char>*<char>.m, filename
%                         is blank, All Files appended.
% or:
%   cell arrays.
%       {'*.m'; '*.mat'} => filter is unchanged, All Files is appended
%       {'*.mat','MAT-files (*.mat)'; '*.mdl','Models (*.mdl)'}
%                => filter is unchanged, All Files is NOT appended.
%       {'*.m;*.fig;*.mat;*.mdl', 'All MATLAB Files (*.m, *.fig, *.mat, *.mdl)'; ...
%         '*.m', 'MATLAB Code Files(*.*)'}
%                => filter is unchanged, All Files is NOT appended.
    function [returned_filter, returned_filename, returned_pathname] = getFilterFileAndPath(filter)

        % Initialize return values
        returned_filter = '';
        returned_filename = '';
        returned_pathname = '';

        % We want to add 'All Files' in all cases unless we have a cell array with descriptors.
        addAllFiles = true;

        % If this is a degenerate case of a 1x1 cell array, convert it to a string.
        % Third condition is to take care of edge case uigetfile(cell(1)).
        if ((iscell(filter)) && (isequal(size(filter), [1 1])) && (~isequal(filter, {[]})))
            filter = char(filter);
        end

        % String manipulation
        if (~iscell(filter))
            % extract path ?
            % Special case - if filter is '*' then change it to '*.*'
            if (isequal(filter, '*'))
                filter = '*.*';
            end
            % Special case '.' and '..' - we can send those right through.
            if ((isequal(filter, '.')) || (isequal(filter, '..')))
                returned_pathname = filter;
            else
                % Special case - if filter is '*.* then do not change it.
                if (isequal(filter, '*.*'))
                    addAllFiles = false;
                    [path, ~, ~] = fileparts(filter);
                    returned_pathname = path;
                    returned_filter = filter;
                else
                    % Break the filter into pieces.
                    [path, file, ext] = fileparts(filter);

                    % Always use the path.
                    returned_pathname = path;

                    % If there is no extension (e.g. 'myfile'), use file leave filter blank.
                    if (isempty(ext))
                        returned_filename = file;
                    elseif ((isempty(strfind(file, '*'))) && (isempty(strfind(ext, '*'))) && ...
                            (isempty(strfind(file, '?'))) && (isempty(strfind(ext, '?'))))
                        % There are no wildcards in the file or extension, use file+ext as
                        % filename and *.ext as filter.
                        returned_filename = [file, ext];
                        returned_filter = ['*', ext];
                    else
                        % There are wildcards, so leave filename blank and file+ext for filter.
                        returned_filter = [file, ext];
                    end
                end
            end
        else % Cell array manipulation
            if (size(filter, 2) == 1)  % No descriptors, add 'All Files' unless '*.*' in list.
                for i=1:size(filter,1)
                    % Special case - if filter is '*' then change it to '*.*'
                    if (isequal(filter(i), '*'))
                        filter(i) = '*.*';
                    end
                    if (isequal(filter(i), {'*.*'}))
                        addAllFiles = false;
                    end
                end
            else  % Descriptors, we do not add 'All Files'.
                addAllFiles = false;
            end
            returned_filter = filter;
        end

        % Now add 'All Files' appropriately.
        if (addAllFiles)
            % If a string, create a cell array and append '*.*'.
            if (~iscell(returned_filter))
                returned_filter = {returned_filter; '*.*'};
                % If it is a cell array without descriptors, add '*.*'.
            elseif (size(returned_filter, 2) == 1)
                returned_filter{end+1} = '*.*';
            end
        end
    end % getFilterFileAndPath

%---------------------------------------------------------------------
% Determine the filename and pathname.
% This is used only for the third default filename/pathname argument; the
% filename and pathname here trump those in the first argument.  If a
% wildcard is passed in, it is used as the filename (backward compatibility)
% but does not affect the filter.
    function [returned_filename, returned_pathname] = getFileAndPath(defaultFilePath)
        %Initialize returned values.
        returned_filename = '';
   
        % Special case '.' and '..' - we can send those right through. 
        if ((isequal(defaultFilePath, '.')) || (isequal(defaultFilePath, '..')))
            returned_pathname = defaultFilePath;
        else
            [path, file, ext] = fileparts(defaultFilePath);
            returned_pathname = path;
            returned_filename = [file, ext];
        end
    end  %getFileAndPath

%---------------------------------------------------------------------
% Descriptors may not be empty.
    function checkForEmptyDescriptors(filter)
        if (iscell(filter))
            if (size(filter, 2) == 2)  % Descriptors
                for i=1:size(filter,1)
                    if (isequal(filter(i,2), {''}))
                        error(message('MATLAB:uigetdir_helper:EmptyDescriptors'))
                    end
                end
            end
        end
    end

%---------------------------------------------------------------------
% Check to see if the input variable is really a string; if not, error
% out and tell the user which variable is bad.
    function [stringout] = checkString(stringin, varName)
        if ~(isempty(stringin))
            if (~(ischar(stringin) && isvector(stringin)))
                error(message('MATLAB:uigetdir_helper:BadStringArg', varName))
            end
            % Do we need this?
            if (ischar(stringin) && isvector(stringin))
                if ~(1 == size(stringin, 1))
                    stringin = stringin';
                end
            end
        end
        stringout = stringin;
    end % checkString

%---------------------------------------------------------------------
% If the user changed the file filter type, the extension(s) may have
% been lost, so let's fix those so we return filename.ext and not just
% filename.
    function [returnedFilename] = fixFileExtensions(filename)
        returnedFilename = filename;
        % Only do this if the filename and file filter are non-empty.
        if (~isempty(filename) && ~isequal(filename, 0) && ~isempty(ufd.FileFilter))
            fileExtension = char(ufd.FileFilter(ufd.FilterIndex));
            if (isempty(strfind(fileExtension, ';')))  % can only do this for non-compound extensions
                dotFound = strfind(fileExtension, '.');  % look for all the dots in the file extension
                extensionToAdd = '';
                if (~isequal(length(dotFound), 0))
                    extensionToAdd = fileExtension(dotFound(end):end);  % get the last extension
                end;
                % g452995 - special case - if extension is '.*' (from 
                % All Files filter, remove it as this is an incorrect
                % extension.
                if (isequal(extensionToAdd, '.*'))
                    extensionToAdd = '';
                end;
                if (~iscell(filename))  % string
                    [~, ~, ext] = fileparts(filename);
                    if (isempty(ext))
                        returnedFilename = [filename, extensionToAdd];
                    end;
                else  % cell array
                    [~, ~, ext] = fileparts(char(filename(1)));
                    if (isempty(ext))
                        for i=1:size(filename, 2)
                            returnedFilename(i) = [filename(i), extensionToAdd];
                        end
                    end
                end
            end
        end
    end % fixFileExtensions

end
