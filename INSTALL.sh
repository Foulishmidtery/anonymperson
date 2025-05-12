#!/bin/bash

echo "Installing anonymperson with Proton VPN Free, Pi-hole, IPFS, and dynamic protection on Kali Linux 2025..."

# Update package lists
apt-get update

# Install dependencies for anonymperson, Proton VPN, Pi-hole, and IPFS
apt-get install -y tor macchanger resolvconf dnsmasq privoxy libnotify-bin curl bleachbit i2p nyx openvpn protonvpn pihole golang-ipfs tor-ctrl

# Create configuration directories
mkdir -p /etc/tor
mkdir -p /etc/privoxy
mkdir -p /etc/openvpn/client
mkdir -p /etc/ipfs

# Copy configuration files
cp configs/torrc /etc/tor/torrc
cp configs/privoxy.config /etc/privoxy/config
cp configs/us-free-22.protonvpn.tcp.ovpn /etc/openvpn/client/us-free-22.protonvpn.tcp.ovpn
cp configs/ipfs_config /etc/ipfs/config

# Set permissions for scripts
cp anonymperson /usr/bin/anonymperson
cp dynamic_tor.sh /usr/local/bin/dynamic_tor.sh
cp dynamic_vpn.sh /usr/local/bin/dynamic_vpn.sh
cp ipfs_manager.sh /usr/local/bin/ipfs_manager.sh
chmod +x /usr/bin/anonymperson /usr/local/bin/dynamic_tor.sh /usr/local/bin/dynamic_vpn.sh /usr/local/bin/ipfs_manager.sh

# Configure Pi-hole
bash configs/pihole_setup.sh

# Initialize IPFS
ipfs init
cp /root/.ipfs/config /etc/ipfs/config

# Notify user of completion
echo -e "\n\n         anonymperson (v 1.1) with Proton VPN Free, Pi-hole, and IPFS Usage Ex:\n"
echo -e "         anON  => automated protection [ON] (Proton VPN Free + Tor + Pi-hole + IPFS)"
echo -e "         anOFF => automated protection [OFF]\n"
echo -e "         ADVANCED COMMANDS LIST:\n"
echo -e "        ----[ Tor Tunneling ]----"
echo -e "         anonymperson start            => Start Tor Tunneling"
echo -e "         anonymperson stop             => Stop Tor Tunneling"
echo -e "         anonymperson change           => Change Tor identity"
echo -e "         anonymperson dynamic          => Enable dynamic Tor circuit rotation"
echo -e "         anonymperson status           => Tor Tunneling Status\n"
echo -e "        ----[ Proton VPN Free ]----"
echo -e "         anonymperson start_vpn        => Start Proton VPN Free"
echo -e "         anonymperson stop_vpn         => Stop Proton VPN Free"
echo -e "         anonymperson status_vpn       => Proton VPN Free Status"
echo -e "         anonymperson dynamic_vpn      => Enable dynamic VPN server rotation\n"
echo -e "        ----[ IPFS P2P ]----"
echo -e "         anonymperson start_ipfs       => Start IPFS daemon"
echo -e "         anonymperson stop_ipfs        => Stop IPFS daemon"
echo -e "         anonymperson status_ipfs      => IPFS daemon status"
echo -e "         anonymperson share_ipfs       => Share file via IPFS"
echo -e "         anonymperson get_ipfs         => Get file from IPFS\n"
echo -e "        ----[ IP Status ]----"
echo -e "         anonymperson status_ip        => Check current IP\n"
echo -e "        ----[ Other Features ]----"
echo -e "         anonymperson start_i2p        => Start I2P services"
echo -e "         anonymperson stop_i2p         => Stop I2P services"
echo -e "         anonymperson status_i2p       => I2P status"
echo -e "         anonymperson start_privoxy    => Start Privoxy services"
echo -e "         anonymperson stop_privoxy     => Stop Privoxy services"
echo -e "         anonymperson status_privoxy   => Privoxy status"
echo -e "         anonymperson start_mac        => Change MAC address"
echo -e "         anonymperson stop_mac         => Restore MAC address"
echo -e "         anonymperson status_mac       => MAC address status"
echo -e "         anonymperson start_nyx        => Start Nyx (Tor monitoring)"
echo -e "         anonymperson wipe             => Clear cache"
echo -e "         anonymperson change_hostname  => Spoof hostname"
echo -e "         anonymperson restore_hostname => Restore hostname"
echo -e "         anonymperson status_hostname  => Show hostname\n"
echo -e "         Note: Use IPFS for P2P file sharing instead of BitTorrent with Proton VPN Free."
