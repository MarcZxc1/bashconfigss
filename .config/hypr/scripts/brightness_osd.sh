#!/bin/bash

# Lock file
LOCK_FILE="/tmp/brightness_osd.lock"
exec 201>$LOCK_FILE
flock -n 201 || exit 1

# Get info
BRIGHTNESS=$(brightnessctl g)
MAX_BRIGHTNESS=$(brightnessctl m)
PERCENT=$(( BRIGHTNESS * 100 / MAX_BRIGHTNESS ))

[ $PERCENT -gt 100 ] && PERCENT=100

# SVG generation logic
H=$(( 300 * PERCENT / 100 ))
Y=$(( 300 - H ))
FILE="/tmp/osd_bright_${PERCENT}.svg"

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

notify-send -a "OSD" -h string:x-canonical-private-synchronous:brightness -i $FILE " " "${PERCENT}%" -t 1000

sleep 0.05
