function result = usev0buttongroup(varargin)
%   Copyright 2009-2015 The MathWorks, Inc.

% This will just return the new buttongroup
% If a new buttongroup is not created based on the built-in logic, defer to
% the old buttongroup creation.

% built-in buttongroup.
result = builtin('hguibuttongroup', varargin{:});

end
