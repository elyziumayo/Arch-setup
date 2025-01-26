#!/bin/bash

# Function to clean package cache
clean_package_cache() {
    echo "Cleaning package cache..."
    if ! sudo pacman -Scc --noconfirm; then
        echo "Error: Failed to clean package cache"
        return 1
    fi
    echo "Package cache has been cleaned!"
}

# Function to remove orphaned packages
remove_orphans() {
    echo "Checking for orphaned packages..."
    
    # Get list of orphaned packages
    local orphans=$(pacman -Qtdq)
    
    if [ -n "$orphans" ]; then
        echo "Found orphaned packages:"
        echo "$orphans"
        echo "Removing orphaned packages..."
        if ! sudo pacman -Rns $(pacman -Qtdq) --noconfirm; then
            echo "Error: Failed to remove orphaned packages"
            return 1
        fi
        echo "Orphaned packages have been removed!"
    else
        echo "No orphaned packages found."
    fi
}

# Check for force flag
FORCE=0
if [ "$1" = "--force" ]; then
    FORCE=1
fi

# Main script
echo "System cleanup"
if [ $FORCE -eq 1 ] || { read -p "Would you like to clean package cache and remove orphaned packages? (y/n): " answer && [[ $answer =~ ^[Yy]$ ]]; }; then
    clean_package_cache
    remove_orphans
    echo "System cleanup completed!"
else
    echo "Skipping system cleanup."
fi 