function out = javasetget(ejag,useSet,jobj,varargin)
% JAVASETGET Helper function to set and get properties on Java Objects.

% Copyright 2010 The MathWorks, Inc.

% This function is called when MATLAB decides to set a property on a Java object.  It 
% is not called when the Java object is automatically wrapped in an HG
% object, as in the case where set/get is called while EnableJavaObject is 1 or 2.

    % make sure we have a Java object
    if ~isjava(jobj)
        error(message('MATLAB:javaset:invalidinput'))
    end

    if useSet
        minrhs = 3;
        maxrhs = inf;
    else
        minrhs = 3;
        maxrhs = 5;
    end

    narginchk(minrhs,maxrhs)
    if nargout
        out = [];
    end
    if isempty(varargin)
        % just display the options
        cmd = 'get';
        if useSet
            cmd = 'set';
        end
        % just use handle - don't use lochandle so we don't
        % show all the callback properties.
        hobj = handle(jobj);
        if nargout
            out = feval(cmd,hobj);
        else
            disp(feval(cmd,hobj))
        end
        return
    end
    argc = length(varargin);

    ind = 1;
    try
        while ind <= argc;
            prop = varargin{ind};
            if isstruct(prop)
                % if prop is a struct, then the field names and values
                % become the property names and values
                fields = fieldnames(prop);
                for ifield = 1:size(fields);
                    field = fields(ifield);
                    doprop(field{1}, prop.(field{1}))
                end
                ind = ind + 1;
            else
                % if prop isn't a struct, use the next arg as the value, if one
                % note these args could both be cell arrays
                if argc < ind+1
                    doprop(prop)
                else
                    doprop(prop, varargin{ind+1})
                end
                ind = ind + 2;
            end
        end
    catch e
        e.throwAsCaller;
    end

    % issue set/get on propname with optional propval, handling the
    % EnableJavaASGObject feature and special case of 'UserData' when the feature = 3 or 4
    function doprop(propname, propval)
        persistent hgprops;
        % Don't bother to handle the cell array case for ejag == 3 or 4.  It'll just be
        % handled like ejag = 0, which means it might fail if the property doesn't exist.
        if ejag == 0 || iscell(propname)
            % This is the eventual behavior where we don't allow HG properties to be set on Java objects
            if (nargin == 2)
                dosetget(propname, propval)
            else
                dosetget(propname)
            end
        else
            % Come here when EnableJavaASGObject is 3 or 4.
            % This works like EnableJavaASGObject = 0, with the exception that
            % UserData will work like EnableJavaASGObject = 1 or 2.  It's not clear we
            % need this, but it can be used in an emergency to get an application working
            % after all other HG properties are deprecated.
            % Get rid of all this code when we no longer need to support
            % legacy behavior (EnableJavaAsGObject ~= 0).
            lpropname = lower(propname);
            % Handle the property using the normal set/get on the handle.  
            % However UserData gets special handling.
            switch lpropname
                case 'userdata'
                    if ejag == 3
                        warning(message('MATLAB:hg:JavaSetHGProperty'))
                    end
                    if useSet
                        if (nargin == 2)
                            javauserdata(useSet, jobj, propval);
                        else
                            fprintf('A %s''s "UserData" property does not have a fixed set of property values.', ...
                                class(jobj))
                        end
                    else
                        out = javauserdata(useSet, jobj);
                    end
                otherwise
                    if (nargin == 2)
                        dosetget(propname, propval)
                    else
                        dosetget(propname)
                    end
            end
        end
    end

    % Issue set/get on propname and optional propval.  This will error out
    % if the property doesn't exist.  If the property is an HG property but not a Java
    % property, this will error out if EnableJavaAsGObject = 0.
    function dosetget(propname, propval)
        if useSet
            if (nargin == 1)
                set(lochandle(jobj),propname)
            else
                set(lochandle(jobj),propname,propval)
            end
        else
            % Error if nargin == 2
            out = get(lochandle(jobj),propname);
        end
    end

    function out=javauserdata(useSet, varargin)
        %JAVAUSERDATA Store userdata on a Java object or return the current value.
        if nargout
            out = javaprop(useSet, 'UserData','mxArray',varargin{:});
        else
            javaprop(useSet, 'UserData','mxArray',varargin{:});
        end
    end

    function out=javaprop(useSet, prop, dtype, jobj, value)
        if useSet
            if ~locisprop(jobj,prop)
                schema.prop(lochandle(jobj),prop,dtype);
            end
            set(lochandle(jobj),prop,value)
        else
            out = [];
            if locisprop(jobj,prop)
                out = get(lochandle(jobj),prop);
            end
        end
    end

    function yesno = locisprop(jobj,prop)
        yesno = ~isempty(findprop(lochandle(jobj), prop));
    end

    function hobj = lochandle(obj)
        % If the object passed in is a UDDObject, it's already been
        % converted to a handle and we need to grab the underlying
        % object. Calling handle with no args will do that.
        if isa(obj,'com.mathworks.jmi.bean.UDDObject')
            obj = handle(obj);
        end
        % If we can't convert the underlying object to a
        % handle, just let the dispatcher deal with it.
        try
            if ejag == 0
                hobj = handle(obj);
            else
                hobj = handle(obj,'callbackPropertiesonoff');
            end
            waserr = false;
        catch e
            waserr = ~isempty(e);
        end
        if waserr
            hobj = obj;
        end
    end
end
