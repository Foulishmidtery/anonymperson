#!/bin/bash
# Dynamic Proton VPN Free server script for anonymperson

# Load ProtonVPN credentials
CONFIG_FILE="/etc/anonymperson/protonvpn_credentials.conf"
if [ -f "$CONFIG_FILE" ]; then
  source "$CONFIG_FILE"
else
  echo "Error: ProtonVPN credentials file ($CONFIG_FILE) not found."
  exit 1
fi

OVPN_FILE="/etc/openvpn/client/us-free-22.protonvpn.tcp.ovpn"

while true; do
  killall openvpn 2>/dev/null || true
  openvpn --config "$OVPN_FILE" --auth-user-pass <(echo -e "$PROTONVPN_USERNAME\n$PROTONVPN_PASSWORD") --daemon
  echo "Connected to $OVPN_FILE"
  sleep 3600 # Rotate every hour
done