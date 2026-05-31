#!/bin/bash

LOCK_FILE="/tmp/volume_osd.lock"
exec 200>$LOCK_FILE
flock -n 200 || exit 1

VOLUME_INFO=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
VOLUME=$(echo "$VOLUME_INFO" | awk '{print int($2 * 100 + 0.5)}')
MUTE=$(echo "$VOLUME_INFO" | grep -o "\[MUTED\]")

total=10
filled=$(( VOLUME * total / 100 ))
[ $filled -gt $total ] && filled=$total
empty=$(( total - filled ))

if [ -n "$MUTE" ]; then
    msg="MUTE"
else
    bar=""
    for ((i=0; i<empty; i++)); do bar+="░\n"; done
    for ((i=0; i<filled; i++)); do bar+="█\n"; done
    msg="${bar}${VOLUME}%"
fi

notify-send -a "OSD" -h string:x-canonical-private-synchronous:volume " " "$(echo -e "$msg")" -t 1000

sleep 0.05
