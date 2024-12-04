#!/bin/bash

# Function to check if Chaotic-AUR is installed
check_chaotic_aur() {
    if grep -q "chaotic-aur" /etc/pacman.conf; then
        return 0  # Chaotic-AUR is installed
    else
        return 1  # Chaotic-AUR is not installed
    fi
}

# Check if Chaotic-AUR is installed
check_chaotic_aur
if [ $? -eq 0 ]; then
    echo "Chaotic-AUR is already installed. Exiting the script."
    exit 0
fi

# Prompt the user to install Chaotic-AUR
echo "Chaotic-AUR is not installed on your system."
read -p "Do you want to install Chaotic-AUR? (y/n): " user_input
if [[ "$user_input" != "y" ]]; then
    echo "Exiting without installing Chaotic-AUR."
    exit 1
fi

# If user agrees, run the installation commands with sudo permission
echo "Installing Chaotic-AUR..."
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

# Add Chaotic-AUR to pacman.conf if it's not there
echo "[chaotic-aur]" | sudo tee -a /etc/pacman.conf > /dev/null
echo "Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf > /dev/null

echo "Chaotic-AUR has been installed successfully. You may need to run 'sudo pacman -Sy' to update your package databases."
