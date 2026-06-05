#!/usr/bin/env sh

sketchybar --add item pomodoro right \
           --set pomodoro \
               update_freq=60 \
               icon="󰔛" \
               icon.font="JetBrainsMono Nerd Font:Regular:16.0" \
               icon.color=0xff939ab7 \
               icon.padding_left=8 \
               icon.padding_right=4 \
               label.font="SF Pro:Semibold:12.0" \
               label.color=0xffcad3f5 \
               label.padding_right=8 \
               script="$PLUGIN_DIR/pomodoro.sh" \
               click_script="$PLUGIN_DIR/pomodoro_click.sh"
