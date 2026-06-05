#!/usr/bin/env sh

sketchybar --add item media right \
           --set media \
               update_freq=5 \
               drawing=off \
               icon.font="JetBrainsMono Nerd Font:Regular:14.0" \
               icon.padding_left=8 \
               icon.padding_right=4 \
               label.font="SF Pro:Semibold:12.0" \
               label.color=0xffcad3f5 \
               label.padding_right=8 \
               script="$PLUGIN_DIR/media.sh" \
               click_script="$PLUGIN_DIR/media_click.sh" \
           --subscribe media system_woke
