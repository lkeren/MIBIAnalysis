function result = usejavadialog(functionName)

%   Copyright 2006-2015 The MathWorks, Inc.
result = usejava('awt');
% For -nojvm/-nodisplay modes the dialogs follow a deprecated code path
% that already throws a warning


% Show the warning for -nodisplay/-noFigureWindows mode
% Throw error in -nojvm mode
% warnfiguredialog method only shows a warning if java is present
warnfiguredialog(functionName);