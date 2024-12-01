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

# Install MySQL
echo "Installing MySQL..."
sudo pacman -S mysql --noconfirm
check_success

# Initialize MySQL database
echo "Initializing MySQL database..."
sudo mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
check_success

# Start and enable MySQL service
echo "Starting and enabling MySQL service..."
sudo systemctl start mysqld
check_success
sudo systemctl enable mysqld
check_success

# Secure MySQL installation
echo "Securing MySQL installation..."
sudo mysql_secure_installation
check_success

# Install MySQL Workbench
echo "Installing MySQL Workbench..."
sudo pacman -S mysql-workbench --noconfirm
check_success

# Confirm the installation
echo "Verifying installation..."
mysql --version
check_success
mysql-workbench --version
check_success

echo "MySQL and MySQL Workbench installed successfully!"
