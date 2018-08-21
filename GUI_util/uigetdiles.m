function [pathnames] = uigetdiles(start_path, dialog_title)
% Pick a directory with the Java widgets instead of uigetdir
% copied most of this from something online

import javax.swing.JFileChooser;

pwd = start_path;

jchooser = javaObjectEDT('javax.swing.JFileChooser', start_path);

jchooser.setFileSelectionMode(JFileChooser.FILES_AND_DIRECTORIES);
jchooser.setMultiSelectionEnabled(true);
if nargin > 1
    jchooser.setDialogTitle(dialog_title);
end

status = jchooser.showOpenDialog([]);

if status == JFileChooser.APPROVE_OPTION
    jFiles = jchooser.getSelectedFiles();
    for i=1:numel(jFiles)
        pathnames{i} = char(jFiles(i).getPath());
    end
elseif status == JFileChooser.CANCEL_OPTION
    pathnames = [];
else
    error('Error occured while picking file.');
end