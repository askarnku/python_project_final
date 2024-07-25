#!/bin/bash

source ~/.bashrc

echo $(date)

#cpu use threshold
cpu_threshold="80"

#mem idle threshold
mem_threshold="80"

#disk use threshold
disk_threshold="90"

#batch13 web hook
slack_wh="$SLACK_WEBHOOK_URL_DEV"

echo "$slack_wh"




declare -A nodes

nodes[node1]='ec2-user@3.95.184.194'
nodes[node2]='ec2-user@54.237.186.247'

# Print all elements of the associative array
for key in "${!nodes[@]}"; do
    echo "Key: $key, Value: ${nodes[$key]}"
    child_server="${nodes[$key]}"

    # Get CPU usage by using the top command and parse it
    cpu_usage=$(ssh $child_server "mpstat 1 1 | awk '/Average:/ {print 100 - \$12}'")

    # Get memory usage
    memory_usage=$(ssh $child_server "free -m | awk '/Mem:/ {print \$3/\$2 * 100.0}'")

    # Get disk usage
    disk_usage=$(ssh $child_server "df -h / | awk '/\// {print \$5}'")
    
    #stat print
    payload="Stats: cpu usage: $cpu_usage% memory usage: $memory_usage% disk usage: $disk_usage"

    if [[ "$cpu_usage" -gt "$cpu_threshold" ]]; then

        current_node="$key"
        date_time=$(date)
        warning="WARNING!!! High CPU usage at: $cpu_usage!"

        json_payload=$(jq -n --arg date "$date_time" --arg warning "$warning" --arg node "$current_node" \
            '{text: ($date + "\n" + $warning + "\n" + $node)}')

        curl -X POST -H 'Content-type: application/json' --data "$json_payload" $slack_wh
    fi


    #Warning of CPU MEM DISK usage if it is above threshold
    

    

    curl -X POST -H 'Content-type: application/json' --data "{"text":\"$key $payload\"}" $slack_wh

    # curl -X POST -H 'Content-type: application/json' --data "{"text":\"$payload\"}" $slack_wh


    echo "CPU Usage: $cpu_usage%"
    echo "Memory Usage: $memory_usage%"
    echo "Disk Usage: $disk_usage"

done


