# Log Analysis Walkthrough: Investigating Suspicious Web Activity

In one of my log analysis exercises, I analyzed a web server access log to determine whether any suspicious activity had occurred. The log file used is a .log file and is of the combined log format (extention of the common log format - CLF).

I can’t share the exact log data because it was part of a paid training course, but I can walk through my analysis approach and findings.

## Key Findings

### 1. Scoping the log data

I started by baselining the data — checking the total number of events and the time range covered by the log so I understood the scope of activity.

![alt text](image-1.png)

- What is the format of the file? What tooling should I use? **ASCII text** 

- How many total events were logged in the file? **343**

- What is the full timestamp of the **first** event in the file? **18/Jul/2024:15:56:47 -0400**

- What is the full timestamp of the **last** event in the file? **18/Jul/2024:15:59:25 -0400)**

### 2. Source IP Behavior

Next, I analyzed source IP behavior by counting requests per IP. One IP stood out with significantly more connections than others, which suggested automated or scripted activity rather than normal user behavior.

![alt text](image-4.png)

- What are the top 3 IP addresses found within the log file? **23 counts of 182.87.64.64, 7 counts of 53.64.228.139, 5 counts of 85.165.170.49**

### 3. Reviewing Different User-agent s

I then reviewed user agent patterns. There were only a few unique user agents in the log, and the high-volume IP consistently used the same one. 

![alt text](image-5.png)

- How many different user agent strings are found in the log file? **3**

- Which user agent string sticks out as suspicious? **(Widows NT 10.0; Win64; x64)**

### 4. Checking for Attack Patterns

From there, I checked for common web attack indicators. When I checked the logs for XSS, path traversal, and LFI, I found no matches.

But when I examined URL query parameters, I identified multiple requests containing SQL injection payloads using keywords like UNION and SELECT, targeting the same parameter.

To assess potential impact, I compared response sizes across these attempts. Most responses were consistent , but one request produced a noticeably different response size, which suggested the application behaved differently for that payload.

By correlating that anomaly with its timestamp, I identified the moment a potentially successful SQL injection attempt occurred.

![alt text](image-6.png)

- What web-based attack can you identify ? **SQL Injection**

- What is the **name** of the vulnerable **URL parameter**? The vulnerable param is **q**

- Based on other indicators in the event logs, what was the **full timestamp** of the potentially successful attempt? **18/Jul/2024:15:58:52 -0400**


## Conclusion

Overall, this exercise reinforced how SOC investigations rely on correlating multiple indicators — request volume, payload content, and response behavior — rather than relying on a single signal.
