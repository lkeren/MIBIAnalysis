function [response] = httpGET(auth_token, uri)
    authinfo = matlab.net.http.AuthInfo('JWT', auth_token);
    header = matlab.net.http.field.AuthorizationField('Authorization', authinfo);
    request = matlab.net.http.RequestMessage('GET', header);
    [response,completedrequest,history] = send(request,uri);
end

