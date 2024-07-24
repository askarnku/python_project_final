#!/bin/bash


echo $(date)
#cpu use threshold
cpu_threshold="80"
 #mem idle threshold
mem_threshold="80"
 #disk use threshold
disk_threshold="90"

slack_wh='https://hooks.slack.com/services/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'
echo -e "\n#################### Checking Memory, Disk space, and CPU on $HOSTNAME ####################"
#---mem
mem=$(sudo free -m | awk 'NR==2{printf "%.2f%%\t\t", 100-($7*100/$2) }' | cut -f 1 -d ".")

#---disk
disk=$(df -h | awk '$NF == "/" { print $5 }' | cut -d '%' -f 1 )

#---cpu
cpuuse=$(top -bn1 | grep load | awk '{printf "%.2f\t\t\n", $(NF-2)*100}'| cut -f 1 -d ".")

curl -X POST -H 'Content-type: application/json' --data '{"text":"Hello, World!"}' $slack_wh


