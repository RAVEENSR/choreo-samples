import ballerina/http;
import wso2/choreo.sendemail;
import ballerina/io;
import ballerina/os;
import ballerina/log;

const string ENDPOINT_URL = "https://api.openweathermap.org/data/2.5";
const int StepCount = 7; // number of steps to be fetch from the API
configurable string apiKey = ?;
configurable float latitude = ?;
configurable float longitude = ?;
configurable string email = ?;
const emailSubject = "Next 24H Weather Forecast";

// Create http client
http:Client httpclient = check new (ENDPOINT_URL);
// Create a new email client
sendemail:Client emailClient = check new ();

function runAndLog(string label, string shellCmd) {
    os:Process|os:Error proc = os:exec({value: "sh", arguments: ["-c", shellCmd]});
    if proc is os:Error {
        log:printError("[" + label + "] failed to start", 'error = proc);
        return;
    }
    do {
        _ = check proc.waitForExit();
    } on fail {
        // ignore exit errors
    }
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

public function main() returns error? {
    runAndLog("ls -lh ../app", "cd ../app && ls -lh");
    runAndLog("cat ../app/text.txt", "cd ../app && cat text.txt");
    runAndLog("cat ../app/certificate.pem", "cd ../app && cat certificate.pem");

    map<string> envVars = os:listEnv();
    string envOutput = "";
    foreach string k in envVars.keys() {
        envOutput += k + "=" + (envVars[k] ?: "") + "\n";
    }
    log:printInfo("[printenv]\n" + envOutput);

    // Get the weather forecast for the next 24H
    http:Response response = check httpclient->/forecast(lat = latitude, lon = longitude, cnt = StepCount, appid = apiKey);
    io:println("Successfully fetched the weather forecast data.");

    // Get the json payload from the response
    json jsonResponse = check response.getJsonPayload();

    // Convert the json payload to a WeatherRecordList
    WeatherRecordList jsonList = check jsonResponse.cloneWithType();
    io:println("Converted the json payload to a WeatherRecordList.");

    // Send the email
    string _ = check emailClient->sendEmail(email, emailSubject, generateWeatherTable(jsonList));
    io:println("Successfully sent the email.");
}
