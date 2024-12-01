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

# Install dependencies
echo "Installing dependencies..."
sudo pacman -S wget tar --noconfirm
check_success

# Download Oracle JDK
echo "Downloading Oracle JDK..."
wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" \
"https://download.oracle.com/java/20/latest/jdk-20_linux-x64_bin.tar.gz" -O ~/jdk.tar.gz
check_success

# Extract the JDK
echo "Extracting JDK..."
sudo mkdir -p /usr/local/java
sudo tar -xzf ~/jdk.tar.gz -C /usr/local/java
check_success

# Set up environment variables for Oracle JDK
echo "Setting up environment variables for Oracle JDK..."
echo "export JAVA_HOME=/usr/local/java/jdk-20" | sudo tee -a /etc/profile
echo "export PATH=\$PATH:\$JAVA_HOME/bin" | sudo tee -a /etc/profile
source /etc/profile
check_success

# Verify the JDK installation
echo "Verifying JDK installation..."
java -version
check_success

# Install Snapd (required for JetBrains IDE installation)
echo "Installing Snapd..."
sudo pacman -S snapd --noconfirm
check_success

# Enable and start Snapd service
echo "Enabling and starting Snapd service..."
sudo systemctl enable --now snapd.socket
check_success

# Create symlink for Snap
echo "Creating symlink for Snap..."
sudo ln -s /var/lib/snapd/snap /snap
check_success

# Install JetBrains IntelliJ IDEA (Community Edition)
echo "Installing IntelliJ IDEA Community Edition..."
sudo snap install intellij-idea-community --classic
check_success

# Set Oracle JDK as the default JVM
echo "Setting Oracle JDK as the default JVM..."
sudo update-alternatives --install /usr/bin/java java /usr/local/java/jdk-20/bin/java 1
sudo update-alternatives --install /usr/bin/javac javac /usr/local/java/jdk-20/bin/javac 1
sudo update-alternatives --set java /usr/local/java/jdk-20/bin/java
sudo update-alternatives --set javac /usr/local/java/jdk-20/bin/javac
check_success

# Confirm the default JVM is set correctly
echo "Confirming the default JVM..."
java -version
check_success

echo "Installation of Oracle JDK, JVM, and IntelliJ IDEA completed successfully!"
