#!/usr/bin/env sh

sketchybar --add item clock_date center \
           --set clock_date \
               update_freq=30 \
               icon.drawing=off \
               label.font="SF Pro:Semibold:11.0" \
               label.color=0xffa5adcb \
               label.padding_left=14 \
               label.padding_right=5 \
               background.drawing=off \
               script="$PLUGIN_DIR/calendar.sh" \
           --subscribe clock_date system_woke \
           \
           --add item clock_time center \
           --set clock_time \
               update_freq=30 \
               icon.drawing=off \
               label.font="SF Pro:Bold:14.0" \
               label.color=0xffcad3f5 \
               label.padding_left=5 \
               label.padding_right=14 \
               background.drawing=off \
               script="$PLUGIN_DIR/calendar.sh" \
           --subscribe clock_time system_woke \
           \
           --add bracket clock_bracket clock_date clock_time \
           --set clock_bracket \
               background.color=0x44ffffff \
               background.corner_radius=11 \
               background.height=28 \
               background.drawing=on
