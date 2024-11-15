#!/bin/bash

# Ensure the script is being run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root!" 
    exit 1
fi

echo "Starting Chaotic AUR setup..."

# Step 1: Receive and sign the key for Chaotic AUR
echo "1. Receiving and signing the Chaotic AUR key..."
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB

# Check if the keyring commands were successful
if [[ $? -ne 0 ]]; then
    echo "Failed to receive and sign the key. Exiting..."
    exit 1
fi

echo "Chaotic AUR key received and signed successfully."

# Step 2: Install Chaotic AUR keyring and mirrorlist
echo "2. Installing Chaotic AUR keyring..."
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'

# Check if keyring installation was successful
if [[ $? -ne 0 ]]; then
    echo "Failed to install Chaotic AUR keyring. Exiting..."
    exit 1
fi

echo "Chaotic AUR keyring installed successfully."

# Step 3: Install Chaotic AUR mirrorlist
echo "3. Installing Chaotic AUR mirrorlist..."
pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Check if mirrorlist installation was successful
if [[ $? -ne 0 ]]; then
    echo "Failed to install Chaotic AUR mirrorlist. Exiting..."
    exit 1
fi

echo "Chaotic AUR mirrorlist installed successfully."

# Done!
echo "Chaotic AUR setup completed successfully! 🎉"
