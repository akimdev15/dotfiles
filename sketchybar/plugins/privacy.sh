#!/usr/bin/env sh

CAMERA_ON=0
MIC_ON=0

# Camera: daemon only runs when camera is active
if pgrep -x "appleh13camerad" > /dev/null 2>&1 || pgrep -x "VDCAssistant" > /dev/null 2>&1; then
  CAMERA_ON=1
fi

# Mic: check active comms/recording apps
for APP in "zoom.us" "Zoom" "FaceTime" "Discord" "Teams" "Slack" "Skype" "obs" "OBS"; do
  if pgrep -xi "$APP" > /dev/null 2>&1; then
    MIC_ON=1
    break
  fi
done

if [ "$CAMERA_ON" -eq 1 ] || [ "$MIC_ON" -eq 1 ]; then
  LABEL=""
  [ "$CAMERA_ON" -eq 1 ] && LABEL="${LABEL}󰄀 "
  [ "$MIC_ON" -eq 1 ]    && LABEL="${LABEL}󰍬"
  LABEL="${LABEL%% }"
  sketchybar --set "$NAME" drawing=on label="$LABEL"
else
  sketchybar --set "$NAME" drawing=off
fi
