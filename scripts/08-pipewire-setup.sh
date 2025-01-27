#!/bin/bash

# Exit on error
set -e

# Color definitions
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Function to handle errors
handle_error() {
    echo -e "${MAGENTA}Error: $1${NC}"
    exit 1
}

# Function to backup a file
backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        if ! cp "$file" "$backup"; then
            handle_error "Failed to create backup of $file"
        fi
        echo -e "${MAGENTA}Created backup: $backup${NC}"
    fi
}

# ASCII Art Banner
echo -e "${MAGENTA}"
cat << "EOF"

██████╗ ██╗██████╗ ███████╗██╗    ██╗██╗██████╗ ███████╗
██╔══██╗██║██╔══██╗██╔════╝██║    ██║██║██╔══██╗██╔════╝
██████╔╝██║██████╔╝█████╗  ██║ █╗ ██║██║██████╔╝█████╗  
██╔═══╝ ██║██╔═══╝ ██╔══╝  ██║███╗██║██║██╔══██╗██╔══╝  
██║     ██║██║     ███████╗╚███╔███╔╝██║██║  ██║███████╗
╚═╝     ╚═╝╚═╝     ╚══════╝ ╚══╝╚══╝ ╚═╝╚═╝  ╚═╝╚══════╝
                                                         
    🚀 PIPEWIRE CONFIGURATION SETUP 🚀
=====================================
EOF
echo -e "${NC}"

# Function to check if a package is installed
check_package() {
    if pacman -Qi "$1" &>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Function to detect sound card rates
detect_sound_rates() {
    local rates=""
    # Try multiple possible sound card paths
    for card in {0..5}; do
        if [ -f "/proc/asound/card${card}/codec#0" ]; then
            rates=$(cat "/proc/asound/card${card}/codec#0" | grep -A 8 "Audio Output" -m 1 | grep rates)
            if [ ! -z "$rates" ]; then
                break
            fi
        fi
    done
    
    # Fallback to safe default rates if detection fails
    if [ -z "$rates" ]; then
        echo "44100 48000"
    else
        echo "$rates" | tr -d '[:alpha:]' | tr -d ':' | tr -s ' '
    fi
}

# Function to create directory if it doesn't exist
create_dir_if_missing() {
    local dir=$1
    if [ ! -d "$dir" ]; then
        if ! mkdir -p "$dir"; then
            handle_error "Failed to create directory: $dir"
        fi
        echo -e "${MAGENTA}Created directory: $dir${NC}"
    fi
}

# Function to check and setup realtime privileges
setup_realtime_privileges() {
    if ! check_package "realtime-privileges"; then
        echo -e "${MAGENTA}Installing realtime-privileges package...${NC}\n"
        if ! sudo pacman -S --noconfirm realtime-privileges; then
            return 1
        fi
    fi
    
    if ! groups "$USER" | grep -q "realtime"; then
        echo -e "${MAGENTA}Adding user to realtime group...${NC}\n"
        if ! sudo gpasswd -a "$USER" realtime; then
            return 1
        fi
        echo -e "${MAGENTA}Note: You will need to log out and log back in for the group changes to take effect.${NC}\n"
    fi
    return 0
}

# Function to verify PipeWire service status
verify_service_status() {
    local service=$1
    if ! systemctl --user is-active --quiet "$service"; then
        echo -e "${MAGENTA}Warning: $service is not active. Attempting to start...${NC}"
        if ! systemctl --user start "$service"; then
            handle_error "Failed to start $service"
        fi
        sleep 2  # Wait for service to stabilize
    fi
}

# Main script
echo -e "\n${MAGENTA}This script will configure PipeWire for optimal audio performance:${NC}"
echo -e "${MAGENTA}• Installs PipeWire and required components${NC}"
echo -e "${MAGENTA}• Sets up realtime privileges${NC}"
echo -e "${MAGENTA}• Sets up optimal sampling rates${NC}"
echo -e "${MAGENTA}• Configures buffer sizes to prevent audio glitches${NC}"
echo -e "${MAGENTA}• Enables 5.1 stereo upmixing${NC}"
echo -e "${MAGENTA}• Creates custom configuration files${NC}\n"

read -p "$(echo -e ${MAGENTA}"Would you like to configure PipeWire? (y/n): "${NC})" choice
echo ""

if [[ $choice =~ ^[Yy]$ ]]; then
    echo -e "${MAGENTA}Starting PipeWire configuration...${NC}\n"
    
    # Check and install required packages
    echo -e "${MAGENTA}Checking required packages...${NC}\n"
    PACKAGES=("pipewire" "pipewire-pulse" "pipewire-jack" "lib32-pipewire" "gst-plugin-pipewire" "wireplumber")
    MISSING_PACKAGES=()
    
    for pkg in "${PACKAGES[@]}"; do
        if ! check_package "$pkg"; then
            MISSING_PACKAGES+=("$pkg")
        fi
    done
    
    if [ ${#MISSING_PACKAGES[@]} -gt 0 ]; then
        echo -e "${MAGENTA}Installing missing packages: ${MISSING_PACKAGES[*]}${NC}\n"
        if ! sudo pacman -S --noconfirm "${MISSING_PACKAGES[@]}"; then
            handle_error "Failed to install required packages"
        fi
        
        # Verify package installation
        for pkg in "${MISSING_PACKAGES[@]}"; do
            if ! check_package "$pkg"; then
                handle_error "Package $pkg was not installed correctly"
            fi
        done
    fi
    
    # Setup realtime privileges
    if ! setup_realtime_privileges; then
        echo -e "${MAGENTA}Warning: Failed to setup realtime privileges. Audio performance may be affected.${NC}\n"
    fi
    
    # Create necessary directories
    echo -e "${MAGENTA}Creating configuration directories...${NC}\n"
    create_dir_if_missing ~/.config/pipewire/pipewire.conf.d
    create_dir_if_missing ~/.config/pipewire/pipewire-pulse.conf.d
    create_dir_if_missing ~/.config/pipewire/client-rt.conf.d
    
    # Backup existing configurations
    echo -e "${MAGENTA}Backing up existing configurations...${NC}\n"
    backup_file ~/.config/pipewire/pipewire.conf.d/10-sound.conf
    backup_file ~/.config/pipewire/pipewire-pulse.conf.d/20-upmix.conf
    backup_file ~/.config/pipewire/client-rt.conf.d/20-upmix.conf
    
    # Detect sound card rates
    echo -e "${MAGENTA}Detecting supported sample rates...${NC}\n"
    RATES=$(detect_sound_rates)
    echo -e "${MAGENTA}Detected rates: $RATES${NC}\n"
    
    # Create sound configuration
    echo -e "${MAGENTA}Creating sound configuration...${NC}\n"
    cat > ~/.config/pipewire/pipewire.conf.d/10-sound.conf << EOL
context.properties = {
    default.clock.rate = 48000
    default.clock.allowed-rates = [ 44100 48000 88200 96000 ]
    default.clock.min-quantum = 512
    default.clock.quantum = 4096
    default.clock.max-quantum = 8192
}
EOL
    
    # Enable 5.1 upmixing
    echo -e "${MAGENTA}Enabling 5.1 stereo upmixing...${NC}\n"
    if [ -f "/usr/share/pipewire/client-rt.conf.avail/20-upmix.conf" ]; then
        cp /usr/share/pipewire/client-rt.conf.avail/20-upmix.conf ~/.config/pipewire/pipewire-pulse.conf.d/
        cp /usr/share/pipewire/client-rt.conf.avail/20-upmix.conf ~/.config/pipewire/client-rt.conf.d/
    else
        echo -e "${MAGENTA}Warning: Upmixing configuration file not found. Skipping.${NC}\n"
    fi
    
    # Enable and start PipeWire services
    echo -e "${MAGENTA}Enabling PipeWire services...${NC}\n"
    systemctl --user enable pipewire pipewire-pulse wireplumber || handle_error "Failed to enable PipeWire services"
    
    # Restart PipeWire services
    echo -e "${MAGENTA}Restarting PipeWire services...${NC}\n"
    systemctl --user restart pipewire.service || handle_error "Failed to restart pipewire.service"
    sleep 1
    systemctl --user restart pipewire-pulse.service || handle_error "Failed to restart pipewire-pulse.service"
    sleep 1
    systemctl --user restart wireplumber.service || handle_error "Failed to restart wireplumber.service"
    
    # Verify all services are running
    echo -e "${MAGENTA}Verifying services...${NC}\n"
    verify_service_status "pipewire.service"
    verify_service_status "pipewire-pulse.service"
    verify_service_status "wireplumber.service"
    
    # Final verification
    echo -e "\n${MAGENTA}Verifying PipeWire configuration:${NC}"
    echo -e "${MAGENTA}--------------------------------${NC}"
    
    if [ -f ~/.config/pipewire/pipewire.conf.d/10-sound.conf ]; then
        echo -e "${MAGENTA}• Sound Configuration: Created${NC}"
    else
        handle_error "Sound configuration file is missing"
    fi
    
    if [ -f ~/.config/pipewire/pipewire-pulse.conf.d/20-upmix.conf ]; then
        echo -e "${MAGENTA}• Upmixing Configuration: Enabled${NC}"
    else
        echo -e "${MAGENTA}• Upmixing Configuration: Not Available${NC}"
    fi
    
    if systemctl --user is-active --quiet pipewire.service; then
        echo -e "${MAGENTA}• PipeWire Service: Active${NC}"
    else
        handle_error "PipeWire service is not active"
    fi
    
    if groups "$USER" | grep -q "realtime"; then
        echo -e "${MAGENTA}• Realtime Privileges: Configured${NC}"
    else
        echo -e "${MAGENTA}• Realtime Privileges: Pending (Requires logout)${NC}"
    fi
    
    # Test audio system
    echo -e "\n${MAGENTA}Testing audio system...${NC}"
    if ! pactl info >/dev/null 2>&1; then
        echo -e "${MAGENTA}Warning: PulseAudio interface is not responding. You may need to restart your session.${NC}"
    else
        echo -e "${MAGENTA}• Audio system test: Passed${NC}"
    fi
    
    echo -e "\n${MAGENTA}Current PipeWire settings:${NC}"
    echo -e "${MAGENTA}• Default Sample Rate: 48000 Hz${NC}"
    echo -e "${MAGENTA}• Allowed Sample Rates: $RATES${NC}"
    echo -e "${MAGENTA}• Buffer Size: 4096${NC}"
    
    echo -e "\n${MAGENTA}✓ PipeWire has been successfully configured.${NC}"
    echo -e "${MAGENTA}Note: You may need to log out and log back in for realtime privileges to take effect.${NC}"
    echo -e "${MAGENTA}Note: You may need to restart your applications to apply the new audio settings.${NC}"
    echo -e "${MAGENTA}Note: If you experience any issues, your original configuration has been backed up.${NC}\n"
else
    echo -e "${MAGENTA}Skipping PipeWire configuration.${NC}\n"
    exit 0
fi 