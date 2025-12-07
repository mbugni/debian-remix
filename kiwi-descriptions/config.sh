#!/usr/bin/bash

set -euxo pipefail

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: $kiwi_iname-$kiwi_iversion"
echo "Profiles: [$kiwi_profiles]"

#======================================
# Setup machine specific configuration
#--------------------------------------
## Setup hostname	
echo "${kiwi_iname,,}" > /etc/hostname
## Clear machine-id on pre generated images
truncate -s 0 /etc/machine-id

#======================================
# Setup default services
#--------------------------------------
## Enable NetworkManager
systemctl enable NetworkManager.service
## Enable systemd-timesyncd
systemctl enable systemd-timesyncd

#======================================
# Setup live system
#--------------------------------------
echo 'Delete the root user password'
passwd -d root
echo 'Lock the root user account'
passwd -l root
echo 'Enable livesys session'
systemctl enable livesys-setup.service
if [[ "$kiwi_profiles" == *"LiveSystemGraphical"* ]]; then
	# Setup graphical system
	systemctl set-default graphical.target
	# Set up default boot theme
	/usr/sbin/plymouth-set-default-theme bgrt
	# Enable remix session settings
	systemctl --global enable remix-session.service
	# Set up Flatpak
	echo "Setting up Flathub repo..."
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
else
	# Fallback to console system
	systemctl set-default multi-user.target
	# Set up default boot theme
	/usr/sbin/plymouth-set-default-theme details
fi

#======================================
# Setup localization
#--------------------------------------
echo "LANG=en_US.UTF-8" > /etc/default/locale
if [[ "$kiwi_profiles" == *"l10n"* ]]; then
	system_locale="${kiwi_language}.UTF-8"
	echo "Set up locale ${system_locale}"
	# Setup system-wide locale
	echo "LANG=${system_locale}" > /etc/default/locale
	# Setup keyboard layout
	sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="'${kiwi_keytable}'"/' /etc/default/keyboard
fi

#======================================
# Additional settings and tweaks
#--------------------------------------
## Enable machine system settings
systemctl enable machine-setup
## Replace default prompt system wide
sed -i -e "s/PS1='.*'/\. \/etc\/profile\.d\/color-prompt\.sh/" /etc/bash.bashrc
## Update system with latest software
apt --assume-yes update && apt --assume-yes --fix-broken install && apt --assume-yes upgrade

#======================================
# System clean
#--------------------------------------
## Purge old kernels (if any)
## See https://ostechnix.com/remove-old-unused-linux-kernels/
last_kernel=$(dpkg --list | awk '{ print $2 }' | grep -E 'linux-image-.+-.+' | \
	sort --version-sort | tail --lines=1)
echo "Purge old kernels and keep $last_kernel"
dpkg --list | awk '{ print $2 }' | grep -E 'linux-image-.+-.+' | \
	{ grep --invert-match $last_kernel || true; } | xargs apt --assume-yes purge
## Do not need a Mail Transfer Agent (MTA)
apt --assume-yes autopurge exim4-base
## Clean software management cache
apt clean

exit 0
