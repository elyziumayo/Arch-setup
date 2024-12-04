#!/bin/bash

# Function to check if CachyOS repository is already installed
check_cachyos_repo() {
    if grep -q "cachyos" /etc/pacman.conf; then
        return 0  # CachyOS repo is installed
    else
        return 1  # CachyOS repo is not installed
    fi
}

# Check if CachyOS repo is installed
check_cachyos_repo
if [ $? -eq 0 ]; then
    echo "CachyOS repository is already installed. Exiting the script."
    exit 0
fi

# Prompt the user to install CachyOS repo if not installed
echo "CachyOS repository is not installed on your system."
read -p "Do you want to install the CachyOS repository? (y/n): " user_input
if [[ "$user_input" != "y" ]]; then
    echo "Exiting without installing CachyOS repository."
    exit 1
fi

# If user agrees, run the installation commands to install CachyOS repo
echo "Installing CachyOS repository..."
cd ~
curl -O https://mirror.cachyos.org/cachyos-repo.tar.xz
tar xvf cachyos-repo.tar.xz
cd cachyos-repo

# Execute the script to install the repository
sudo ./cachyos-repo.sh

# Check again if the repo was successfully added
check_cachyos_repo
if [ $? -eq 0 ]; then
    echo "CachyOS repository installed successfully."
else
    echo "Something went wrong. CachyOS repository installation failed."
    exit 1
fi
