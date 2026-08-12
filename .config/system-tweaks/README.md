# Arch Linux System Tweaks

This folder contains backups of system-level configurations (files that normally live in `/etc/`) that I use to optimize my Arch Linux setup. Keeping them here allows me to track them with my dotfiles repository so I can easily reference them when setting up a new system (like CachyOS) in the future.

## 1. Memory Management (zRAM)
I prefer using **zRAM** instead of a traditional swap file on my SSD. This creates a highly efficient, compressed swap space directly in RAM, which improves responsiveness and reduces wear on the SSD.

*   **Config file:** `zram-generator.conf` (Normally goes in `/etc/systemd/zram-generator.conf`)
*   **Behavior:** It's configured to use up to half of the total system RAM, capped at a maximum of 8 GB, using the fast `zstd` compression algorithm.

## 2. Swappiness Tuning
To make the most of the fast zRAM, I tune the kernel's swappiness.
*   **Config file:** `99-zram-swappiness.conf` (Normally goes in `/etc/sysctl.d/`)
*   **Behavior:** By increasing `vm.swappiness` to 70, the kernel is encouraged to move data into the ultra-fast zRAM earlier, keeping active applications snappier under heavy load.

## 3. Kernel Boot Parameters
My kernel parameters are optimized for a clean, silent boot and peak performance.
*   **Reference file:** `kernel-parameters.txt` (These are typically added to `/boot/loader/entries/` or `/etc/default/grub` depending on the bootloader).

**Key Performance Flags:**
*   `zswap.enabled=0`: Disables zswap to prevent "double-compression" latency since zRAM is already handling it.
*   `nowatchdog`: Disables the NMI hardware watchdog timer to reduce background CPU polling, slightly improving battery life and performance.
*   `quiet loglevel=3 udev.log_level=3 vt.global_cursor_default=0 splash`: Ensures a silent, flicker-free boot experience without unnecessary text logs.

*(Note: The actual `PARTUUID` in the kernel parameters file has been generalized for privacy.)*
