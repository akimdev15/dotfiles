#!/usr/bin/env sh

sketchybar --add item front_app left \
           --set front_app \
               icon.font="sketchybar-app-font:Regular:14.0" \
               icon.color=$BLUE \
               icon.padding_left=8 \
               icon.padding_right=4 \
               label.font="SF Pro:Semibold:13.0" \
               label.color=$WHITE \
               label.padding_right=10 \
               background.color=0x26ffffff \
               background.corner_radius=6 \
               background.height=24 \
               background.drawing=on \
               script="$PLUGIN_DIR/front_app.sh" \
           --subscribe front_app front_app_switched
