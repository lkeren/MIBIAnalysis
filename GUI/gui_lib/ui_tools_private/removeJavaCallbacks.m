%   Copyright 2011 The MathWorks, Inc.
%  This function is for internal use and will change in a future release


%-----------------------------------------------------
% We are giving ourselves a hook to run resource cleanup functions
% like freeing up callbacks. This is important for uitree because
% the expand and selectionchange callbacks need to be freed when
% the figure is destroyed. See G769077 for more information.
%-----------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Empties all callbacks on the given java UDD handle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function removeJavaCallbacks(jh)
  c = classhandle(jh);
  if (~isJavaHandleWithCallbacks(c))
      return;
  end
  E = c.Events;
  for k = 1:length(E)
     set(jh, [E(k).Name 'Callback'] , []);
  end
 
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Helper that determines if a given class handle
% is a java handle with callbacks or not
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function withCbks = isJavaHandleWithCallbacks(metacls)
assert(isa(metacls,'schema.class'));
pkgName = metacls.Package.Name;
withCbks = strcmp(pkgName,'javahandle_withcallbacks');
end