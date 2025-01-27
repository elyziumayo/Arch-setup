#!/bin/bash

# Exit on error
set -e

# Color definitions
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to handle errors
handle_error() {
    echo -e "${CYAN}Error: $1${NC}"
    exit 1
}

# Function to create systemd user directory
create_systemd_user_dir() {
    local dir="$HOME/.config/systemd/user"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
}

# Function to create the SQLite optimization script
create_optimize_script() {
    local script_path="$HOME/.local/bin/optimize-sqlite.sh"
    
    # Create bin directory if it doesn't exist
    mkdir -p "$HOME/.local/bin"
    
    # Create the optimization script
    cat > "$script_path" << 'EOL'
#!/bin/bash
find "$HOME" -type f -regextype posix-egrep -regex '.*\.(db|sqlite)' \
    -exec bash -c '[ "$(file -b --mime-type {})" = "application/vnd.sqlite3" ] && sqlite3 {} "VACUUM; REINDEX;"' \; 2>/dev/null
EOL
    
    # Make it executable
    chmod +x "$script_path"
    
    echo "$script_path"
}

# Function to create systemd service
create_systemd_service() {
    local script_path="$1"
    local service_path="$HOME/.config/systemd/user/sqlite-optimize.service"
    
    cat > "$service_path" << EOL
[Unit]
Description=SQLite Database Optimization
After=default.target

[Service]
Type=oneshot
ExecStart=$script_path
Nice=19
IOSchedulingClass=idle

[Install]
WantedBy=default.target
EOL
}

# ASCII Art Banner
echo -e "${CYAN}"
cat << "EOF"

███████╗ ██████╗ ██╗     ██╗████████╗███████╗
██╔════╝██╔═══██╗██║     ██║╚══██╔══╝██╔════╝
███████╗██║   ██║██║     ██║   ██║   █████╗  
╚════██║██║▄▄ ██║██║     ██║   ██║   ██╔══╝  
███████║╚██████╔╝███████╗██║   ██║   ███████╗
╚══════╝ ╚══▀▀═╝ ╚══════╝╚═╝   ╚═╝   ╚══════╝
                                              
    🗃️ SQLITE OPTIMIZATION SETUP 🗃️
====================================
EOF
echo -e "${NC}"

# Main script
echo -e "\n${CYAN}This script will set up automatic SQLite database optimization:${NC}"
echo -e "${CYAN}• Creates an optimization script${NC}"
echo -e "${CYAN}• Sets up a systemd user service${NC}"
echo -e "${CYAN}• Enables optimization at user login${NC}\n"

read -r -p $'Would you like to set up SQLite optimization? (y/n): ' answer

if [[ $answer =~ ^[Yy]$ ]]; then
    echo -e "\n${CYAN}Setting up SQLite optimization...${NC}"
    
    # Create systemd user directory
    create_systemd_user_dir
    
    # Create optimization script
    script_path=$(create_optimize_script)
    echo -e "${CYAN}Created optimization script at: $script_path${NC}"
    
    # Create systemd service
    create_systemd_service "$script_path"
    echo -e "${CYAN}Created systemd service${NC}"
    
    # Enable and start the service
    systemctl --user daemon-reload
    systemctl --user enable sqlite-optimize.service
    
    echo -e "\n${CYAN}✓ SQLite optimization has been set up!${NC}"
    echo -e "${CYAN}• The service will run at each user login${NC}"
    echo -e "${CYAN}• It will run with low priority to avoid system slowdown${NC}"
    echo -e "${CYAN}• You can manually run it with: systemctl --user start sqlite-optimize${NC}\n"
else
    echo -e "${CYAN}Skipping SQLite optimization setup.${NC}\n"
    exit 0
fi 