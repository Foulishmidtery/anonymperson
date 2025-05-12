#!/bin/bash

# Dynamic Tor circuit rotation script for anonymperson
while true; do
    echo "SIGNAL NEWNYM" | nc 127.0.0.1 9051
    echo "Tor circuit rotated"
    sleep 300 # Rotate every 5 minutes
done
