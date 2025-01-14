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
localedef -i en_US -c -f UTF-8 en_US.UTF-8
echo "C.UTF-8 UTF-8" > /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/default/locale
if [[ "$kiwi_profiles" == *"l10n"* ]]; then
	echo "Update locales..."
	echo "it_IT.UTF-8 UTF-8" >> /etc/locale.gen
	localedef -i it_IT -c -f UTF-8 it_IT.UTF-8
fi
echo "Generate locales..."
locale-gen
locale -a

#======================================
# Base system
#--------------------------------------
## Configure additional sources
source /etc/os-release
cat << EOF > /etc/apt/sources.list
# See https://wiki.debian.org/SourcesList for more information
deb https://deb.debian.org/debian $VERSION_CODENAME main non-free-firmware contrib non-free
#deb-src https://deb.debian.org/debian $VERSION_CODENAME main non-free-firmware contrib non-free

deb https://deb.debian.org/debian $VERSION_CODENAME-updates main non-free-firmware contrib non-free
#deb-src https://deb.debian.org/debian $VERSION_CODENAME-updates main non-free-firmware contrib non-free

deb https://security.debian.org/debian-security/ $VERSION_CODENAME-security main non-free-firmware contrib non-free
#deb-src https://security.debian.org/debian-security/ $VERSION_CODENAME-security main non-free-firmware contrib non-free

# Backports allow you to install newer versions of software made available for this release
deb https://deb.debian.org/debian $VERSION_CODENAME-backports main non-free-firmware contrib non-free
#deb-src https://deb.debian.org/debian $VERSION_CODENAME-backports main non-free-firmware contrib non-free
EOF
## Update package database
apt update
## No interaction during install
export APT_LISTCHANGES_FRONTED=none DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true
## Setup base system
tasksel install standard
