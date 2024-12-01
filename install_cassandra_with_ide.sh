#!/bin/bash

# Function to check if the previous command succeeded
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error encountered! Exiting script."
        exit 1
    fi
}

# Update package database and upgrade the system
echo "Updating package database and upgrading the system..."
sudo pacman -Syu --noconfirm
check_success

# Install Java (required for Cassandra)
echo "Installing Java (JDK)..."
sudo pacman -S jdk-openjdk --noconfirm
check_success

# Set Cassandra version
CASSANDRA_VERSION="4.1.2"  # Replace this with the latest version available
CASSANDRA_URL="https://downloads.apache.org/cassandra/${CASSANDRA_VERSION}/apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz"

# Install Apache Cassandra
echo "Installing Apache Cassandra..."
wget "${CASSANDRA_URL}" -O ~/cassandra.tar.gz
check_success

# Extract the tarball to /opt/cassandra
sudo mkdir -p /opt/cassandra
sudo tar -xzf ~/cassandra.tar.gz -C /opt/cassandra --strip-components=1
check_success

# Create a Cassandra systemd service
echo "Setting up Cassandra as a systemd service..."
sudo bash -c 'cat <<EOF > /etc/systemd/system/cassandra.service
[Unit]
Description=Apache Cassandra
After=network.target

[Service]
Type=forking
ExecStart=/opt/cassandra/bin/cassandra -R
ExecStop=/opt/cassandra/bin/nodetool stopdaemon
User=cassandra
Group=cassandra
Restart=on-failure
LimitNOFILE=100000

[Install]
WantedBy=multi-user.target
EOF'
check_success

# Create Cassandra user and set permissions
echo "Creating Cassandra user and setting permissions..."
sudo useradd -r -m -U -d /opt/cassandra -s /bin/bash cassandra
sudo chown -R cassandra:cassandra /opt/cassandra
check_success

# Enable and start Cassandra service
echo "Enabling and starting Cassandra service..."
sudo systemctl enable cassandra
check_success
sudo systemctl start cassandra
check_success

# Install IntelliJ IDEA (Community Edition) as the IDE
echo "Installing IntelliJ IDEA (Community Edition)..."
sudo pacman -S intellij-idea-community-edition --noconfirm
check_success

# Post-installation message
echo "Apache Cassandra and IntelliJ IDEA installation completed successfully!"
echo "You can manage Cassandra with the 'systemctl' command and use IntelliJ IDEA for development."
