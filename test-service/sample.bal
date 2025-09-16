import ballerina/http;
import ballerina/oauth2;

public type PasswordGrantConfig record {|
    string tokenUrl;
    string username;
    string password;
    string clientId?;
    string clientSecret?;
    string|string[] scopes?;
    decimal defaultTokenExpTime = 3600;
    decimal clockSkew = 0;
    map<string> optionalParams?;
    oauth2:CredentialBearer credentialBearer = oauth2:AUTH_HEADER_BEARER;
    oauth2:ClientConfiguration clientConfig = {};
|};

configurable PasswordGrantConfig passwordConfig = ?;
final http:OAuth2PasswordGrantConfig config = {
    tokenUrl: passwordConfig.password,
    username: passwordConfig.username,
    password: passwordConfig.password,
    clientId: passwordConfig.clientId,
    clientSecret: passwordConfig.clientSecret,
    scopes: passwordConfig.scopes,
    refreshConfig: oauth2:INFER_REFRESH_CONFIG,
    defaultTokenExpTime: passwordConfig.defaultTokenExpTime,
    clockSkew: passwordConfig.clockSkew,
    optionalParams: passwordConfig.optionalParams,
    credentialBearer: passwordConfig.credentialBearer,
    clientConfig: passwordConfig.clientConfig
};

configurable string atsClientUrl = ?;
final http:Client atsClient = check new (atsClientUrl, {
    auth: {...config},
    httpVersion: http:HTTP_1_1,
    http1Settings: {keepAlive: http:KEEPALIVE_NEVER},
    timeout: 180.0,
    retryConfig: {
        count: 3,
        interval: 5.0,
        statusCodes: [
            http:STATUS_REQUEST_TIMEOUT,
            http:STATUS_BAD_GATEWAY,
            http:STATUS_SERVICE_UNAVAILABLE,
            http:STATUS_GATEWAY_TIMEOUT
        ]
    }
});
