#!/bin/bash

# Dynamic Proton VPN Free server script for anonymperson
OVPN_FILE="/etc/openvpn/client/us-free-22.protonvpn.tcp.ovpn"
PROTONVPN_USER="NsObwvgdCmu5fNYA"
PROTONVPN_PASS="3bovzCgOhOy8Ro8uBxFv92Npymbz34wo"

killall openvpn
openvpn --config "$OVPN_FILE" --auth-user-pass <(echo -e "$PROTONVPN_USER\n$PROTONVPN_PASS") --daemon
echo "Connected to $OVPN_FILE"
