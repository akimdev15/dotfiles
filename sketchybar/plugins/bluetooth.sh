#!/usr/bin/env sh

CONNECTED=$(system_profiler SPBluetoothDataType 2>/dev/null | grep -c "Connected: Yes")

if [ "$CONNECTED" -gt 0 ]; then
  sketchybar --set "$NAME" icon="󰂯" icon.color=0xff8aadf4 label="${CONNECTED} connected"
else
  sketchybar --set "$NAME" icon="󰂲" icon.color=0xff939ab7 label=""
fi
