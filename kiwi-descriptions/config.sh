#!/bin/bash

set -euxo pipefail

#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]-[$kiwi_iversion]..."
echo "Profiles: [$kiwi_profiles]"

#======================================
# Clear machine specific configuration
#--------------------------------------
## Force generic hostname	
echo "localhost" > /etc/hostname
## Clear machine-id on pre generated images
truncate -s 0 /etc/machine-id

#======================================
# Configure grub correctly
#--------------------------------------
## Works around issues with grub-bls
## See: https://github.com/OSInside/kiwi/issues/2198
# echo "GRUB_DEFAULT=saved" >> /etc/default/grub
## Disable submenus to match Fedora
# echo "GRUB_DISABLE_SUBMENU=true" >> /etc/default/grub
## Disable recovery entries to match Fedora
# echo "GRUB_DISABLE_RECOVERY=true" >> /etc/default/grub

#======================================
# Setup default services
#--------------------------------------
## Enable NetworkManager
systemctl enable NetworkManager.service
## Enable chrony
systemctl enable chrony.service

#======================================
# Setup default target
#--------------------------------------
if [[ "$kiwi_profiles" == *"Desktop"* ]]; then
	systemctl set-default graphical.target
else
	systemctl set-default multi-user.target
fi

#======================================
# Remix root user
#--------------------------------------
## Delete and lock the root user password
passwd -d root
passwd -l root

#======================================
# Remix graphical
#--------------------------------------
if [[ "$kiwi_profiles" == *"LiveSystemGraphical"* ]]; then
	echo "Set up desktop ${kiwi_displayname}"
	# Set up default boot theme
	/usr/sbin/plymouth-set-default-theme spinner
	# Enable livesys services
	systemctl enable livesys.service
	# Set up Flatpak
	echo "Setting up Flathub repo..."
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

#======================================
# Remix localization
#--------------------------------------
if [[ "$kiwi_profiles" == *"Localization"* ]]; then
	livesys_locale="${kiwi_language}.UTF-8"
	livesys_language="${kiwi_language}"
	livesys_keymap="${kiwi_keytable}"
	echo "Set up language ${livesys_locale}"
	# Replace default locale settings
	sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="'${livesys_keymap}'"/' /etc/default/keyboard
	sed -i "s/^LANG=.*/LANG=${livesys_locale}/" /etc/xdg/plasma-localerc
	sed -i "s/^LANGUAGE=.*/LANGUAGE="${livesys_language}"/" /etc/xdg/plasma-localerc
	sed -i "s/^defaultLanguage=.*/defaultLanguage=${livesys_language}/" /etc/skel/.config/KDE/Sonnet.conf
fi

#======================================
# Remix	fixes and tweaks
#--------------------------------------
## Replace default prompt system wide
sed -i -e "s/PS1='.*'/\. \/etc\/profile\.d\/color-prompt\.sh/" /etc/bash.bashrc
## Remove preferred browser icon in KDE taskmanager
if [ -f /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml ]; then
    sed -i -e 's/\,preferred:\/\/browser//' \
    /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml
fi
apt-get clean

exit 0
