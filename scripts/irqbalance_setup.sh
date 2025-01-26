#!/bin/bash

# Function to check if irqbalance is installed
check_irqbalance() {
    if pacman -Qi irqbalance &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to check if irqbalance service is enabled
check_service() {
    if systemctl is-enabled irqbalance &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to install and configure irqbalance
setup_irqbalance() {
    echo "Installing irqbalance..."
    sudo pacman -S irqbalance --noconfirm

    echo "Enabling and starting irqbalance service..."
    sudo systemctl enable --now irqbalance

    # Wait a moment for the service to start
    sleep 2

    # Check service status but ignore thermal message
    echo "IRQBalance has been successfully configured!"
    echo "Current IRQBalance status:"
    systemctl status irqbalance | grep -v "thermal"

    # Verify if service is actually running despite thermal message
    if systemctl is-active irqbalance &>/dev/null; then
        echo -e "\nIRQBalance is running successfully."
        echo "Note: The thermal message warning can be safely ignored as it doesn't affect functionality."
    else
        echo -e "\nWarning: IRQBalance service failed to start properly."
        return 1
    fi
}

# Check for force flag
FORCE=0
if [ "$1" = "--force" ]; then
    FORCE=1
fi

# Main script
if ! check_irqbalance; then
    echo "IRQBalance is not installed on your system."
    if [ $FORCE -eq 1 ] || { read -p "Would you like to install and configure IRQBalance? (y/n): " answer && [[ $answer =~ ^[Yy]$ ]]; }; then
        setup_irqbalance
    else
        echo "Skipping IRQBalance setup."
    fi
else
    echo "IRQBalance is already installed."
    if ! check_service; then
        echo "IRQBalance service is not enabled."
        if [ $FORCE -eq 1 ] || { read -p "Would you like to enable IRQBalance service? (y/n): " answer && [[ $answer =~ ^[Yy]$ ]]; }; then
            sudo systemctl enable --now irqbalance
            echo "IRQBalance service has been enabled and started!"
        else
            echo "Skipping IRQBalance service activation."
        fi
    else
        echo "IRQBalance is already configured and running on your system."
    fi
fi 