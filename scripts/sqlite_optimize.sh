#!/bin/bash
set -e  # Exit on any error

# Function to optimize SQLite databases
optimize_sqlite() {
    echo "Starting SQLite database optimization..."
    find ~/ -type f -regextype posix-egrep -regex '.*\.(db|sqlite)' \
        -exec bash -c '[ "$(file -b --mime-type {})" = "application/vnd.sqlite3" ] && sqlite3 {} "VACUUM; REINDEX;"' \;
    echo "SQLite optimization completed!"
}

# If script is run directly, execute optimization
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    optimize_sqlite
fi 