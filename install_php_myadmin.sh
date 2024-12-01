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

# Install Apache
echo "Installing Apache web server..."
sudo pacman -S --noconfirm apache
check_success "Failed to install Apache."

# Enable and start Apache service
echo "Enabling and starting Apache service..."
sudo systemctl enable httpd
sudo systemctl start httpd
check_success "Failed to enable or start Apache."

# Install PHP and PHP SDK
echo "Installing PHP and PHP SDK..."
sudo pacman -S --noconfirm php php-apache
check_success "Failed to install PHP or PHP SDK."

# Configure PHP for Apache
echo "Configuring PHP with Apache..."
sudo sed -i 's/#LoadModule php_module modules\/libphp.so/LoadModule php_module modules\/libphp.so/' /etc/httpd/conf/httpd.conf
sudo sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' /etc/httpd/conf/httpd.conf
check_success "Failed to configure PHP for Apache."

# Install MariaDB (MySQL replacement)
echo "Installing MariaDB database server..."
sudo pacman -S --noconfirm mariadb
check_success "Failed to install MariaDB."

# Initialize and start MariaDB
echo "Initializing and starting MariaDB..."
sudo mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
check_success "Failed to initialize MariaDB."
sudo systemctl enable mariadb
sudo systemctl start mariadb
check_success "Failed to start MariaDB."

# Secure MariaDB installation
echo "Securing MariaDB installation..."
sudo mysql_secure_installation
check_success "Failed to secure MariaDB."

# Install phpMyAdmin
echo "Installing phpMyAdmin..."
sudo pacman -S --noconfirm phpmyadmin
check_success "Failed to install phpMyAdmin."

# Configure phpMyAdmin for Apache
echo "Configuring phpMyAdmin for Apache..."
echo 'Include /etc/webapps/phpmyadmin/apache.conf' | sudo tee -a /etc/httpd/conf/httpd.conf
check_success "Failed to configure phpMyAdmin."

# Restart Apache to apply changes
echo "Restarting Apache to apply PHP and phpMyAdmin configuration..."
sudo systemctl restart httpd
check_success "Failed to restart Apache."

# Verify installation
if systemctl is-active --quiet httpd && systemctl is-active --quiet mariadb; then
    echo "Apache, PHP, phpMyAdmin, and MariaDB installed successfully!"
    echo "You can access phpMyAdmin via http://localhost/phpmyadmin"
else
    error_exit "Services failed to start. Check the configuration."
fi

exit 0
