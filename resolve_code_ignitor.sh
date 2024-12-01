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

# Install php-intl extension
echo "Installing php-intl extension..."
sudo pacman -S --noconfirm php-intl
check_success "Failed to install php-intl extension."

# Enable the intl extension in the php.ini file
PHP_INI="/etc/php/php.ini"
if grep -q "^;extension=intl" $PHP_INI; then
    echo "Enabling intl extension in php.ini..."
    sudo sed -i 's/^;extension=intl/extension=intl/' $PHP_INI
    check_success "Failed to enable intl extension in php.ini."
else
    echo "intl extension is already enabled in php.ini."
fi

# Restart Apache to apply changes
echo "Restarting Apache..."
sudo systemctl restart httpd
check_success "Failed to restart Apache."

# Print success message
echo "php-intl extension installed and enabled successfully!"
echo "You can now run the Composer command to install CodeIgniter."

exit 0
