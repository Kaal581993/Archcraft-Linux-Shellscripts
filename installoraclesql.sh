#!/bin/bash

# Function to check if the previous command succeeded
check_success() {
    if [ $? -ne 0 ]; then
        echo "Error encountered! Exiting script."
        exit 1
    fi
}

# Function to ensure a file was downloaded successfully
check_file_exists() {
    if [ ! -f "$1" ]; then
        echo "File $1 not found! Exiting script."
        exit 1
    fi
}

# Update package database
echo "Updating package database..."
sudo pacman -Syu --noconfirm
check_success

# Install required packages
echo "Installing required packages..."
sudo pacman -S wine winetricks wget unzip libaio --noconfirm
check_success

# Download Oracle Database Express Edition (XE)
echo "Downloading Oracle Database Express Edition (XE)..."
wget -O oracle-xe.zip "https://download.oracle.com/otn/linux/oracle19c/190000/oracle-database-xe-19c-1.0-1.ol7.x86_64.rpm.zip"
check_success
check_file_exists "oracle-xe.zip"

# Unzip the Oracle Database
echo "Unzipping Oracle Database..."
unzip oracle-xe.zip
check_success

# Convert RPM to Arch package (requires debtap or rpmextract)
echo "Installing Oracle Database..."
sudo pacman -S rpmextract --noconfirm
check_success
mkdir oracle-db-install
cd oracle-db-install
rpmextract.sh ../oracle-database-xe-19c-1.0-1.ol7.x86_64.rpm
check_success

cd ..
sudo cp -r oracle-db-install/* /opt/oracle/
check_success

# Set up environment variables
echo "Setting up environment variables..."
echo "export ORACLE_HOME=/opt/oracle/product/19c/dbhomeXE" >> ~/.bashrc
echo "export PATH=\$PATH:\$ORACLE_HOME/bin" >> ~/.bashrc
source ~/.bashrc
check_success

# Run Oracle post-installation setup
echo "Running Oracle post-installation setup..."
sudo /opt/oracle/product/19c/dbhomeXE/root.sh
check_success

# Start Oracle Database
echo "Starting Oracle Database..."
sudo systemctl enable oracle-xe-19c
check_success
sudo systemctl start oracle-xe-19c
check_success

# Set up Wine for PL/SQL Developer
echo "Setting up Wine environment for PL/SQL Developer..."
winetricks corefonts
check_success

# Download and install PL/SQL Developer
echo "Downloading PL/SQL Developer..."
wget -O plsqldev.zip "https://www.allroundautomations.com/files/plsqldev.zip"
check_success
check_file_exists "plsqldev.zip"

echo "Unzipping PL/SQL Developer..."
unzip plsqldev.zip -d plsqldev-installer
check_success

echo "Installing PL/SQL Developer with Wine..."
wine plsqldev-installer/setup.exe
check_success

echo "Installation of Oracle Database and PL/SQL Developer completed successfully!"
