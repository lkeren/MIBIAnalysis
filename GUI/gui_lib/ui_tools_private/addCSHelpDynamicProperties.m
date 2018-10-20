% Copyright 2009-2014 The MathWorks, Inc.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper functions - MCOS transition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addCSHelpDynamicProperties(FigHandle)
p = findprop(FigHandle,'CSHelpMode');
if isempty(p) 
    hprop = addprop(FigHandle,'CSHelpMode');
    hprop.SetObservable = true;
    hprop.AbortSet = true;
    checkfunction = @(x) isstring(x);
    hprop.SetMethod = valueCheckFunction(hprop,checkfunction);
    addprop(FigHandle,'CSHelpData');
end
end

function h = valueCheckFunction(hprop, checkfunction)
    function setproperty(obj, val)
        checkfunction(val);
        obj.(hprop.Name) = val;
    end
h = @setproperty;
end

function isstring(x)
if ~ischar(x)
    error(message('MATLAB:cshelp:InvalidStringInput'));
end
end
