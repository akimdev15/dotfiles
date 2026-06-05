#!/usr/bin/env sh

SSID=$(networksetup -getairportnetwork en0 2>/dev/null | awk -F': ' '{print $2}')

if [ -z "$SSID" ] || echo "$SSID" | grep -q "not associated"; then
  sketchybar --set "$NAME" icon="󰤭" icon.color=0xff939ab7 label="Off"
else
  sketchybar --set "$NAME" icon="󰤨" icon.color=0xff8aadf4 label="$SSID"
fi
