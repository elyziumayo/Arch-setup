#!/bin/bash

# Function to check if makepkg.conf exists
check_makepkg_conf() {
    if [ -f ~/.makepkg.conf ]; then
        return 0
    else
        return 1
    fi
}

# Function to configure makepkg.conf
configure_makepkg() {
    echo "Configuring makepkg.conf with optimized compilation flags..."
    
    # Create or overwrite makepkg.conf
    cat > ~/.makepkg.conf << 'EOF'
# Optimized compilation flags for maximum performance

# C compilation flags
CFLAGS="-march=native -mtune=native -O2 -pipe -fno-plt -fexceptions \
      -Wp,-D_FORTIFY_SOURCE=3 -Wformat -Werror=format-security \
      -fstack-clash-protection -fcf-protection"

# C++ compilation flags
CXXFLAGS="$CFLAGS -Wp,-D_GLIBCXX_ASSERTIONS"

# Rust compilation flags
RUSTFLAGS="-C opt-level=3 -C target-cpu=native -C link-arg=-z -C link-arg=pack-relative-relocs"

# Make flags for parallel compilation
MAKEFLAGS="-j$(nproc) -l$(nproc)"

# Note: If you encounter build errors with specific packages,
# you may need to disable LTO by adding !lto to the options.
EOF

    echo "makepkg.conf has been configured with optimized compilation flags!"
    echo "Note: If you encounter build errors, you may need to disable LTO for specific packages."
}

# Check for force flag
FORCE=0
if [ "$1" = "--force" ]; then
    FORCE=1
fi

# Main script
if check_makepkg_conf; then
    echo "Existing makepkg.conf found."
    if [ $FORCE -eq 1 ]; then
        # Backup existing config
        cp ~/.makepkg.conf ~/.makepkg.conf.backup
        echo "Existing configuration backed up to ~/.makepkg.conf.backup"
        configure_makepkg
    else
        read -p "Would you like to overwrite it with optimized settings? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
            # Backup existing config
            cp ~/.makepkg.conf ~/.makepkg.conf.backup
            echo "Existing configuration backed up to ~/.makepkg.conf.backup"
            configure_makepkg
        else
            echo "Keeping existing makepkg.conf configuration."
        fi
    fi
else
    echo "No existing makepkg.conf found."
    if [ $FORCE -eq 1 ]; then
        configure_makepkg
    else
        read -p "Would you like to create it with optimized settings? (y/n): " answer
        if [[ $answer =~ ^[Yy]$ ]]; then
            configure_makepkg
        else
            echo "Skipping makepkg.conf configuration."
        fi
    fi
fi 