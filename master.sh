#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
ORANGE='\033[0;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# ASCII Art
CHAOTIC_ASCII="
${YELLOW}
 ██████╗██╗  ██╗ █████╗  ██████╗ ████████╗██╗ ██████╗
██╔════╝██║  ██║██╔══██╗██╔═══██╗╚══██╔══╝██║██╔════╝
██║     ███████║███████║██║   ██║   ██║   ██║██║     
██║     ██╔══██║██╔══██║██║   ██║   ██║   ██║██║     
╚██████╗██║  ██║██║  ██║╚██████╔╝   ██║   ██║╚██████╗
 ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝    ╚═╝   ╚═╝ ╚═════╝
${NC}"

ALHP_ASCII="
${BLUE}
 █████╗ ██╗     ██╗  ██╗██████╗ 
██╔══██╗██║     ██║  ██║██╔══██╗
███████║██║     ███████║██████╔╝
██╔══██║██║     ██╔══██║██╔═══╝ 
██║  ██║███████╗██║  ██║██║     
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     
${NC}"

CACHYOS_ASCII="
${GREEN}
 ██████╗ █████╗  ██████╗██╗  ██╗██╗   ██╗ ██████╗ ███████╗
██╔════╝██╔══██╗██╔════╝██║  ██║╚██╗ ██╔╝██╔═══██╗██╔════╝
██║     ███████║██║     ███████║ ╚████╔╝ ██║   ██║███████╗
██║     ██╔══██║██║     ██╔══██║  ╚██╔╝  ██║   ██║╚════██║
╚██████╗██║  ██║╚██████╗██║  ██║   ██║   ╚██████╔╝███████║
 ╚═════╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚══════╝
${NC}"

MAKEPKG_ASCII="
${CYAN}
███╗   ███╗ █████╗ ██╗  ██╗███████╗██████╗ ██╗  ██╗ ██████╗ 
████╗ ████║██╔══██╗██║ ██╔╝██╔════╝██╔══██╗██║ ██╔╝██╔════╝ 
██╔████╔██║███████║█████╔╝ █████╗  ██████╔╝█████╔╝ ██║  ███╗
██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══╝  ██╔═══╝ ██╔═██╗ ██║   ██║
██║ ╚═╝ ██║██║  ██║██║  ██╗███████╗██║     ██║  ██╗╚██████╔╝
╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝ ╚═════╝ 
${NC}"

ZRAM_ASCII="
${MAGENTA}
███████╗██████╗  █████╗ ███╗   ███╗
╚══███╔╝██╔══██╗██╔══██╗████╗ ████║
  ███╔╝ ██████╔╝███████║██╔████╔██║
 ███╔╝  ██╔══██╗██╔══██║██║╚██╔╝██║
███████╗██║  ██║██║  ██║██║ ╚═╝ ██║
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝
${NC}"

IRQ_ASCII="
${WHITE}
██╗██████╗  ██████╗ ██████╗  █████╗ ██╗      █████╗ ███╗   ██╗ ██████╗███████╗
██║██╔══██╗██╔═══██╗██╔══██╗██╔══██╗██║     ██╔══██╗████╗  ██║██╔════╝██╔════╝
██║██████╔╝██║   ██║██████╔╝███████║██║     ███████║██╔██╗ ██║██║     █████╗  
██║██╔══██╗██║▄▄ ██║██╔══██╗██╔══██║██║     ██╔══██║██║╚██╗██║██║     ██╔══╝  
██║██║  ██║╚██████╔╝██████╔╝██║  ██║███████╗██║  ██║██║ ╚████║╚██████╗███████╗
╚═╝╚═╝  ╚═╝ ╚══▀▀═╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝╚══════╝
${NC}"

SQLITE_ASCII="
${ORANGE}
███████╗ ██████╗ ██╗     ██╗████████╗███████╗     ██████╗ ██████╗ ████████╗
██╔════╝██╔═══██╗██║     ██║╚══██╔══╝██╔════╝    ██╔═══██╗██╔══██╗╚══██╔══╝
███████╗██║   ██║██║     ██║   ██║   █████╗      ██║   ██║██████╔╝   ██║   
╚════██║██║▄▄ ██║██║     ██║   ██║   ██╔══╝      ██║   ██║██╔═══╝    ██║   
███████║╚██████╔╝███████╗██║   ██║   ███████╗    ╚██████╔╝██║        ██║   
╚══════╝ ╚══▀▀═╝ ╚══════╝╚═╝   ╚═╝   ╚══════╝     ╚═════╝ ╚═╝        ╚═╝   
${NC}"

PACKAGES_ASCII="
${PURPLE}
██████╗  █████╗  ██████╗██╗  ██╗ █████╗  ██████╗ ███████╗███████╗
██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔════╝ ██╔════╝██╔════╝
██████╔╝███████║██║     █████╔╝ ███████║██║  ███╗█████╗  ███████╗
██╔═══╝ ██╔══██║██║     ██╔═██╗ ██╔══██║██║   ██║██╔══╝  ╚════██║
██║     ██║  ██║╚██████╗██║  ██╗██║  ██║╚██████╔╝███████╗███████║
╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝
${NC}"

OOMD_ASCII="
${MAGENTA}
 ██████╗  ██████╗ ███╗   ███╗██████╗ 
██╔═══██╗██╔═══██╗████╗ ████║██╔══██╗
██║   ██║██║   ██║██╔████╔██║██║  ██║
██║   ██║██║   ██║██║╚██╔╝██║██║  ██║
╚██████╔╝╚██████╔╝██║ ╚═╝ ██║██████╔╝
 ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚═════╝ 
${NC}"

PACMAN_CLEANER_ASCII="
${YELLOW}
██████╗  █████╗  ██████╗███╗   ███╗ █████╗ ███╗   ██╗
██╔══██╗██╔══██╗██╔════╝████╗ ████║██╔══██╗████╗  ██║
██████╔╝███████║██║     ██╔████╔██║███████║██╔██╗ ██║
██╔═══╝ ██╔══██║██║     ██║╚██╔╝██║██╔══██║██║╚██╗██║
██║     ██║  ██║╚██████╗██║ ╚═╝ ██║██║  ██║██║ ╚████║
╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝
${NC}"

INITRAMFS_ASCII="
${CYAN}
██╗███╗   ██╗██╗████████╗██████╗  █████╗ ███╗   ███╗███████╗███████╗
██║████╗  ██║██║╚══██╔══╝██╔══██╗██╔══██╗████╗ ████║██╔════╝██╔════╝
██║██╔██╗ ██║██║   ██║   ██████╔╝███████║██╔████╔██║█████╗  ███████╗
██║██║╚██╗██║██║   ██║   ██╔══██╗██╔══██║██║╚██╔╝██║██╔══╝  ╚════██║
██║██║ ╚████║██║   ██║   ██║  ██║██║  ██║██║ ╚═╝ ██║██║     ███████║
╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝     ╚══════╝
${NC}"

CLEANUP_ASCII="
${RED}
 ██████╗██╗     ███████╗ █████╗ ███╗   ██╗██╗   ██╗██████╗ 
██╔════╝██║     ██╔════╝██╔══██╗████╗  ██║██║   ██║██╔══██╗
██║     ██║     █████╗  ███████║██╔██╗ ██║██║   ██║██████╔╝
██║     ██║     ██╔══╝  ██╔══██║██║╚██╗██║██║   ██║██╔═══╝ 
╚██████╗███████╗███████╗██║  ██║██║ ╚████║╚██████╔╝██║     
 ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     
${NC}"

# Check if script is run as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}Please do not run this script directly as root${NC}"
    exit 1
fi

# Request sudo privileges at the start and maintain them
echo -e "${BLUE}Requesting sudo privileges...${NC}"
sudo -v

# Keep sudo privileges alive in the background
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

# Create scripts directory if it doesn't exist
mkdir -p scripts

echo -e "${BLUE}Starting Arch Linux setup...${NC}\n"

# Function to execute a script with ASCII art
execute_script() {
    local script=$1
    local ascii_art=$2
    local description=$3
    
    echo -e "$ascii_art"
    echo -e "${BLUE}$description${NC}"
    read -p "Would you like to proceed with this setup? (y/n): " answer
    echo
    
    if [[ $answer =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}Running: $script${NC}"
        chmod +x "scripts/$script"
        if ! "./scripts/$script" --force; then
            echo -e "${RED}Error: $script failed${NC}"
            read -p "Would you like to continue with the next script? (y/n): " continue_answer
            [[ $continue_answer =~ ^[Yy]$ ]] || exit 1
        fi
        echo
    else
        echo -e "${YELLOW}Skipping: $script${NC}"
        echo
    fi
}

# Execute scripts in order with their ASCII art and descriptions
execute_script "chaotic_aur.sh" "$CHAOTIC_ASCII" "Chaotic AUR provides a large collection of pre-built AUR packages and other additions."

execute_script "alhp_setup.sh" "$ALHP_ASCII" "ALHP (Arch Linux Hardware Profile) provides optimized packages for modern processors."

execute_script "cachyos_repo.sh" "$CACHYOS_ASCII" "CachyOS Repository provides performance-oriented packages and kernel optimizations."

# Ask about package database synchronization
echo -e "${BLUE}Package Database Synchronization${NC}"
read -p "Would you like to synchronize package databases? (y/n): " sync_answer
if [[ $sync_answer =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Synchronizing package databases...${NC}"
    sudo pacman -Syy
else
    echo -e "${YELLOW}Skipping package database synchronization${NC}"
fi
echo

execute_script "makepkg_config.sh" "$MAKEPKG_ASCII" "Configure makepkg with optimized compilation flags for better performance."

execute_script "zram_setup.sh" "$ZRAM_ASCII" "Setup ZRAM for compressed swap in RAM, improving system performance and memory management."

execute_script "irqbalance_setup.sh" "$IRQ_ASCII" "Setup IRQBalance daemon to automatically distribute interrupt handling across processors for better performance."

execute_script "sqlite_service_setup.sh" "$SQLITE_ASCII" "Setup automated SQLite database optimization service to run daily, improving application performance and reducing disk usage."

execute_script "oomd_setup.sh" "$OOMD_ASCII" "Setup systemd-oomd to prevent system hangs from out-of-memory situations by intelligently managing memory usage."

execute_script "pacman_cleaner_setup.sh" "$PACMAN_CLEANER_ASCII" "Setup automated weekly pacman cache cleaning to prevent disk space wastage."

execute_script "initramfs_setup.sh" "$INITRAMFS_ASCII" "Configure initramfs with LZ4 compression for faster system boot times."

# Final step: Package installation
execute_script "packages_setup.sh" "$PACKAGES_ASCII" "Install and configure essential packages for your system."

# Cleanup step
execute_script "cleanup.sh" "$CLEANUP_ASCII" "Clean package cache and remove orphaned packages to free up disk space."

echo -e "${GREEN}Setup completed!${NC}"
