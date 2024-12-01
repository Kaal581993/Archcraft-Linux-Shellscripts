#!/bin/bash

# Function to check if the previous command succeeded
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error encountered! Exiting script."
        exit 1
    fi
}

# Remove any existing Neo4j repository configurations
echo "Removing existing Neo4j repository configurations..."
sudo sed -i '/neo4j/d' /etc/pacman.conf
sudo rm -f /etc/pacman.d/neo4j.conf
check_success

# Clean up Pacman cache and sync databases
echo "Cleaning up Pacman cache and synchronizing databases..."
sudo pacman -Scc --noconfirm
sudo pacman -Syyu --noconfirm
check_success

# Install necessary dependencies
echo "Installing dependencies..."
sudo pacman -S wget unzip jdk-openjdk snapd --noconfirm
check_success

# Install Neo4j using tarball
echo "Downloading Neo4j..."
wget https://neo4j.com/artifact.php?name=neo4j-community-5.5.0-unix.tar.gz -O ~/neo4j-community.tar.gz
check_success

# Extract and set up Neo4j
echo "Setting up Neo4j..."
sudo mkdir -p /opt/neo4j
sudo tar -xzf ~/neo4j-community.tar.gz -C /opt/neo4j --strip-components=1
check_success

# Set up systemd service for Neo4j
echo "Setting up Neo4j as a systemd service..."
sudo bash -c 'cat <<EOF > /etc/systemd/system/neo4j.service
[Unit]
Description=Neo4j Graph Database
After=network.target

[Service]
Type=forking
ExecStart=/opt/neo4j/bin/neo4j start
ExecStop=/opt/neo4j/bin/neo4j stop
User=neo4j
Group=neo4j
Restart=on-failure
LimitNOFILE=60000

[Install]
WantedBy=multi-user.target
EOF'
check_success

# Create Neo4j user and set permissions
echo "Creating Neo4j user and setting permissions..."
sudo useradd -r -m -U -d /opt/neo4j -s /bin/bash neo4j
sudo chown -R neo4j:neo4j /opt/neo4j
check_success

# Enable and start Neo4j service
echo "Enabling and starting Neo4j service..."
sudo systemctl enable neo4j
check_success
sudo systemctl start neo4j
check_success

# Install Neo4j Desktop
echo "Downloading and setting up Neo4j Desktop..."
wget https://neo4j.com/artifact.php?name=neo4j-desktop-2.6.2.AppImage -O ~/neo4j-desktop.AppImage
chmod +x ~/neo4j-desktop.AppImage
sudo mv ~/neo4j-desktop.AppImage /usr/local/bin/neo4j-desktop
check_success

# Set up Snap and install Neo4j Browser
echo "Setting up Snap and installing Neo4j Browser..."
sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap
sudo snap install neo4j-browser
check_success

# Creating desktop shortcut for Neo4j Desktop
echo "Creating desktop shortcut for Neo4j Desktop..."
echo -e "[Desktop Entry]\nName=Neo4j Desktop\nExec=/usr/local/bin/neo4j-desktop\nIcon=neo4j\nType=Application\nCategories=Development;Database;" | sudo tee /usr/share/applications/neo4j-desktop.desktop
check_success

echo "Neo4j, Neo4j Desktop, and Neo4j Browser installation completed successfully!"
