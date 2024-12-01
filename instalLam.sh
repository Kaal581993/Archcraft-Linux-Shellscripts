#!/bin/bash

# Update the system repositories
echo "Updating system..."
sudo pacman -Syu --noconfirm

# Install Apache (httpd)
echo "Installing Apache..."
sudo pacman -S --noconfirm apache

# Start and enable Apache to run on boot
echo "Starting and enabling Apache..."
sudo systemctl start httpd.service
sudo systemctl enable httpd.service

# Install PHP
echo "Installing PHP and required PHP modules..."
sudo pacman -S --noconfirm php php-apache

# Configure Apache to work with PHP
echo "Configuring Apache to support PHP..."
sudo sed -i 's|#LoadModule mpm_prefork_module modules/mod_mpm_prefork.so|LoadModule mpm_prefork_module modules/mod_mpm_prefork.so|' /etc/httpd/conf/httpd.conf
sudo sed -i 's|#LoadModule php_module modules/libphp.so|LoadModule php_module modules/libphp.so|' /etc/httpd/conf/httpd.conf
sudo sed -i 's|#Include conf/extra/php_module.conf|Include conf/extra/php_module.conf|' /etc/httpd/conf/httpd.conf

# Restart Apache to apply changes
echo "Restarting Apache..."
sudo systemctl restart httpd.service

# Check Apache and PHP status
echo "Checking the status of Apache and PHP..."
sudo systemctl status httpd.service

echo "LAMP stack without MySQL installed successfully!"
