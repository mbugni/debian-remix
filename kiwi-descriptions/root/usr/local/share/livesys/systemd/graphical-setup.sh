#!/usr/bin/bash
#
# graphical-setup: desktop settings for liveuser

# Set up auto login for live user
if [ -f /etc/trinity/tdm/tdmrc ]; then
    sed -i 's/^AllowNullPasswd=.*/AllowNullPasswd=true/' /etc/trinity/tdm/tdmrc
    sed -i 's/^#AutoLoginEnable=.*/AutoLoginEnable=true/' /etc/trinity/tdm/tdmrc
    sed -i 's/^#AutoLoginUser=.*/AutoLoginUser=liveuser/' /etc/trinity/tdm/tdmrc
else
cat > /etc/trinity/tdm/tdmrc << TDM_EOF
[X-*-Core]
AllowNullPasswd=true
AutoLoginEnable=true
AutoLoginUser=liveuser
TDM_EOF
fi

## Hide original installer actions
desktop-file-edit --set-key=Hidden --set-value=true /usr/share/applications/install-debian.desktop
desktop-file-edit --set-key=Hidden --set-value=true /etc/xdg/autostart/calamares-desktop-icon.desktop
mv /usr/share/applications/calamares.desktop.orig /usr/share/applications/livesys-install.desktop
## Adjust installer launcher
installer_cmd="/opt/trinity/bin/tdesu 'calamares -D6'"
desktop-file-edit --set-key=Exec --set-value="$installer_cmd" /usr/share/applications/livesys-install.desktop

## Setup Calamares settings
rsync -a /usr/local/share/livesys/calamares/config/ /etc/calamares/

# Add installer icon to liveuser desktop
mkdir /home/liveuser/Desktop
cp -a /usr/share/applications/livesys-install.desktop /home/liveuser/Desktop
# Make installer icon executable to disable TDE security warning
chmod +x /home/liveuser/Desktop/livesys-install.desktop

# Default settings for liveuser
mkdir -p /home/liveuser/.trinity/share/config

# Disable desktop media icons
cat > /home/liveuser/.trinity/share/config/kdesktoprc << DESKTOP_EOF
[Media]
enabled=false
DESKTOP_EOF

# Disable new device popup during install
cat > /home/liveuser/.trinity/share/config/mediamanagerrc << MEDIA_EOF
[Global]
AutostartEnabled=false
DeviceMonitorPopupsEnabled=false
NotificationPopupsEnabled=false
MEDIA_EOF
 
if [ -f /etc/default/keyboard ]; then
    source /etc/default/keyboard
    localectl set-x11-keymap $XKBLAYOUT $XKBMODEL
fi
