#!/usr/bin/env sh

sketchybar --set clock_date label="$(date '+%a  %b %-d')" \
           --set clock_time label="$(date '+%-I:%M %p')"
