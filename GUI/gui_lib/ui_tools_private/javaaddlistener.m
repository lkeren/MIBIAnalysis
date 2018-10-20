function hdl=javaaddlistener(jobj, eventName, response)
%  ADDLISTENER Add a listener to a Java object.
%
%  L=ADDLISTENER(JObject, EventName, Callback)
%  Adds a listener to the specified Java object for the given
%  event name. The listener will stop firing when the return
%  value L goes out of scope.
%
%  ADDLISTENER(JObject)
%  Lists all the available event names.
%
%  Examples:
%
%  jf = javaObjectEDT('javax.swing.JFrame');
%  addlistener(jf) % list all events
%
%  % Basic string eval callback:
%  addlistener(jf,'WindowClosing','disp closing')
%
%  % Function handle callback
%  addlistener(jf,'WindowClosing',@(o,e) disp(e))

% Copyright 2003-2010 The MathWorks, Inc.

% make sure we have a Java objects
    if ~isjava(jobj)
        error(message('MATLAB:addlistener:InvalidNonJavaObject'))
    end
    if nargin == 1
        if nargout
            error(message('MATLAB:addlistener:InvalidNumberOfInputArguments'))
        end
        % just display the possible events
        hSrc = handle(jobj,'callbackproperties');
        allfields = sortrows(fields(set(hSrc)));
        for i = 1:length(allfields)
            fn = allfields{i};
            if ~isempty(strfind(fn,'Callback'))
                fn = strrep(fn,'Callback','');
                disp(fn)
            end
        end
        return;
    end

    hdl = handle.listener(handle(jobj), eventName, ...
                          @(o,e) cbBridge(o,e,response));
    set(hdl,'RecursionLimit',255); % Allow nested callbacks g681014
end

function cbBridge(o,e,response)
    hgfeval(response, java(o), e.JavaEvent)
end

% LocalWords:  JObject jf invalidinput callbackproperties
