#!/bin/bash

# Function to check if CachyOS repo is configured
check_cachyos() {
    if grep -q "\[cachyos\]" /etc/pacman.conf; then
        return 0
    else
        return 1
    fi
}

# Function to install CachyOS repo
install_cachyos() {
    echo "Installing CachyOS repository..."
    
    # Create temporary directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Download and extract the repo script
    echo "Downloading CachyOS repository setup script..."
    if ! curl -O https://mirror.cachyos.org/cachyos-repo.tar.xz; then
        echo "Error: Failed to download CachyOS repository archive"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Extract archive
    echo "Extracting archive..."
    if ! tar xf cachyos-repo.tar.xz; then
        echo "Error: Failed to extract archive"
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Run the setup script
    echo "Running CachyOS repository setup script..."
    cd cachyos-repo
    if ! sudo ./cachyos-repo.sh; then
        echo "Error: Failed to setup CachyOS repository"
        cd
        rm -rf "$temp_dir"
        exit 1
    fi
    
    # Cleanup
    cd
    rm -rf "$temp_dir"
    
    echo "CachyOS repository has been successfully configured!"
}

# Check for force flag
FORCE=0
if [ "$1" = "--force" ]; then
    FORCE=1
fi

# Main script
if ! check_cachyos; then
    echo "CachyOS repository is not configured on your system."
    if [ $FORCE -eq 1 ] || { read -p "Would you like to install it? (y/n): " answer && [[ $answer =~ ^[Yy]$ ]]; }; then
        install_cachyos
    else
        echo "Skipping CachyOS repository installation."
    fi
else
    echo "CachyOS repository is already configured on your system."
fi 