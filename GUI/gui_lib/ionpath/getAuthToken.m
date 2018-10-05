function [auth_token] = getAuthToken(url, email, pswrd)
    uri = [url, '/api-token-auth/'];
    header = matlab.net.http.HeaderField('Content-Type', 'application/json');
    body_struct.email = email;
    body_struct.password = pswrd;
    body = matlab.net.http.MessageBody(body_struct);
    request = matlab.net.http.RequestMessage('POST', header, body);
    [response,completedrequest,history] = send(request,uri);
    auth_token = response.Body.Data.token;
end

