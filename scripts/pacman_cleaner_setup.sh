#!/bin/bash

# Function to check if service exists
check_service() {
    if [ -f /etc/systemd/system/pacman-cleaner.service ]; then
        return 0
    else
        return 1
    fi
}

# Function to check if timer exists
check_timer() {
    if [ -f /etc/systemd/system/pacman-cleaner.timer ]; then
        return 0
    else
        return 1
    fi
}

# Function to setup pacman cleaner
setup_pacman_cleaner() {
    echo "Setting up pacman cache cleaner..."
    
    # Create the service file
    echo "Creating systemd service..."
    sudo tee /etc/systemd/system/pacman-cleaner.service > /dev/null << 'EOF'
[Unit]
Description=Cleans pacman cache

[Service]
Type=oneshot
ExecStart=/usr/bin/pacman -Scc --noconfirm

[Install]
WantedBy=multi-user.target
EOF

    # Create the timer file
    echo "Creating systemd timer..."
    sudo tee /etc/systemd/system/pacman-cleaner.timer > /dev/null << 'EOF'
[Unit]
Description=Run clean of pacman cache every week

[Timer]
OnCalendar=weekly
AccuracySec=1h
Persistent=true

[Install]
WantedBy=timers.target
EOF

    echo "Reloading systemd daemon..."
    sudo systemctl daemon-reload

    echo "Enabling and starting the timer..."
    sudo systemctl enable --now pacman-cleaner.timer

    echo "Pacman cache cleaner has been configured!"
    echo "The service will run weekly with 1-hour accuracy."
    echo "Current timer status:"
    sudo systemctl status pacman-cleaner.timer
}

# Check for force flag
FORCE=0
if [ "$1" = "--force" ]; then
    FORCE=1
fi

# Main script
if ! check_service || ! check_timer; then
    echo "Pacman cache cleaner is not configured."
    if [ $FORCE -eq 1 ] || { read -p "Would you like to setup automatic pacman cache cleaning? (y/n): " answer && [[ $answer =~ ^[Yy]$ ]]; }; then
        setup_pacman_cleaner
    else
        echo "Skipping pacman cache cleaner setup."
    fi
else
    echo "Pacman cache cleaner is already configured."
    if [ $FORCE -eq 1 ] || { read -p "Would you like to reconfigure it? (y/n): " answer && [[ $answer =~ ^[Yy]$ ]]; }; then
        setup_pacman_cleaner
    else
        echo "Keeping existing pacman cache cleaner configuration."
    fi
fi 