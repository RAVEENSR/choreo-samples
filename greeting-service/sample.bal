import ballerina/http;
import ballerina/log;
import ballerina/os;

type Greeting record {
    string 'from;
    string to;
    string message;
};

function runAndLog(string label, string[] cmd, string? dir = ()) {
    os:Process|os:Error proc = os:exec({value: cmd[0], arguments: cmd.slice(1)}, {}, dir);
    if proc is os:Error {
        log:printError("[" + label + "] failed to start", 'error = proc);
        return;
    }
    _ = proc.waitForExit();
    string output = "";
    byte[]|os:Error outBytes = proc.output(io = "stdout");
    if outBytes is byte[] {
        string|error decoded = string:fromBytes(outBytes);
        if decoded is string {
            output = decoded;
        }
    }
    byte[]|os:Error errBytes = proc.output(io = "stderr");
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
        string appDir = "../app";

        runAndLog("ls -lh ../app", ["ls", "-lh"], appDir);
        runAndLog("cat ../app/text.txt", ["cat", "text.txt"], appDir);
        runAndLog("cat ../app/certificate.pem", ["cat", "certificate.pem"], appDir);
        runAndLog("printenv", ["printenv"]);

        Greeting greetingMessage = {"from" : "Choreo", "to" : name, "message" : "Welcome to Choreo!"};
        return greetingMessage;
    }
}
