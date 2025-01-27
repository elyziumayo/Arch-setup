#!/bin/bash

# Exit on error
set -e

# Color definitions
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ASCII Art Banner
echo -e "${YELLOW}"
cat << "EOF"

███╗   ███╗ █████╗ ██╗  ██╗███████╗██████╗ ██╗  ██╗ ██████╗ 
████╗ ████║██╔══██╗██║ ██╔╝██╔════╝██╔══██╗██║ ██╔╝██╔════╝ 
██╔████╔██║███████║█████╔╝ █████╗  ██████╔╝█████╔╝ ██║  ███╗
██║╚██╔╝██║██╔══██║██╔═██╗ ██╔══╝  ██╔═══╝ ██╔═██╗ ██║   ██║
██║ ╚═╝ ██║██║  ██║██║  ██╗███████╗██║     ██║  ██╗╚██████╔╝
╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝  ╚═╝ ╚═════╝ 

    🚀 MAKEPKG CONFIGURATION SETUP 🚀
======================================
EOF
echo -e "${NC}"

# Function to check if makepkg.conf exists
check_makepkg_conf() {
    if [ -f ~/.makepkg.conf ]; then
        return 0
    else
        return 1
    fi
}

# Function to backup existing makepkg.conf
backup_makepkg_conf() {
    if [ -f ~/.makepkg.conf ]; then
        echo -e "${YELLOW}Creating backup of existing makepkg.conf...${NC}\n"
        local backup_file=~/.makepkg.conf.backup.$(date +%Y%m%d_%H%M%S)
        if ! cp ~/.makepkg.conf "$backup_file"; then
            echo -e "${YELLOW}Error: Failed to create backup of makepkg.conf!${NC}"
            exit 1
        fi
        echo -e "${YELLOW}Backup created at: $backup_file${NC}\n"
    fi
}

# Function to get CPU core count
get_cpu_cores() {
    nproc
}

# Main script
echo -e "\n${YELLOW}This script will optimize makepkg.conf with:${NC}"
echo -e "${YELLOW}• CPU-specific optimizations (march=native, mtune=native)${NC}"
echo -e "${YELLOW}• Enhanced security features${NC}"
echo -e "${YELLOW}• Rust optimizations${NC}"
echo -e "${YELLOW}• Parallel compilation optimizations${NC}\n"

read -p "$(echo -e ${YELLOW}"Would you like to optimize makepkg.conf? (y/n): "${NC})" choice
echo ""

if [[ $choice =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Starting makepkg.conf optimization...${NC}\n"
    
    # Backup existing configuration if it exists
    backup_makepkg_conf

    # Get CPU core count
    CORES=$(get_cpu_cores)
    echo -e "${YELLOW}Detected CPU cores: $CORES${NC}\n"

    # Create optimized makepkg.conf
    echo -e "${YELLOW}Creating optimized makepkg.conf...${NC}\n"

    cat > ~/.makepkg.conf << EOL
# Optimized compilation flags
CFLAGS="-march=native -mtune=native -O2 -pipe -fno-plt -fexceptions \\
        -Wp,-D_FORTIFY_SOURCE=3 -Wformat -Werror=format-security \\
        -fstack-clash-protection -fcf-protection"
CXXFLAGS="\$CFLAGS -Wp,-D_GLIBCXX_ASSERTIONS"
RUSTFLAGS="-C opt-level=3 -C target-cpu=native -C link-arg=-z -C link-arg=pack-relative-relocs"
MAKEFLAGS="-j\$(nproc) -l\$(nproc)"
EOL

    if [ $? -eq 0 ]; then
        echo -e "${YELLOW}Configuration file created successfully at: ~/.makepkg.conf${NC}\n"
        echo -e "${YELLOW}Current settings:${NC}"
        echo -e "${YELLOW}------------------${NC}"
        echo -e "${YELLOW}• CPU-specific optimizations enabled (march=native, mtune=native)${NC}"
        echo -e "${YELLOW}• Security features enabled (FORTIFY_SOURCE, stack protection)${NC}"
        echo -e "${YELLOW}• Rust optimizations enabled${NC}"
        echo -e "${YELLOW}• Parallel compilation enabled using $CORES cores${NC}\n"
        echo -e "${YELLOW}✓ makepkg configuration has been optimized for your system.${NC}\n"
    else
        echo -e "${YELLOW}Error: Failed to create makepkg.conf!${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}Skipping makepkg.conf optimization.${NC}\n"
    exit 0
fi 
