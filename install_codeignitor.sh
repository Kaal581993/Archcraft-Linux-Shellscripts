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

# Install Apache, PHP, and other dependencies
echo "Installing Apache and PHP..."
sudo pacman -S --noconfirm apache php php-apache unzip
check_success "Failed to install Apache and PHP."

# Enable Apache service
echo "Enabling and starting Apache service..."
sudo systemctl enable httpd
sudo systemctl start httpd
check_success "Failed to start Apache."

# Configure PHP for Apache
echo "Configuring PHP with Apache..."
sudo sed -i 's/#LoadModule php_module modules\/libphp.so/LoadModule php_module modules\/libphp.so/' /etc/httpd/conf/httpd.conf
sudo sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' /etc/httpd/conf/httpd.conf
check_success "Failed to configure PHP."

# Install Composer (if not installed) - Required for CodeIgniter
if ! command -v composer &> /dev/null; then
    echo "Composer not found, installing Composer..."
    sudo pacman -S --noconfirm composer
    check_success "Failed to install Composer."
else
    echo "Composer is already installed."
fi

# Install CodeIgniter using Composer
echo "Installing CodeIgniter via Composer..."
cd /srv/http
sudo composer create-project codeigniter4/appstarter CodeIgniter
check_success "Failed to install CodeIgniter."

# Set correct permissions
echo "Setting correct permissions..."
sudo chown -R http:http /srv/http/CodeIgniter
check_success "Failed to set permissions."

# Restart Apache to apply changes
echo "Restarting Apache..."
sudo systemctl restart httpd
check_success "Failed to restart Apache."

# Installation complete
echo "CodeIgniter installation completed successfully!"
echo "You can access CodeIgniter by visiting http://localhost/CodeIgniter in your browser."

exit 0
