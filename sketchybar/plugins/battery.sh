#!/usr/bin/env sh

PERCENTAGE=$(pmset -g batt | grep -Eo '\d+%' | head -1 | tr -d '%')
CHARGING=$(pmset -g batt | grep -c 'AC Power')

if [ "$CHARGING" -gt 0 ]; then
  ICON="󰂄"
  COLOR=0xff8aadf4
elif [ "$PERCENTAGE" -ge 80 ]; then
  ICON="󰁹"
  COLOR=0xffa6da95
elif [ "$PERCENTAGE" -ge 60 ]; then
  ICON="󰂁"
  COLOR=0xffa6da95
elif [ "$PERCENTAGE" -ge 40 ]; then
  ICON="󰁾"
  COLOR=0xffeed49f
elif [ "$PERCENTAGE" -ge 20 ]; then
  ICON="󰁼"
  COLOR=0xfff5a97f
else
  ICON="󰁺"
  COLOR=0xffed8796
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%"
