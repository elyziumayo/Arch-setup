#!/bin/bash

# Get the script name and location
SCRIPT_NAME=$(basename "$0")
USER_HOME=$(eval echo ~$SUDO_USER)  # Get the home directory of the user running the script
SCRIPT_DIR="$USER_HOME/scripts"  # Set the directory to ~/scripts of the current user

# Function to print banner with colors
print_banner() {
    echo -e "\033[1;34m"
    echo "========================================"
    echo -e "\033[1;32m     Welcome to $SCRIPT_NAME  "
    echo -e "\033[1;33m     Script to setup arch/artix"
    echo -e "\033[1;34m========================================"
    echo -e "\033[0m"
}

# Function to give executable permissions to all scripts in the directory
give_permissions() {
    for file in "$SCRIPT_DIR"/*.sh; do
        if [ -f "$file" ]; then
            chmod +x "$file"
            echo "Gave execute permission to: $file"
        fi
    done
}

# Check if the script is running with sudo
check_sudo() {
    if [ "$(id -u)" -ne 0 ]; then
        echo -e "\033[1;31mThis script needs to be run with sudo permission to proceed.\033[0m"
        read -p "Do you want to run the script with sudo? (y/n): " answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
            sudo "$0" "$@"  # Re-run the script with sudo
            exit 0
        else
            echo "You need sudo permission to continue. Exiting..."
            exit 1
        fi
    fi
}

# Function to run scripts one by one
run_scripts() {
    for file in "$SCRIPT_DIR"/*.sh; do
        if [ -f "$file" ]; then
            echo "Running script: $file"
            bash "$file"  # Run each script
            if [ $? -ne 0 ]; then
                echo -e "\033[1;31mError occurred while running $file. Exiting...\033[0m"
                exit 1  # Exit if any script fails
            fi
        fi
    done
}

# Main logic

# Run the check_sudo function to ensure the script is running with sudo
check_sudo "$@"

# Validate that the ~/scripts directory exists for the user
if [ ! -d "$SCRIPT_DIR" ]; then
    echo -e "\033[1;31mThe directory $SCRIPT_DIR does not exist. Exiting...\033[0m"
    exit 1
fi

# Print the banner
print_banner

# Give execute permissions to all scripts in the ~/scripts directory
give_permissions

# Run the scripts one by one
run_scripts

# End of script
echo -e "\033[1;32mAll tasks completed successfully.\033[0m"

