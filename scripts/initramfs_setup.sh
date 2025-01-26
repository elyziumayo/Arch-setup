#!/bin/bash

# Function to check if lz4 compression is configured
check_lz4_config() {
    if grep -q "^COMPRESSION=\"lz4\"" /etc/mkinitcpio.conf; then
        return 0
    else
        return 1
    fi
}

# Function to backup config
backup_config() {
    if [ ! -f /etc/mkinitcpio.conf.backup ]; then
        echo "Creating backup of mkinitcpio.conf..."
        sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.backup
    fi
}

# Function to configure lz4 compression
setup_lz4_compression() {
    echo "Configuring LZ4 compression for initramfs..."
    
    # Backup original config
    backup_config
    
    # Check if compression is already set
    if grep -q "^COMPRESSION=" /etc/mkinitcpio.conf; then
        # Replace existing compression setting
        sudo sed -i 's/^COMPRESSION=.*/COMPRESSION="lz4"/' /etc/mkinitcpio.conf
    else
        # Add compression setting
        echo 'COMPRESSION="lz4"' | sudo tee -a /etc/mkinitcpio.conf > /dev/null
    fi
    
    # Check if compression options are already set
    if grep -q "^COMPRESSION_OPTIONS=" /etc/mkinitcpio.conf; then
        # Replace existing compression options
        sudo sed -i 's/^COMPRESSION_OPTIONS=.*/COMPRESSION_OPTIONS=(-9)/' /etc/mkinitcpio.conf
    else
        # Add compression options
        echo 'COMPRESSION_OPTIONS=(-9)' | sudo tee -a /etc/mkinitcpio.conf > /dev/null
    fi
    
    echo "Regenerating initramfs images..."
    if ! sudo mkinitcpio -P; then
        echo "Error: Failed to regenerate initramfs images"
        return 1
    fi
    
    echo "LZ4 compression has been successfully configured!"
    echo "Current mkinitcpio compression settings:"
    grep "^COMPRESSION" /etc/mkinitcpio.conf
}

# Check for force flag
FORCE=0
if [ "$1" = "--force" ]; then
    FORCE=1
fi

# Main script
if ! check_lz4_config; then
    echo "LZ4 compression is not configured for initramfs."
    if [ $FORCE -eq 1 ] || { read -p "Would you like to configure LZ4 compression? (y/n): " answer && [[ $answer =~ ^[Yy]$ ]]; }; then
        setup_lz4_compression
    else
        echo "Skipping LZ4 compression setup."
    fi
else
    echo "LZ4 compression is already configured for initramfs."
    if [ $FORCE -eq 1 ] || { read -p "Would you like to reconfigure it? (y/n): " answer && [[ $answer =~ ^[Yy]$ ]]; }; then
        setup_lz4_compression
    else
        echo "Keeping existing LZ4 compression configuration."
    fi
fi 