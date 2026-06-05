#!/usr/bin/env sh

if command -v nowplaying-cli &>/dev/null; then
  nowplaying-cli togglePlayPause
elif pgrep -x "Spotify" > /dev/null 2>&1; then
  osascript -e 'tell application "Spotify" to playpause'
elif pgrep -x "Music" > /dev/null 2>&1; then
  osascript -e 'tell application "Music" to playpause'
fi
