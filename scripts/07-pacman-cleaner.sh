#!/bin/bash

# Exit on error
set -e

# Color definitions
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# ASCII Art Banner
echo -e "${GREEN}"
cat << "EOF"

██████╗  █████╗  ██████╗███╗   ███╗ █████╗ ███╗   ██╗
██╔══██╗██╔══██╗██╔════╝████╗ ████║██╔══██╗████╗  ██║
██████╔╝███████║██║     ██╔████╔██║███████║██╔██╗ ██║
██╔═══╝ ██╔══██║██║     ██║╚██╔╝██║██╔══██║██║╚██╗██║
██║     ██║  ██║╚██████╗██║ ╚═╝ ██║██║  ██║██║ ╚████║
╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝
                                                      
    🚀 PACMAN CACHE CLEANER SETUP 🚀
=====================================
EOF
echo -e "${NC}"

# Function to check if service exists
check_service_exists() {
    if [ -f "/etc/systemd/system/pacman-cleaner.service" ]; then
        return 0
    else
        return 1
    fi
}

# Function to check if timer exists
check_timer_exists() {
    if [ -f "/etc/systemd/system/pacman-cleaner.timer" ]; then
        return 0
    else
        return 1
    fi
}

# Function to check if timer is enabled
check_timer_enabled() {
    if systemctl is-enabled --quiet pacman-cleaner.timer; then
        return 0
    else
        return 1
    fi
}

# Main script
echo -e "\n${GREEN}This script will configure automatic pacman cache cleaning:${NC}"
echo -e "${GREEN}• Creates a systemd service for cache cleaning${NC}"
echo -e "${GREEN}• Sets up a weekly timer${NC}"
echo -e "${GREEN}• Runs with 1-hour accuracy${NC}"
echo -e "${GREEN}• Automatically cleans old packages${NC}\n"

read -p "$(echo -e ${GREEN}"Would you like to setup automatic pacman cache cleaning? (y/n): "${NC})" choice
echo ""

if [[ $choice =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}Starting pacman cache cleaner setup...${NC}\n"
    
    # Create service file
    echo -e "${GREEN}Creating pacman-cleaner service...${NC}\n"
    sudo tee /etc/systemd/system/pacman-cleaner.service > /dev/null << EOL
[Unit]
Description=Cleans pacman cache

[Service]
Type=oneshot
ExecStart=/usr/bin/pacman -Scc --noconfirm

[Install]
WantedBy=multi-user.target
EOL
    
    # Create timer file
    echo -e "${GREEN}Creating pacman-cleaner timer...${NC}\n"
    sudo tee /etc/systemd/system/pacman-cleaner.timer > /dev/null << EOL
[Unit]
Description=Run clean of pacman cache every week

[Timer]
OnCalendar=weekly
AccuracySec=1h
Persistent=true

[Install]
WantedBy=timers.target
EOL
    
    # Reload systemd daemon
    echo -e "${GREEN}Reloading systemd daemon...${NC}\n"
    if ! sudo systemctl daemon-reload; then
        echo -e "${GREEN}Error: Failed to reload systemd daemon!${NC}"
        exit 1
    fi
    
    # Enable and start timer
    echo -e "${GREEN}Enabling and starting pacman-cleaner timer...${NC}\n"
    if ! sudo systemctl enable --now pacman-cleaner.timer; then
        echo -e "${GREEN}Error: Failed to enable and start pacman-cleaner timer!${NC}"
        exit 1
    fi
    
    # Verify setup
    echo -e "\n${GREEN}Verifying pacman cache cleaner setup:${NC}"
    echo -e "${GREEN}--------------------------------${NC}"
    
    if [ -f "/etc/systemd/system/pacman-cleaner.service" ]; then
        echo -e "${GREEN}• Service File: Created${NC}"
    else
        echo -e "${GREEN}• Service File: Missing (Error)${NC}"
        exit 1
    fi
    
    if [ -f "/etc/systemd/system/pacman-cleaner.timer" ]; then
        echo -e "${GREEN}• Timer File: Created${NC}"
    else
        echo -e "${GREEN}• Timer File: Missing (Error)${NC}"
        exit 1
    fi
    
    if systemctl is-enabled --quiet pacman-cleaner.timer; then
        echo -e "${GREEN}• Timer Status: Enabled${NC}"
    else
        echo -e "${GREEN}• Timer Status: Disabled (Error)${NC}"
        exit 1
    fi
    
    # Show next run time
    NEXT_RUN=$(systemctl status pacman-cleaner.timer | grep "Trigger:" | awk '{print $2, $3, $4, $5, $6}')
    if [ ! -z "$NEXT_RUN" ]; then
        echo -e "${GREEN}• Next Run: $NEXT_RUN${NC}"
    fi
    
    echo -e "\n${GREEN}✓ Pacman cache cleaner has been successfully configured.${NC}"
    echo -e "${GREEN}The cache will be automatically cleaned weekly.${NC}\n"
else
    echo -e "${GREEN}Skipping pacman cache cleaner setup.${NC}\n"
    exit 0
fi 