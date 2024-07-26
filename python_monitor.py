#!/bin/python3

import paramiko

# SSH parameters for each node
nodes = {
    'node1': 'ec2-user@3.95.184.194',
    'node2': 'ec2-user@54.237.186.247'
}

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

# Function to create an SSH client
def create_ssh_client(user, host, port=22):
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())  # Accepts host key automatically
    client.load_system_host_keys()  # Tries to load known host keys from the user's local known_hosts file
    client.connect(hostname=host, port=port, username=user)
    return client


def get_usage_fact(ssh_client_par, command):
    stdin, stdout, stderr = ssh_client_par.exec_command(command)
    # Read the standard output
    output = stdout.read().decode().strip()
    # Handle potential error
    if stderr.read().decode().strip():
        print("Error:", stderr.read().decode().strip())
    else:
        return output


# Loop through the nodes and connect to each
for node, addr in nodes.items():
    user, host = addr.split('@')
    try:
        ssh_client = create_ssh_client(user, host)
        print(f"Connected to {node} successfully!")

        # current usages
        cpu_usage = get_usage_fact(ssh_client, command_cpu)

        mem_usage = get_usage_fact(ssh_client, command_mem)

        disk_usage = get_usage_fact(ssh_client, command_disk)

        print(f"CPU usage {cpu_usage}")
        print(f"Memory Usage {mem_usage}")
        print(f"Disk usage {disk_usage}")

        # Close the SSH connection
        ssh_client.close()

    except Exception as e:
        print(f"Failed to connect to {node}: {str(e)}")
