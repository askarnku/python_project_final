#!/usr/bin/env python3

import paramiko
import os
import requests
import json
from datetime import datetime

# child server data
nodes = {
    'node1': 'ec2-user@3.95.184.194',
    'node2': 'ec2-user@54.237.186.247'
}

# Fetch the webhook URL from the environment variables
slack_wh = os.getenv('SLACK_WEBHOOK_URL')

# Thresholds
# cpu use threshold
cpu_threshold = 80

# mem use threshold
mem_threshold = 50

# disk use threshold
disk_threshold = 90

# Command to get CPU usage
command_cpu = "mpstat 1 1 | awk '/Average:/ {print 100 - $12}'"

# Command to get MEM usage
command_mem = "free -m | awk '/Mem:/ {print $3/$2 * 100.0}'"

# Command to get DISK usage
command_disk = "df -h / | awk '/\// {print $5}'"


def create_ssh_client(user, host, port=22):
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())  # Accepts host key automatically
    client.load_system_host_keys()  # Tries to load known host keys from the user's local known_hosts file
    client.connect(hostname=host, port=port, username=user)
    return client


def get_usage_fact(ssh_client_ob, command):
    stdin, stdout, stderr = ssh_client_ob.exec_command(command)
    # Read the standard output
    output = stdout.read().decode().strip()
    # Handle potential error
    if stderr.read().decode().strip():
        print("Error:", stderr.read().decode().strip())
    else:
        return output


def send_warning(node_server, cpu, mem, disk):
    current_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    message = (
        f"------Stats as of {current_date}------\n"
        f"One or more of the resources on {node_server} are over utilized\n"
        f"CPU usage: {cpu}%\n"
        f"Memory Usage: {mem}%\n"
        f"Disk usage: {disk}%"
    )

    payload = {
        "text": message
    }

    response = requests.post(slack_wh, data=json.dumps(payload))
    print(f"Status code: {response.status_code}")


def check_thresholds(node, cpu_usage, mem_usage, disk_usage):
    if cpu_usage >= cpu_threshold or mem_usage >= mem_threshold or disk_usage >= disk_threshold:
        send_warning(node, cpu_usage, mem_usage, disk_usage)


for node, addr in nodes.items():
    user, host = addr.split('@')
    current_date = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    try:
        ssh_client = create_ssh_client(user, host)
        with ssh_client:
            print(f"{current_date} Connected to {node} successfully!")
            cpu_usage = int(float(get_usage_fact(ssh_client, command_cpu)))
            mem_usage = int(float(get_usage_fact(ssh_client, command_mem)))
            disk_usage = int(float(get_usage_fact(ssh_client, command_disk).strip('%')))
            
            check_thresholds(node, cpu_usage, mem_usage, disk_usage)

    except Exception as e:
        print(f"Failed to connect to {node}: {str(e)}")
