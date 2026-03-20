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
systemctl enable livesys-boot-setup.service
plymouth_theme="details"
if [[ "$kiwi_profiles" == *"LiveSystemGraphical"* ]]; then
	# Setup graphical system
	systemctl set-default graphical.target
	# Setup graphical boot theme
	plymouth_theme="bgrt"
	# Enable user session setup
	systemctl --global enable remix-session-setup.service
	# Set up Flatpak
	echo "Setting up Flathub repo..."
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
else
	# Fallback to console system
	systemctl set-default multi-user.target
fi
# Setup default boot theme
/usr/sbin/plymouth-set-default-theme "${plymouth_theme}"

#======================================
# Additional settings and tweaks
#--------------------------------------
## Enable system wide settings
systemctl enable remix-system-setup.service
## Update system with latest software
export APT_LISTCHANGES_FRONTEND=none DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
apt --assume-yes --fix-broken install && apt --assume-yes upgrade

#======================================
# System clean
#--------------------------------------
## Purge old kernels (if any)
## See https://ostechnix.com/remove-old-unused-linux-kernels/
last_kernel=$(dpkg --list | awk '{ print $2 }' | grep -E 'linux-image-.+-.+' | \
	sort --version-sort | tail --lines=1)
echo "Purge old kernels and keep $last_kernel"
dpkg --list | awk '{ print $2 }' | grep -E 'linux-image-.+-.+' | \
	{ grep --invert-match $last_kernel || true; } | xargs apt-get --assume-yes purge
## Clean software management cache
apt-get clean

exit 0
