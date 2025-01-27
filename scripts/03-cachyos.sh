#!/bin/bash

# Exit on error
set -e

# Color definitions
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# ASCII Art Banner
echo -e "${GREEN}"
cat << "EOF"

 ██████╗ █████╗  ██████╗██╗  ██╗██╗   ██╗ ██████╗ ███████╗
██╔════╝██╔══██╗██╔════╝██║  ██║╚██╗ ██╔╝██╔═══██╗██╔════╝
██║     ███████║██║     ███████║ ╚████╔╝ ██║   ██║███████╗
██║     ██╔══██║██║     ██╔══██║  ╚██╔╝  ██║   ██║╚════██║
╚██████╗██║  ██║╚██████╗██║  ██║   ██║   ╚██████╔╝███████║
 ╚═════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚══════╝

    🚀 CACHYOS REPOSITORY SETUP 🚀
===================================
EOF
echo -e "${NC}"

# Function to check if CachyOS repo is configured
check_cachyos_repo() {
    if grep -q "\[cachyos\]" /etc/pacman.conf; then
        return 0
    else
        return 1
    fi
}

# Function to backup pacman.conf
backup_pacman_conf() {
    echo -e "${GREEN}Creating backup of pacman.conf...${NC}\n"
    local backup_file="/etc/pacman.conf.backup.$(date +%Y%m%d_%H%M%S)"
    if ! sudo cp /etc/pacman.conf "$backup_file"; then
        echo -e "${GREEN}Error: Failed to create backup of pacman.conf!${NC}"
        exit 1
    fi
    echo -e "${GREEN}Backup created at: $backup_file${NC}"
}

# Main script
echo -e "\n${GREEN}Checking for CachyOS repository...${NC}\n"

if check_cachyos_repo; then
    echo -e "${GREEN}CachyOS repository is already configured.${NC}\n"
    exit 0
else
    echo -e "${GREEN}CachyOS repository is not configured.${NC}\n"
    read -p "$(echo -e ${GREEN}"Would you like to install CachyOS repository? (y/n): "${NC})" choice
    echo ""
    
    if [[ $choice =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Installing CachyOS repository...${NC}\n"
        
        # Create temporary directory
        echo -e "${GREEN}Creating temporary directory...${NC}\n"
        temp_dir=$(mktemp -d)
        cd "$temp_dir"
        
        # Download and extract the script
        echo -e "${GREEN}Downloading CachyOS repository script...${NC}\n"
        if ! curl -O https://mirror.cachyos.org/cachyos-repo.tar.xz; then
            echo -e "${GREEN}Error: Failed to download CachyOS repository script!${NC}"
            rm -rf "$temp_dir"
            exit 1
        fi
        
        # Extract archive
        echo -e "${GREEN}Extracting archive...${NC}\n"
        if ! tar xvf cachyos-repo.tar.xz; then
            echo -e "${GREEN}Error: Failed to extract archive!${NC}"
            rm -rf "$temp_dir"
            exit 1
        fi
        
        # Run the script
        echo -e "${GREEN}Running CachyOS repository setup script...${NC}\n"
        cd cachyos-repo
        if ! sudo ./cachyos-repo.sh; then
            echo -e "${GREEN}Error: Failed to setup CachyOS repository!${NC}"
            cd
            rm -rf "$temp_dir"
            exit 1
        fi
        
        # Cleanup
        cd
        rm -rf "$temp_dir"
        
        # Update database
        echo -e "\n${GREEN}Updating package database...${NC}\n"
        if ! sudo pacman -Syy; then
            echo -e "${GREEN}Error: Failed to update package database!${NC}"
            exit 1
        fi
        
        echo -e "\n${GREEN}CachyOS repository has been successfully installed and configured.${NC}\n"
    else
        echo -e "${GREEN}Skipping CachyOS repository installation.${NC}\n"
        exit 0
    fi
fi 