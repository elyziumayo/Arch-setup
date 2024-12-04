#!/bin/bash

# Check if the script is being run with sudo
if [[ $(id -u) -ne 0 ]]; then
    echo -e "\033[1;31mThis script needs to be run with sudo. Re-running it with sudo...\033[0m"
    exec sudo "$0" "$@"
    exit 0
fi

# Define some color variables for output
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RESET='\033[0m'

# ASCII Art for Success and Failure
ASCII_SUCCESS="  _____   _____   _____
 |  __ \ / ____| |  __ \ 
 | |__) | (___   | |__) | 
 |  ___/ \___ \  |  _  /  
 | |     ____) | | | \ \ 
 |_|    |_____/  |_|  \_\ "

ASCII_FAILURE="  _______   ____   ____   _____
 | ____| \ | __ \  | ____|
 | |__   | |__) | | |__   
 |___ \  |  _  /  |___ \  
 ___) | | | \ \   ___) | 
 |____/  |_|  \_\ |____/ "

# Package list (This can be read from a file or provided directly)
packages=("wayland" "thunar" "gvfs" "kity" "rofi-wayland" "ttf-jetbrains" "otf-font-awesome" "waybar" "btop" "nwg-look" "hyprland" "hyprpaper")

# Function to install a package
install_package() {
    local package=$1
    echo -e "${CYAN}Checking if $package is installed...${RESET}"
    
    # Check if the package is already installed
    if pacman -Qi "$package" &> /dev/null; then
        echo -e "${GREEN}$package is already installed.${RESET}"
    else
        echo -e "${YELLOW}$package is not installed.${RESET}"
        
        # Ask user for confirmation before installation
        read -p "Do you want to install $package? (y/n): " confirm
        if [[ "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Installing $package...${RESET}"
            pacman -S --noconfirm "$package"
            
            # Check if installation was successful
            if [[ $? -ne 0 ]]; then
                echo -e "${RED}Error: Failed to install $package. Exiting.${RESET}"
                echo -e "$ASCII_FAILURE"
                exit 1
            else
                echo -e "${GREEN}$package installed successfully.${RESET}"
                echo -e "$ASCII_SUCCESS"
            fi
        else
            echo -e "${YELLOW}Skipping $package.${RESET}"
        fi
    fi
}

# Main script execution
echo -e "${CYAN}Welcome to the interactive package installer!${RESET}"

# Loop through each package in the list
for package in "${packages[@]}"; do
    install_package "$package"
done

echo -e "${GREEN}All specified packages have been processed successfully.${RESET}"

