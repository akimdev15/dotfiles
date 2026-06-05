#!/usr/bin/env sh

get_icon() {
  case "$1" in
    "Brave Browser")        echo ":brave_browser:" ;;
    "Google Chrome")        echo ":google_chrome:" ;;
    "Safari")               echo ":safari:" ;;
    "Firefox")              echo ":firefox:" ;;
    "Ghostty")              echo ":ghostty:" ;;
    "Alacritty"|"kitty"|"iTerm2"|"WezTerm"|"Terminal") echo ":terminal:" ;;
    "Visual Studio Code")   echo ":code:" ;;
    "IntelliJ IDEA")        echo ":idea:" ;;
    "Xcode")                echo ":xcode:" ;;
    "Android Studio")       echo ":android_studio:" ;;
    "Obsidian")             echo ":obsidian:" ;;
    "Notion")               echo ":notion:" ;;
    "Finder")               echo ":finder:" ;;
    "Slack")                echo ":slack:" ;;
    "Discord")              echo ":discord:" ;;
    "Telegram")             echo ":telegram:" ;;
    "WhatsApp")             echo ":whats_app:" ;;
    "Music")                echo ":music:" ;;
    "Spotify")              echo ":spotify:" ;;
    "Figma")                echo ":figma:" ;;
    "Linear")               echo ":linear:" ;;
    "Zoom"|"zoom.us")       echo ":zoom:" ;;
    "System Settings"|"System Preferences") echo ":gear:" ;;
    "Activity Monitor")     echo ":activity_monitor:" ;;
    "Preview")              echo ":pdf:" ;;
    "Notes")                echo ":notes:" ;;
    "Calendar")             echo ":calendar:" ;;
    "Mail")                 echo ":mail:" ;;
    *)                      echo ":default:" ;;
  esac
}

ICON=$(get_icon "$INFO")
sketchybar --set "$NAME" label="$INFO" icon="$ICON"
