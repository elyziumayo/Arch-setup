#!/bin/bash

# Ensure the script is being run with superuser privileges
if [[ $(id -u) -ne 0 ]]; then
    echo "Please run this script as root using 'sudo'."
    exit 1
fi

# Define the script file path and service file path
SCRIPT_PATH="/usr/local/bin/vacuum_reindex.sh"
SERVICE_PATH="/etc/systemd/system/vacuum_reindex.service"

# Step 1: Create the bash script that will find and vacuum/reindex SQLite databases
echo "Creating the vacuum_reindex.sh script..."

cat << 'EOF' > $SCRIPT_PATH
#!/bin/bash
set -e  # Exit on any error

find ~/ -type f -regextype posix-egrep -regex '.*\.(db|sqlite)' \
  -exec bash -c '[ "$(file -b --mime-type {})" = "application/vnd.sqlite3" ] && sqlite3 {} "VACUUM; REINDEX;"' \;

EOF

# Make the script executable
chmod +x $SCRIPT_PATH

# Step 2: Create the systemd service to run the script at boot
echo "Creating the vacuum_reindex.service systemd service..."

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

# Step 3: Enable the systemd service
echo "Enabling the vacuum_reindex systemd service..."
systemctl enable vacuum_reindex.service

# Step 4: Start the service immediately (optional for testing)
echo "Starting the vacuum_reindex service..."
systemctl start vacuum_reindex.service

# Step 5: Check the status of the service
echo "Checking the status of the vacuum_reindex service..."
systemctl status vacuum_reindex.service

echo "Setup complete! The vacuum_reindex script will now run automatically at startup."
