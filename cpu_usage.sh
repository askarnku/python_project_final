#!/bin/bash


declare -A nodes

nodes[node1]='ec2-user@3.95.184.194'
nodes[node2]='ec2-user@54.237.186.247'

# Print all elements of the associative array
for key in "${!nodes[@]}"; do
    echo "Key: $key, Value: ${nodes[$key]}"
done

exit 1





# Define the child server's SSH details
child_server="ec2-user@3.95.184.194"

# Get CPU usage by using the top command and parse it
cpu_usage=$(ssh $child_server "mpstat 1 1 | awk '/Average:/ {print 100 - \$12}'")

# Get memory usage
memory_usage=$(ssh $child_server "free -m | awk '/Mem:/ {print \$3/\$2 * 100.0}'")

# Get disk usage
disk_usage=$(ssh $child_server "df -h / | awk '/\// {print \$5}'")

# Print the results
echo "CPU Usage: $cpu_usage%"
echo "Memory Usage: $memory_usage%"
echo "Disk Usage: $disk_usage"

