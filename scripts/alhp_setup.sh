#!/bin/bash

# Function to check if ALHP is configured
check_alhp() {
    if grep -q "\[core-x86-64-v[34]\]" /etc/pacman.conf; then
        return 0
    else
        return 1
    fi
}

# Function to detect CPU architecture version
detect_cpu_version() {
    # Check for x86-64-v4 support
    if grep -q "^flags.*avx512" /proc/cpuinfo; then
        echo "v4"
    # Check for x86-64-v3 support
    elif grep -q "^flags.*avx2" /proc/cpuinfo; then
        echo "v3"
    else
        echo "unsupported"
    fi
}

# Function to configure ALHP
configure_alhp() {
    local cpu_version=$1
    local temp_file=$(mktemp)

    # Backup original pacman.conf
    sudo cp /etc/pacman.conf /etc/pacman.conf.backup

    # Process the file and add ALHP repositories before their standard counterparts
    while IFS= read -r line; do
        if [[ $line == "[core]"* ]]; then
            echo "[core-x86-64-$cpu_version]" >> "$temp_file"
            echo "Include = /etc/pacman.d/alhp-mirrorlist" >> "$temp_file"
            echo "" >> "$temp_file"
        elif [[ $line == "[extra]"* ]]; then
            echo "[extra-x86-64-$cpu_version]" >> "$temp_file"
            echo "Include = /etc/pacman.d/alhp-mirrorlist" >> "$temp_file"
            echo "" >> "$temp_file"
        elif [[ $line == "[multilib]"* ]]; then
            echo "[multilib-x86-64-$cpu_version]" >> "$temp_file"
            echo "Include = /etc/pacman.d/alhp-mirrorlist" >> "$temp_file"
            echo "" >> "$temp_file"
        fi
        echo "$line" >> "$temp_file"
    done < /etc/pacman.conf

    # Replace the original file
    sudo mv "$temp_file" /etc/pacman.conf
}

# Function to install ALHP
install_alhp() {
    local cpu_version=$1
    echo "Installing ALHP for x86-64-$cpu_version..."

    # Check if yay is installed
    if ! command -v yay &> /dev/null; then
        echo "Error: yay is not installed. Please install yay first."
        exit 1
    fi

    # Install ALHP keyring and mirrorlist
    yay -S alhp-keyring alhp-mirrorlist --noconfirm

    # Configure pacman.conf
    configure_alhp "$cpu_version"

    echo "ALHP has been successfully configured for x86-64-$cpu_version!"
}

# Check for force flag
FORCE=0
if [ "$1" = "--force" ]; then
    FORCE=1
fi

# Main script
if ! check_alhp; then
    echo "ALHP is not configured on your system."
    
    # Detect CPU version
    cpu_version=$(detect_cpu_version)
    
    if [ "$cpu_version" = "unsupported" ]; then
        echo "Your CPU does not support ALHP (requires at least x86-64-v3)."
        exit 1
    fi
    
    echo "Detected CPU architecture: x86-64-$cpu_version"
    if [ $FORCE -eq 1 ] || { read -p "Would you like to install ALHP? (y/n): " answer && [[ $answer =~ ^[Yy]$ ]]; }; then
        install_alhp "$cpu_version"
    else
        echo "Skipping ALHP installation."
    fi
else
    echo "ALHP is already configured on your system."
fi 