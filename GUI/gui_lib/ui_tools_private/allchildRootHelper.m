function rootobj = allchildRootHelper(handleList)
% This function is undocumented and will change in a future release

%   Copyright 2011-2014 The MathWorks, Inc.

% establish the correct root object
rootobj = 0;
if ~isempty( handleList )
    rootobj = groot;
end
