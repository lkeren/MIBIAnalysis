function result = usev0tab(varargin)

%   Copyright 2009-2014 The MathWorks, Inc.

if (usev0dialog(varargin{:}))
    error(message('MATLAB:uitab:MigratedFunction'));
else
    result = builtin('hguitab', varargin{:});
end
