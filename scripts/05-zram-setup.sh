#!/bin/bash

# Exit on error
set -e

# Color definitions
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ASCII Art Banner
echo -e "${BLUE}"
cat << "EOF"

███████╗██████╗  █████╗ ███╗   ███╗
╚══███╔╝██╔══██╗██╔══██╗████╗ ████║
  ███╔╝ ██████╔╝███████║██╔████╔██║
 ███╔╝  ██╔══██╗██╔══██║██║╚██╔╝██║
███████╗██║  ██║██║  ██║██║ ╚═╝ ██║
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝

    🚀 ZRAM CONFIGURATION SETUP 🚀
===================================
EOF
echo -e "${NC}"

# Function to check if zram-generator is installed
check_zram_installed() {
    if pacman -Qi zram-generator &>/dev/null; then
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

# Function to get total RAM
get_total_ram() {
    free -h | awk '/^Mem:/ {print $2}'
}

# Main script
echo -e "\n${BLUE}This script will configure ZRAM for optimized memory compression:${NC}"
echo -e "${BLUE}• Installs zram-generator${NC}"
echo -e "${BLUE}• Configures ZRAM size equal to RAM${NC}"
echo -e "${BLUE}• Uses zstd compression algorithm${NC}"
echo -e "${BLUE}• Sets up systemd service${NC}\n"

read -p "$(echo -e ${BLUE}"Would you like to configure ZRAM? (y/n): "${NC})" choice
echo ""

if [[ $choice =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}Starting ZRAM configuration...${NC}\n"
    
    # Check and install zram-generator if not present
    if ! check_zram_installed; then
        echo -e "${BLUE}Installing zram-generator...${NC}\n"
        if ! sudo pacman -S --noconfirm zram-generator; then
            echo -e "${BLUE}Error: Failed to install zram-generator!${NC}"
            exit 1
        fi
    else
        echo -e "${BLUE}zram-generator is already installed.${NC}\n"
    fi
    
    # Get total RAM
    TOTAL_RAM=$(get_total_ram)
    echo -e "${BLUE}Detected total RAM: $TOTAL_RAM${NC}\n"
    
    # Create zram configuration
    echo -e "${BLUE}Creating ZRAM configuration...${NC}\n"
    
    # Backup existing config if it exists
    if check_zram_config; then
        echo -e "${BLUE}Backing up existing ZRAM configuration...${NC}\n"
        sudo cp /etc/systemd/zram-generator.conf "/etc/systemd/zram-generator.conf.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Create new config
    sudo tee /etc/systemd/zram-generator.conf > /dev/null << EOL
[zram0]
zram-size = ram
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOL
    
    if [ $? -eq 0 ]; then
        echo -e "${BLUE}ZRAM configuration created successfully.${NC}\n"
        
        # Reload systemd and start service
        echo -e "${BLUE}Reloading systemd daemon...${NC}\n"
        if ! sudo systemctl daemon-reload; then
            echo -e "${BLUE}Error: Failed to reload systemd daemon!${NC}"
            exit 1
        fi
        
        echo -e "${BLUE}Starting ZRAM service...${NC}\n"
        if ! sudo systemctl start systemd-zram-setup@zram0.service; then
            echo -e "${BLUE}Error: Failed to start ZRAM service!${NC}"
            exit 1
        fi
        
        # Verify ZRAM is working
        echo -e "${BLUE}Verifying ZRAM setup...${NC}\n"
        if ! swapon --show | grep -q '/dev/zram0'; then
            echo -e "${BLUE}Error: ZRAM device is not active!${NC}"
            exit 1
        fi
        
        # Get ZRAM stats
        ZRAM_SIZE=$(swapon --bytes --noheadings | grep zram0 | awk '{print $3}')
        ZRAM_SIZE_HUMAN=$(numfmt --to=iec-i --suffix=B $ZRAM_SIZE)
        
        echo -e "${BLUE}Current ZRAM status:${NC}"
        echo -e "${BLUE}------------------${NC}"
        echo -e "${BLUE}• ZRAM size: $ZRAM_SIZE_HUMAN (Equal to RAM)${NC}"
        echo -e "${BLUE}• Compression algorithm: zstd${NC}"
        echo -e "${BLUE}• Swap priority: 100${NC}"
        echo -e "${BLUE}• Service status: Active and verified${NC}\n"
        echo -e "${BLUE}✓ ZRAM has been successfully configured and activated.${NC}\n"
        echo -e "${BLUE}Note: ZRAM will be automatically managed by systemd on boot.${NC}\n"
    else
        echo -e "${BLUE}Error: Failed to create ZRAM configuration!${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}Skipping ZRAM configuration.${NC}\n"
    exit 0
fi 
