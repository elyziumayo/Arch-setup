#!/bin/bash

# Function to check if service exists
check_service() {
    if [ -f /etc/systemd/system/sqlite-optimize.service ]; then
        return 0
    else
        return 1
    fi
}

# Function to setup SQLite optimization service
setup_sqlite_service() {
    echo "Setting up SQLite optimization service..."
    
    # Create the optimization script in /usr/local/bin
    echo "Installing SQLite optimization script..."
    sudo install -Dm755 "$(dirname "$0")/sqlite_optimize.sh" /usr/local/bin/sqlite_optimize.sh

    echo "Creating systemd service..."
    # Create the service file
    sudo tee /etc/systemd/system/sqlite-optimize.service > /dev/null << 'EOF'
[Unit]
Description=SQLite Database Optimization
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/sqlite_optimize.sh
RemainAfterExit=true
Nice=19
IOSchedulingClass=best-effort
IOSchedulingPriority=7

[Install]
WantedBy=multi-user.target
EOF

    # Create the timer file
    sudo tee /etc/systemd/system/sqlite-optimize.timer > /dev/null << 'EOF'
[Unit]
Description=SQLite Database Optimization Timer

[Timer]
OnStartupSec=5min
OnUnitActiveSec=1d

[Install]
WantedBy=timers.target
EOF

    echo "Reloading systemd daemon..."
    sudo systemctl daemon-reload

    echo "Enabling and starting the timer..."
    sudo systemctl enable sqlite-optimize.timer
    sudo systemctl start sqlite-optimize.timer

    echo "SQLite optimization service has been configured!"
    echo "The service will run 5 minutes after boot and then daily."
    echo "Current timer status:"
    sudo systemctl status sqlite-optimize.timer
}

# Check for force flag
FORCE=0
if [ "$1" = "--force" ]; then
    FORCE=1
fi

# Main script
if ! check_service; then
    echo "SQLite optimization service is not configured."
    if [ $FORCE -eq 1 ] || { read -p "Would you like to setup SQLite optimization service? (y/n): " answer && [[ $answer =~ ^[Yy]$ ]]; }; then
        setup_sqlite_service
    else
        echo "Skipping SQLite optimization service setup."
    fi
else
    echo "SQLite optimization service is already configured."
    if [ $FORCE -eq 1 ] || { read -p "Would you like to reconfigure it? (y/n): " answer && [[ $answer =~ ^[Yy]$ ]]; }; then
        setup_sqlite_service
    else
        echo "Keeping existing SQLite optimization service configuration."
    fi
fi 