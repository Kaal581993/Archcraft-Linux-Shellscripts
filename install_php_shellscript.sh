#!/bin/bash

# Function to update mirrors and refresh pacman cache
update_mirrors() {
  echo "Updating mirror list and refreshing package database..."
  sudo pacman -Sy reflector --noconfirm
  sudo reflector --verbose --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
  sudo pacman -Syyu --noconfirm
}

# Function to clear rust and cargo cache and install the latest rust/cargo
update_rust() {
  echo "Updating rust and cargo..."
  sudo pacman -S rust cargo --noconfirm
  # Clear cargo's build cache
  cargo clean || echo "Cargo clean-up not required."
  rustup update
}

# Function to remove cached and installed versions of yay and paru, and recompile the latest versions
reinstall_aur_helper() {
  # Update mirrors and clear cached packages
  update_mirrors

  # Update rust and cargo to avoid build issues
  update_rust

  # Remove yay and paru if they exist
  echo "Removing any existing yay or paru installations..."
  sudo rm -rf /usr/bin/yay /usr/bin/paru
  sudo rm -rf /opt/yay /opt/paru
  
  # Clear yay and paru caches to prevent old versions from being reused
  sudo pacman -Rns yay paru --noconfirm || echo "yay or paru not found to remove."
  sudo pacman -Sc --noconfirm
  
  # Rebuild yay or paru from the AUR source to ensure compatibility with the latest libalpm version
  echo "Installing the latest yay from source..."
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si --noconfirm
  cd ..
  rm -rf yay

  # If yay fails, try installing paru as a fallback
  if ! command -v yay &> /dev/null; then
    echo "yay installation failed, trying to install paru..."
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
  fi

  # Verify that either yay or paru was installed successfully
  if command -v yay &> /dev/null || command -v paru &> /dev/null; then
    echo "AUR helper installed successfully."
  else
    echo "Failed to install an AUR helper. Exiting..."
    exit 1
  fi
}

# Reinstall AUR helper (yay or paru) to ensure compatibility
reinstall_aur_helper

# Function to install PHP 5.6
install_php56() {
  if command -v yay &> /dev/null; then
    echo "Installing PHP 5.6 with yay..."
    yay -S php56 --noconfirm || {
      echo "PHP 5.6 installation with yay failed. Trying with paru..."
      paru -S php56 --noconfirm
    }
  elif command -v paru &> /dev/null; then
    echo "Installing PHP 5.6 with paru..."
    paru -S php56 --noconfirm
  else
    echo "No AUR helper available to install PHP 5.6."
    exit 1
  fi
}

# Attempt to install PHP 5.6
install_php56

# Verify PHP 5.6 installation
if ! command -v php56 &> /dev/null; then
  echo "PHP 5.6 installation failed."
  exit 1
fi

# Set up PHP 5.6 as the default PHP version
echo "Setting PHP 5.6 as the default PHP version..."
sudo ln -sf /usr/bin/php56 /usr/bin/php

# Check PHP version
php -v

# Install Composer
echo "Installing Composer..."
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Verify Composer installation
if ! command -v composer &> /dev/null; then
  echo "Composer installation failed."
  exit 1
fi

# Display installed versions
echo "PHP version:"
php -v
echo "Composer version:"
composer --version

echo "PHP 5.6 and Composer have been successfully installed."
