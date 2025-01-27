#!/bin/bash

# Exit on error
set -e

# Color definitions
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ASCII Art Banner
echo -e "${YELLOW}"
cat << "EOF"

 ██████╗  ██████╗ ███╗   ███╗██████╗ 
██╔═══██╗██╔═══██╗████╗ ████║██╔══██╗
██║   ██║██║   ██║██╔████╔██║██║  ██║
██║   ██║██║   ██║██║╚██╔╝██║██║  ██║
╚██████╔╝╚██████╔╝██║ ╚═╝ ██║██████╔╝
 ╚═════╝  ╚═════╝ ╚═╝     ╚═╝╚═════╝ 

    🚀 OOMD CONFIGURATION SETUP 🚀
===================================
EOF
echo -e "${NC}"

# Function to check if systemd-oomd is available
check_oomd_available() {
    if systemctl list-unit-files systemd-oomd.service &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to check if systemd-oomd is already running
check_oomd_running() {
    if systemctl is-active --quiet systemd-oomd.service; then
        return 0
    else
        return 1
    fi
}

# Function to check if systemd-oomd is enabled
check_oomd_enabled() {
    if systemctl is-enabled --quiet systemd-oomd.service; then
        return 0
    else
        return 1
    fi
}

# Main script
echo -e "\n${YELLOW}This script will configure systemd-oomd (Out-Of-Memory Daemon):${NC}"
echo -e "${YELLOW}• Enables systemd's built-in OOM killer${NC}"
echo -e "${YELLOW}• Provides faster reaction to memory exhaustion${NC}"
echo -e "${YELLOW}• Uses efficient PSI-based monitoring${NC}"
echo -e "${YELLOW}• Prevents system hangs due to memory pressure${NC}\n"

read -p "$(echo -e ${YELLOW}"Would you like to configure systemd-oomd? (y/n): "${NC})" choice
echo ""

if [[ $choice =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Starting systemd-oomd configuration...${NC}\n"
    
    # Check if systemd-oomd is available
    if ! check_oomd_available; then
        echo -e "${YELLOW}Error: systemd-oomd service is not available on your system!${NC}"
        exit 1
    fi
    
    # Check current status
    if check_oomd_running; then
        echo -e "${YELLOW}systemd-oomd is already running.${NC}"
    fi
    
    if check_oomd_enabled; then
        echo -e "${YELLOW}systemd-oomd is already enabled.${NC}"
    fi
    
    # Enable and start systemd-oomd
    echo -e "\n${YELLOW}Enabling and starting systemd-oomd...${NC}\n"
    if ! sudo systemctl enable --now systemd-oomd.service; then
        echo -e "${YELLOW}Error: Failed to enable and start systemd-oomd!${NC}"
        exit 1
    fi
    
    # Verify service status
    echo -e "\n${YELLOW}Verifying systemd-oomd status:${NC}"
    echo -e "${YELLOW}---------------------------${NC}"
    
    if systemctl is-active --quiet systemd-oomd.service; then
        echo -e "${YELLOW}• Service Status: Active${NC}"
    else
        echo -e "${YELLOW}• Service Status: Inactive (Error)${NC}"
        exit 1
    fi
    
    if systemctl is-enabled --quiet systemd-oomd.service; then
        echo -e "${YELLOW}• Boot Status: Enabled${NC}"
    else
        echo -e "${YELLOW}• Boot Status: Disabled (Error)${NC}"
        exit 1
    fi
    
    # Show memory pressure monitoring status
    if [ -f /proc/pressure/memory ]; then
        echo -e "${YELLOW}• PSI Memory Monitoring: Available${NC}"
    else
        echo -e "${YELLOW}• PSI Memory Monitoring: Not Available (Warning)${NC}"
    fi
    
    echo -e "\n${YELLOW}✓ systemd-oomd has been successfully configured and activated.${NC}"
    echo -e "${YELLOW}The service will automatically manage memory pressure and prevent system hangs.${NC}\n"
else
    echo -e "${YELLOW}Skipping systemd-oomd configuration.${NC}\n"
    exit 0
fi 