function [olduitable] = uitable_parseold(varargin)

%   Copyright 2007-2008 The MathWorks, Inc.

% Initialize return value of olduitable.
olduitable = false;

% List of old uitable property names.
oldpropnames = {'columnnames', 'datachangedcallback', 'enabled', 'gridcolor', 'numcolumns', 'numrows', 'rowheight'};

% Get a local copy of varargin.
args = varargin;
numArgs = numel(args);

% Check to see if the first argument is a parent handle.  If so, that is ok
% and can be used by the new uitable; this can be lopped off the argument
% list so we can continue checking on.  olduitable is  set to false, 
% which is valid.
if ((numArgs > 0) && isscalar(args{1}))
    if (ishghandle(args{1}) || ... 
        ~isvalid(args{1})) % Additionally, for deleted handle, go to the new uitable for validation and error - g1436085
    
        % Only handle or deleted handle was sent in, we are done.
        if (numArgs == 1)
            numArgs = 0; 
        else
            args = args(2:end);
            numArgs = numel(args);
        end
    end
end

% Now that the parent (if any) is gone, we can start checking the rest of
% the arguments.  If there are no more, then we are set, newuitableusage is
% true and we can try to run with the new uitable.  If not, we have to
% special-check for old uitable usages and properties.
if (numArgs > 0)
    % Did the user enter in anything except a property string? If so, this
    % is old uitable usage, let it figure out if the syntax is valid.
    if ~(ischar(args{1}))
        olduitable = true;
    else
        index = 1;
        while(index < numArgs)
            if (~isempty(strmatch(lower(args{index}), oldpropnames, 'exact')))
                olduitable = true;
            end
            index = index + 2;
        end
    end
end

end