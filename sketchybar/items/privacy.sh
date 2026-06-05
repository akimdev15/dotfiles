#!/usr/bin/env sh

sketchybar --add item privacy right \
           --set privacy \
               update_freq=10 \
               drawing=off \
               icon.drawing=off \
               label.font="JetBrainsMono Nerd Font:Regular:15.0" \
               label.color=0xffed8796 \
               label.padding_left=8 \
               label.padding_right=8 \
               script="$PLUGIN_DIR/privacy.sh"
