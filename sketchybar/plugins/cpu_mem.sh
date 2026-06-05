#!/usr/bin/env sh

CPU=$(top -l 1 | grep "CPU usage" | awk '{gsub(/%,?/,""); printf "%.0f", $3+$5}')

MEM=$(vm_stat | awk -v ps="$(sysctl -n hw.pagesize)" '
  /^Pages active/               {gsub(/\./, "", $3); active=$3+0}
  /^Pages wired down/           {gsub(/\./, "", $4); wired=$4+0}
  /^Pages occupied by compressor/ {gsub(/\./, "", $5); comp=$5+0}
  END {printf "%.1f", (active + wired + comp) * ps / 1073741824}
')

sketchybar --set "$NAME" label="${CPU}%  ${MEM}G"
