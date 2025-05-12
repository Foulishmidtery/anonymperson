#!/bin/bash

# Configure Pi-hole for anonymperson

# Install Pi-hole
curl -sSL https://install.pi-hole.net | bash

# Configure Pi-hole to listen on tun0 (Proton VPN interface)
sed -i 's/PIHOLE_INTERFACE=.*/PIHOLE_INTERFACE=tun0/' /etc/pihole/setupVars.conf
sed -i 's/DNSMASQ_LISTENING=.*/DNSMASQ_LISTENING=all/' /etc/dnsmasq.d/01-pihole.conf

# Add ad blocklists
pihole -b -f https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts
pihole -b -f https://raw.githubusercontent.com/chadmayfield/my-pihole-blocklists/master/lists/pi_blocklist_porn_all.list

# Restart Pi-hole
service pihole-FTL restart

echo "Pi-hole configured with ad blocklists for anonymperson"
