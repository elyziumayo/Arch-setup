#!/bin/bash

# Ensure the script is being run with superuser privileges
if [[ $(id -u) -ne 0 ]]; then
    echo "Please run this script as root using 'sudo'."
    exit 1
fi

# Define the script file path and service file path
SCRIPT_PATH="/usr/local/bin/vacuum_reindex.sh"
SERVICE_PATH="/etc/systemd/system/vacuum_reindex.service"

# Function to check if CachyOS repository is installed
is_cachyos_repo_installed() {
    # Check if the CachyOS repository is present in pacman configuration
    grep -q "CachyOS" /etc/pacman.conf
}

# Function to ask the user for input when replacing files or directories
ask_user() {
    local prompt="$1"
    local choice
    read -p "$prompt (y/n): " choice
    case "$choice" in
        [Yy]*) return 0 ;;  # User chose 'yes'
        [Nn]*) return 1 ;;  # User chose 'no'
        *) echo "Invalid option. Defaulting to no."; return 1 ;;  # Default to no
    esac
}

# Function to display ASCII Art for Section Headers
show_ascii_art() {
    local header="$1"
    echo -e "\033[1m"
    echo "======================================"
    echo "  $header"
    echo "======================================"
    echo -e "\033[0m"
}

# Step 1: Setup CachyOS Repository
show_ascii_art "CachyOS Repository Setup"

echo -e "\033[1mChecking CachyOS repository...\033[0m"

if is_cachyos_repo_installed; then
    echo -e "\033[1mCachyOS repository is already installed.\033[0m"
else
    ask_user "Do you want to install the CachyOS repository?"
    if [[ $? -eq 0 ]]; then
        echo -e "\033[1mInstalling CachyOS repository...\033[0m"
        # Download CachyOS repository tarball and extract it
        curl -O https://mirror.cachyos.org/cachyos-repo.tar.xz
        tar xvf cachyos-repo.tar.xz && cd cachyos-repo
        
        # Run the installation script for CachyOS repo
        sudo ./cachyos-repo.sh

        # Confirm successful installation
        if is_cachyos_repo_installed; then
            echo -e "\033[1mCachyOS repository installed successfully!\033[0m"
        else
            echo -e "\033[1mFailed to install CachyOS repository. Please check for errors.\033[0m"
        fi
    else
        echo -e "\033[1mSkipping CachyOS repository installation.\033[0m"
    fi
fi

# Step 2: Setup Chaotic AUR
show_ascii_art "Chaotic AUR Setup"

# Add Chaotic AUR key and mirrorlist
echo -e "\033[1mChecking and setting up Chaotic AUR...\033[0m"
if ! is_package_installed "chaotic-keyring"; then
    ask_install_package "Chaotic AUR keyring and mirrorlist"
    if [[ $? -eq 0 ]]; then
        echo -e "\033[1mInstalling Chaotic AUR keyring and mirrorlist...\033[0m"
        pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
        pacman-key --lsign-key 3056513887B78AEB
        pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
        pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'
    else
        echo -e "\033[1mSkipping Chaotic AUR keyring and mirrorlist installation.\033[0m"
    fi
else
    echo -e "\033[1mChaotic AUR keyring and mirrorlist are already installed.\033[0m"
fi

# Step 3: Setup PipeWire, ALSA, and Real-Time Privileges
show_ascii_art "PipeWire, ALSA, and Real-Time Privileges Setup"

echo -e "\033[1mInstalling PipeWire, ALSA, and related packages...\033[0m"
if ! is_package_installed "pipewire"; then
    ask_install_package "PipeWire and related packages"
    if [[ $? -eq 0 ]]; then
        pacman -S --noconfirm pipewire pipewire-pulse pipewire-jack lib32-pipewire gst-plugin-pipewire wireplumber
    else
        echo -e "\033[1mSkipping PipeWire installation.\033[0m"
    fi
else
    echo -e "\033[1mPipeWire and related packages are already installed.\033[0m"
fi

# Install realtime-privileges if not installed
if ! is_package_installed "realtime-privileges"; then
    ask_install_package "Realtime privileges (realtime-privileges and rtkit)"
    if [[ $? -eq 0 ]]; then
        pacman -S --noconfirm realtime-privileges rtkit
    else
        echo -e "\033[1mSkipping realtime-privileges installation.\033[0m"
    fi
else
    echo -e "\033[1mRealtime privileges are already installed.\033[0m"
fi

# Add user to the realtime group
if ! groups "$USER" | grep -q "\brealtime\b"; then
    ask_user "Add $USER to 'realtime' group?"
    if [[ $? -eq 0 ]]; then
        usermod -aG realtime "$USER"
        echo -e "\033[1m$USER added to 'realtime' group.\033[0m"
    else
        echo -e "\033[1mSkipping adding $USER to 'realtime' group.\033[0m"
    fi
else
    echo -e "\033[1m$USER is already in the 'realtime' group.\033[0m"
fi

# Step 4: Configure PipeWire
show_ascii_art "PipeWire Configuration"

echo -e "\033[1mConfiguring PipeWire...\033[0m"

# Create PipeWire configuration directories
config_dir="$HOME/.config/pipewire"
pipewire_pulse_dir="$config_dir/pipewire-pulse.conf.d"
client_rt_dir="$config_dir/client-rt.conf.d"
pipewire_conf_dir="$config_dir/pipewire.conf.d"

# Ensure necessary directories are created
mkdir -p "$pipewire_pulse_dir" "$client_rt_dir" "$pipewire_conf_dir"

# Copy 20-upmix.conf if it does not exist
if [[ ! -f "$pipewire_pulse_dir/20-upmix.conf" ]]; then
    ask_user "Copy 20-upmix.conf to PipeWire Pulse directory?"
    if [[ $? -eq 0 ]]; then
        echo -e "\033[1mCopying 20-upmix.conf to PipeWire Pulse directory...\033[0m"
        cp /usr/share/pipewire/client-rt.conf.avail/20-upmix.conf "$pipewire_pulse_dir/"
        cp /usr/share/pipewire/client-rt.conf.avail/20-upmix.conf "$client_rt_dir/"
    else
        echo -e "\033[1mSkipping copy of 20-upmix.conf.\033[0m"
    fi
else
    ask_user "20-upmix.conf already exists. Do you want to replace it?"
    if [[ $? -eq 0 ]]; then
        echo -e "\033[1mReplacing 20-upmix.conf...\033[0m"
        cp /usr/share/pipewire/client-rt.conf.avail/20-upmix.conf "$pipewire_pulse_dir/"
        cp /usr/share/pipewire/client-rt.conf.avail/20-upmix.conf "$client_rt_dir/"
    else
        echo -e "\033[1mSkipping replacement of 20-upmix.conf.\033[0m"
    fi
fi

# Create 10-sound.conf for PipeWire
sound_config="$pipewire_conf_dir/10-sound.conf"
if [[ ! -f "$sound_config" ]]; then
    ask_user "Create PipeWire sound configuration file?"
    if [[ $? -eq 0 ]]; then
        echo -e "\033[1mCreating PipeWire sound configuration file...\033[0m"
        cat <<EOL > "$sound_config"
# PipeWire Sound Configuration
context.properties = {
   default.clock.rate = 48000
   default.clock.allowed-rates = [ 44100 48000 88200 96000 ]
   default.clock.min-quantum = 2048
}
EOL
    else
        echo -e "\033[1mSkipping PipeWire sound configuration file creation.\033[0m"
    fi
else
    echo -e "\033[1mPipeWire sound configuration file already exists.\033[0m"
fi

# Step 5: Vacuum and Reindex SQLite Databases (Optional)
show_ascii_art "Vacuum and Reindex SQLite Databases"

ask_user "Do you want to set up the vacuum and reindex SQLite databases service?"
if [[ $? -eq 0 ]]; then
    echo -e "\033[1mSetting up vacuum and reindex SQLite databases...\033[0m"
    # Create the vacuum_reindex.sh script and service
    cat << 'EOF' > $SCRIPT_PATH
#!/bin/bash
set -e  # Exit on any error

find ~/ -type f -regextype posix-egrep -regex '.*\.(db|sqlite)' \
  -exec bash -c '[ "$(file -b --mime-type {})" = "application/vnd.sqlite3" ] && sqlite3 {} "VACUUM; REINDEX;"' \;
EOF
    chmod +x $SCRIPT_PATH

    # Create the systemd service
    cat << 'EOF' > $SERVICE_PATH
[Unit]
Description=Vacuum and Reindex SQLite Databases
After=network.target

[Service]
Type=oneshot       # This makes it a one-time task
ExecStart=/usr/local/bin/vacuum_reindex.sh
User=root
Group=root
RemainAfterExit=true  # Keeps the service status as 'active' after it finishes

[Install]
WantedBy=multi-user.target
EOF

    # Enable and start the service
    systemctl enable vacuum_reindex.service
    systemctl start vacuum_reindex.service

    # Check the service status
    systemctl status vacuum_reindex.service
    echo -e "\033[1mVacuum and Reindex setup complete!\033[0m"
else
    echo -e "\033[1mSkipping vacuum_reindex script and service setup.\033[0m"
fi

# Final Message
echo -e "\033[1mSetup complete! All requested configurations are in place.\033[0m"

