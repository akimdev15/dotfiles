#!/usr/bin/env sh

# Try nowplaying-cli (works with any app — brew install nowplaying-cli)
if command -v nowplaying-cli &>/dev/null; then
  STATE=$(nowplaying-cli get playbackRate 2>/dev/null)
  if [ "$STATE" = "1" ]; then
    TITLE=$(nowplaying-cli get title 2>/dev/null)
    ARTIST=$(nowplaying-cli get artist 2>/dev/null)
    APP=$(nowplaying-cli get bundleIdentifier 2>/dev/null)
    case "$APP" in
      *spotify*) ICON="󰓇"; COLOR=0xff8aadf4 ;;
      *music*)   ICON="󰎆"; COLOR=0xffed8796 ;;
      *podcast*) ICON="󰦔"; COLOR=0xffeed49f ;;
      *)         ICON="󰝚"; COLOR=0xffa6da95 ;;
    esac
    LABEL="${ARTIST} — ${TITLE}"
    [ "${#LABEL}" -gt 40 ] && LABEL="${LABEL:0:38}…"
    sketchybar --set "$NAME" drawing=on icon="$ICON" icon.color="$COLOR" label="$LABEL"
    exit 0
  fi
fi

# Fallback: Spotify
if pgrep -x "Spotify" > /dev/null 2>&1; then
  RESULT=$(osascript -e '
    tell application "Spotify"
      if player state is playing then
        return (artist of current track) & " — " & (name of current track)
      end if
    end tell' 2>/dev/null)
  if [ -n "$RESULT" ]; then
    [ "${#RESULT}" -gt 40 ] && RESULT="${RESULT:0:38}…"
    sketchybar --set "$NAME" drawing=on icon="󰓇" icon.color=0xff8aadf4 label="$RESULT"
    exit 0
  fi
fi

# Fallback: Apple Music
if pgrep -x "Music" > /dev/null 2>&1; then
  RESULT=$(osascript -e '
    tell application "Music"
      if player state is playing then
        return (artist of current track) & " — " & (name of current track)
      end if
    end tell' 2>/dev/null)
  if [ -n "$RESULT" ]; then
    [ "${#RESULT}" -gt 40 ] && RESULT="${RESULT:0:38}…"
    sketchybar --set "$NAME" drawing=on icon="󰎆" icon.color=0xffed8796 label="$RESULT"
    exit 0
  fi
fi

sketchybar --set "$NAME" drawing=off
