#!/usr/bin/env bash

sketchybar --add event aerospace_workspace_change

for sid in 1 2 3 4 5 6 7 8 9; do
    sketchybar --add item "space.$sid" left \
        --subscribe "space.$sid" aerospace_workspace_change front_app_switched \
        --set "space.$sid" \
            icon="$sid" \
            icon.font="SF Pro:Bold:13.0" \
            icon.color=0xffcad3f5 \
            icon.highlight_color=0xff8aadf4 \
            icon.padding_left=10 \
            icon.padding_right=4 \
            label.font="sketchybar-app-font:Regular:14.0" \
            label.color=0xffcad3f5 \
            label.padding_left=2 \
            label.padding_right=10 \
            background.color=0x44ffffff \
            background.corner_radius=6 \
            background.height=24 \
            background.drawing=off \
            click_script="aerospace workspace $sid" \
            script="$CONFIG_DIR/plugins/aerospacer.sh $sid"
done
