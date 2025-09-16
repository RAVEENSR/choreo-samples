import ballerina/http;

configurable http:OAuth2PasswordGrantConfig config = ?;

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

service / on new http:Listener(8090) {
    resource function get .(string name) returns string {
        return "Hello";
    }
}
