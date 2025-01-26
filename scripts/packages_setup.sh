#!/bin/bash

# Array of packages to install
# Add new packages to this array
PACKAGES=(
    # System utilities
    "brightnessctl"    # Brightness control
    "waybar"          # Status bar for wayland
    "swaync"          # Notification daemon for sway
    
    # File management
    "thunar"          # File manager
    "thunar-volman"   # Thunar volume manager
    "xarchiver"       # Archive manager
    
    # Terminal
    "kitty"           # Terminal emulator
    "ttf-jetbrains-mono-nerd"   #For rofi themes
    "yay"                 #Package manager
    # Add more packages here in the format:
    # "package-name"    # Package description
)

# Function to check if a package is installed
check_package() {
    if pacman -Qi "$1" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to install packages
install_packages() {
    local packages_to_install=()
    local packages_already_installed=()

    # Check which packages need to be installed
    for package in "${PACKAGES[@]}"; do
        if ! check_package "$package"; then
            packages_to_install+=("$package")
        else
            packages_already_installed+=("$package")
        fi
    done

    # Show already installed packages
    if [ ${#packages_already_installed[@]} -gt 0 ]; then
        echo -e "\nAlready installed packages:"
        printf '%s\n' "${packages_already_installed[@]}"
    fi

    # Install missing packages
    if [ ${#packages_to_install[@]} -gt 0 ]; then
        echo -e "\nPackages to install:"
        printf '%s\n' "${packages_to_install[@]}"
        echo -e "\nInstalling missing packages..."
        sudo pacman -S --needed "${packages_to_install[@]}"
    else
        echo "All packages are already installed!"
    fi
}

# Check for force flag
FORCE=0
if [ "$1" = "--force" ]; then
    FORCE=1
fi

# Main script
echo "Package installation setup"
if [ $FORCE -eq 1 ] || { read -p "Would you like to proceed with package installation? (y/n): " answer && [[ $answer =~ ^[Yy]$ ]]; }; then
    install_packages
else
    echo "Skipping package installation."
fi 
