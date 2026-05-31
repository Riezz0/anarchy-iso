#!/bin/bash

# Get the first connected device battery from bluetoothctl
# You can change "Battery Percentage" to "battery-level" if using Solaar logic
BATTERY=$(bluetoothctl info | grep "Battery Percentage" | awk -F '[()]' '{print $2}')

if [ -z "$BATTERY" ]; then
    # If no battery found, hide or show "N/A"
    echo "" 
else
    # Output in JSON format for Waybar
    echo "{\"text\": \" $BATTERY%\", \"tooltip\": \"Bluetooth Battery\", \"class\": \"custom-bt-batt\"}"
fi
