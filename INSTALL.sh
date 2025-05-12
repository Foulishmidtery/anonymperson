#!/bin/bash
# INSTALL.sh
# Install anonymperson dependencies on Kali Linux with Pi-hole integration

# Exit on error
set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)"
  exit 1
fi

echo "Installing anonymperson with Proton VPN Free, Tor, IPFS, Pi-hole, and dynamic protection on Kali Linux 2025..."

# Update package list
echo "Updating package list..."
apt-get update

# Install available dependencies
echo "Installing available dependencies..."
apt-get install -y tor privoxy openvpn macchanger nyx curl bleachbit resolvconf libnotify-bin || {
  echo "Failed to install some dependencies. Check your internet connection or package availability."
  exit 1
}

# Disable dnsmasq to avoid conflict with Pi-hole
echo "Disabling dnsmasq to avoid port 53 conflict..."
systemctl disable dnsmasq 2>/dev/null || true
systemctl stop dnsmasq 2>/dev/null || true

# Install Docker for Pi-hole
echo "Installing Docker..."
apt-get install -y docker.io
systemctl enable --now docker || {
  echo "Failed to start Docker service."
  exit 1
}

# Run Pi-hole container without WEBPASSWORD
echo "Setting up Pi-hole container..."
docker pull pihole/pihole:latest
docker run -d --name pihole \
  -p 53:53/tcp \
  -p 53:53/udp \
  -p 80:80 \
  -p 443:443 \
  -e TZ="Asia/Jakarta" \
  pihole/pihole:latest || {
  echo "Failed to start Pi-hole container. Check Docker status or port conflicts."
  exit 1
}

# Wait for Pi-hole to initialize
sleep 10
# Disable web password for Pi-hole
docker exec pihole pihole -a -p || {
  echo "Failed to disable Pi-hole web password."
  exit 1
}

# Install I2P
echo "Installing I2P..."
if ! command -v i2prouter &> /dev/null; then
  echo "Adding I2P repository..."
  apt-get install -y apt-transport-https
  echo "deb https://deb.i2p2.de/ buster main" > /etc/apt/sources.list.d/i2p.list
  wget -q https://deb.i2p2.de/archive.key -O - | apt-key add -
  apt-get update
  apt-get install -y i2p || {
    echo "Failed to install I2P. Check the repository or install manually."
    exit 1
  }
else
  echo "I2P already installed."
fi

# Install ProtonVPN CLI
echo "Installing ProtonVPN CLI..."
if ! command -v protonvpn-cli &> /dev/null; then
  wget https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3-2_all.deb
  dpkg -i protonvpn-stable-release_1.0.3-2_all.deb
  apt-get update
  apt-get install -y protonvpn || {
    echo "Failed to install ProtonVPN. Check the repository or install manually."
    exit 1
  }
  rm protonvpn-stable-release_1.0.3-2_all.deb
else
  echo "ProtonVPN CLI already installed."
fi

# Install IPFS
echo "Installing IPFS..."
if ! command -v ipfs &> /dev/null; then
  wget https://dist.ipfs.io/go-ipfs/v0.12.0/go-ipfs_v0.12.0_linux-amd64.tar.gz
  tar -xvzf go-ipfs_v0.12.0_linux-amd64.tar.gz
  cd go-ipfs
  bash install.sh
  cd ..
  rm -rf go-ipfs go-ipfs_v0.12.0_linux-amd64.tar.gz
  ipfs init || {
    echo "Failed to initialize IPFS."
    exit 1
  }
  mkdir -p /etc/ipfs
  cp configs/ipfs_config /etc/ipfs/config
else
  echo "IPFS already installed."
fi

# Create configuration directories
mkdir -p /etc/tor /etc/privoxy /etc/openvpn/client /etc/ipfs /etc/anonymperson

# Copy configuration files
cp configs/torrc /etc/tor/torrc
cp configs/privoxy.config /etc/privoxy/config
cp configs/us-free-22.protonvpn.tcp.ovpn /etc/openvpn/client/us-free-22.protonvpn.tcp.ovpn
cp configs/ipfs_config /etc/ipfs/config

# Create ProtonVPN credentials file (placeholder)
if [ ! -f /etc/anonymperson/protonvpn_credentials.conf ]; then
  echo "PROTONVPN_USERNAME=\"your_username\"" > /etc/anonymperson/protonvpn_credentials.conf
  echo "PROTONVPN_PASSWORD=\"your_password\"" >> /etc/anonymperson/protonvpn_credentials.conf
  chmod 600 /etc/anonymperson/protonvpn_credentials.conf
  echo "ProtonVPN credentials file created at /etc/anonymperson/protonvpn_credentials.conf. Please update with your credentials."
else
  echo "ProtonVPN credentials file already exists."
fi

# Set permissions for scripts
cp anonymperson /usr/bin/anonymperson
cp dynamic_tor.sh /usr/local/bin/dynamic_tor.sh
cp dynamic_vpn.sh /usr/local/bin/dynamic_vpn.sh
cp ipfs_manager.sh /usr/local/bin/ipfs_manager.sh
chmod +x /usr/bin/anonymperson /usr/local/bin/dynamic_tor.sh /usr/local/bin/dynamic_vpn.sh /usr/local/bin/ipfs_manager.sh

# Configure services
echo "Configuring services..."
systemctl enable tor privoxy
systemctl start tor privoxy

# Configure resolv.conf to use Pi-hole
echo "Configuring DNS to use Pi-hole..."
echo "nameserver 127.0.0.1" > /etc/resolv.conf
chmod 644 /etc/resolv.conf

echo "Installation completed!"
echo "anonymperson (v 1.2) with Proton VPN Free, Tor, IPFS, and Pi-hole Usage Ex:"
echo "anON  => automated protection [ON] (Proton VPN Free + Tor + IPFS + Pi-hole)"
echo "anOFF => automated protection [OFF]"
echo "Run 'sudo anonymperson --help' for advanced commands."
echo "Access Pi-hole dashboard at http://localhost/admin (no password required)."