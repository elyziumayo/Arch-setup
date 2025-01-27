#!/bin/bash

# Exit on error
set -e

# Color definitions
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# ASCII Art Banner
echo -e "${MAGENTA}"
cat << "EOF"

 ██████╗██╗  ██╗ █████╗  ██████╗ ████████╗██╗ ██████╗
██╔════╝██║  ██║██╔══██╗██╔═══██╗╚══██╔══╝██║██╔════╝
██║     ███████║███████║██║   ██║   ██║   ██║██║     
██║     ██╔══██║██╔══██║██║   ██║   ██║   ██║██║     
╚██████╗██║  ██║██║  ██║╚██████╔╝   ██║   ██║╚██████╗
 ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚═╝ ╚═════╝

    🚀 CHAOTIC AUR REPOSITORY SETUP 🚀
===================================================
EOF
echo -e "${NC}"

# Function to check if chaotic-aur is in pacman.conf
check_chaotic_repo() {
    if grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
        return 0
    else
        return 1
    fi
}

# Function to backup pacman.conf
backup_pacman_conf() {
    echo -e "${MAGENTA}Creating backup of pacman.conf...${NC}\n"
    local backup_file="/etc/pacman.conf.backup.$(date +%Y%m%d_%H%M%S)"
    if ! sudo cp /etc/pacman.conf "$backup_file"; then
        echo -e "${MAGENTA}Error: Failed to create backup of pacman.conf!${NC}"
        exit 1
    fi
    echo -e "${MAGENTA}Backup created at: $backup_file${NC}"
}

# Function to add chaotic keys
add_chaotic_keys() {
    echo -e "${MAGENTA}Adding GPG keys...${NC}\n"
    local key="3056513887B78AEB"
    local keyservers=("keyserver.ubuntu.com" "keys.gnupg.net" "pgp.mit.edu")
    
    for server in "${keyservers[@]}"; do
        if sudo pacman-key --recv-key "$key" --keyserver "$server" &>/dev/null; then
            if sudo pacman-key --lsign-key "$key"; then
                return 0
            fi
        fi
    done
    
    echo -e "${MAGENTA}Error: Failed to add GPG keys after trying multiple keyservers!${NC}"
    exit 1
}

# Main script
echo -e "\n${MAGENTA}Checking for Chaotic AUR repository...${NC}\n"

if check_chaotic_repo; then
    echo -e "${MAGENTA}Chaotic AUR repository is already configured.${NC}\n"
    exit 0
else
    echo -e "${MAGENTA}Chaotic AUR repository is not configured.${NC}\n"
    read -p "$(echo -e ${MAGENTA}"Would you like to install Chaotic AUR repository? (y/n): "${NC})" choice
    echo ""
    
    if [[ $choice =~ ^[Yy]$ ]]; then
        echo -e "${MAGENTA}Installing Chaotic AUR repository...${NC}\n"
        
        # Backup pacman.conf
        backup_pacman_conf
        
        # Add keys with multiple keyserver fallback
        add_chaotic_keys
        
        # Install keyring and mirrorlist with retries
        echo -e "\n${MAGENTA}Installing keyring and mirrorlist...${NC}\n"
        for i in {1..3}; do
            if sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' --noconfirm && \
               sudo pacman -U 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' --noconfirm; then
                break
            elif [ $i -eq 3 ]; then
                echo -e "${MAGENTA}Error: Failed to install chaotic packages after multiple attempts!${NC}"
                exit 1
            else
                echo -e "${MAGENTA}Retrying package installation (attempt $i of 3)...${NC}\n"
                sleep 2
            fi
        done
        
        # Append to pacman.conf
        echo -e "\n${MAGENTA}Configuring pacman.conf...${NC}\n"
        if ! echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf >/dev/null; then
            echo -e "${MAGENTA}Error: Failed to update pacman.conf!${NC}"
            exit 1
        fi
        
        # Update database
        echo -e "\n${MAGENTA}Updating package database...${NC}\n"
        if ! sudo pacman -Syy; then
            echo -e "${MAGENTA}Error: Failed to update package database!${NC}"
            exit 1
        fi
        
        echo -e "\n${MAGENTA}Chaotic AUR repository has been successfully installed and configured.${NC}\n"
    else
        echo -e "${MAGENTA}Skipping Chaotic AUR repository installation.${NC}\n"
        exit 0
    fi
fi 