#!/bin/bash

# Check if the script is being run with sudo
if [[ $(id -u) -ne 0 ]]; then
    echo "This script needs to be run with sudo. Re-running it with sudo..."
    exec sudo "$0" "$@"
    exit 0
fi

echo "Starting setup for ALSA, PipeWire, and real-time privileges..."

# Step 1: Install realtime-privileges and ALSA packages
echo "Installing realtime-privileges and ALSA packages..."
pacman -S --noconfirm realtime-privileges alsa-lib alsa-utils alsa-firmware alsa-card-profiles alsa-plugins

# Step 2: Add the current user to the 'realtime' group
echo "Adding user $USER to the 'realtime' group..."
gpasswd -a "$USER" realtime

# Step 3: Install PipeWire and related packages
echo "Installing PipeWire and related packages..."
pacman -S --noconfirm pipewire pipewire-pulse pipewire-jack lib32-pipewire gst-plugin-pipewire wireplumber

# Step 4: Create directories for PipeWire Pulse and client-rt configuration
echo "Creating PipeWire Pulse and client-rt configuration directories..."
mkdir -p ~/.config/pipewire/pipewire-pulse.conf.d
mkdir -p ~/.config/pipewire/client-rt.conf.d

# Step 5: Copy 20-upmix.conf to PipeWire configuration directories
echo "Copying 20-upmix.conf to PipeWire configuration directories..."
cp /usr/share/pipewire/client-rt.conf.avail/20-upmix.conf ~/.config/pipewire/pipewire-pulse.conf.d/
cp /usr/share/pipewire/client-rt.conf.avail/20-upmix.conf ~/.config/pipewire/client-rt.conf.d/

# Step 6: Create PipeWire sound configuration file (10-sound.conf)
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

# Step 7: Notify user about configuration
echo "Configuration files copied successfully!"
echo "The '20-upmix.conf' file has been copied to the following locations:"
echo "~/.config/pipewire/pipewire-pulse.conf.d/"
echo "~/.config/pipewire/client-rt.conf.d/"
echo "The PipeWire sound configuration file has been created at: ~/.config/pipewire/pipewire.conf.d/10-sound.conf"

# Done!
echo "ALSA, PipeWire, and real-time privileges setup completed successfully! 🎉"
