#!/bin/bash

# Check if the script is being run with sudo
if [[ $(id -u) -ne 0 ]]; then
    echo "This script needs to be run with sudo. Re-running it with sudo..."
    exec sudo "$0" "$@"
    exit 0
fi

echo "Starting setup for ALSA, PipeWire, and real-time privileges..."

# Step 1: Check if realtime-privileges and ALSA packages are installed
check_alsa_packages_installed() {
    pacman -Q realtime-privileges alsa-lib alsa-utils alsa-firmware alsa-card-profiles alsa-plugins &> /dev/null
    return $?
}

check_pipewire_packages_installed() {
    pacman -Q pipewire pipewire-pulse pipewire-jack lib32-pipewire gst-plugin-pipewire wireplumber &> /dev/null
    return $?
}

# Step 2: Install realtime-privileges and ALSA packages if not installed
if ! check_alsa_packages_installed; then
    echo "Installing realtime-privileges and ALSA packages..."
    pacman -S --noconfirm realtime-privileges alsa-lib alsa-utils alsa-firmware alsa-card-profiles alsa-plugins
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to install ALSA or realtime-privileges. Exiting."
        exit 1
    fi
else
    echo "ALSA and realtime-privileges packages are already installed."
fi

# Step 3: Add the current user to the 'realtime' group if not already a member
if ! groups "$USER" | grep -q "\brealtime\b"; then
    echo "Adding user $USER to the 'realtime' group..."
    usermod -aG realtime "$USER"
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to add $USER to the 'realtime' group. Exiting."
        exit 1
    fi
else
    echo "User $USER is already in the 'realtime' group."
fi

# Step 4: Install PipeWire and related packages if not installed
if ! check_pipewire_packages_installed; then
    echo "Installing PipeWire and related packages..."
    pacman -S --noconfirm pipewire pipewire-pulse pipewire-jack lib32-pipewire gst-plugin-pipewire wireplumber
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to install PipeWire packages. Exiting."
        exit 1
    fi
else
    echo "PipeWire and related packages are already installed."
fi

# Step 5: Create directories for PipeWire Pulse and client-rt configuration if they do not exist
if [[ ! -d ~/.config/pipewire/pipewire-pulse.conf.d ]]; then
    echo "Creating PipeWire Pulse and client-rt configuration directories..."
    mkdir -p ~/.config/pipewire/pipewire-pulse.conf.d
    mkdir -p ~/.config/pipewire/client-rt.conf.d
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to create directories for PipeWire configuration. Exiting."
        exit 1
    fi
else
    echo "PipeWire configuration directories already exist."
fi

# Step 6: Copy 20-upmix.conf to PipeWire configuration directories if not already copied
if [[ ! -f ~/.config/pipewire/pipewire-pulse.conf.d/20-upmix.conf ]]; then
    echo "Copying 20-upmix.conf to PipeWire configuration directories..."
    cp /usr/share/pipewire/client-rt.conf.avail/20-upmix.conf ~/.config/pipewire/pipewire-pulse.conf.d/
    cp /usr/share/pipewire/client-rt.conf.avail/20-upmix.conf ~/.config/pipewire/client-rt.conf.d/
    if [[ $? -ne 0 ]]; then
        echo "Error: Failed to copy configuration files. Exiting."
        exit 1
    fi
else
    echo "20-upmix.conf file already exists in the PipeWire configuration directories."
fi

# Step 7: Create PipeWire sound configuration file (10-sound.conf) if not already created
if [[ ! -f ~/.config/pipewire/pipewire.conf.d/10-sound.conf ]]; then
    echo "Creating PipeWire sound configuration file..."
    mkdir -p ~/.config/pipewire/pipewire.conf.d
    cat <<EOL > ~/.config/pipewire/pipewire.conf.d/10-sound.conf
# PipeWire configuration for sound with real-time properties

context.properties = {
   default.clock.rate = 48000
   default.clock.allowed-rates = [ 48000  ]
   default.clock.min-quantum = 2048
   default.clock.quantum = 4096
   default.clock.max-quantum = 8192
}
EOL
else
    echo "10-sound.conf file already exists in the PipeWire configuration directory."
fi

# Step 8: Notify user about the completed configuration
echo "Configuration files copied successfully!"
echo "The '20-upmix.conf' file has been copied to the following locations:"
echo "~/.config/pipewire/pipewire-pulse.conf.d/"
echo "~/.config/pipewire/client-rt.conf.d/"
echo "The PipeWire sound configuration file has been created at: ~/.config/pipewire/pipewire.conf.d/10-sound.conf"

# Done!
echo "ALSA, PipeWire, and real-time privileges setup completed successfully! 🎉"
