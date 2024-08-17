#!/usr/bin/bash

set -euxo pipefail

#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Bootstrap image: [$kiwi_iname]-[$kiwi_iversion]..."
echo "Profiles: [$kiwi_profiles]"

#======================================
# Generate locales
#--------------------------------------
localedef -i en_US -c -f UTF-8 en_US.UTF-8
echo "C.UTF-8 UTF-8" > /etc/locale.gen
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "LANG=en_US.UTF-8" > /etc/default/locale
if [[ "$kiwi_profiles" == *"Localization"* ]]; then
    livesys_locale="${kiwi_language}.UTF-8"
    livesys_language="${kiwi_language}"
    echo "Set up language ${livesys_locale}"
	localedef -i ${livesys_language} -c -f UTF-8 ${livesys_locale}
    echo "${livesys_locale} UTF-8" >> /etc/locale.gen
    # Setup system-wide locale
	echo "LANG=${livesys_locale}" > /etc/default/locale
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
# See https://wiki.debian.org/SourcesList for more information.
deb http://deb.debian.org/debian $VERSION_CODENAME main non-free-firmware contrib non-free
#deb-src http://deb.debian.org/debian $VERSION_CODENAME main non-free-firmware contrib non-free

deb http://deb.debian.org/debian $VERSION_CODENAME-updates main non-free-firmware contrib non-free
#deb-src http://deb.debian.org/debian $VERSION_CODENAME-updates main non-free-firmware contrib non-free

deb http://security.debian.org/debian-security/ $VERSION_CODENAME-security main non-free-firmware contrib non-free
#deb-src http://security.debian.org/debian-security/ $VERSION_CODENAME-security main non-free-firmware contrib non-free

# Backports allow you to install newer versions of software made available for this release
deb http://deb.debian.org/debian $VERSION_CODENAME-backports main non-free-firmware contrib non-free
#deb-src http://deb.debian.org/debian $VERSION_CODENAME-backports main non-free-firmware contrib non-free
EOF
## No interaction during install
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTED=none
## Setup base system
tasksel install standard
