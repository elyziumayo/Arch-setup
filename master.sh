#!/bin/bash

# Exit on error
set -e

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ASCII Art Banner
echo -e "${CYAN}"
cat << "EOF"

 █████╗ ██████╗  ██████╗██╗  ██╗    ███████╗███████╗████████╗
██╔══██╗██╔══██╗██╔════╝██║  ██║    ██╔════╝██╔════╝╚══██╔══╝
███████║██████╔╝██║     ███████║    ███████╗█████╗     ██║   
██╔══██║██╔══██╗██║     ██╔══██║    ╚════██║██╔══╝     ██║   
██║  ██║██║  ██║╚██████╗██║  ██║    ███████║███████╗   ██║   
╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝    ╚══════╝╚══════╝   ╚═╝   

           🚀 SYSTEM SETUP AUTOMATION 🚀
==============================================
EOF
echo -e "${NC}"

# Check if scripts directory exists
if [ ! -d "scripts" ]; then
    echo -e "${RED}Error: 'scripts' directory not found!${NC}"
    exit 1
fi

# Check if there are any .sh files in scripts directory
if [ -z "$(ls -A scripts/*.sh 2>/dev/null)" ]; then
    echo -e "${RED}Error: No scripts found in 'scripts' directory!${NC}"
    exit 1
fi

# Get sudo privileges at the start
echo -e "\n${BLUE}Please enter your sudo password to begin the setup process.${NC}\n"
if ! sudo -v; then
    echo -e "${RED}Error: Failed to obtain sudo privileges!${NC}"
    exit 1
fi

# Keep sudo privileges active
while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
done 2>/dev/null &

# Function to set executable permissions for all scripts
set_permissions() {
    echo -e "\n${BLUE}Setting executable permissions for all scripts...${NC}\n"
    if ! sudo chmod +x scripts/*.sh; then
        echo -e "${RED}Error: Failed to set executable permissions!${NC}"
        exit 1
    fi
}

# Main execution
echo -e "\n${YELLOW}Starting Arch Linux system setup...${NC}"
echo -e "${YELLOW}-----------------------------------${NC}\n"

# Update package database first
echo -e "${CYAN}Updating package database...${NC}\n"
if ! sudo pacman -Syy; then
    echo -e "${RED}Error: Failed to update package database!${NC}"
    exit 1
fi

# Set permissions for all scripts
set_permissions

# Execute scripts in order
for script in scripts/*.sh; do
    if [ -f "$script" ]; then
        echo -e "\n${YELLOW}-----------------------------------${NC}"
        echo -e "${CYAN}Running $(basename "$script")...${NC}"
        echo -e "${YELLOW}-----------------------------------${NC}\n"
        
        if ! bash "$script"; then
            echo -e "\n${RED}✗ Error executing: $(basename "$script")${NC}"
            read -p "$(echo -e ${YELLOW}"Do you want to continue with the next script? (y/n): "${NC})" continue_choice
            if [[ ! $continue_choice =~ ^[Yy]$ ]]; then
                echo -e "\n${RED}Setup aborted by user.${NC}\n"
                exit 1
            fi
        else
            echo -e "\n${GREEN}✓ Successfully completed: $(basename "$script")${NC}"
        fi
    fi
done

echo -e "\n${YELLOW}-----------------------------------${NC}"
echo -e "${GREEN}✓ Setup completed successfully!${NC}"
echo -e "${YELLOW}-----------------------------------${NC}\n"
