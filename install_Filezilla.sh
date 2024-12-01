#!/bin/bash

# Function to display error message and exit
error_exit() {
    echo "[ERROR] $1"
    echo "Installation failed. Please check the errors above."
    exit 1
}

# Function to check if the last command was successful
check_success() {
    if [ $? -ne 0 ]; then
        error_exit "$1"
    fi
}

# Update system packages
echo "Updating system packages..."
sudo pacman -Syu --noconfirm
check_success "Failed to update system packages."

# Install FileZilla
echo "Installing FileZilla..."
sudo pacman -S --noconfirm filezilla
check_success "Failed to install FileZilla."

# Verify the installation
if command -v filezilla &> /dev/null; then
    echo "FileZilla installed successfully!"
else
    error_exit "FileZilla installation failed."
fi

exit 0
