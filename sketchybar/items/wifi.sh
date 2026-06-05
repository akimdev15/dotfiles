#!/usr/bin/env sh

sketchybar --add item wifi right \
           --set wifi \
               update_freq=30 \
               icon.font="JetBrainsMono Nerd Font:Regular:15.0" \
               icon.padding_left=8 \
               icon.padding_right=4 \
               label.font="SF Pro:Semibold:12.0" \
               label.color=0xffcad3f5 \
               label.padding_right=8 \
               script="$PLUGIN_DIR/wifi.sh" \
           --subscribe wifi wifi_change
