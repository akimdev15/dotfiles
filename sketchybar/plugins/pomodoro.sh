#!/usr/bin/env sh

STATE_FILE="/tmp/sketchybar_pomodoro"

if [ -f "$STATE_FILE" ]; then
  STATE=$(sed -n '1p' "$STATE_FILE")
  VALUE=$(sed -n '2p' "$STATE_FILE")
else
  STATE="idle"
  VALUE=0
fi

case "$STATE" in
  running)
    NOW=$(date +%s)
    REMAINING=$((VALUE - NOW))
    if [ "$REMAINING" -le 0 ]; then
      osascript -e 'display notification "Time to take a break!" with title "Pomodoro Done" sound name "Glass"' 2>/dev/null
      rm -f "$STATE_FILE"
      sketchybar --set "$NAME" icon.color=0xff939ab7 label="25:00" update_freq=60
    else
      MINS=$((REMAINING / 60))
      SECS=$((REMAINING % 60))
      sketchybar --set "$NAME" icon.color=0xffed8796 \
                               label="$(printf '%02d:%02d' $MINS $SECS)" \
                               update_freq=1
    fi
    ;;
  paused)
    MINS=$((VALUE / 60))
    SECS=$((VALUE % 60))
    sketchybar --set "$NAME" icon.color=0xffeed49f \
                             label="$(printf '%02d:%02d' $MINS $SECS)" \
                             update_freq=60
    ;;
  *)
    sketchybar --set "$NAME" icon.color=0xff939ab7 label="25:00" update_freq=60
    ;;
esac
