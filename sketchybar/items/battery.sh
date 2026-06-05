#!/usr/bin/env sh

sketchybar --add item battery right \
           --set battery \
               update_freq=60 \
               icon.font="JetBrainsMono Nerd Font:Regular:16.0" \
               icon.padding_left=8 \
               icon.padding_right=4 \
               label.font="SF Pro:Semibold:12.0" \
               label.color=0xffcad3f5 \
               label.padding_right=8 \
               script="$PLUGIN_DIR/battery.sh" \
           --subscribe battery power_source_change
