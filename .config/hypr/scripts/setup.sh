#!/bin/bash

# Windows-like Hyprland Setup Script for Arch Linux
# Version: Hyprland v0.55.2

echo "Starting Windows-like Hyprland Setup..."

# 1. Install Required Packages
echo "Installing official packages..."
sudo pacman -S --needed waybar hyprpaper rofi-wayland dunst xdg-desktop-portal-hyprland \
pipewire pipewire-pulse wireplumber pavucontrol playerctl \
nm-connection-editor network-manager-applet blueman udiskie \
thunar thunar-volman gvfs ttf-noto-fonts-cjk papirus-icon-theme nwg-look alacritty

# 2. Install AUR Packages (using yay)
if command -v yay >/dev/null 2>&1; then
    echo "Installing AUR packages..."
    yay -S --needed hyprswitch hyprpicker-git hyprshot ttf-segoe-ui-variable
else
    echo "Warning: 'yay' not found. Please install AUR packages (hyprswitch, hyprpicker-git, hyprshot, ttf-segoe-ui-variable) manually."
fi

# 3. Create necessary directories
mkdir -p ~/.config/waybar ~/.config/hypr/scripts

echo "Setup script finished. Config files are already in place."
