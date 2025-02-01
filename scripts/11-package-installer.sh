#!/bin/bash

# Exit on error
set -e

# Color definitions
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Package Lists by category
DEVELOPMENT_PKGS=(
    "git"           # Version control system
    "base-devel"    # Development tools
)

SYSTEM_PKGS=(
    "fastfetch"     # System information
    "kitty"         # Terminal emulator
    "waybar"
    "swaync"
    "rofi-wayland"
    "otf-font-awesome"
    "ttf-jetbrains-mono-nerd"
    "brightnessctl"
    "oh-my-posh"
    "zsh"
    "fzf"
    "zoxide"
    "eza"
    
)

FILE_MANAGER_PKGS=(
    "thunar"        # File manager
    "thunar-volman" # Volume manager for Thunar
)

# Function to handle errors
handle_error() {
    echo -e "${GREEN}Error: $1${NC}"
    exit 1
}

# Function to check if a package is installed
check_package() {
    pacman -Qi "$1" &> /dev/null
}

# Function to install packages from array
install_package_group() {
    local -n pkg_array=$1  # Use nameref for array
    local to_install=()
    
    # Check which packages need to be installed
    for pkg in "${pkg_array[@]}"; do
        if ! check_package "$pkg"; then
            to_install+=("$pkg")
        fi
    done
    
    # If no packages need to be installed
    if [ ${#to_install[@]} -eq 0 ]; then
        echo -e "${GREEN}All packages in this group are already installed!${NC}"
        return 0
    fi
    
    # Install missing packages
    echo -e "${GREEN}Installing packages: ${to_install[*]}${NC}\n"
    if ! sudo pacman -S --needed --noconfirm "${to_install[@]}"; then
        handle_error "Failed to install packages"
    fi
}

# Function to list packages in a group
list_package_group() {
    local -n pkg_array=$1  # Use nameref for array
    for pkg in "${pkg_array[@]}"; do
        if check_package "$pkg"; then
            echo -e "${GREEN}✓ $pkg${NC}"
        else
            echo -e "${GREEN}• $pkg${NC}"
        fi
    done
}

# ASCII Art Banner
echo -e "${GREEN}"
cat << "EOF"

██████╗  █████╗  ██████╗██╗  ██╗ █████╗  ██████╗ ███████╗███████╗
██╔══██╗██╔══██╗██╔════╝██║ ██╔╝██╔══██╗██╔════╝ ██╔════╝██╔════╝
██████╔╝███████║██║     █████╔╝ ███████║██║  ███╗█████╗  ███████╗
██╔═══╝ ██╔══██║██║     ██╔═██╗ ██╔══██║██║   ██║██╔══╝  ╚════██║
██║     ██║  ██║╚██████╗██║  ██╗██║  ██║╚██████╔╝███████╗███████║
╚═╝     ╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝
                                                                   
    📦 PACKAGE INSTALLER 📦
===========================
EOF
echo -e "${NC}"

# Main script
echo -e "\n${GREEN}This script will help you install commonly used packages.${NC}"
echo -e "${GREEN}You can choose which groups of packages to install:${NC}\n"

# Development Tools
echo -e "${GREEN}Development Tools:${NC}"
list_package_group DEVELOPMENT_PKGS
read -r -p $'Install development tools? (y/n): ' install_dev
echo ""

# System Utilities
echo -e "${GREEN}System Utilities:${NC}"
list_package_group SYSTEM_PKGS
read -r -p $'Install system utilities? (y/n): ' install_sys
echo ""

# File Manager
echo -e "${GREEN}File Manager:${NC}"
list_package_group FILE_MANAGER_PKGS
read -r -p $'Install file manager? (y/n): ' install_fm
echo ""

# Install selected package groups
echo -e "\n${GREEN}Installing selected packages...${NC}\n"

[[ $install_dev =~ ^[Yy]$ ]] && {
    echo -e "${GREEN}Installing development tools...${NC}"
    install_package_group DEVELOPMENT_PKGS
}

[[ $install_sys =~ ^[Yy]$ ]] && {
    echo -e "${GREEN}Installing system utilities...${NC}"
    install_package_group SYSTEM_PKGS
}

[[ $install_fm =~ ^[Yy]$ ]] && {
    echo -e "${GREEN}Installing file manager...${NC}"
    install_package_group FILE_MANAGER_PKGS
}

echo -e "\n${GREEN}✓ Package installation completed!${NC}"
echo -e "${GREEN}• To add more packages, edit the package arrays in this script${NC}\n" 
