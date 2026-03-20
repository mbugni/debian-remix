#!/usr/bin/bash
# -------------------------------------------------------------------------
# Post-installation cleanup for Debian
# Run inside the target system (chroot)
# -------------------------------------------------------------------------

# Disable live-specific services
/usr/bin/systemctl disable livesys-boot-setup.service || true
rm -f /etc/systemd/system/livesys-boot-setup.service

# Purge installer-only packages
# Use DEBIAN_FRONTEND=noninteractive to ensure no prompts block Calamares
export DEBIAN_FRONTEND=noninteractive
/usr/bin/apt-get autopurge --assume-yes --quiet "calamares*" dracut-live dracut-squash

# Remove live-specific data
rm -rf /usr/local/share/livesys
