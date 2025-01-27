#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Function to display banner
print_banner() {
    echo -e "${MAGENTA}"
    cat << "EOF"

 █████╗ ██╗     ██╗  ██╗██████╗ 
██╔══██╗██║     ██║  ██║██╔══██╗
███████║██║     ███████║██████╔╝
██╔══██║██║     ██╔══██║██╔═══╝ 
██║  ██║███████╗██║  ██║██║     
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝     

    🚀 ALHP REPOSITORY SETUP 🚀
===================================================
EOF
echo -e "${NC}"
}

# Function to install yay
install_yay() {
    echo -e "${YELLOW}Installing yay...${NC}"
    
    # Check if running as root
    if [ "$(id -u)" -eq 0 ]; then
        echo -e "${RED}Error: yay must not be installed as root${NC}"
        exit 1
    fi
    
    # Create temp directory
    local temp_dir=$(mktemp -d)
    cd "$temp_dir" || {
        echo -e "${RED}Error: Failed to create temporary directory${NC}"
        exit 1
    }
    
    # Install dependencies
    echo -e "${MAGENTA}Installing dependencies...${NC}"
    sudo pacman -S --needed --noconfirm git base-devel || {
        echo -e "${RED}Error: Failed to install yay dependencies${NC}"
        cd - >/dev/null
        rm -rf "$temp_dir"
        exit 1
    }
    
    # Clone and build yay-bin
    echo -e "${MAGENTA}Cloning yay-bin...${NC}"
    git clone https://aur.archlinux.org/yay-bin.git || {
        echo -e "${RED}Error: Failed to clone yay-bin repository${NC}"
        cd - >/dev/null
        rm -rf "$temp_dir"
        exit 1
    }
    
    cd yay-bin || {
        echo -e "${RED}Error: Failed to enter yay-bin directory${NC}"
        cd - >/dev/null
        rm -rf "$temp_dir"
        exit 1
    }
    
    echo -e "${MAGENTA}Building and installing yay...${NC}"
    # Build package without sudo
    makepkg -s || {
        echo -e "${RED}Error: Failed to build yay-bin${NC}"
        cd - >/dev/null
        rm -rf "$temp_dir"
        exit 1
    }
    
    # Install with sudo
    sudo pacman -U --noconfirm ./*.pkg.tar.zst || {
        echo -e "${RED}Error: Failed to install yay-bin package${NC}"
        cd - >/dev/null
        rm -rf "$temp_dir"
        exit 1
    }
    
    # Cleanup
    cd - >/dev/null
    rm -rf "$temp_dir"
    echo -e "${GREEN}yay installed successfully${NC}"
}

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

    echo -e "${MAGENTA}Configuring ALHP repositories...${NC}"
    
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
    echo -e "${GREEN}ALHP repositories configured successfully${NC}"
}

# Function to install ALHP
install_alhp() {
    local cpu_version=$1
    echo -e "${MAGENTA}Installing ALHP for x86-64-$cpu_version...${NC}"

    # Check if yay is installed
    if ! command -v yay &> /dev/null; then
        echo -ne "${YELLOW}yay is not installed. Would you like to install it? [Y/n]: ${NC}"
        read -r answer
        if [[ $answer =~ ^[Yy]$ ]] || [[ -z $answer ]]; then
            install_yay
        else
            echo -e "${RED}Error: yay is required for ALHP installation${NC}"
            exit 1
        fi
    fi

    # Install ALHP keyring and mirrorlist
    echo -e "${MAGENTA}Installing ALHP packages...${NC}"
    yay -S alhp-keyring alhp-mirrorlist --noconfirm || {
        echo -e "${RED}Error: Failed to install ALHP packages${NC}"
        exit 1
    }

    # Configure pacman.conf
    configure_alhp "$cpu_version"

    # Sync package databases
    echo -e "${MAGENTA}Syncing package databases...${NC}"
    sudo pacman -Syy || {
        echo -e "${RED}Error: Failed to sync package databases${NC}"
        exit 1
    }

    echo -e "${GREEN}ALHP has been successfully configured for x86-64-$cpu_version!${NC}"
}

# Check for force flag
FORCE=0
if [ "$1" = "--force" ]; then
    FORCE=1
fi

# Main script
print_banner

if ! check_alhp; then
    echo -e "${YELLOW}ALHP is not configured on your system.${NC}"
    
    # Detect CPU version
    cpu_version=$(detect_cpu_version)
    
    if [ "$cpu_version" = "unsupported" ]; then
        echo -e "${RED}Your CPU does not support ALHP (requires at least x86-64-v3).${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Detected CPU architecture: x86-64-$cpu_version${NC}"
    echo
    echo -e "${MAGENTA}ALHP provides optimized packages for your CPU architecture.${NC}"
    echo -e "${MAGENTA}This can improve performance of your system.${NC}"
    echo
    
    if [ $FORCE -eq 1 ] || { read -p "Would you like to install ALHP? [Y/n]: " answer && [[ $answer =~ ^[Yy]$ ]] || [[ -z $answer ]]; }; then
        install_alhp "$cpu_version"
    else
        echo -e "${YELLOW}Skipping ALHP installation.${NC}"
    fi
else
    echo -e "${GREEN}ALHP is already configured on your system.${NC}"
fi
