#!/bin/bash

# Exit on error
set -e

# Color definitions
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to handle errors
handle_error() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

# Function to backup a file
backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        if ! sudo cp "$file" "$backup"; then
            handle_error "Failed to create backup of $file"
        fi
        echo -e "${RED}Created backup: $backup${NC}"
    fi
}

# Function to check if lz4 is installed
check_lz4() {
    if ! command -v lz4 &>/dev/null; then
        echo -e "${RED}Installing lz4 package...${NC}\n"
        if ! sudo pacman -S --noconfirm lz4; then
            handle_error "Failed to install lz4"
        fi
    fi
}

# Function to check if mkinitcpio is installed
check_mkinitcpio() {
    if ! command -v mkinitcpio &>/dev/null; then
        echo -e "${RED}Installing mkinitcpio package...${NC}\n"
        if ! sudo pacman -S --noconfirm mkinitcpio; then
            handle_error "Failed to install mkinitcpio"
        fi
    fi
}

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
        echo -e "${RED}Creating backup of mkinitcpio.conf...${NC}"
        sudo cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.backup
    fi
}

# Function to configure lz4 compression
setup_lz4_compression() {
    echo -e "${RED}Configuring LZ4 compression for initramfs...${NC}"
    
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
    
    echo -e "${RED}Regenerating initramfs images...${NC}"
    if ! sudo mkinitcpio -P; then
        echo -e "${RED}Error: Failed to regenerate initramfs images${NC}"
        return 1
    fi
    
    echo -e "${RED}LZ4 compression has been successfully configured!${NC}"
    echo -e "${RED}Current mkinitcpio compression settings:${NC}"
    grep "^COMPRESSION" /etc/mkinitcpio.conf
}

# ASCII Art Banner
echo -e "${RED}"
cat << "EOF"

██╗███╗   ██╗██╗████████╗██████╗  █████╗ ███╗   ███╗███████╗███████╗
██║████╗  ██║██║╚══██╔══╝██╔══██╗██╔══██╗████╗ ████║██╔════╝██╔════╝
██║██╔██╗ ██║██║   ██║   ██████╔╝███████║██╔████╔██║█████╗  ███████╗
██║██║╚██╗██║██║   ██║   ██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ╚════██║
██║██║ ╚████║██║   ██║   ██║  ██║██║  ██║██║ ╚═╝ ██║██║     ███████║
╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝     ╚══════╝
                                                                      
    🚀 INITRAMFS COMPRESSION SETUP 🚀
=====================================
EOF
echo -e "${NC}"

# Main script
if ! check_lz4_config; then
    echo -e "${RED}LZ4 compression is not configured for initramfs.${NC}"
    read -r -p $'Would you like to configure LZ4 compression? (y/n): ' answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        setup_lz4_compression
    else
        echo -e "${RED}Skipping LZ4 compression setup.${NC}"
    fi
else
    echo -e "${RED}LZ4 compression is already configured for initramfs.${NC}"
    read -r -p $'Would you like to reconfigure it? (y/n): ' answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        setup_lz4_compression
    else
        echo -e "${RED}Keeping existing LZ4 compression configuration.${NC}"
    fi
fi
