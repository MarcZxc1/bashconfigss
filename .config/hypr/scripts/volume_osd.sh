#!/bin/bash

# Lock file
LOCK_FILE="/tmp/volume_osd.lock"
exec 200>$LOCK_FILE
flock -n 200 || exit 1

# Get info
VOLUME_INFO=$(wpctl get-volume @DEFAULT_AUDIO_SINK@)
VOLUME=$(echo "$VOLUME_INFO" | awk '{print int($2 * 100 + 0.5)}')
MUTE=$(echo "$VOLUME_INFO" | grep -o "\[MUTED\]")

[ $VOLUME -gt 100 ] && VOLUME=100

# SVG generation logic
H=$(( 300 * VOLUME / 100 ))
Y=$(( 300 - H ))
FILE="/tmp/osd_vol_${VOLUME}.svg"

# Ensure /tmp exists and write the SVG
cat <<SVG > $FILE
<svg width="100" height="300" viewBox="0 0 100 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <clipPath id="fillClip">
      <rect x="0" y="$Y" width="100" height="$H" />
    </clipPath>
    <linearGradient id="boltGrad" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#ffffff" />
      <stop offset="40%" stop-color="#e0f2fe" />
      <stop offset="100%" stop-color="#3b82f6" />
    </linearGradient>
    <filter id="glow">
      <feGaussianBlur stdDeviation="3" result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
  </defs>
  
  <!-- Background/Empty state (Dimmed dark blue outline) -->
  <polygon points="70,0 10,180 55,180 25,300 90,130 45,130" fill="#1a1b26" stroke="#3b82f6" stroke-width="1" />
  
  <!-- Filled state (Blue/White gradient with glow and pulse animation) -->
  <g clip-path="url(#fillClip)">
    <polygon points="70,0 10,180 55,180 25,300 90,130 45,130" fill="url(#boltGrad)" filter="url(#glow)">
      <animate attributeName="opacity" values="0.7;1.0;0.7" dur="0.2s" repeatCount="indefinite" />
    </polygon>
  </g>
</svg>
SVG

if [ -n "$MUTE" ]; then
    # Completely dimmed if muted
    cat <<SVG > $FILE
<svg width="100" height="300" viewBox="0 0 100 300" xmlns="http://www.w3.org/2000/svg">
  <polygon points="70,0 10,180 55,180 25,300 90,130 45,130" fill="#1a1b26" stroke="#565f89" stroke-width="1" />
</svg>
SVG
    notify-send -a "OSD" -h string:x-canonical-private-synchronous:volume -i $FILE " " "MUTE" -t 1000
else
    notify-send -a "OSD" -h string:x-canonical-private-synchronous:volume -i $FILE " " "${VOLUME}%" -t 1000
fi

sleep 0.05
