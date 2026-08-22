#!/bin/bash

# Battery low notification script
# Thresholds (adjust as needed)
WARN_LEVEL=20
CRITICAL_LEVEL=10

# Track state to avoid spamming notifications
WARNED=0
CRITICAL_WARNED=0

while true; do
    CAPACITY=$(cat /sys/class/power_supply/BAT0/capacity)
    STATUS=$(cat /sys/class/power_supply/BAT0/status)

    if [ "$STATUS" = "Discharging" ]; then
        if [ "$CAPACITY" -le "$CRITICAL_LEVEL" ] && [ "$CRITICAL_WARNED" -eq 0 ]; then
            notify-send -u critical "Battery Critical!" "Battery at ${CAPACITY}% — plug in NOW!"
            CRITICAL_WARNED=1
        elif [ "$CAPACITY" -le "$WARN_LEVEL" ] && [ "$WARNED" -eq 0 ]; then
            notify-send -u normal "Battery Low" "Battery at ${CAPACITY}%"
            WARNED=1
        fi
    else
        # Reset warnings when charging
        WARNED=0
        CRITICAL_WARNED=0
    fi

    sleep 60
done
