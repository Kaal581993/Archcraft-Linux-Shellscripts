#!/bin/bash

# Function to check if the previous command succeeded
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error encountered! Exiting script."
        exit 1
    fi
}

# Update package database
echo "Updating package database..."
sudo pacman -Syu --noconfirm
check_success

# Install Python 3
echo "Installing Python 3..."
sudo pacman -S python --noconfirm
check_success

# Install pip (Python package installer)
echo "Installing pip..."
sudo pacman -S python-pip --noconfirm
check_success

# Install Jupyter Notebook
echo "Installing Jupyter Notebook..."
pip install --user jupyter
check_success

# Install Snapd (required for PyCharm installation)
echo "Installing Snapd..."
sudo pacman -S snapd --noconfirm
check_success

# Enable and start Snapd service
echo "Enabling and starting Snapd service..."
sudo systemctl enable --now snapd.socket
check_success

# Create symlink for Snap
echo "Creating symlink for Snap..."
sudo ln -s /var/lib/snapd/snap /snap
check_success

# Install PyCharm
echo "Installing PyCharm..."
sudo snap install pycharm-community --classic
check_success

echo "Installation completed successfully!"
