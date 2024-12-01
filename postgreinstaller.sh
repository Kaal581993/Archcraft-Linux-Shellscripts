#!/bin/bash

# Update the system package database
echo "Updating package database..."
sudo pacman -Syu --noconfirm

# Install PostgreSQL
echo "Installing PostgreSQL..."
sudo pacman -S postgresql --noconfirm

# Initialize the PostgreSQL database cluster
echo "Initializing PostgreSQL database cluster..."
sudo -iu postgres initdb -D /var/lib/postgres/data

# Start and enable PostgreSQL service
echo "Starting and enabling PostgreSQL service..."
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Print PostgreSQL status
echo "PostgreSQL installation complete. Service status:"
sudo systemctl status postgresql

# Instructions to create a PostgreSQL user
echo "To create a PostgreSQL user, use the following command:"
echo "sudo -iu postgres createuser --interactive"

# Instructions to create a PostgreSQL database
echo "To create a PostgreSQL database, use the following command:"
echo "sudo -iu postgres createdb <your_database_name>"

# Reminder to secure your PostgreSQL installation
echo "Remember to secure your PostgreSQL installation by setting a password for the PostgreSQL user 'postgres'."
echo "Use the following command:"
echo "sudo -iu postgres psql -c \"ALTER USER postgres PASSWORD 'your_password';\""

echo "Installation and setup of PostgreSQL on Arch Linux is complete!"

