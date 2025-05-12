#!/bin/bash
# setup_anonymperson.sh
# Automates directory creation, file copying, permissions, and installation for anonymperson project
# Run from any location (e.g., Downloads/anonymperson): sudo ./setup_anonymperson.sh

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root (use sudo)"
    exit 1
fi

# Define source directory (where script is run)
SRC_DIR="$(pwd)"
if [ ! -d "$SRC_DIR/configs" ]; then
    echo "Error: configs/ directory not found in $SRC_DIR"
    exit 1
fi

# Define destination directory (default: /home/$USER/anonymperson)
USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
DEST_DIR="${USER_HOME}/anonymperson"
CONFIG_DIR="$DEST_DIR/configs"

# Allow override via environment variable
if [ -n "$ANONYMPERSON_DEST" ]; then
    DEST_DIR="$ANONYMPERSON_DEST"
    CONFIG_DIR="$DEST_DIR/configs"
fi

# List of main files to copy to DEST_DIR
MAIN_FILES=(
    "INSTALL.sh"
    "anonymperson"
    "dynamic_tor.sh"
    "dynamic_vpn.sh"
    "ipfs_manager.sh"
    "README.md"
    ".gitignore"
)

# List of config files to copy to CONFIG_DIR
CONFIG_FILES=(
    "torrc"
    "privoxy.config"
    "us-free-22.protonvpn.tcp.ovpn"
    "ipfs_config"
)

# Check for critical files
for file in "INSTALL.sh" "anonymperson"; do
    if [ ! -f "$SRC_DIR/$file" ]; then
        echo "Error: Critical file $file not found in $SRC_DIR"
        exit 1
    fi
done

# Create destination directory structure
echo "Creating directory structure at $DEST_DIR..."
mkdir -p "$DEST_DIR" "$CONFIG_DIR" || {
    echo "Error: Failed to create directories at $DEST_DIR"
    exit 1
}

# Copy main files
echo "Copying main files to $DEST_DIR..."
for file in "${MAIN_FILES[@]}"; do
    if [ -f "$SRC_DIR/$file" ]; then
        cp "$SRC_DIR/$file" "$DEST_DIR/" || {
            echo "Error: Failed to copy $file to $DEST_DIR"
            exit 1
        }
        echo "Copied $file to $DEST_DIR"
    else
        echo "Warning: $file not found in $SRC_DIR"
    fi
done

# Copy config files
echo "Copying config files to $CONFIG_DIR..."
for file in "${CONFIG_FILES[@]}"; do
    if [ -f "$SRC_DIR/configs/$file" ]; then
        cp "$SRC_DIR/configs/$file" "$CONFIG_DIR/" || {
            echo "Error: Failed to copy $file to $CONFIG_DIR"
            exit 1
        }
        echo "Copied $file to $CONFIG_DIR"
    else
        echo "Warning: $file not found in $SRC_DIR/configs"
    fi
done

# Set permissions
echo "Setting permissions..."
chmod 755 "$DEST_DIR/INSTALL.sh" "$DEST_DIR/anonymperson" "$DEST_DIR/dynamic_tor.sh" "$DEST_DIR/dynamic_vpn.sh" "$DEST_DIR/ipfs_manager.sh" || {
    echo "Error: Failed to set executable permissions"
    exit 1
}
chmod 644 "$DEST_DIR/README.md" "$DEST_DIR/.gitignore" 2>/dev/null || true
chmod 644 "$CONFIG_DIR"/* 2>/dev/null || true
echo "Permissions set for files"

# Check for port conflicts (for Pi-hole)
echo "Checking for port conflicts..."
for port in 53 80 443; do
    if ss -tuln | grep -q ":$port "; then
        echo "Error: Port $port is in use. Stop conflicting services (e.g., sudo systemctl stop <service>)"
        exit 1
    fi
done

# Run INSTALL.sh
echo "Running INSTALL.sh..."
cd "$DEST_DIR" || {
    echo "Error: Failed to change to $DEST_DIR"
    exit 1
}
if [ -f "INSTALL.sh" ]; then
    sudo ./INSTALL.sh || {
        echo "Error: INSTALL.sh failed. Check logs in $DEST_DIR/install_error.log"
        ./INSTALL.sh 2> install_error.log
        exit 1
    }
else
    echo "Error: INSTALL.sh not found in $DEST_DIR"
    exit 1
fi

echo "Setup completed!"
echo "Project is now set up at $DEST_DIR"
echo "Next steps:"
echo "1. Edit ProtonVPN credentials:"
echo "   sudo nano /etc/anonymperson/protonvpn_credentials.conf"
echo "2. Test the project:"
echo "   sudo anonymperson anON"
echo "   sudo anonymperson status"
echo "3. Access Pi-hole dashboard at http://localhost/admin (no password)"
echo "See $DEST_DIR/README.md for more details."