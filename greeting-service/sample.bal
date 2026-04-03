import ballerina/http;

type Greeting record {
    string 'from;
    string to;
    string message;
};

service / on new http:Listener(8090) {
    resource function get .(string name) returns Greeting {
        Greeting greetingMessage = {"from" : "WSO2 Developer Platform", "to" : name, "message" : "Welcome to WSO2 Developer Platform!"};
        return greetingMessage;
    }

    resource function post .(string name) returns Greeting {
        Greeting greetingMessage = {"from" : "WSO2 Developer Platform", "to" : name, "message" : "Welcome to WSO2 Developer Platform!"};
        return greetingMessage;
    }

    resource function delete .(string name) returns Greeting {
        Greeting greetingMessage = {"from" : "WSO2 Developer Platform", "to" : name, "message" : "Welcome to WSO2 Developer Platform!"};
        return greetingMessage;
    }
}
