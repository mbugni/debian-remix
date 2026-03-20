#!/usr/bin/bash

set -euxo pipefail

#======================================
# Greeting...
#--------------------------------------
echo "Bootstrap image: $kiwi_iname-$kiwi_iversion"
echo "Profiles: [$kiwi_profiles]"

#======================================
# Generate locales
#--------------------------------------
echo "C.UTF-8 UTF-8" > /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
system_locale="${kiwi_language}.UTF-8"
if [[ "$kiwi_profiles" == *"l10n"* ]]; then
    # Additional system-wide locale
	echo "${system_locale} UTF-8" >> /etc/locale.gen
    # Setup keyboard layout
	sed -i 's/^XKBLAYOUT=.*/XKBLAYOUT="'${kiwi_keytable}'"/' /etc/default/keyboard
	sed -i 's/^XKBMODEL=.*/XKBMODEL="pc105"/' /etc/default/keyboard
fi
echo "LANG=${system_locale}" > /etc/default/locale
echo "--- Generate locales ---"
locale-gen
locale -a

#======================================
# Base system
#--------------------------------------
## Configure additional sources
source /etc/os-release
cat << EOF > /etc/apt/sources.list
# See https://wiki.debian.org/SourcesList for more information
deb https://deb.debian.org/debian $VERSION_CODENAME main contrib non-free non-free-firmware
#deb-src https://deb.debian.org/debian $VERSION_CODENAME main contrib non-free non-free-firmware

deb https://deb.debian.org/debian $VERSION_CODENAME-updates main contrib non-free non-free-firmware
#deb-src https://deb.debian.org/debian $VERSION_CODENAME-updates main contrib non-free non-free-firmware

deb https://security.debian.org/debian-security/ $VERSION_CODENAME-security main contrib non-free non-free-firmware
#deb-src https://security.debian.org/debian-security/ $VERSION_CODENAME-security main contrib non-free non-free-firmware
EOF
## No interaction during install
export APT_LISTCHANGES_FRONTEND=none DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
echo "--- Update package database ---"
apt-get update --assume-yes
## Workaroud to address missing keymap for localectl systemd-firstboot. See:
##		https://groups.google.com/g/kiwi-images/c/5zHockGLFy8
apt-get --assume-yes install --no-install-recommends console-data
ln -s /usr/share/keymaps/i386/qwerty/it.kmap.gz /usr/share/keymaps/i386/qwerty/it.map.gz
