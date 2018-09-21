function [response] = uploadTIFF(auth_token, url, runID, filepath)
    % filepath needs to be a path to a properly-formatted multipage TIFF
    py.importlib.import_module('requests');
    file = py.open(filepath, 'rb');
    
    files = py.dict();
    [~, filepath, ~] = fileparts(filepath);
    files{'tiff'} = py.tuple({[filepath, '.tiff'], file, 'image/tiff'});
    
    headers = py.dict();
    format = py.str('JWT {}');
    headers{'Authorization'} = format.format(auth_token);
    
    data = py.dict();
    data{'run'} = py.int(runID);
    
    try
        response = py.requests.post([url, '/upload_tiff/'], pyargs('data', data, 'files', files, 'headers', headers));
        response.raise_for_status();
    catch e
        response = e;
    end
end