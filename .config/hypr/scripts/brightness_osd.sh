#!/bin/bash

LOCK_FILE="/tmp/brightness_osd.lock"
exec 201>$LOCK_FILE
flock -n 201 || exit 1

BRIGHTNESS=$(brightnessctl g)
MAX_BRIGHTNESS=$(brightnessctl m)
PERCENT=$(( BRIGHTNESS * 100 / MAX_BRIGHTNESS ))

total=10
filled=$(( PERCENT * total / 100 ))
[ $filled -gt $total ] && filled=$total
empty=$(( total - filled ))

bar=""
for ((i=0; i<empty; i++)); do bar+="░\n"; done
for ((i=0; i<filled; i++)); do bar+="█\n"; done
msg="${bar}${PERCENT}%"

notify-send -a "OSD" -h string:x-canonical-private-synchronous:brightness " " "$(echo -e "$msg")" -t 1000

sleep 0.05
