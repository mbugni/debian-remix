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
echo "127.0.0.1 ${kiwi_iname,,}" >> /etc/hosts
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
	# Enable TDM login manager
	systemctl enable tdm.service
else
	# Fallback to console system
	systemctl set-default multi-user.target
fi
# Setup default boot theme
/usr/sbin/plymouth-set-default-theme "${plymouth_theme}"

#======================================
# Setup localization
#--------------------------------------
if [[ "$kiwi_profiles" == *"l10n"* ]]; then
	echo "Setup TDE keyboard layout ${kiwi_keytable}"
	sed -i 's/^LayoutList=.*/LayoutList='${kiwi_keytable}'/' /etc/trinity/kxkbrc
fi

#======================================
# Additional settings and tweaks
#--------------------------------------
## Enable system wide settings
systemctl enable remix-system-setup.service
## Update system with latest software
apt --assume-yes update && apt --assume-yes --fix-broken install && apt --assume-yes upgrade
## Hide legacy xterm icons
mkdir /usr/local/share/applications
for legacy_entry in xterm uxterm
do
    cp /usr/share/applications/debian-${legacy_entry}.desktop /usr/local/share/applications
	echo "NoDisplay=true" >> /usr/local/share/applications/debian-${legacy_entry}.desktop
done

#======================================
# System clean
#--------------------------------------
## Purge old kernels (if any)
## See https://ostechnix.com/remove-old-unused-linux-kernels/
last_kernel=$(dpkg --list | awk '{ print $2 }' | grep -E 'linux-image-.+-.+-.+' | \
	sort --version-sort | tail --lines=1)
echo "Purge old kernels and keep $last_kernel"
dpkg --list | awk '{ print $2 }' | grep -E 'linux-image-.+-.+-.+' | \
	{ grep --invert-match $last_kernel || true; } | xargs apt --assume-yes purge
## Do not need a Mail Transfer Agent (MTA)
apt --assume-yes autopurge exim4-base
## Clean software management cache
apt clean

exit 0
