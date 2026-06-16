#!/bin/bash
echo "Script starting"
echo $$ > /tmp/waybar_autohide.pid
echo "PID written: $(cat /tmp/waybar_autohide.pid)"
while true; do
    echo "Looping..."
    sleep 1
done
