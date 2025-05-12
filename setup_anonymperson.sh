#!/bin/bash

# setup_anonymperson.sh
# Automates directory creation, file copying, permissions, and installation for anonymperson project
# Run from Downloads/anonymperson: sudo ./setup_anonymperson.sh

# Check if running as root
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root (use sudo)"
    exit 1
fi

# Define source and destination directories
SRC_DIR="$(pwd)"
DEST_DIR="/home/wkali/anonymperson"
CONFIG_DIR="$DEST_DIR/configs"

# Create destination directory structure
echo "Creating directory structure at $DEST_DIR..."
mkdir -p "$DEST_DIR" "$CONFIG_DIR"

# List of files to copy to DEST_DIR
MAIN_FILES=(
    "INSTALL.sh"
    "anonymperson"
    "dynamic_tor.sh"
    "dynamic_vpn.sh"
    "ipfs_manager.sh"
    "README.md"
    ".gitignore"
)

# List of files to copy to CONFIG_DIR
CONFIG_FILES=(
    "torrc"
    "privoxy.config"
    "us-free-22.protonvpn.tcp.ovpn"
    "pihole_setup.sh"
    "ipfs_config"
)

# Copy main files
echo "Copying main files to $DEST_DIR..."
for file in "${MAIN_FILES[@]}"; do
    if [ -f "$SRC_DIR/$file" ]; then
        cp "$SRC_DIR/$file" "$DEST_DIR/"
        echo "Copied $file to $DEST_DIR"
    else
        echo "Warning: $file not found in $SRC_DIR"
    fi
done

# Copy config files
echo "Copying config files to $CONFIG_DIR..."
for file in "${CONFIG_FILES[@]}"; do
    if [ -f "$SRC_DIR/configs/$file" ]; then
        cp "$SRC_DIR/configs/$file" "$CONFIG_DIR/"
        echo "Copied $file to $CONFIG_DIR"
    else
        echo "Warning: $file not found in $SRC_DIR/configs"
    fi
done

# Set executable permissions
echo "Setting executable permissions..."
chmod +x "$DEST_DIR/INSTALL.sh" "$DEST_DIR/anonymperson" "$DEST_DIR/dynamic_tor.sh" "$DEST_DIR/dynamic_vpn.sh" "$DEST_DIR/ipfs_manager.sh" "$CONFIG_DIR/pihole_setup.sh"
echo "Permissions set for executable files"

# Run INSTALL.sh
echo "Running INSTALL.sh..."
cd "$DEST_DIR"
if [ -f "INSTALL.sh" ]; then
    ./INSTALL.sh
else
    echo "Error: INSTALL.sh not found in $DEST_DIR"
    exit 1
fi

echo "Setup completed! You can now use 'sudo anonymperson [command]'"
echo "Please edit $DEST_DIR/anonymperson and $DEST_DIR/dynamic_vpn.sh to add your Proton VPN credentials."
