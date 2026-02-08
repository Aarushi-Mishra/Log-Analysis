#!/usr/bin/env bash
# Detecting brute-force patterns from auth logs

# Check if filename argument is provided
if [ $# -eq 0 ]; then
  echo "Usage: $0 <json_file>"
  exit 1
fi

# log="access.log"
log="$1"

# File type validation, size
echo "File type: $(file "$log")"
echo "File size: $(wc -c < "$log"|awk '{print $1}') bytes"

# Gathering basic stats about the data
# # 1. Number of events
echo "Number of entries/events: $(wc -l < "$log"|awk '{print $1}')"

# # 2. Timestamp Range
start=$(head -n 1 "$log" | awk '{print $4, $5}')
end=$(tail -n 1 "$log" | awk '{print $4, $5}')
echo "Start Timestamp: $start"
echo "End Timestamp: $end"

# # 3. List and count of unique IPs, count greater than 1
echo "List of unique IPs appearing more than once:"
cut -d " " -f 1 "$log"|sort|uniq -c|sort -nr| grep -v " 1 "


# # 4. Number of concerning response codes
status_400=$(awk '$9 > 400 {print $9}' "$log"|sort|uniq -c |sort -nr)
echo "Events with response codes greeater than 400:"
echo "$status_400"

# Analysis Logic
failed_count=0
threshold=3
prev_ip=""
alert_shown=0

while read -r ip date time status
do
    # ---- FIX: detect IP change FIRST ----
    if [ -n "$prev_ip" ] && [ "$ip" != "$prev_ip" ]; then
        if [ "$alert_shown" -eq 0 ] && [ "$failed_count" -ge "$threshold" ]; then
            echo "*--------------------------------------------------------------------*"
            echo "WARNING: Possible brute-force attack attempt from IP $prev_ip"
            echo "Failed Attempts: $failed_count"
            echo "*--------------------------------------------------------------------*"
            echo ""
        fi

        failed_count=0
        alert_shown=0
    fi

    prev_ip="$ip"

    # ---- now process the current event ----
    if [ "$status" = "401" ]; then
        failed_count=$((failed_count + 1))
    fi

    if [ "$status" = "429" ] && [ "$failed_count" -ge "$threshold" ]; then
        echo "*--------------------------------------------------------------------*"
        echo "ALERT: Brute-force attack detected & blocked from IP $ip"
        echo "Failed attempts: $failed_count followed by a $status status"
        echo "*--------------------------------------------------------------------*"
        echo ""
        alert_shown=1
    fi

    if [ "$status" = "200" ] && [ "$failed_count" -ge "$threshold" ]; then
        echo "*--------------------------------------------------------------------*"
        echo "ALERT: Successful Brute-force attack detected from IP $ip"
        echo "Failed attempts: $failed_count followed by a $status status"
        echo "*--------------------------------------------------------------------*"
        echo ""
        alert_shown=1
    fi

done < <(cut -d " " -f 1,4,5,9 "$log" | sort -k1,1 -k2,3)
