#!/bin/python3

import paramiko

# Define the SSH parameters for each node
nodes = {
    'node1': 'ec2-user@3.95.184.194',
    'node2': 'ec2-user@54.237.186.247'
}


# Function to create an SSH client
def create_ssh_client(user, host, port=22):
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())  # Accepts host key automatically
    client.load_system_host_keys()  # Tries to load known host keys from the user's local known_hosts file
    client.connect(hostname=host, port=port, username=user)
    return client


# Loop through the nodes and connect to each
for node, addr in nodes.items():
    user, host = addr.split('@')
    try:

        # Command to get MEM usage
        # command_mem = "free -m | awk '/Mem:/ {print $3/$2 * 100.0}'"

        # Command to get DISK usage
        command_disk = "df -h / | awk '/\// {print \$5}'"

        ssh_client = create_ssh_client(user, host)
        print(f"Connected to {node} successfully!")

        # Example: Execute a command (like 'hostname')
        stdin, stdout, stderr = ssh_client.exec_command(command_disk)
        print(f"stout: {stdout.read().decode().strip()}")
        print(f"stderr of {node}: {stderr.read().decode().strip()}")

        # Close the SSH connection
        ssh_client.close()

    except Exception as e:
        print(f"Failed to connect to {node}: {str(e)}")
