#!/usr/bin/env sh

STATE_FILE="/tmp/sketchybar_pomodoro"
WORK_DURATION=1500  # 25 min

# Right click: reset
if [ "$BUTTON" = "right" ]; then
  rm -f "$STATE_FILE"
  sketchybar --set pomodoro icon.color=0xff939ab7 label="25:00" update_freq=60
  exit 0
fi

# Left click: start / pause / resume
if [ -f "$STATE_FILE" ]; then
  STATE=$(sed -n '1p' "$STATE_FILE")
  VALUE=$(sed -n '2p' "$STATE_FILE")
else
  STATE="idle"
  VALUE=0
fi

case "$STATE" in
  idle)
    END_TIME=$(( $(date +%s) + WORK_DURATION ))
    printf 'running\n%s\n' "$END_TIME" > "$STATE_FILE"
    sketchybar --set pomodoro icon.color=0xffed8796 update_freq=1
    ;;
  running)
    NOW=$(date +%s)
    REMAINING=$(( VALUE - NOW ))
    printf 'paused\n%s\n' "$REMAINING" > "$STATE_FILE"
    sketchybar --set pomodoro icon.color=0xffeed49f update_freq=60
    ;;
  paused)
    END_TIME=$(( $(date +%s) + VALUE ))
    printf 'running\n%s\n' "$END_TIME" > "$STATE_FILE"
    sketchybar --set pomodoro icon.color=0xffed8796 update_freq=1
    ;;
esac
