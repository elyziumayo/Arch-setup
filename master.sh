#!/bin/bash

# List of scripts (paths relative to the master script or absolute paths)
SCRIPTS
    "~/Performance-optimization/chaotic.sh"
      "~/Performance-optimization/sqlite_optimize.sh"
)

# Log file (optional)
LOG_FILE="master_script.log"

# Log function
log() {
    echo "$(date): $1" >> "$LOG_FILE"
}

# Iterate through all scripts
for SCRIPT in "${SCRIPTS[@]}"; do
    if [ -f "$SCRIPT" ]; then
        log "Setting execute permissions for $SCRIPT..."
        
        # Give execute permission to the script
        chmod +x "$SCRIPT"

        # Execute the script and log the output
        log "Running $SCRIPT..."
        "$SCRIPT" >> "$LOG_FILE" 2>&1

        # Check if the script executed successfully
        if [ $? -eq 0 ]; then
            log "$SCRIPT executed successfully."
        else
            log "Error executing $SCRIPT!"
        fi
    else
        log "Error: $SCRIPT not found!"
    fi
done
