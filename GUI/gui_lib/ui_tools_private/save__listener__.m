function save__listener__(hC,hl)

%   Copyright 2008 The MathWorks, Inc.
for i= 1:numel(hC)
    p = findprop(hC(i), 'Listeners__');
    if (isempty(p))
        p = schema.prop(hC(i), 'Listeners__', 'handle vector');
        % Hide this property and make it non-serializable and
        % non copy-able.
        set(p,  'AccessFlags.Serialize', 'off', ...
            'AccessFlags.Copy', 'off',...
            'FactoryValue', [], 'Visible', 'off');
    end
    % filter out any non-handles
    hC(i).Listeners__ = hC(i).Listeners__(ishandle(hC(i).Listeners__));
    hC(i).Listeners__ = [hC(i).Listeners__; hl];
end



