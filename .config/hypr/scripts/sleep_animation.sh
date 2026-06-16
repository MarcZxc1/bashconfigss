#!/bin/bash
FILE="/tmp/sleep_crack.svg"

# SMPTE Color bar colors
COLORS=("#C0C0C0" "#C0C000" "#00C0C0" "#00C000" "#C000C0" "#C00000" "#0000C0")

# 1. Start the SVG file and add the TV test pattern background
cat <<EOF > $FILE
<svg width="1920" height="1080" viewBox="0 0 1920 1080" xmlns="http://www.w3.org/2000/svg">
  <!-- TV Test Pattern (Color Bars) -->
  <g opacity="0.85">
    <rect x="0" y="0" width="274" height="1080" fill="${COLORS[0]}" />
    <rect x="274" y="0" width="274" height="1080" fill="${COLORS[1]}" />
    <rect x="548" y="0" width="274" height="1080" fill="${COLORS[2]}" />
    <rect x="822" y="0" width="274" height="1080" fill="${COLORS[3]}" />
    <rect x="1096" y="0" width="274" height="1080" fill="${COLORS[4]}" />
    <rect x="1370" y="0" width="274" height="1080" fill="${COLORS[5]}" />
    <rect x="1644" y="0" width="276" height="1080" fill="${COLORS[6]}" />
  </g>

  <!-- WARNING Text -->
  <rect x="560" y="440" width="800" height="200" fill="black" opacity="0.8" />
  <text x="960" y="565" font-family="monospace" font-size="120" font-weight="bold" fill="#ffffff" text-anchor="middle">WARNING</text>
  
  <!-- Cracks Group -->
  <g>
EOF

# Awk script for realistic procedural shattering (simplified for performance)
awk -v seed=$RANDOM '
BEGIN {
    srand(seed)
    # Impact point (slightly off-center for realism)
    cx = 960 + (rand() * 400 - 200)
    cy = 540 + (rand() * 200 - 100)
    pi = 3.1415926535
    
    # --- 1. Main Radial Fault Lines (Jagged & Branching) ---
    num_radials = 15 + int(rand() * 10)
    for (i = 0; i < num_radials; i++) {
        base_angle = (i / num_radials) * 2 * pi + (rand() * 0.2 - 0.1)
        dist = 2000 # Long cracks to reach edges
        
        curr_x = cx
        curr_y = cy
        angle = base_angle
        
        path = sprintf("    <path d=\"M%f,%f", curr_x, curr_y)
        
        r = 0
        while (r < dist) {
            step = 50 + rand() * 100 + (r * 0.1)
            r += step
            
            # Sharp directional changes (kinks)
            if (rand() > 0.5) {
                angle += (rand() * 0.6 - 0.3)
            }
            
            next_x = cx + r * cos(angle)
            next_y = cy + r * sin(angle)
            
            path = path sprintf(" L%f,%f", next_x, next_y)
            
            # Store points for concentric web
            if (r > 60) {
                ring_points[int(r/150) * 100 + i] = sprintf("%f,%f", next_x, next_y)
            }
            
            # Generate glass splinters along the crack
            if (rand() > 0.6) {
                splinter_a = angle + (rand() > 0.5 ? 1 : -1) * (0.3 + rand()*0.5)
                splinter_l = 20 + rand() * 80
                sx = next_x + splinter_l * cos(splinter_a)
                sy = next_y + splinter_l * sin(splinter_a)
                
                sw = 1 + rand() * 2
                printf "    <path d=\"M%f,%f L%f,%f\" stroke=\"#000000\" stroke-width=\"%f\" fill=\"none\" opacity=\"0.9\" />\n", next_x, next_y, sx, sy, sw+2
                printf "    <path d=\"M%f,%f L%f,%f\" stroke=\"#ffffff\" stroke-width=\"%f\" fill=\"none\" opacity=\"0.9\" />\n", next_x, next_y, sx, sy, sw
            }
        }
        
        w = 2 + rand() * 4
        op = 0.8 + rand() * 0.2
        
        # Depth shadow
        printf "%s\" stroke=\"#000000\" stroke-width=\"%f\" stroke-linejoin=\"bevel\" fill=\"none\" opacity=\"0.9\" />\n", path, w+3
        # Highlight
        printf "%s\" stroke=\"#ffffff\" stroke-width=\"%f\" stroke-linejoin=\"bevel\" fill=\"none\" opacity=\"%f\" />\n", path, w, op
    }
    
    # --- 2. Concentric Spiderweb Rings (Fracture Grids) ---
    for (r = 150; r < 1800; r+=150) {
        for (i = 0; i < num_radials; i++) {
            idx1 = r + i
            idx2 = r + ((i + 1) % num_radials)
            
            if (idx1 in ring_points && idx2 in ring_points && rand() > 0.4) {
                split(ring_points[idx1], p1, ",")
                split(ring_points[idx2], p2, ",")
                
                # Creates a jagged connecting line (two segments)
                mid_x = (p1[1] + p2[1]) / 2 + (rand() * 80 - 40)
                mid_y = (p1[2] + p2[2]) / 2 + (rand() * 80 - 40)
                
                w = 1 + rand() * 2
                
                printf "    <path d=\"M%s L%f,%f L%s\" stroke=\"#000000\" stroke-width=\"%f\" stroke-linejoin=\"bevel\" fill=\"none\" opacity=\"0.8\" />\n", ring_points[idx1], mid_x, mid_y, ring_points[idx2], w+2
                printf "    <path d=\"M%s L%f,%f L%s\" stroke=\"#ffffff\" stroke-width=\"%f\" stroke-linejoin=\"bevel\" fill=\"none\" opacity=\"0.9\" />\n", ring_points[idx1], mid_x, mid_y, ring_points[idx2], w
            }
        }
    }
    
    # --- 3. Loose Floating Glass Shards ---
    for (i = 0; i < 30; i++) {
        dist = 50 + rand() * 600
        angle = rand() * 2 * pi
        fx = cx + dist * cos(angle)
        fy = cy + dist * sin(angle)
        
        size = 15 + rand() * 50
        
        pts = ""
        sides = 3 + int(rand() * 4)
        for(j=0; j<sides; j++) {
             a = (j/sides) * 2 * pi + rand()
             sr = size * (0.4 + rand() * 0.6)
             pts = pts sprintf("%f,%f ", fx + sr * cos(a), fy + sr * sin(a))
        }
        
        # Dark shard background
        printf "    <polygon points=\"%s\" fill=\"#000000\" opacity=\"0.8\" />\n", pts
        # Highlight shard
        printf "    <polygon points=\"%s\" fill=\"#ffffff\" opacity=\"%f\" />\n", pts, 0.6 + rand()*0.4
    }
}
' >> $FILE

# 6. Close the SVG
cat <<EOF >> $FILE
  </g>
</svg>
EOF

# Display the fullscreen shatter notification
notify-send -a "Sleep-Anim" -h string:x-canonical-private-synchronous:sleep -i $FILE " " " " -t 1500

# Wait for 1.2 seconds, then suspend
sleep 1.2
systemctl suspend
