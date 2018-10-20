function result = usev0tabgroup(varargin)

%   Copyright 2009-2014 The MathWorks, Inc.

if (usev0dialog(varargin{:}))
    error(message('MATLAB:uitabgroup:MigratedFunction'));
else
    result = builtin('hguitabgroup',varargin{:});
end
