#!/bin/bash
# toggle-internet.sh

INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
STATE_FILE="/tmp/internet_state"

if [ -f "$STATE_FILE" ] && [ "$(cat $STATE_FILE)" = "off" ]; then
    # Turn ON
    sudo ip link set "$INTERFACE" up
    echo "on" > "$STATE_FILE"
    notify-send "Internet" "Connection ENABLED on $INTERFACE"
    echo "Internet enabled on $INTERFACE"
else
    # Turn OFF
    sudo ip link set "$INTERFACE" down
    echo "off" > "$STATE_FILE"
    notify-send "Internet" "Connection DISABLED on $INTERFACE"
    echo "Internet disabled on $INTERFACE"
fi

