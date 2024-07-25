#!/bin/bash

echo $(date)

#cpu use threshold
cpu_threshold="80"

#mem idle threshold
mem_threshold="80"

#disk use threshold
disk_threshold="90"

#batch13 web hook
slack_wh='https://hooks.slack.com/services/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'




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

    #Warning of CPU MEM DISK usage if it is above threshold
    payload="Stats: cpu usage: $cpu_usage memory usage: $memory_usage disk usage: $disk_usage"

    curl -X POST -H 'Content-type: application/json' --data '{"text":"Testing"}' $slack_wh

    # curl -X POST -H 'Content-type: application/json' --data "{"text":\"$payload\"}" $slack_wh


    echo "CPU Usage: $cpu_usage%"
    echo "Memory Usage: $memory_usage%"
    echo "Disk Usage: $disk_usage"

done

