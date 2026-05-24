#!/bin/bash

# Lock file to prevent multiple instances and rate limit
LOCK_FILE="/tmp/brightness_osd.lock"
exec 201>$LOCK_FILE
flock -n 201 || exit 1

# Get current brightness
BRIGHTNESS=$(brightnessctl g)
MAX_BRIGHTNESS=$(brightnessctl m)

# Calculate percentage
PERCENT=$(( BRIGHTNESS * 100 / MAX_BRIGHTNESS ))

# Generate smooth vertical string bar
lines=15
total_steps=$(( lines * 8 ))
active_steps=$(( PERCENT * total_steps / 100 ))
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

# Use synchronous hint to force mako/dunst to replace the existing notification
notify-send -a "OSD" -h string:x-canonical-private-synchronous:brightness "$bar" -t 1000

# Hold the lock for a tiny bit longer to throttle the next execution
sleep 0.05
