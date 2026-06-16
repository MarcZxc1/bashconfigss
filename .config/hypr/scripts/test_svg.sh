#!/bin/bash
PERCENT=$1
H=$(( 300 * PERCENT / 100 ))
Y=$(( 300 - H ))

FILE="/home/marc/.config/hypr/osd_${PERCENT}.svg"

cat <<SVG > $FILE
<svg width="100" height="300" viewBox="0 0 100 300" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <clipPath id="fillClip">
      <rect x="0" y="$Y" width="100" height="$H" />
    </clipPath>
  </defs>
  <!-- Background/Empty state (Dimmed purple) -->
  <polygon points="70,0 10,180 55,180 25,300 90,130 45,130" fill="#3d2d4d" />
  <!-- Filled state (Bright purple) -->
  <polygon points="70,0 10,180 55,180 25,300 90,130 45,130" fill="#c084fc" clip-path="url(#fillClip)" />
</svg>
SVG

notify-send -a "OSD" -h string:x-canonical-private-synchronous:osdtest -i $FILE " " "${PERCENT}%" -t 1000
