#!/bin/bash

# Function to check if systemd-oomd is enabled
check_oomd() {
    if systemctl is-enabled systemd-oomd &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to check if systemd-oomd is active
check_oomd_active() {
    if systemctl is-active systemd-oomd &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to setup systemd-oomd
setup_oomd() {
    echo "Enabling and starting systemd-oomd..."
    sudo systemctl enable --now systemd-oomd

    # Wait a moment for the service to start
    sleep 2

    # Check if service is running
    if check_oomd_active; then
        echo "systemd-oomd has been successfully enabled and started!"
        echo "Current status:"
        systemctl status systemd-oomd
    else
        echo "Error: Failed to start systemd-oomd"
        return 1
    fi
}

# Check for force flag
FORCE=0
if [ "$1" = "--force" ]; then
    FORCE=1
fi

# Main script
if ! check_oomd; then
    echo "systemd-oomd is not enabled on your system."
    if [ $FORCE -eq 1 ] || { read -p "Would you like to enable systemd-oomd? (y/n): " answer && [[ $answer =~ ^[Yy]$ ]]; }; then
        setup_oomd
    else
        echo "Skipping systemd-oomd setup."
    fi
else
    if ! check_oomd_active; then
        echo "systemd-oomd is enabled but not running."
        if [ $FORCE -eq 1 ] || { read -p "Would you like to start systemd-oomd? (y/n): " answer && [[ $answer =~ ^[Yy]$ ]]; }; then
            sudo systemctl start systemd-oomd
            echo "systemd-oomd has been started!"
        else
            echo "Skipping systemd-oomd activation."
        fi
    else
        echo "systemd-oomd is already enabled and running on your system."
    fi
fi 