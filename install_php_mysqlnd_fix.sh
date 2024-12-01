#!/bin/bash

# Automated conflict resolution and installation of php-mysqlnd in Archcraft Linux

# Function to display messages
log() {
    echo -e "\e[1;32m[INFO]\e[0m $1"
}

error() {
    echo -e "\e[1;31m[ERROR]\e[0m $1"
    exit 1
}

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root. Use sudo."
fi

# Force remove conflicting package
log "Checking for conflicting packages..."
if pacman -Qi gnu-netcat > /dev/null 2>&1; then
    log "Removing gnu-netcat to resolve conflict..."
    if ! sudo pacman -Rdd gnu-netcat --noconfirm; then
        error "Failed to remove gnu-netcat. Please check manually."
    fi
    log "gnu-netcat removed successfully."
fi

# Update package database
log "Updating package database and resolving replacements..."
if ! sudo pacman -Syu --noconfirm --needed; then
    error "Failed to update the package database."
fi

# Install required packages
log "Installing php and php-mysqlnd..."
if ! sudo pacman -S php php-mysqlnd openbsd-netcat --noconfirm --needed; then
    error "Failed to install required packages."
fi

# Enable mysqlnd in PHP configuration if necessary
log "Ensuring mysqlnd is enabled in PHP configuration..."
php_config_file="/etc/php/php.ini"
if ! grep -q "extension=mysqli" "$php_config_file"; then
    log "Adding 'extension=mysqli' to PHP configuration..."
    echo "extension=mysqli" | sudo tee -a "$php_config_file" > /dev/null
else
    log "'extension=mysqli' is already in the PHP configuration."
fi

# Restarting PHP-FPM service
log "Restarting PHP-FPM service..."
if systemctl is-active --quiet php-fpm.service; then
    if ! sudo systemctl restart php-fpm.service; then
        error "Failed to restart PHP-FPM service."
    fi
else
    log "PHP-FPM service is not active. Starting it..."
    if ! sudo systemctl start php-fpm.service; then
        error "Failed to start PHP-FPM service."
    fi
fi

# Verify installation
log "Verifying php-mysqlnd installation..."
if php -m | grep -q "mysqli"; then
    log "php-mysqlnd has been installed and enabled successfully!"
else
    error "php-mysqlnd installation or activation failed."
fi

exit 0

