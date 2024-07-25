#!/bin/bash

source ~/.bashrc

# Define thresholds
cpu_threshold="$1"
mem_threshold="$2"
disk_threshold="$3"

# Slack Webhook
slack_wh="$SLACK_WEBHOOK_URL"

# Node definitions
declare -A nodes=(
    [node1]='ec2-user@3.95.184.194'
    [node2]='ec2-user@54.237.186.247'
)

send_slack_alert() {
    local message=$1
    local date_time=$(date)
    local json_payload=$(jq -n --arg date "$date_time" --arg message "$message" \
        '{text: ($date + "\n" + $message + "\n")}')

    curl -X POST -H 'Content-type: application/json' --data "$json_payload" $slack_wh
}

check_error() {
    if [ $1 -ne 0 ]; then
        send_slack_alert "ERROR!!! Unable to connect or execute on $2. Check SSH connection or remote commands."
        return 1
    fi
    return 0
}

for key in "${!nodes[@]}"; do
    child_server="${nodes[$key]}"
    
    # Fetch CPU usage via SSH
    cpu_usage=$(ssh $child_server "mpstat 1 1 | awk '/Average:/ {print 100 - \$12}'")
    check_error $? $key || continue

    # Fetch memory usage via SSH
    memory_usage=$(ssh $child_server "free -m | awk '/Mem:/ {print \$3/\$2 * 100.0}'")
    check_error $? $key || continue

    # Fetch disk usage via SSH
    disk_usage=$(ssh $child_server "df -h / | awk '/\// {print \$5}'")
    check_error $? $key || continue

    # Alert if CPU usage is high
    if [[ "$cpu_usage" -gt "$cpu_threshold" ]]; then
        send_slack_alert "WARNING!!! High CPU usage: $cpu_usage% on $key!"
    fi

    # Alert if memory usage is high
    if [[ "$memory_usage" -ge "$mem_threshold" ]]; then
        send_slack_alert "WARNING!!! High memory usage: $memory_usage% on $key!"
    fi

    # Alert if disk usage is high
    if [[ "${disk_usage%\%}" -gt "$disk_threshold" ]]; then
        send_slack_alert "WARNING!!! Low on disk storage: $disk_usage% used on $key!"
    fi

    # Log resource usage
    echo "CPU Usage: $cpu_usage%"
    echo "Memory Usage: $memory_usage%"
    echo "Disk Usage: $disk_usage"
done

create_json_payload() {
    local cpu=$1
    local mem=$2
    local disk=$3

    # Construct JSON payload with jq
    local json_payload=$(jq -n \
        --arg cpu_usage "$cpu" \
        --arg mem_usage "$mem" \
        --arg disk_usage "$disk" \
        '{
            CPU_Usage: $cpu_usage,
            Memory_Usage: $mem_usage,
            Disk_Usage: $disk_usage
        }')
    echo "$json_payload"
}


