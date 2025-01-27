#!/bin/bash

# Exit on error
set -e

# Color definitions
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to handle errors
handle_error() {
    echo -e "${YELLOW}Error: $1${NC}"
    exit 1
}

# Function to clean pacman cache
clean_pacman_cache() {
    echo -e "${YELLOW}Cleaning pacman cache...${NC}"
    
    # Remove all cached versions except the latest one
    if ! sudo paccache -r; then
        handle_error "Failed to clean pacman cache"
    fi
    
    # Remove all uninstalled package cache
    if ! sudo paccache -ruk0; then
        handle_error "Failed to remove uninstalled package cache"
    fi
}

# Function to clean user cache
clean_user_cache() {
    echo -e "${YELLOW}Cleaning user cache...${NC}"
    
    # Clean common cache directories
    rm -rf ~/.cache/thumbnails/* 2>/dev/null || true
    rm -rf ~/.cache/mozilla/firefox/*/.cache/* 2>/dev/null || true
    rm -rf ~/.cache/chromium/Default/Cache/* 2>/dev/null || true
    rm -rf ~/.cache/google-chrome/Default/Cache/* 2>/dev/null || true
    rm -rf ~/.cache/yay/* 2>/dev/null || true
}

# Function to clean journal logs
clean_journal() {
    echo -e "${YELLOW}Cleaning system journals...${NC}"
    
    # Vacuum journals older than 3 days
    if ! sudo journalctl --vacuum-time=3d; then
        handle_error "Failed to clean journal logs"
    fi
}

# Function to clean temporary files
clean_temp() {
    echo -e "${YELLOW}Cleaning temporary files...${NC}"
    
    # Clean /tmp directory
    if ! sudo rm -rf /tmp/* /var/tmp/* 2>/dev/null; then
        echo -e "${YELLOW}Note: Some temporary files could not be removed (in use)${NC}"
    fi
}

# Function to clean old config backups
clean_backups() {
    echo -e "${YELLOW}Cleaning old backup files...${NC}"
    
    # Find and remove .bak, .old, and *~ files older than 30 days
    find ~ -type f \( -name "*.bak" -o -name "*.old" -o -name "*~" \) -mtime +30 -exec rm -f {} \; 2>/dev/null || true
}

# Function to clean broken symlinks
clean_symlinks() {
    echo -e "${YELLOW}Cleaning broken symlinks in home directory...${NC}"
    
    # Find and remove broken symlinks
    find ~ -xtype l -delete 2>/dev/null || true
}

# ASCII Art Banner
echo -e "${YELLOW}"
cat << "EOF"

 ██████╗██╗     ███████╗ █████╗ ███╗   ██╗██╗   ██╗██████╗ 
██╔════╝██║     ██╔════╝██╔══██╗████╗  ██║██║   ██║██╔══██╗
██║     ██║     █████╗  ███████║██╔██╗ ██║██║   ██║██████╔╝
██║     ██║     ██╔══╝  ██╔══██║██║╚██╗██║██║   ██║██╔═══╝ 
╚██████╗███████╗███████╗██║  ██║██║ ╚████║╚██████╔╝██║     
 ╚═════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚═╝     
                                                            
    🧹 SYSTEM CLEANUP UTILITY 🧹
================================
EOF
echo -e "${NC}"

# Main script
echo -e "\n${YELLOW}This script will clean up your system.${NC}"
echo -e "${YELLOW}Select which items to clean:${NC}\n"

# Ask for each cleanup operation
read -r -p $'Clean package cache (old versions and uninstalled)? (y/n): ' clean_pkg
read -r -p $'Clean user cache (browsers, thumbnails)? (y/n): ' clean_usr
read -r -p $'Clean system journals? (y/n): ' clean_journal_ans
read -r -p $'Clean temporary files? (y/n): ' clean_tmp
read -r -p $'Clean old backups and broken symlinks? (y/n): ' clean_old
read -r -p $'Remove orphaned packages? (y/n): ' clean_orphans

# Install paccache if needed and selected package cleanup
if [[ $clean_pkg =~ ^[Yy]$ ]] && ! command -v paccache &>/dev/null; then
    echo -e "\n${YELLOW}Installing pacman-contrib for cleanup utilities...${NC}"
    sudo pacman -S --noconfirm pacman-contrib
fi

# Perform selected cleanup operations
echo -e "\n${YELLOW}Starting cleanup...${NC}"

[[ $clean_pkg =~ ^[Yy]$ ]] && clean_pacman_cache
[[ $clean_usr =~ ^[Yy]$ ]] && clean_user_cache
[[ $clean_journal_ans =~ ^[Yy]$ ]] && clean_journal
[[ $clean_tmp =~ ^[Yy]$ ]] && clean_temp
[[ $clean_old =~ ^[Yy]$ ]] && {
    clean_backups
    clean_symlinks
}
[[ $clean_orphans =~ ^[Yy]$ ]] && {
    echo -e "${YELLOW}Checking for orphaned packages...${NC}"
    if orphans=$(pacman -Qtdq 2>/dev/null) && [ -n "$orphans" ]; then
        echo -e "${YELLOW}Found orphaned packages. Removing...${NC}"
        sudo pacman -Rns $orphans --noconfirm || handle_error "Failed to remove orphaned packages"
        echo -e "${YELLOW}✓ Orphaned packages removed${NC}"
    else
        echo -e "${YELLOW}No orphaned packages found${NC}"
    fi
}

# Show completion message
echo -e "\n${YELLOW}✓ System cleanup completed!${NC}"
[[ $clean_pkg =~ ^[Yy]$ ]] && echo -e "${YELLOW}• Package cache has been cleaned${NC}"
[[ $clean_usr =~ ^[Yy]$ ]] && echo -e "${YELLOW}• User cache has been cleaned${NC}"
[[ $clean_journal_ans =~ ^[Yy]$ ]] && echo -e "${YELLOW}• System journals have been vacuumed${NC}"
[[ $clean_tmp =~ ^[Yy]$ ]] && echo -e "${YELLOW}• Temporary files have been removed${NC}"
[[ $clean_old =~ ^[Yy]$ ]] && echo -e "${YELLOW}• Old backups and broken symlinks have been cleaned${NC}"
[[ $clean_orphans =~ ^[Yy]$ ]] && echo -e "${YELLOW}• Orphaned packages have been removed${NC}"
echo -e "\n" 