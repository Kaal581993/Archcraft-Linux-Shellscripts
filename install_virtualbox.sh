#!/bin/bash

# Function to display error message and exit
error_exit() {
    echo "[ERROR] $1"
    echo "Installation failed. Please check the errors above and try again."
    exit 1
}

# Function to check if the last command was successful
check_success() {
    if [ $? -ne 0 ]; then
        error_exit "$1"
    fi
}

# Update the system and install prerequisites
echo "Updating the system and installing prerequisites..."
sudo pacman -Syu --noconfirm
check_success "System update failed."

echo "Installing VirtualBox and required kernel modules..."
sudo pacman -S --noconfirm virtualbox virtualbox-host-modules-arch
check_success "Failed to install VirtualBox."

# Check if the kernel modules are loaded
echo "Checking if kernel modules are loaded..."
sudo modprobe vboxdrv
check_success "Failed to load VirtualBox kernel modules. You might need to reboot and try again."

# Add current user to vboxusers group
echo "Adding current user to vboxusers group..."
sudo usermod -aG vboxusers $USER
check_success "Failed to add user to vboxusers group."

# Print success message
echo "VirtualBox installation completed successfully!"
echo "Please reboot your system before using VirtualBox."

exit 0
