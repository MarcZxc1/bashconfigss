#!/usr/bin/env python3
import subprocess
import time
import signal
import os

# Configuration
TRIGGER_Y_SHOW = 5
TRIGGER_Y_HOVER = 45
HIDE_TIMEOUT = 3.0  # seconds
POLL_INTERVAL = 0.1 # seconds

PID_FILE = "/tmp/waybar_autohide.pid"
with open(PID_FILE, "w") as f:
    f.write(str(os.getpid()))

def is_bar_running():
    try:
        subprocess.check_output(["pgrep", "-x", "waybar"])
        return True
    except subprocess.CalledProcessError:
        return False

def show_bar():
    if not is_bar_running():
        subprocess.Popen(["waybar"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def hide_bar():
    if is_bar_running():
        subprocess.run(["killall", "-9", "waybar"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def toggle_bar(signum, frame):
    if is_bar_running():
        hide_bar()
    else:
        show_bar()

def get_cursor_y():
    try:
        output = subprocess.check_output(["hyprctl", "cursorpos"], stderr=subprocess.DEVNULL).decode("utf-8")
        return int(output.split(",")[1].strip())
    except:
        return 1000 

signal.signal(signal.SIGUSR1, toggle_bar)

# Start by killing any existing waybar
subprocess.run(["killall", "-9", "waybar"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

ticks = 0.0
while True:
    try:
        y = get_cursor_y()
        running = is_bar_running()
        
        if not running:
            if y <= TRIGGER_Y_SHOW:
                show_bar()
                ticks = 0.0
        else:
            if y > TRIGGER_Y_HOVER:
                ticks += POLL_INTERVAL
                if ticks >= HIDE_TIMEOUT:
                    hide_bar()
                    ticks = 0.0
            else:
                ticks = 0.0
    except Exception:
        pass
            
    time.sleep(POLL_INTERVAL)
