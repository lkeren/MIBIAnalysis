function [methodname,clslist] = parseJavaSignature(sig)

% Copyright 2005 The MathWorks, Inc.

ind = find(sig == '(');
if isempty(ind)
    % ( doesn't exist, set ind to 0. This may be a pure signature.
    ind = 0;
end

methodname = sig(1:ind-1);
% Parse JNI-style signature and convert args to Java values
k=ind+1;
clslist1 = {};
while k <= length(sig)
    switch sig(k)
        case 'I'
            clslist1(end+1) = java.lang.Integer.TYPE;
            k = k+1;
        case 'J'
            clslist1(end+1) = java.lang.Long.TYPE;
            k = k+1;
        case 'Z'
            clslist1(end+1) = java.lang.Boolean.TYPE;
            k = k+1;
        case 'B'
            clslist1(end+1) = java.lang.Byte.TYPE;
            k = k+1;
        case 'C'
            clslist1(end+1) = java.lang.Character.TYPE;
            k = k+1;
        case 'S'
            clslist1(end+1) = java.lang.Short.TYPE;
            k = k+1;
        case 'F'
            clslist1(end+1) = java.lang.Float.TYPE;
            k = k+1;
        case 'D'
            clslist1(end+1) = java.lang.Double.TYPE;
            k = k+1;
        case 'L'
            n = k;
            while (n <= length(sig)) && (sig(n) ~= ';')
                n = n + 1;
            end
            if n > length(sig)
                error(message('MATLAB:awtinvoke:IllegalSignature', sig));
            end
            clsstr = sig((k+1):n-1);
            clsstr(clsstr == '/') = '.';
            clslist1(end+1) = com.mathworks.jmi.ClassLoaderManager.findClass(clsstr);
            k = n+1;
        case '['
            n = k;
            while (n <= length(sig)) && (sig(n) == '[')
                n = n + 1;
            end
            if n > length(sig)
                error(message('MATLAB:awtinvoke:IllegalSignature', sig));
            end
            if sig(n) == 'L'
                while (n <= length(sig)) && (sig(n) ~= ';')
                    n = n + 1;
                end
                if n > length(sig)
                    error(message('MATLAB:awtinvoke:IllegalSignature', sig));
                end
            end
            clsstr = sig(k:n);
            clsstr(clsstr == '/') = '.';
            clslist1(end+1) = com.mathworks.jmi.ClassLoaderManager.findClass(clsstr);
            k = n+1;
        case ')'
            break;
        otherwise
            error(message('MATLAB:awtinvoke:IllegalCharacterInSignature', sig( k )));
    end
end

if isempty(clslist1)
    clslist = [];
else
    clslist = javaArray('java.lang.Class',length(clslist1));
    for k=1:length(clslist1)
        clslist(k) = clslist1{k};
    end
end

