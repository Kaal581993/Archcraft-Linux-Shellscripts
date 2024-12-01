#!/bin/bash

# Failsafe: Exit on error
set -e

# Function to check command availability
check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo "Error: $1 is not installed. Aborting."
        exit 1
    fi
}

# Ensure the system is up-to-date
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install yay (if not already installed)
if ! command -v yay &>/dev/null; then
    echo "Installing yay (AUR Helper)..."
    git clone https://aur.archlinux.org/yay.git
    cd yay || exit
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
else
    echo "yay is already installed."
fi

# Install PHP 5.6 from AUR
echo "Installing PHP 5.6..."
yay -S php56 php56-apache --noconfirm

# Verify PHP installation
echo "Verifying PHP installation..."
if ! php -v | grep -q "PHP 5.6"; then
    echo "Error: PHP 5.6 installation failed."
    exit 1
fi
echo "PHP 5.6 installed successfully."

# Install Composer
echo "Installing Composer..."
check_command curl
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
check_command composer
echo "Composer installed successfully."

# Set up Laravel
echo "Setting up Laravel..."
composer global require "laravel/installer=~1.4"
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Verify Laravel installation
if ! command -v laravel &>/dev/null; then
    echo "Error: Laravel installation failed."
    exit 1
fi
echo "Laravel installed successfully."

# Post-installation reminders
echo "Setup complete. To start a new Laravel project, run:"
echo "laravel new project-name"
