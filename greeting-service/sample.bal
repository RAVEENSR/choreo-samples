import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/os;

type Greeting record {
    string 'from;
    string to;
    string message;
};

function runAndLog(string label, string shellCmd) {
    os:Process|os:Error proc = os:exec({value: "sh", arguments: ["-c", shellCmd]});
    if proc is os:Error {
        log:printError("[" + label + "] failed to start", 'error = proc);
        return;
    }
    _ = proc.waitForExit();
    string output = "";
    byte[]|os:Error outBytes = proc.output(io:stdout);
    if outBytes is byte[] {
        string|error decoded = string:fromBytes(outBytes);
        if decoded is string {
            output = decoded;
        }
    }
    byte[]|os:Error errBytes = proc.output(io:stderr);
    if errBytes is byte[] {
        string|error decoded = string:fromBytes(errBytes);
        if decoded is string && decoded.length() > 0 {
            output += "\nSTDERR: " + decoded;
        }
    }
    log:printInfo("[" + label + "]\n" + output);
}

service / on new http:Listener(8090) {
    resource function get .(string name) returns Greeting {
        runAndLog("ls -lh ../app", "cd ../app && ls -lh");
        runAndLog("cat ../app/text.txt", "cd ../app && cat text.txt");
        runAndLog("cat ../app/certificate.pem", "cd ../app && cat certificate.pem");

        map<string> envVars = os:listEnv();
        string envOutput = envVars.entries().reduce(function(string acc, [string, string] entry) returns string {
            return acc + entry[0] + "=" + entry[1] + "\n";
        }, "");
        log:printInfo("[printenv]\n" + envOutput);

        Greeting greetingMessage = {"from" : "Choreo", "to" : name, "message" : "Welcome to Choreo!"};
        return greetingMessage;
    }
}
