#!/bin/bash

# Failsafe script to install php-mysqlnd in Archcraft Linux

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

# Update package database
log "Updating package database..."
if ! sudo pacman -Syu --noconfirm; then
    error "Failed to update the package database."
fi

# Install PHP and mysqlnd if not already installed
log "Checking for PHP installation..."
if ! pacman -Qi php > /dev/null 2>&1; then
    log "PHP is not installed. Installing PHP..."
    if ! sudo pacman -S php --noconfirm; then
        error "Failed to install PHP."
    fi
else
    log "PHP is already installed."
fi

log "Checking for php-mysqlnd extension..."
if php -m | grep -q "mysqli"; then
    log "php-mysqlnd is already installed and enabled."
else
    log "Installing php-mysqlnd extension..."
    if ! sudo pacman -S php-mysqlnd --noconfirm; then
        error "Failed to install php-mysqlnd."
    fi
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

# Restarting PHP service if required
log "Restarting PHP-FPM (FastCGI Process Manager) service..."
if systemctl is-active --quiet php-fpm.service; then
    if ! sudo systemctl restart php-fpm.service; then
        error "Failed to restart PHP-FPM service."
    fi
    log "PHP-FPM service restarted successfully."
else
    log "PHP-FPM service is not active. Starting it..."
    if ! sudo systemctl start php-fpm.service; then
        error "Failed to start PHP-FPM service."
    fi
    log "PHP-FPM service started successfully."
fi

# Verify installation
log "Verifying php-mysqlnd installation..."
if php -m | grep -q "mysqli"; then
    log "php-mysqlnd has been installed and enabled successfully!"
else
    error "php-mysqlnd installation or activation failed."
fi

exit 0
