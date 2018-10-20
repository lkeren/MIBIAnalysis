function arglist = parseJavaArgs(args,clslist)

% Copyright 2005-2007 The MathWorks, Inc.

if isempty(args) || isempty(clslist)
    arglist = [];
    return;
end
arglist = javaArray('java.lang.Object',length(clslist));
for n=1:length(clslist)
    arglist(n) = convertToJava(args{n},clslist(n));
end

    function [javaObj] = convertToJava(mlObj,class)
        % store persistent vars in MATLAB workspace as a small performance enhancement
        persistent inttype doubletype booltype longtype;
        persistent bytetype chartype shorttype floattype objecttype;
        if isempty(inttype)
            inttype    = java.lang.Integer.TYPE;
            doubletype = java.lang.Double.TYPE;
            booltype   = java.lang.Boolean.TYPE;
            longtype   = java.lang.Long.TYPE;
            bytetype   = java.lang.Byte.TYPE;
            chartype   = java.lang.Character.TYPE;
            shorttype  = java.lang.Short.TYPE;
            floattype  = java.lang.Float.TYPE;
            objecttype = java.lang.Class.forName('java.lang.Object');
        end
        
        if nargin == 1
            if isinteger(mlObj)
                class = inttype;
            elseif isfloat(mlObj)
                class = doubletype;
            elseif islogical(mlObj)
                class = booltype;
            else
                class = objecttype;
            end
        end
        
        if equals(class,inttype)
            javaObj = java.lang.Integer(mlObj);
        elseif equals(class,doubletype)
            javaObj = java.lang.Double(mlObj);
        elseif equals(class,booltype)
            javaObj = java.lang.Boolean(mlObj);
        elseif equals(class,longtype)
            javaObj = java.lang.Long(mlObj);
        elseif equals(class,bytetype)
            javaObj = java.lang.Byte(mlObj);
        elseif equals(class,chartype)
            javaObj = java.lang.Character(mlObj);
        elseif equals(class,shorttype)
            javaObj = java.lang.Short(mlObj);
        elseif equals(class,floattype)
            javaObj = java.lang.Float(mlObj);
        elseif isempty(mlObj)
            javaObj = [];
        elseif ischar(mlObj)
            javaObj = java.lang.String(mlObj);
        elseif iscellstr(mlObj)
            javaObj = javaArray('java.lang.String',length(mlObj));
            for m = 1:length(mlObj)
                javaObj(m) = java.lang.String(mlObj{m});
            end
        elseif iscell(mlObj) &&...
                (strcmpi(clslist(n).getName,'[[Ljava.lang.Object;') ||...
                strcmpi(clslist(n).getName,'[Ljava.lang.Object;'))
            javaObj = javaArray('java.lang.Object',size(mlObj,1),size(mlObj,2));
            for m = 1:size(mlObj,1)
                for p = 1:size(mlObj,2)
                    javaObj(m,p) = convertToJava(mlObj{m,p});
                end
            end
        elseif iscell(mlObj) && (size(mlObj,1) == 1 || size(mlObj,2) == 1)
            javaObj = javaArray('java.lang.Object',length(mlObj));
            for i = 1:length(mlObj)
                javaObj(i) = convertToJava(mlObj{i});
            end
        elseif iscell(mlObj) 
            javaObj = javaArray('java.lang.Object',size(mlObj,1),size(mlObj,2));
            for m = 1:size(mlObj,1)
                for p = 1:size(mlObj,2)
                    javaObj(m,p) = convertToJava(mlObj{m,p});
                end
            end            
        else
            javaObj = mlObj;
        end
    end
end