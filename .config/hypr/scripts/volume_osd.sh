#!/bin/bash

# Lock file to prevent multiple instances and rate limit
LOCK_FILE="/tmp/volume_osd.lock"
exec 200>$LOCK_FILE
flock -n 200 || exit 1

# Get current volume and mute status
VOLUME_INFO=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
VOLUME=$(echo "$VOLUME_INFO" | awk '{print int($2 * 100 + 0.5)}')
MUTE=$(echo "$VOLUME_INFO" | grep -o "\[MUTED\]")

# Generate smooth vertical string bar
lines=15
total_steps=$(( lines * 8 ))
active_steps=$(( VOLUME * total_steps / 100 ))
[ $active_steps -gt $total_steps ] && active_steps=$total_steps

full=$(( active_steps / 8 ))
frac=$(( active_steps % 8 ))

chars=(" " " " "▂" "▃" "▄" "▅" "▆" "▇")
bar=""

# Empty blocks
empty=$(( lines - full - (frac > 0 ? 1 : 0) ))
for ((i=0; i<empty; i++)); do bar+=" "$'\n'; done

# Fractional block
if [ $frac -gt 0 ]; then
    bar+="${chars[$frac]}"$'\n'
fi

# Full blocks
for ((i=0; i<full; i++)); do bar+="█"$'\n'; done
bar=${bar%?}

if [ -n "$MUTE" ]; then
    notify-send -a "OSD" -h string:x-canonical-private-synchronous:volume "$bar" -t 1000
else
    notify-send -a "OSD" -h string:x-canonical-private-synchronous:volume "$bar" -t 1000
fi

# Hold the lock for a tiny bit longer to throttle the next execution
sleep 0.05
