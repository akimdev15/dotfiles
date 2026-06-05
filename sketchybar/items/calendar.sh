#!/usr/bin/env sh

sketchybar --add item     calendar right                    \
           --set calendar update_freq=30                    \
                          icon.drawing=off                  \
                          label.color=0xff181926            \
                          label.font="SF Pro:Semibold:12.0" \
                          label.padding_left=8              \
                          label.padding_right=8             \
                          background.color=0xffb8c0e0       \
                          background.height=26              \
                          background.corner_radius=11       \
                          script="$PLUGIN_DIR/calendar.sh"  \
           --subscribe calendar system_woke
