#!/bin/bash

# Function to check if Chaotic AUR is configured
check_chaotic() {
    if grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
        return 0
    else
        return 1
    fi
}

# Check for force flag
FORCE=0
if [ "$1" = "--force" ]; then
    FORCE=1
fi

# Main script
if ! check_chaotic; then
    echo "Chaotic AUR is not configured on your system."
    if [ $FORCE -eq 1 ] || { read -p "Would you like to install it? (y/n): " answer && [[ $answer =~ ^[Yy]$ ]]; }; then
        # Install keyring
        sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        sudo pacman-key --lsign-key 3056513887B78AEB

        # Install chaotic-keyring and chaotic-mirrorlist
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm
        sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm

        # Add repository to pacman.conf
        echo -e "\n[chaotic-aur]" | sudo tee -a /etc/pacman.conf
        echo "Include = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf

        echo "Chaotic AUR has been successfully configured!"
    else
        echo "Skipping Chaotic AUR installation."
    fi
else
    echo "Chaotic AUR is already configured on your system."
fi 