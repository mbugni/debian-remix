#!/usr/bin/bash

set -euxo pipefail

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: $kiwi_iname-$kiwi_iversion"
echo "Profiles: [$kiwi_profiles]"

#======================================
# Clear machine specific configuration
#--------------------------------------
## Force generic hostname	
echo "localhost" > /etc/hostname
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
# Setup default target
#--------------------------------------
if [[ "$kiwi_profiles" == *"Desktop"* ]]; then
	systemctl set-default graphical.target
else
	systemctl set-default multi-user.target
fi

#======================================
# Remix livesystem
#--------------------------------------
if [[ "$kiwi_profiles" == *"LiveSystem"* ]]; then
	echo "Delete the root user password"
	passwd -d root
	if [[ "$kiwi_profiles" == *"LiveSystemConsole"* ]]; then
		echo "Delete the liveuser password"
		passwd -d liveuser
		# Set up default boot theme
		/usr/sbin/plymouth-set-default-theme details
	fi
fi

#======================================
# Remix graphical
#--------------------------------------
if [[ "$kiwi_profiles" == *"LiveSystemGraphical"* ]]; then
	echo "Lock the root user account"
	passwd -l root
	# Set up default boot theme
	/usr/sbin/plymouth-set-default-theme spinner
	# Enable livesys session service
	systemctl enable livesys-setup.service
	# Enable remix session settings
	systemctl --global enable remix-session.service
	# Set up Flatpak
	echo "Setting up Flathub repo..."
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

#======================================
# Remix localization
#--------------------------------------
echo "LANG=en_US.UTF-8" > /etc/default/locale
if [[ "$kiwi_profiles" == *"l10n"* ]]; then
	livesys_locale="${kiwi_language}.UTF-8"
	echo "Set up locale ${livesys_locale}"
	# Setup system-wide locale
	echo "LANG=${livesys_locale}" > /etc/default/locale
	# Replace default locale settings
	sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="'${kiwi_keytable}'"/' /etc/default/keyboard
	sed -i "s/^LANG=.*/LANG=${livesys_locale}/" /etc/xdg/plasma-localerc
	sed -i "s/^LANGUAGE=.*/LANGUAGE="${kiwi_language}"/" /etc/xdg/plasma-localerc
	sed -i "s/^defaultLanguage=.*/defaultLanguage=${kiwi_language}/" /etc/skel/.config/KDE/Sonnet.conf
fi

#======================================
# Remix	settings and tweaks
#--------------------------------------
## Enable machine system settings
systemctl enable machine-setup
## Replace default prompt system wide
sed -i -e "s/PS1='.*'/\. \/etc\/profile\.d\/color-prompt\.sh/" /etc/bash.bashrc
## Remove preferred browser icon in KDE taskmanager
if [ -f /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml ]; then
    sed -i -e 's/\,preferred:\/\/browser//' \
    /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml
fi
## Update system with latest software
apt --assume-yes upgrade
## Install systemd-resolved here because it breaks previous scripts cause DNS resolution
apt --assume-yes install systemd-resolved libnss-resolve libnss-myhostname

#======================================
# Remix	system clean
#--------------------------------------
## Purge old kernels (if any)
## See https://ostechnix.com/remove-old-unused-linux-kernels/
last_kernel=$(dpkg --list | awk '{ print $2 }' | grep -E 'linux-image-.+-.+-.+' | \
	sort --version-sort | tail --lines=1)
echo "Purge old kernels and keep $last_kernel"
dpkg --list | awk '{ print $2 }' | grep -E 'linux-image-.+-.+-.+' | \
	{ grep --invert-match $last_kernel || true; } | xargs apt --assume-yes purge
## Clean software management cache
apt clean

exit 0
