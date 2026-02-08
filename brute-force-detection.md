# Brute Force Detection Script (Web Log Analysis)

This script analyzes web server access logs to identify potential brute-force login attempts based on repeated authentication failures.

The goal of this script is to demonstrate how raw logs can be processed using basic command-line tools and shell scripting to detect suspicious behavior—similar to how early-stage detections are prototyped before being implemented in a SIEM.

The script focuses on:
Failed login attempts
Repeated behavior from the same source IP
Consistent response patterns that indicate automation

## Example Analysis

To validate the script, I ran it against a sample web access log containing a mix of:
- Normal user traffic
- Failed login attempts
- Automated authentication behavior

During execution, the script identified one or more source 
IP addresses that:
- Attempted to authenticate repeatedly
- Returned consistent failure responses
- Exceeded the configured failure threshold

The script output clearly highlighted:
- The source IP address
- The number of failed attempts

Below, I’ve included screenshots of the script execution and output.

![alt text](/images/ss-7.png)


## Instructions to use the script

The script is available download in the scripts directory. You can use sample logs in the log-file directory.

### Prerequisites
- Linux or macOS terminal
- Bash shell
- A web server access log in combined log format
- Basic familiarity with command-line tools (grep, awk, sort, uniq)

### Runnning the Script

#### Make the Script Executable

- chmod +x brute_force_detection.sh

#### Run the Script

- ./brute_force_detection.sh

- ./brute_force_detection.sh your_log_file.log




