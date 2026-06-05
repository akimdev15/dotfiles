#!/usr/bin/env sh

sketchybar --add item cpu_mem right \
           --set cpu_mem \
               update_freq=5 \
               icon="󰻠" \
               icon.font="JetBrainsMono Nerd Font:Regular:14.0" \
               icon.color=0xffc6a0f6 \
               icon.padding_left=8 \
               icon.padding_right=4 \
               label.font="SF Pro:Semibold:12.0" \
               label.color=0xffcad3f5 \
               label.padding_right=8 \
               script="$PLUGIN_DIR/cpu_mem.sh" \
               click_script="open -a 'Activity Monitor'"
