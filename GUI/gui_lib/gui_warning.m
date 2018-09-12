function gui_warning(message)
    disp(['[' 8 message ']' 8]);
    warndlg(message, 'Achtung!');
    beep;
end

