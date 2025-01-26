#!/bin/bash

# Function to check if zram-generator is installed
check_zram() {
    if pacman -Qi zram-generator &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to check if zram config exists
check_zram_config() {
    if [ -f /etc/systemd/zram-generator.conf ]; then
        return 0
    else
        return 1
    fi
}

# Function to install and configure zram
setup_zram() {
    echo "Installing zram-generator..."
    sudo pacman -S zram-generator --noconfirm

    echo "Creating zram configuration..."
    # Create the configuration file
    sudo tee /etc/systemd/zram-generator.conf > /dev/null << 'EOF'
[zram0]
zram-size = ram
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOF

    echo "Reloading systemd daemon..."
    sudo systemctl daemon-reload

    echo "Starting zram service..."
    sudo systemctl start systemd-zram-setup@zram0.service

    # Enable the service to start on boot
    sudo systemctl enable systemd-zram-setup@zram0.service

    echo "ZRAM has been successfully configured!"
    echo "Current ZRAM status:"
    sudo zramctl
}

# Check for force flag
FORCE=0
if [ "$1" = "--force" ]; then
    FORCE=1
fi

# Main script
if ! check_zram; then
    echo "ZRAM generator is not installed on your system."
    if [ $FORCE -eq 1 ] || { read -p "Would you like to install and configure ZRAM? (y/n): " answer && [[ $answer =~ ^[Yy]$ ]]; }; then
        setup_zram
    else
        echo "Skipping ZRAM setup."
    fi
else
    echo "ZRAM generator is already installed."
    if ! check_zram_config; then
        echo "ZRAM configuration file not found."
        if [ $FORCE -eq 1 ] || { read -p "Would you like to create ZRAM configuration? (y/n): " answer && [[ $answer =~ ^[Yy]$ ]]; }; then
            setup_zram
        else
            echo "Skipping ZRAM configuration."
        fi
    else
        echo "ZRAM is already configured on your system."
    fi
fi 