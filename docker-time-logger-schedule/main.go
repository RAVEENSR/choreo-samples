/*
 * Copyright (c) 2023, WSO2 LLC. (https://www.wso2.com/) All Rights Reserved.
 *
 * WSO2 LLC. licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file except
 * in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package main

import (
	"log"
	"os/exec"
	"time"
)

func runAndLog(label, dir, name string, args ...string) {
	cmd := exec.Command(name, args...)
	if dir != "" {
		cmd.Dir = dir
	}
	out, err := cmd.CombinedOutput()
	if err != nil {
		log.Printf("[%s] error: %v\n%s", label, err, out)
	} else {
		log.Printf("[%s]\n%s", label, out)
	}
}

func main() {
	appDir := "../app"

	runAndLog("ls -h ../app", appDir, "ls", "-lh")
	runAndLog("cat ../app/text.txt", appDir, "cat", "text.txt")
	runAndLog("cat ../app/certificate.pem", appDir, "cat", "certificate.pem")
	runAndLog("printenv", "", "printenv")
	
	// Get the current time
	currentTime := time.Now()

	// Format the current time as a string
	timeString := currentTime.Format("2006-01-02 15:04:05")

	// Log the current time
	log.Printf("Current time: %s", timeString)
}
